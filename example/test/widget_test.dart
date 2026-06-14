import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_launcher_example/main.dart';

void main() {
  testWidgets('home page exposes the launcher overlay', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Drag the floating bubble'), findsOneWidget);
    expect(find.byIcon(Icons.rocket_launch), findsWidgets);
  });
}
