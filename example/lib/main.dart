import 'package:flutter/material.dart';
import 'package:screen_launcher/screen_launcher.dart';

void main() => runApp(const ExampleApp());

const List<LaunchableScreen> launcherScreens = [
  LaunchableScreen(
    name: '/home',
    title: 'Home',
    group: 'Core',
    icon: Icons.home_outlined,
  ),
  LaunchableScreen(
    name: '/profile',
    title: 'Profile',
    group: 'Core',
    icon: Icons.person_outline,
    arguments: {'userId': 'demo-user'},
  ),
  LaunchableScreen(
    name: '/settings',
    title: 'Settings',
    group: 'Core',
    icon: Icons.settings_outlined,
  ),
  LaunchableScreen(
    name: '/cart',
    title: 'Cart',
    group: 'Commerce',
    icon: Icons.shopping_cart_outlined,
  ),
  LaunchableScreen(
    name: '/notifications',
    title: 'Notifications',
    group: 'System',
    icon: Icons.notifications_outlined,
  ),
  LaunchableScreen(
    name: '/about',
    title: 'About',
    group: 'System',
    icon: Icons.info_outline,
  ),
];

final Map<String, WidgetBuilder> namedRoutes = {
  for (final screen in launcherScreens)
    screen.name: (_) => _DemoScreen(screen: screen),
};

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Launcher Example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
      routes: namedRoutes,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DraggyBubbleHandle? _bubble;

  @override
  void initState() {
    super.initState();
    // Insert the draggable bubble into the root overlay once the first frame
    // is laid out. Tapping it opens the screen launcher with named routes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bubble = ScreenLauncher.showBubble(
        context,
        groupByCategory: true,
        screens: launcherScreens,
        onLaunch: _launchWithNamedRoute,
      );
    });
  }

  @override
  void dispose() {
    _bubble?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Launcher Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Drag the floating bubble and tap it to open the launcher, '
                'or use the button below.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.rocket_rounded),
                label: const Text('Open Screen Launcher'),
                onPressed: () => ScreenLauncher.open(
                  context,
                  screens: launcherScreens,
                  groupByCategory: true,
                  onLaunch: _launchWithNamedRoute,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchWithNamedRoute(BuildContext context, LaunchableScreen screen) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(screen.name, arguments: screen.arguments);
  }
}

class _DemoScreen extends StatelessWidget {
  const _DemoScreen({required this.screen});

  final LaunchableScreen screen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(screen.displayLabel)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(screen.icon, size: 48),
              const SizedBox(height: 16),
              Text(
                '${screen.displayLabel} screen',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (screen.arguments != null) ...[
                const SizedBox(height: 12),
                Text('Arguments: ${screen.arguments}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
