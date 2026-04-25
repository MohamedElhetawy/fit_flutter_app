// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/src/features/auth/presentation/role_selection_screen.dart';

void main() {
  testWidgets('role selection screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RoleSelectionScreen(),
        ),
      ),
    );

    expect(find.text('أهلاً بيك! اختار نوع حسابك'), findsOneWidget);
  });
}
