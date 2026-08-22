
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_flow/app.dart';
import 'package:task_flow/screens/auth/login_screen.dart';

void main() {
  testWidgets('App boots to splash, then routes to login', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());

    expect(find.text('TaskFlow'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Login form shows validation errors when empty', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Valid login navigates away from the login screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/home': (_) => const Scaffold(body: Center(child: Text('HOME'))),
        },
        home: const LoginScreen(),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd!');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
  });
}