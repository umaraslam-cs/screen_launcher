import 'package:flutter/material.dart';

import 'draggy_bubble.dart';
import 'launchable_screen.dart';
import 'screen_launcher_theme.dart';

/// Signature for the callback invoked when a [LaunchableScreen] is tapped.
typedef OnScreenLaunch = void Function(
  BuildContext context,
  LaunchableScreen screen,
);

/// Builder used to fully customise how a [LaunchableScreen] tile is rendered.
typedef ScreenTileBuilder = Widget Function(
  BuildContext context,
  LaunchableScreen screen,
  VoidCallback launch,
);

/// A searchable list of app screens that can be launched on demand.
///
/// [ScreenLauncher] is a router-agnostic developer/QA tool. Provide it with the
/// list of [screens] your app exposes and an [onLaunch] callback that performs
/// the actual navigation (GetX, go_router, Navigator, etc.).
///
/// ```dart
/// ScreenLauncher(
///   screens: const [
///     LaunchableScreen(name: '/home', title: 'Home'),
///     LaunchableScreen(name: '/profile', title: 'Profile'),
///   ],
///   onLaunch: (context, screen) => Navigator.pushNamed(context, screen.name),
/// )
/// ```
class ScreenLauncher extends StatefulWidget {
  /// Creates a screen launcher.
  const ScreenLauncher({
    super.key,
    required this.screens,
    required this.onLaunch,
    this.title = 'Screen Launcher',
    this.searchHint = 'Search screens',
    this.caseSensitive = false,
    this.showAppBar = true,
    this.groupByCategory = false,
    this.theme,
    this.emptyBuilder,
    this.tileBuilder,
  });

  /// The screens available to launch.
  final List<LaunchableScreen> screens;

  /// Called when an entry is tapped. Perform navigation here.
  final OnScreenLaunch onLaunch;

  /// App bar / header title.
  final String title;

  /// Placeholder text for the search field.
  final String searchHint;

  /// Whether search is case sensitive. Defaults to `false`.
  final bool caseSensitive;

  /// Whether to wrap the content in a [Scaffold] with an [AppBar].
  ///
  /// Set to `false` to embed the launcher inside your own layout.
  final bool showAppBar;

  /// Whether to render section headers using [LaunchableScreen.group].
  final bool groupByCategory;

  /// Optional visual overrides.
  final ScreenLauncherTheme? theme;

  /// Builder for the empty/no-results state.
  final WidgetBuilder? emptyBuilder;

  /// Optional builder to fully customise each row.
  final ScreenTileBuilder? tileBuilder;

  /// Pushes the launcher onto the navigator and returns the resulting route.
  static Future<T?> open<T>(
    BuildContext context, {
    required List<LaunchableScreen> screens,
    required OnScreenLaunch onLaunch,
    String title = 'Screen Launcher',
    String searchHint = 'Search screens',
    bool caseSensitive = false,
    bool groupByCategory = false,
    ScreenLauncherTheme? theme,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder: (_) => ScreenLauncher(
          screens: screens,
          onLaunch: onLaunch,
          title: title,
          searchHint: searchHint,
          caseSensitive: caseSensitive,
          groupByCategory: groupByCategory,
          theme: theme,
        ),
      ),
    );
  }

  /// Inserts a draggable floating bubble into the app's root [Overlay].
  ///
  /// Tapping the bubble opens [ScreenLauncher]. The returned handle can be used
  /// to remove the bubble when it is no longer needed.
  ///
  /// ```dart
  /// final handle = ScreenLauncher.showBubble(
  ///   context,
  ///   screens: screens,
  ///   onLaunch: (context, screen) => Navigator.pushNamed(context, screen.name),
  /// );
  /// ```
  static DraggyBubbleHandle showBubble(
    BuildContext context, {
    required List<LaunchableScreen> screens,
    required OnScreenLaunch onLaunch,
    String title = 'Screen Launcher',
    String searchHint = 'Search screens',
    bool caseSensitive = false,
    bool groupByCategory = false,
    ScreenLauncherTheme? theme,
    VoidCallback? onLongPress,
    IconData icon = Icons.rocket_launch,
    Color backgroundColor = const Color(0xFFFF9800),
    Color foregroundColor = Colors.white,
    double size = 48,
    double opacity = 0.7,
    Offset? initialOffset,
  }) {
    // The bubble lives in the root overlay and floats above the launcher route
    // too, so guard against opening a second launcher while one is already open.
    var isOpen = false;
    return showDraggyBubble(
      context,
      onTap: () {
        if (isOpen) return;
        isOpen = true;
        ScreenLauncher.open(
          context,
          screens: screens,
          onLaunch: onLaunch,
          title: title,
          searchHint: searchHint,
          caseSensitive: caseSensitive,
          groupByCategory: groupByCategory,
          theme: theme,
        ).whenComplete(() => isOpen = false);
      },
      onLongPress: onLongPress,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      size: size,
      opacity: opacity,
      initialOffset: initialOffset,
    );
  }

  @override
  State<ScreenLauncher> createState() => _ScreenLauncherState();
}

class _ScreenLauncherState extends State<ScreenLauncher> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LaunchableScreen> get _filtered {
    if (_query.isEmpty) return widget.screens;
    return widget.screens
        .where((s) => s.matches(_query, caseSensitive: widget.caseSensitive))
        .toList(growable: false);
  }

  void _launch(LaunchableScreen screen) => widget.onLaunch(context, screen);

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: _SearchField(
            controller: _searchController,
            hint: widget.searchHint,
            fillColor: theme?.searchFieldColor,
            icon: theme?.searchIcon ?? Icons.search,
            onChanged: (value) => setState(() => _query = value.trim()),
            onClear: () => setState(() {
              _searchController.clear();
              _query = '';
            }),
          ),
        ),
        Expanded(child: _buildList(context)),
      ],
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: theme?.backgroundColor,
      appBar: AppBar(title: Text(widget.title)),
      body: body,
    );
  }

  Widget _buildList(BuildContext context) {
    final items = _filtered;
    if (items.isEmpty) {
      return widget.emptyBuilder?.call(context) ?? _defaultEmptyState(context);
    }

    final padding =
        widget.theme?.contentPadding ?? const EdgeInsets.only(bottom: 24);

    if (!widget.groupByCategory) {
      return ListView.separated(
        padding: padding,
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) => _buildTile(context, items[index]),
      );
    }

    final grouped = <String, List<LaunchableScreen>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.group ?? 'Other', () => []).add(item);
    }

    final widgets = <Widget>[];
    grouped.forEach((group, entries) {
      widgets.add(_GroupHeader(
        label: group,
        style: widget.theme?.groupHeaderTextStyle,
      ));
      for (final entry in entries) {
        widgets.add(_buildTile(context, entry));
        widgets.add(const Divider(height: 1));
      }
    });

    return ListView(padding: padding, children: widgets);
  }

  Widget _buildTile(BuildContext context, LaunchableScreen screen) {
    if (widget.tileBuilder != null) {
      return widget.tileBuilder!(context, screen, () => _launch(screen));
    }

    final theme = widget.theme;
    final hasTitle = screen.title?.trim().isNotEmpty == true;
    return ListTile(
      tileColor: theme?.tileColor,
      leading: screen.icon == null ? null : Icon(screen.icon),
      title: Text(screen.displayLabel, style: theme?.titleTextStyle),
      subtitle:
          hasTitle ? Text(screen.name, style: theme?.subtitleTextStyle) : null,
      trailing: Icon(theme?.trailingIcon ?? Icons.chevron_right),
      onTap: () => _launch(screen),
    );
  }

  Widget _defaultEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 12),
          Text(
            'No screens found',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onChanged,
    required this.onClear,
    this.fillColor,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color? fillColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClear,
            );
          },
        ),
        filled: fillColor != null,
        fillColor: fillColor,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, this.style});

  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: style ??
            Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
      ),
    );
  }
}
