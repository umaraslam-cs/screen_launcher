import 'package:flutter/widgets.dart';

/// A single entry shown in the [ScreenLauncher] list.
///
/// Each entry represents a screen/route in your app that can be launched
/// directly for development, QA, or demo purposes. It is intentionally
/// router-agnostic: you decide how to actually open the screen via the
/// `onLaunch` callback on [ScreenLauncher].
@immutable
class LaunchableScreen {
  /// Creates a launchable screen entry.
  ///
  /// [name] is required and is typically the route name/path
  /// (e.g. `/home-screen`). It is used as the launch identifier and as the
  /// fallback label when [title] is not provided.
  const LaunchableScreen({
    required this.name,
    this.title,
    this.group,
    this.arguments,
    this.icon,
    this.keywords = const <String>[],
  });

  /// The unique route name/identifier used to launch the screen.
  final String name;

  /// An optional human-friendly title shown as the primary label.
  ///
  /// When null, [name] is shown instead.
  final String? title;

  /// Optional category used to group entries under section headers.
  final String? group;

  /// Optional arguments forwarded to your `onLaunch` callback.
  final Object? arguments;

  /// Optional leading icon for the list tile.
  final IconData? icon;

  /// Extra terms that should match this entry during search.
  final List<String> keywords;

  /// The label displayed as the primary text of the tile.
  String get displayLabel => title?.trim().isNotEmpty == true ? title! : name;

  /// Returns whether this entry matches the given [query].
  ///
  /// Matching is performed against [name], [title], [group] and [keywords].
  /// Set [caseSensitive] to `true` to perform an exact-case match.
  bool matches(String query, {bool caseSensitive = false}) {
    final term = caseSensitive ? query : query.toLowerCase();
    if (term.isEmpty) return true;

    bool contains(String? value) {
      if (value == null || value.isEmpty) return false;
      return (caseSensitive ? value : value.toLowerCase()).contains(term);
    }

    return contains(name) ||
        contains(title) ||
        contains(group) ||
        keywords.any(contains);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LaunchableScreen &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          title == other.title &&
          group == other.group &&
          arguments == other.arguments &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(name, title, group, arguments, icon);

  @override
  String toString() => 'LaunchableScreen(name: $name, title: $title)';
}
