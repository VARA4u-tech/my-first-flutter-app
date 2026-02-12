import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_flutter_app/main.dart';

void main() {
  testWidgets('SmartQuack app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SmartQuackApp()),
    );
    expect(find.text('Hello, Pappuri 👋'), findsOneWidget);
  });
}
