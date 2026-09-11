#!/usr/bin/env python3
"""Renders every 吨吨吨 brand asset from vector geometry.

The mark is three milk drops - two large, one small nestled in front - drawn
analytically as signed distance fields, so the app icon stays sharp at 48 px
instead of turning to mush the way a downscaled raster does.

Run from anywhere:  python tools/branding/generate_branding.py [--preview]
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]

# --------------------------------------------------------------------------
# Palette, sampled from the original artwork so the redraw stays on brand.
# --------------------------------------------------------------------------
CORAL = (0xEE, 0x75, 0x74)  # brand coral, the icon tile
CORAL_HI = (0xF3, 0x8B, 0x88)  # gradient top
CORAL_LO = (0xE6, 0x69, 0x68)  # gradient bottom
CREAM_HI = (0xFD, 0xF7, 0xE7)  # drop body, lit
CREAM_LO = (0xF4, 0xDF, 0xBE)  # drop body, shaded. Deliberately a mid-cream,
#                                not a near-white: the gloss is pure white, so
#                                it only reads if the body underneath doesn't
#                                already sit at the top of the range.
OUTLINE = (0x97, 0x25, 0x33)  # deep rose keyline
INK = (0x5B, 0x5E, 0x5E)  # eyes and mouth
BLUSH = (0xF9, 0x76, 0x61)  # cheeks
BLUE = (0x5C, 0xB0, 0xD7)  # splash accent
HILL_BACK = (0xD9, 0x5B, 0x5A)  # deeper rear hill
CONFETTI = (0xF7, 0x9E, 0x9A)  # sprinkle dots, lighter than the backdrop

# The splash's top row. Android 12+ shows the system splash as a flat colour
# for the whole cold start and cannot draw a bitmap there, so this exact value
# is also what res/values/colors.xml uses for brand_splash_background. Keep the
# two in step - the seam is only invisible while they match.
#
# It is deliberately the coral icon tile rather than a near-white: on a bright
# screen a near-white hold reads as an unstyled/blank app, whereas coral reads
# as intentional and makes the launcher icon look like it opens into the splash.
SPLASH_TOP = CORAL_HI

# Reference geometry: the drop layout in the 1024 px master at scale 1.0.
REF_BIG_R = 195.0
REF_BIG_APEX = 236.0
REF_SMALL_R = 112.0
REF_SMALL_APEX = 152.0
REF_SPREAD = 214.0
REF_SMALL_DY = 170.0
REF_OUTLINE = 13.0

# Bounding box of the trio, measured from the big drops' centres.
GROUP_HALF_W = REF_SPREAD + REF_BIG_R  # 409
GROUP_TOP = REF_BIG_R + REF_BIG_APEX  # 431 above
GROUP_BOTTOM = REF_SMALL_DY + REF_SMALL_R  # 282 below
GROUP_CENTRE_DY = (GROUP_BOTTOM - GROUP_TOP) / 2.0  # -74.5


def _norm(color):
    """Palette entries are 0-255; the canvas works in linear 0-1."""
    return np.asarray(color, np.float32) / 255.0


def _grid(px):
    """Pixel-centre coordinate grids."""
    return np.meshgrid(
        np.arange(px, dtype=np.float32) + 0.5,
        np.arange(px, dtype=np.float32) + 0.5,
    )


# --------------------------------------------------------------------------
# Signed distance fields: distance in pixels, negative inside.
# --------------------------------------------------------------------------


def sd_circle(X, Y, cx, cy, r):
    return np.hypot(X - cx, Y - cy) - r


def sd_ellipse(X, Y, cx, cy, rx, ry, rot=0.0):
    dx, dy = X - cx, Y - cy
    if rot:
        c, s = math.cos(rot), math.sin(rot)
        dx, dy = c * dx + s * dy, -s * dx + c * dy
    return (np.hypot(dx / rx, dy / ry) - 1.0) * min(rx, ry)


def sd_triangle(X, Y, a, b, c):
    """Inigo Quilez's exact 2D triangle SDF."""
    ax, ay = a
    bx, by = b
    cx, cy = c
    e0x, e0y = bx - ax, by - ay
    e1x, e1y = cx - bx, cy - by
    e2x, e2y = ax - cx, ay - cy
    v0x, v0y = X - ax, Y - ay
    v1x, v1y = X - bx, Y - by
    v2x, v2y = X - cx, Y - cy
    s = np.sign(e0x * e2y - e0y * e2x)

    def edge(vx, vy, ex, ey):
        t = np.clip((vx * ex + vy * ey) / (ex * ex + ey * ey), 0.0, 1.0)
        qx, qy = vx - ex * t, vy - ey * t
        return qx * qx + qy * qy, s * (vx * ey - vy * ex)

    d0, g0 = edge(v0x, v0y, e0x, e0y)
    d1, g1 = edge(v1x, v1y, e1x, e1y)
    d2, g2 = edge(v2x, v2y, e2x, e2y)

    # GLSL's min(vec2, vec2) is component-wise, so in the original the two
    # halves come from different edges: the squared distance is the nearest
    # one, but the orientation term is the smallest of all three. Pairing the
    # sign with the nearest edge instead flips it around every vertex, which
    # makes the SDF claim "inside" over the whole corner wedge.
    dist2 = np.minimum(np.minimum(d0, d1), d2)
    orient = np.minimum(np.minimum(g0, g1), g2)
    return -np.sqrt(dist2) * np.sign(orient)


def sd_teardrop(X, Y, cx, cy, r, apex_len):
    """A circle fused with the cone of tangents drawn up to its apex.

    The tangent points sit at cos(phi) = r / h, so the cone meets the circle
    exactly tangent and the union reads as one smooth drop rather than a ball
    with a spike stuck on top.
    """
    h = r + apex_len
    cos_phi = r / h
    sin_phi = math.sqrt(max(0.0, 1.0 - cos_phi * cos_phi))
    d_cone = sd_triangle(
        X, Y, (cx, cy - h), (cx - r * sin_phi, cy - r * cos_phi),
        (cx + r * sin_phi, cy - r * cos_phi),
    )
    return np.minimum(sd_circle(X, Y, cx, cy, r), d_cone)


# --------------------------------------------------------------------------
# A tiny premultiplied-RGBA painter. Everything composites source-over;
# mode="out" punches holes (round-icon corners, monochrome separation gaps).
# --------------------------------------------------------------------------


class Canvas:
    def __init__(self, w, h, background):
        self.w, self.h = w, h
        self.X, self.Y = _grid(max(w, h))
        self.X, self.Y = self.X[:h, :w], self.Y[:h, :w]
        if background is None:
            self.rgb = np.zeros((h, w, 3), np.float32)
            self.a = np.zeros((h, w), np.float32)
        elif isinstance(background, np.ndarray):
            self.rgb = background.astype(np.float32).copy()
            self.a = np.ones((h, w), np.float32)
        else:
            self.rgb = np.empty((h, w, 3), np.float32)
            self.rgb[:] = _norm(background)
            self.a = np.ones((h, w), np.float32)

    def region(self, bbox):
        x0 = max(0, int(math.floor(bbox[0])))
        y0 = max(0, int(math.floor(bbox[1])))
        x1 = min(self.w, int(math.ceil(bbox[2])) + 1)
        y1 = min(self.h, int(math.ceil(bbox[3])) + 1)
        if x1 <= x0 or y1 <= y0:
            return None
        return (x0, y0, x1, y1), self.X[y0:y1, x0:x1], self.Y[y0:y1, x0:x1]

    def blit(self, region, alpha, color, mode="over"):
        (x0, y0, x1, y1), _, _ = region
        sl = np.s_[y0:y1, x0:x1]
        if mode == "out":
            keep = 1.0 - alpha
            self.rgb[sl] *= keep[..., None]
            self.a[sl] *= keep
            return
        src = _norm(color)
        self.rgb[sl] = self.rgb[sl] * (1.0 - alpha[..., None]) + src * alpha[..., None]
        self.a[sl] = self.a[sl] * (1.0 - alpha) + alpha

    def fill(self, bbox, sdf, color, soft=1.0, gain=1.0, clip_sdf=None, mode="over"):
        region = self.region(bbox)
        if region is None:
            return
        _, X, Y = region
        alpha = np.clip(0.5 - sdf(X, Y) / soft, 0.0, 1.0) * gain
        if clip_sdf is not None:
            # Always clip on a 1 px edge - reusing `soft` here would let a
            # blurred shape bleed `soft / 2` px past the clip boundary.
            alpha = alpha * np.clip(0.5 - clip_sdf(X, Y), 0.0, 1.0)
        self.blit(region, alpha, color, mode)


def vertical_gradient(w, h, stops):
    """stops: [(position 0..1, rgb), ...]; flat between equal neighbours."""
    t = np.linspace(0.0, 1.0, h, dtype=np.float32)
    pos = np.array([s[0] for s in stops], np.float32)
    cols = np.array([s[1] for s in stops], np.float32)
    col = np.empty((h, 3), np.float32)
    for ch in range(3):
        col[:, ch] = np.interp(t, pos, cols[:, ch])
    return np.repeat(col[:, None, :], w, axis=1) / 255.0


# --------------------------------------------------------------------------
# The mark.
# --------------------------------------------------------------------------


def draw_drops(canvas, cx, cy, s, *, shadow=True, faces=True):
    """Two big drops flanking one small drop, centred on (cx, cy).

    `s` is the master scale: 1.0 is the 1024 px reference layout.
    """
    big_r, big_apex = REF_BIG_R * s, REF_BIG_APEX * s
    small_r, small_apex = REF_SMALL_R * s, REF_SMALL_APEX * s
    spread, small_dy = REF_SPREAD * s, REF_SMALL_DY * s
    # Sub-pixel keylines just read as grey haze; keep them >= 1.1 px, and drop
    # them entirely on tiny icons where they would only muddy the cream.
    ol = max(REF_OUTLINE * s, 1.1) if s >= 0.10 else 0.0

    left, right = (cx - spread, cy), (cx + spread, cy)
    small = (cx, cy + small_dy)

    def teardrop(c, r, apex):
        def f(X, Y):
            return sd_teardrop(X, Y, c[0], c[1], r, apex)

        return f

    def ground_shadow(c, r, gain):
        # Bbox has to clear the blur falloff, or the alpha gets sliced flat and
        # the shadow ends in a hard rectangle.
        canvas.fill(
            (c[0] - r * 2.5, c[1] - r * 1.2, c[0] + r * 2.5, c[1] + r * 2.2),
            lambda X, Y, c=c, r=r: sd_ellipse(
                X, Y, c[0], c[1] + r * 0.98, r * 0.86, r * 0.20
            ),
            CORAL_LO,
            soft=max(r * 0.55, 1.0),
            gain=gain,
        )

    def paint_body(c, r, apex):
        sdf = teardrop(c, r, apex)
        bbox = (c[0] - r - 6, c[1] - r - apex - 6, c[0] + r + 6, c[1] + r + 6)
        region = canvas.region(bbox)
        if region is None:
            return
        _, X, Y = region
        d = sdf(X, Y)
        if ol:
            # Lay the whole silhouette down in the keyline colour, then drop
            # the cream interior on top inset by `ol` - leaving a ring exactly
            # `ol` wide, and a slightly softened tip where the SDF rounds it.
            canvas.blit(region, np.clip(0.5 - d, 0.0, 1.0), OUTLINE)
        inner = np.clip(0.5 - (d + ol), 0.0, 1.0)
        # Soft vertical cream ramp so each drop reads as a lit volume.
        k = np.clip((Y - (c[1] - r)) / (2.0 * r), 0.0, 1.0)[..., None]
        col = np.asarray(CREAM_HI, np.float32) * (1.0 - k) + np.asarray(
            CREAM_LO, np.float32
        ) * k
        canvas.blit(region, inner, col)

        if faces and r > 6:
            # Glossy highlight, clipped to the drop so it never bleeds out.
            hx, hy = c[0] - r * 0.46, c[1] - r * 0.42
            canvas.fill(
                (hx - r * 0.5, hy - r * 0.6, hx + r * 0.5, hy + r * 0.6),
                lambda X, Y, hx=hx, hy=hy, r=r: sd_ellipse(
                    X, Y, hx, hy, r * 0.12, r * 0.29, 0.45
                ),
                (0xFF, 0xFF, 0xFF),
                # Tight enough to read as a defined streak; wider and it just
                # washes the whole upper-left quadrant pale.
                soft=max(r * 0.13, 1.0),
                gain=0.95,
                clip_sdf=sdf,
            )

    def paint_face(c, r):
        if not faces or r < 9:
            return
        eye_r = r * 0.26
        w = max(r * 0.085, 0.9)
        for sign in (-1, 1):
            ex, ey = c[0] + sign * r * 0.34, c[1] - r * 0.10
            pad = eye_r + w
            # Happy closed eye: top half of a ring, finished with round caps.
            canvas.fill(
                (ex - pad, ey - pad, ex + pad, ey + pad),
                lambda X, Y, ex=ex, ey=ey, eye_r=eye_r, w=w: np.maximum(
                    np.abs(np.hypot(X - ex, Y - ey) - eye_r) - w / 2.0, Y - ey
                ),
                INK,
            )
            for tx in (ex - eye_r, ex + eye_r):
                canvas.fill(
                    (tx - w, ey - w, tx + w, ey + w),
                    lambda X, Y, tx=tx, ey=ey, w=w: np.hypot(X - tx, Y - ey) - w / 2.0,
                    INK,
                )
            bx, by = c[0] + sign * r * 0.58, c[1] + r * 0.21
            canvas.fill(
                (bx - r * 0.28, by - r * 0.25, bx + r * 0.28, by + r * 0.25),
                lambda X, Y, bx=bx, by=by, r=r: sd_ellipse(
                    X, Y, bx, by, r * 0.17, r * 0.115
                ),
                BLUSH,
                soft=max(r * 0.09, 1.0),
                gain=0.55,
            )

        mx, my, mr = c[0], c[1] + r * 0.36, r * 0.22
        canvas.fill(
            (mx - mr - w, my - w, mx + mr + w, my + mr + w),
            lambda X, Y, mx=mx, my=my, mr=mr, w=w: np.maximum(
                np.abs(np.hypot(X - mx, Y - my) - mr) - w / 2.0, my - Y
            ),
            INK,
        )
        for tx in (mx - mr, mx + mr):
            canvas.fill(
                (tx - w, my - w, tx + w, my + w),
                lambda X, Y, tx=tx, my=my, w=w: np.hypot(X - tx, Y - my) - w / 2.0,
                INK,
            )

    if shadow:
        for c, r, _ in ((left, big_r, big_apex), (right, big_r, big_apex)):
            ground_shadow(c, r, 0.40)

    for c, r, apex in ((left, big_r, big_apex), (right, big_r, big_apex)):
        paint_body(c, r, apex)
        paint_face(c, r)

    # The small drop rides in front, so its shadow falls onto the big two.
    if shadow:
        ground_shadow(small, small_r, 0.35)
    paint_body(small, small_r, small_apex)
    paint_face(small, small_r)


def render_mark(px, *, background, art_width=0.80):
    """The drop trio on a square canvas.

    `art_width` is the group's width as a fraction of the canvas: 0.80 for the
    full-bleed master logo, ~0.60 for adaptive icons so no part of the mark
    gets clipped by the launcher's mask.
    """
    s = px * art_width / (GROUP_HALF_W * 2.0)
    bg = vertical_gradient(px, px, [(0.0, CORAL_HI), (1.0, CORAL_LO)]) if background == "coral" else background
    canvas = Canvas(px, px, bg)
    draw_drops(canvas, px / 2.0, px / 2.0 - GROUP_CENTRE_DY * s, s)
    return canvas


def render_silhouette(px, art_width=0.60):
    """Monochrome layer for Android 13 themed icons: solid drops with a
    hairline gap carved around the little one so all three still read."""
    s = px * art_width / (GROUP_HALF_W * 2.0)
    cx, cy = px / 2.0, px / 2.0 - GROUP_CENTRE_DY * s
    canvas = Canvas(px, px, None)

    big_r, big_apex = REF_BIG_R * s, REF_BIG_APEX * s
    small_r, small_apex = REF_SMALL_R * s, REF_SMALL_APEX * s
    spread, small_dy = REF_SPREAD * s, REF_SMALL_DY * s

    for sign in (-1, 1):
        c = (cx + sign * spread, cy)
        canvas.fill(
            (c[0] - big_r, c[1] - big_r - big_apex, c[0] + big_r, c[1] + big_r),
            lambda X, Y, c=c: sd_teardrop(X, Y, c[0], c[1], big_r, big_apex),
            (0, 0, 0),
        )

    sc = (cx, cy + small_dy)
    gap = max(px * 0.014, 1.5)
    canvas.fill(
        (sc[0] - small_r * 2, sc[1] - small_r - small_apex - gap * 2,
         sc[0] + small_r * 2, sc[1] + small_r + gap * 2),
        lambda X, Y: sd_teardrop(
            X, Y, sc[0], sc[1], small_r + gap, small_apex + gap
        ),
        None,
        mode="out",
    )
    canvas.fill(
        (sc[0] - small_r, sc[1] - small_r - small_apex, sc[0] + small_r, sc[1] + small_r),
        lambda X, Y: sd_teardrop(X, Y, sc[0], sc[1], small_r, small_apex),
        (0, 0, 0),
    )
    return canvas


# --------------------------------------------------------------------------
# Splash. Sized 1080x2400 for the test device and designed for `cover`: the
# trio stays inside the middle ~70 % so any aspect crop only eats decoration.
# --------------------------------------------------------------------------

SPLASH_W, SPLASH_H = 1080, 2400


def render_splash():
    bg = vertical_gradient(
        SPLASH_W, SPLASH_H,
        [(0.0, SPLASH_TOP), (0.40, CORAL), (1.0, CORAL_LO)],
    )
    canvas = Canvas(SPLASH_W, SPLASH_H, bg)

    # Rear hill first, offset right and a shade deeper, for depth.
    canvas.fill((0, 1450, SPLASH_W, SPLASH_H - 1),
                lambda X, Y: sd_ellipse(X, Y, 780, 2400, 800, 720), HILL_BACK)
    canvas.fill((0, 1600, SPLASH_W, SPLASH_H - 1),
                lambda X, Y: sd_ellipse(X, Y, 460, 2450, 940, 760), CORAL_LO)

    # Blue accents, pushed to the outer thirds so cropping is harmless.
    canvas.fill((-160, 1420, 260, 1740),
                lambda X, Y: sd_ellipse(X, Y, 30, 1580, 145, 110, 0.35), BLUE)
    canvas.fill((760, 1210, 980, 1360),
                lambda X, Y: sd_ellipse(X, Y, 868, 1286, 96, 42, -0.42), BLUE)
    canvas.fill((800, 2050, 1010, 2260),
                lambda X, Y: sd_ellipse(X, Y, 905, 2155, 76, 62, 0.5), BLUE)

    for dx, dy, rx, ry, rot in ((150, 1180, 34, 20, -0.5), (960, 1620, 30, 18, 0.7),
                                (96, 1960, 26, 16, 0.2), (620, 1130, 22, 14, 0.9)):
        canvas.fill(
            (dx - rx - 4, dy - ry - 4, dx + rx + 4, dy + ry + 4),
            lambda X, Y, dx=dx, dy=dy, rx=rx, ry=ry, rot=rot: sd_ellipse(
                X, Y, dx, dy, rx, ry, rot),
            CONFETTI,
        )

    draw_drops(canvas, SPLASH_W / 2.0, 1569.0, 0.93)
    return canvas


# --------------------------------------------------------------------------
# Output plumbing.
# --------------------------------------------------------------------------


def to_image(canvas):
    a = canvas.a[..., None]
    rgb = np.clip(canvas.rgb / np.where(a > 1e-4, a, 1.0), 0.0, 1.0)
    rgba = np.concatenate([rgb, np.clip(canvas.a, 0.0, 1.0)[..., None]], axis=2)
    arr = (rgba * 255.0 + 0.5).astype(np.uint8)
    if np.all(arr[..., 3] == 255):
        return Image.fromarray(arr[..., :3], "RGB")
    return Image.fromarray(arr, "RGBA")


def save(canvas, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    to_image(canvas).save(path, optimize=True)
    print(f"  {path.relative_to(ROOT)}  ({path.stat().st_size / 1024.0:.0f} KB)")


DENSITIES = [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)]
ADAPTIVE = [("mdpi", 108), ("hdpi", 162), ("xhdpi", 216), ("xxhdpi", 324), ("xxxhdpi", 432)]

RES = ROOT / "android" / "app" / "src" / "main" / "res"
BRANDING = ROOT / "assets" / "branding"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--preview", action="store_true")
    args = ap.parse_args()

    print("Master logo")
    save(render_mark(1024, background="coral"), BRANDING / "dun_dun_dun_logo_1024.png")

    print("Splash")
    splash = render_splash()
    save(splash, BRANDING / "dun_dun_dun_splash.png")
    # Second copy under res/ so launch_background.xml can paint the artwork
    # from the very first window frame, before the Flutter engine is up.
    # Without it the user stares at a flat backdrop for the whole cold start.
    save(splash, RES / "drawable-nodpi" / "splash_art.png")

    print("Launcher icons")
    for name, px in DENSITIES:
        save(render_mark(px, background="coral"), RES / f"mipmap-{name}" / "ic_launcher.png")
        canvas = render_mark(px, background="coral")
        # "out" erases where the SDF is negative, so the mask is inverted:
        # keep the disc, punch the corners.
        canvas.fill((-2, -2, px + 2, px + 2),
                    lambda X, Y, px=px: -sd_circle(X, Y, px / 2.0, px / 2.0, px / 2.0),
                    None, mode="out")
        save(canvas, RES / f"mipmap-{name}" / "ic_launcher_round.png")

    print("Adaptive icon layers")
    for name, px in ADAPTIVE:
        save(render_mark(px, background=None, art_width=0.60),
             RES / f"drawable-{name}" / "ic_launcher_foreground.png")
        save(render_silhouette(px),
             RES / f"drawable-{name}" / "ic_launcher_monochrome.png")

    if args.preview:
        out = ROOT / "build" / "branding_preview"
        out.mkdir(parents=True, exist_ok=True)
        px = 432
        fg = to_image(render_mark(px, background=None, art_width=0.60))
        fga = np.asarray(fg, np.float32) / 255.0
        fg_rgb, fg_a = fga[..., :3] * fga[..., 3:4], fga[..., 3]
        # Model the launcher's *actual* mask, not the whole 108dp layer. The
        # system only ever shows the inner 72dp - previewing the full canvas is
        # what hides clipping.
        safe = px * 72.0 / 108.0 / 2.0
        corner = safe * 0.45
        for label, mask in (
            ("circle", lambda X, Y: -sd_circle(X, Y, px / 2.0, px / 2.0, safe)),
            ("squircle", lambda X, Y: corner - np.hypot(
                np.maximum(np.abs(X - px / 2.0) - (safe - corner), 0.0),
                np.maximum(np.abs(Y - px / 2.0) - (safe - corner), 0.0),
            )),
        ):
            c = Canvas(px, px, vertical_gradient(px, px, [(0.0, CORAL_HI), (1.0, CORAL_LO)]))
            c.rgb = c.rgb * (1.0 - fg_a[..., None]) + fg_rgb
            c.a = np.clip(c.a + fg_a, 0.0, 1.0)
            # Mask last: the launcher clips the *composited* icon, so masking
            # the background first would draw the foreground straight over the
            # outside of the mask and hide any clipping.
            c.fill((0, 0, px - 1, px - 1), mask, None, mode="out")
            save(c, out / f"adaptive_{label}.png")
        to_image(render_mark(1024, background="coral")).resize(
            (256, 256), Image.LANCZOS
        ).save(out / "logo_small.png", optimize=True)
        save(render_silhouette(px), out / "monochrome.png")

    print("\nDone.")


if __name__ == "__main__":
    main()
