import 'package:flutter/material.dart';

/// Full-bleed launch artwork shown over the first frames.
///
/// The asset is authored at the target device's own size (1080x2400) and drawn
/// with [BoxFit.cover], so it fills the screen on any aspect ratio rather than
/// letterboxing. Please keep it that way: with [BoxFit.contain] a 736x1264
/// source on a 1080x2400 screen left a ~272px bar top and bottom.
///
/// [_background] is an exact match for the artwork's top band *and* for the
/// Android native launch background (`brand_splash_background`), so the hand-off
/// from the system splash to this page has no visible seam - including on the
/// frame before the asset finishes decoding.
class BrandLaunchPage extends StatefulWidget {
  const BrandLaunchPage({required this.onFinished, super.key});

  static const pageKey = Key('brand-launch-page');
  static const assetName = 'assets/branding/dun_dun_dun_splash.png';

  final VoidCallback onFinished;

  @override
  State<BrandLaunchPage> createState() => _BrandLaunchPageState();
}

class _BrandLaunchPageState extends State<BrandLaunchPage>
    with SingleTickerProviderStateMixin {
  /// Must equal `brand_splash_background` in res/values/colors.xml, which in
  /// turn is the artwork's top row - that is what Android shows during the cold
  /// start, and any mismatch here shows up as a band during the hand-off.
  static const _background = Color(0xFFF38B88);

  /// Held just long enough to register as intentional branding. The cold start
  /// already costs a wait before this page is even reachable, so a long hold on
  /// top of it makes the app feel slow to open.
  static const _hold = Duration(milliseconds: 1200);

  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _hold);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1), weight: 82),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 18),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      key: BrandLaunchPage.pageKey,
      child: FadeTransition(
        opacity: _opacity,
        child: ColoredBox(
          color: _background,
          child: Image.asset(
            BrandLaunchPage.assetName,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
