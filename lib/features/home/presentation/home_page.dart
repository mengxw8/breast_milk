import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = 'home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('吨吨吨'),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push('/printer-debug'),
                icon: const Icon(Icons.print_outlined),
                label: const Text('打印机调试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
