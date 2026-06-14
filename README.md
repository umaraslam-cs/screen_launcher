# screen_launcher

A lightweight, **router-agnostic** developer & QA tool for Flutter.

It shows a **searchable list of every screen in your app** so you can jump
straight to any route — no more clicking through five screens to reach a deep
page. You bring the list of screens and tell it how to navigate; it does the
rest.

- Zero third-party dependencies (Flutter SDK only).
- Works with **any** navigation: `Navigator`, `go_router`, `GetX`, `auto_route`, …
- Optional floating, draggable bubble to open the launcher from anywhere.

<img
  src="https://raw.githubusercontent.com/umaraslam-cs/screen_launcher/main/doc/screen_launcher_banner.png"
  alt="Screen Launcher preview: a searchable, grouped list of app screens with a draggable launcher bubble"
  width="100%"
/>

---

## Install

Add it to your `pubspec.yaml`:

```yaml
dependencies:
  screen_launcher: ^0.1.3
```

Then fetch packages:

```bash
flutter pub get
```

Import it:

```dart
import 'package:screen_launcher/screen_launcher.dart';
```

---

## Quick start (3 steps)

### 1. List the screens you want to launch

`name` is the only required field — it's the identifier passed back to you when
a row is tapped (usually your route name). Everything else is optional.

```dart
const launcherScreens = [
  LaunchableScreen(name: '/home', title: 'Home', group: 'Core'),
  LaunchableScreen(name: '/profile', title: 'Profile', group: 'Core'),
  LaunchableScreen(name: '/settings', title: 'Settings', group: 'System'),
];
```

### 2. Show the launcher

Pick whichever fits your app:

```dart
// Open it on demand (e.g. from a debug button)
ScreenLauncher.open(
  context,
  screens: launcherScreens,
  onLaunch: _launch,
);
```

```dart
// Or embed the widget anywhere in your own layout
ScreenLauncher(
  screens: launcherScreens,
  onLaunch: _launch,
);
```

### 3. Tell it how to navigate

This is the only part that depends on your app. The launcher never navigates
for you — it just calls `onLaunch` with the tapped screen:

```dart
void _launch(BuildContext context, LaunchableScreen screen) {
  Navigator.of(context).pushNamed(screen.name, arguments: screen.arguments);
}
```

That's it.

---

## Use it with your router

Just change the body of `onLaunch`:

```dart
// Navigator (named routes)
onLaunch: (context, screen) =>
    Navigator.of(context).pushNamed(screen.name, arguments: screen.arguments),

// go_router
onLaunch: (context, screen) => context.push(screen.name, extra: screen.arguments),

// GetX
onLaunch: (context, screen) => Get.toNamed(screen.name, arguments: screen.arguments),

// auto_route
onLaunch: (context, screen) => context.router.pushNamed(screen.name),
```

---

## Floating draggable bubble

Insert a draggable bubble into the app's root `Overlay`. Tapping it opens the
launcher. Add it once from a screen that has an `Overlay` ancestor (a
post-frame callback in `initState` is the easiest place):

```dart
class _HomePageState extends State<HomePage> {
  DraggyBubbleHandle? _bubble;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bubble = ScreenLauncher.showBubble(
        context,
        screens: launcherScreens,
        groupByCategory: true,
        onLaunch: (context, screen) {
          Navigator.of(context).pop(); // close the launcher first
          Navigator.of(context).pushNamed(screen.name);
        },
      );
    });
  }

  @override
  void dispose() {
    _bubble?.remove(); // remove the bubble when no longer needed
    super.dispose();
  }
}
```

Bubble options: `icon` (defaults to `Icons.rocket_launch`), `backgroundColor` (defaults
to `Color(0xFFFF9800)`), `foregroundColor` (defaults to `Colors.white`),
`size`, `opacity`, `initialOffset` — plus all the launcher options below.

For a fully custom overlay action, use the lower-level helper:

```dart
showDraggyBubble(context, onTap: () => debugPrint('Open any dev tool here'));
```

---

## Options

Passed to `ScreenLauncher`, `ScreenLauncher.open(...)` and
`ScreenLauncher.showBubble(...)`:

| Option            | Default            | Description                                  |
| ----------------- | ------------------ | -------------------------------------------- |
| `screens`         | —                  | The list of screens to show. **Required.**   |
| `onLaunch`        | —                  | Called when a row is tapped. **Required.**   |
| `title`           | `'Screen Launcher'`| Header / app bar title.                      |
| `searchHint`      | `'Search screens'` | Placeholder text for the search field.       |
| `caseSensitive`   | `false`            | Whether search is case sensitive.            |
| `groupByCategory` | `false`            | Group rows under `LaunchableScreen.group`.   |
| `theme`           | `null`             | Visual overrides (see below).                |

`ScreenLauncher` (the widget) also supports `showAppBar`, `emptyBuilder`, and
`tileBuilder` for deeper customization.

### Theming

```dart
ScreenLauncher(
  screens: launcherScreens,
  title: 'Dev Menu',
  theme: const ScreenLauncherTheme(
    trailingIcon: Icons.arrow_forward_ios,
  ),
  onLaunch: _launch,
);
```

Every `ScreenLauncherTheme` field is optional and falls back to the ambient
`Theme.of(context)`, so it blends into your app by default.

---

## Heads-up for production

The launcher opens routes directly and does **not** synthesize required
arguments. Screens that depend on `arguments`, query params, or prior state may
open incomplete. It's meant for development/QA — gate it behind a debug flag:

```dart
if (kDebugMode) {
  ScreenLauncher.showBubble(context, screens: launcherScreens, onLaunch: _launch);
}
```

---

See the [`example`](example) directory for a complete, runnable app.

## License

MIT — see [LICENSE](LICENSE).
