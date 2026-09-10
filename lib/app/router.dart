import 'package:breast_milk/features/home/presentation/home_page.dart';
import 'package:breast_milk/features/printer_debug/presentation/printer_debug_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: HomePage.routeName,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/printer-debug',
        name: PrinterDebugPage.routeName,
        builder: (context, state) => const PrinterDebugPage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
