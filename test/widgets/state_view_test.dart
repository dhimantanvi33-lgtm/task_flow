import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/core/view_state.dart';
import 'package:task_flow/widgets/state_view.dart';

Widget _host(ViewState<String> state) => MaterialApp(
  home: Scaffold(
    body: StateView<String>(
      state: state,
      emptyMessage: 'Nothing here',
      onSuccess: (_, data) => Text(data),
    ),
  ),
);

void main() {
  testWidgets('loading -> spinner', (tester) async {
    await tester.pumpWidget(_host(const ViewState.loading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('empty -> empty message', (tester) async {
    await tester.pumpWidget(_host(const ViewState.empty()));
    await tester.pump();
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('error -> error message', (tester) async {
    await tester.pumpWidget(_host(const ViewState.error('Boom')));
    await tester.pump();
    expect(find.text('Boom'), findsOneWidget);
  });

  testWidgets('success -> child content', (tester) async {
    await tester.pumpWidget(_host(const ViewState.success('Hello')));
    await tester.pump();
    expect(find.text('Hello'), findsOneWidget);
  });
}