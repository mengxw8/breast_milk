import 'package:flutter/material.dart';

/// Full-bleed launch artwork shown over the first Flutter frames.
///
/// Drawn with [BoxFit.cover] so the illustration fills the screen without
/// letterboxing or stretching. Background matches Android
/// `brand_splash_background` for a seamless hand-off from the system splash.
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
  /// Must equal `brand_splash_background` in res/values/colors.xml.
  static const _background = Color(0xFFD6AC8C);

  /// Brief brand beat after first paint; cold start already spent time on the
  /// native splash, so keep this short.
  static const _hold = Duration(milliseconds: 480);

  late final AnimationController _controller;
  late final Animation<double> _opacity;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _hold);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished();
      }
    });
    // Fallback if the image frame callback never fires (tests / missing asset).
    WidgetsBinding.instance.addPostFrameCallback((_) => _startHold());
  }

  void _startHold() {
    if (_started || !mounted) return;
    _started = true;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final size = MediaQuery.sizeOf(context);
    final cacheHeight = (size.height * dpr).round();

    return Positioned.fill(
      key: BrandLaunchPage.pageKey,
      child: FadeTransition(
        opacity: _opacity,
        child: ColoredBox(
          color: _background,
          child: Image(
            image: cacheHeight > 0
                ? ResizeImage(
                    const AssetImage(BrandLaunchPage.assetName),
                    height: cacheHeight,
                    policy: ResizeImagePolicy.fit,
                  )
                : const AssetImage(BrandLaunchPage.assetName),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            width: size.width.isFinite ? size.width : null,
            height: size.height.isFinite ? size.height : null,
            filterQuality: FilterQuality.low,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame != null || wasSynchronouslyLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _startHold());
              }
              return child;
            },
          ),
        ),
      ),
    );
  }
}
