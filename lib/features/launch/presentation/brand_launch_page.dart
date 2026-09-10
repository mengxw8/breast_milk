import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BrandLaunchPage extends StatefulWidget {
  const BrandLaunchPage({required this.onFinished, super.key});

  static const pageKey = Key('brand-launch-page');
  static const assetName = 'assets/branding/dun_dun_dun_splash_v3.png';

  final VoidCallback onFinished;

  @override
  State<BrandLaunchPage> createState() => _BrandLaunchPageState();
}

class _BrandLaunchPageState extends State<BrandLaunchPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _textOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1), weight: 88),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 12),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _textOffset = Tween(begin: const Offset(0, 0.14), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.2, curve: Curves.easeOutCubic),
      ),
    );
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
          color: const Color(0xFFF3C5C2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                BrandLaunchPage.assetName,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              SafeArea(
                child: Align(
                  alignment: const Alignment(0, -0.48),
                  child: SlideTransition(
                    position: _textOffset,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '吨吨吨',
                          style: TextStyle(
                            color: Color(0xFF6D2930),
                            fontSize: 42,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '每一袋，都安心有序',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppTheme.ink.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
