## 0.1.3

- Refresh the README banner image (new asset URL so pub.dev serves the latest).

## 0.1.2

- Add a README hero banner with the app screenshot in a device mockup and
  Flutter branding.

## 0.1.1

- The draggable bubble now snaps to the nearest screen edge on release, stays
  clear of system insets, and drags more smoothly.
- Guard against opening multiple launcher routes from repeated bubble taps.
- Default bubble appearance is `Icons.rocket_launch` on a bright orange
  background.
- Add a preview image and clearer setup steps to the README.

## 0.1.0

- Add a draggable bubble overlay: `DraggyBubble`, `showDraggyBubble(...)`, and
  `ScreenLauncher.showBubble(...)` for inserting a draggable launcher bubble
  into the root overlay that opens the launcher on tap.

## 0.0.1

- Initial release.
- `ScreenLauncher` widget: searchable, router-agnostic list of app screens.
- `LaunchableScreen` model with `title`, `group`, `arguments`, `icon` and
  `keywords` support.
- Case-insensitive search by default with optional case-sensitive matching.
- Optional grouping by category, custom tile builder, empty-state builder and
  `ScreenLauncherTheme` for visual overrides.
- `ScreenLauncher.open(...)` helper to push the launcher onto the navigator.
