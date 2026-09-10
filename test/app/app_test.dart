import 'package:breast_milk/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('应用从首页启动', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BreastMilkApp()));
    await tester.pumpAndSettle();

    expect(find.text('吨吨吨'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
