import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_launcher/screen_launcher.dart';

void main() {
  const screens = [
    LaunchableScreen(name: '/home', title: 'Home', group: 'Main'),
    LaunchableScreen(name: '/profile', title: 'Profile', group: 'Main'),
    LaunchableScreen(name: '/settings', title: 'Settings', group: 'System'),
  ];

  group('LaunchableScreen', () {
    test('displayLabel falls back to name when title is empty', () {
      expect(const LaunchableScreen(name: '/x').displayLabel, '/x');
      expect(
        const LaunchableScreen(name: '/x', title: 'X').displayLabel,
        'X',
      );
    });

    test('matches is case-insensitive by default', () {
      const screen = LaunchableScreen(name: '/home', title: 'Home');
      expect(screen.matches('HOME'), isTrue);
      expect(screen.matches('HOME', caseSensitive: true), isFalse);
      expect(screen.matches('home', caseSensitive: true), isTrue);
    });

    test('matches against keywords', () {
      const screen = LaunchableScreen(
        name: '/p',
        keywords: ['account', 'user'],
      );
      expect(screen.matches('user'), isTrue);
      expect(screen.matches('missing'), isFalse);
    });
  });

  group('ScreenLauncher widget', () {
    testWidgets('renders all screens and launches on tap', (tester) async {
      LaunchableScreen? launched;

      await tester.pumpWidget(
        MaterialApp(
          home: ScreenLauncher(
            screens: screens,
            onLaunch: (_, screen) => launched = screen,
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(launched?.name, '/profile');
    });

    testWidgets('filters the list as the user types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenLauncher(
            screens: screens,
            onLaunch: (_, __) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'set');
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('shows empty state when nothing matches', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScreenLauncher(
            screens: screens,
            onLaunch: (_, __) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'zzz-nope');
      await tester.pump();

      expect(find.text('No screens found'), findsOneWidget);
    });

    testWidgets('showBubble inserts a draggable launcher bubble',
        (tester) async {
      late DraggyBubbleHandle handle;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    handle = ScreenLauncher.showBubble(
                      context,
                      screens: screens,
                      onLaunch: (_, __) {},
                    );
                  },
                  child: const Text('Show bubble'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show bubble'));
      await tester.pump();

      expect(find.byIcon(Icons.rocket_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.rocket_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Screen Launcher'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      handle.remove();
    });
  });
}
