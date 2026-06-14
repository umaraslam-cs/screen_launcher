## 0.1.0

- Add a draggable bubble overlay: `DraggyBubble`, `showDraggyBubble(...)`, and
  `ScreenLauncher.showBubble(...)` for inserting a draggable launcher bubble
  into the root overlay that opens the launcher on tap.
- The draggable bubble snaps to the nearest screen edge on release, stays clear
  of system insets, and guards against opening multiple launcher routes from
  repeated taps.
- Default bubble appearance is `Icons.rocket_rounded` on a bright orange
  background.

## 0.0.1

- Initial release.
- `ScreenLauncher` widget: searchable, router-agnostic list of app screens.
- `LaunchableScreen` model with `title`, `group`, `arguments`, `icon` and
  `keywords` support.
- Case-insensitive search by default with optional case-sensitive matching.
- Optional grouping by category, custom tile builder, empty-state builder and
  `ScreenLauncherTheme` for visual overrides.
- `ScreenLauncher.open(...)` helper to push the launcher onto the navigator.
