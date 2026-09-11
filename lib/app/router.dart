import 'package:breast_milk/app/app_shell.dart';
import 'package:breast_milk/features/home/presentation/home_page.dart';
import 'package:breast_milk/features/intake/presentation/intake_page.dart';
import 'package:breast_milk/features/inventory/presentation/inventory_page.dart';
import 'package:breast_milk/features/printer_debug/presentation/printer_debug_page.dart';
import 'package:breast_milk/features/scanner/presentation/scanner_page.dart';
import 'package:breast_milk/features/settings/presentation/settings_page.dart';
import 'package:breast_milk/features/statistics/presentation/statistics_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: HomePage.routeName,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'intake',
                    name: IntakePage.routeName,
                    builder: (context, state) => const IntakePage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                name: InventoryPage.routeName,
                builder: (context, state) => const InventoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                name: ScannerPage.routeName,
                builder: (context, state) => const ScannerPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                name: StatisticsPage.routeName,
                builder: (context, state) => const StatisticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: SettingsPage.routeName,
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'printer',
                    name: PrinterDebugPage.routeName,
                    builder: (context, state) => const PrinterDebugPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
