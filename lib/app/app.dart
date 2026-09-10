import 'package:breast_milk/app/router.dart';
import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/features/launch/presentation/brand_launch_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BreastMilkApp extends ConsumerStatefulWidget {
  const BreastMilkApp({super.key});

  @override
  ConsumerState<BreastMilkApp> createState() => _BreastMilkAppState();
}

class _BreastMilkAppState extends ConsumerState<BreastMilkApp> {
  bool _showLaunch = true;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: '吨吨吨',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            ?child,
            if (_showLaunch)
              BrandLaunchPage(
                onFinished: () {
                  if (mounted) setState(() => _showLaunch = false);
                },
              ),
          ],
        );
      },
    );
  }
}
