import 'package:flutter/material.dart';

/// Visual configuration for [ScreenLauncher].
///
/// All fields are optional; when omitted the widget falls back to the
/// ambient [ThemeData] so it blends into the host app.
@immutable
class ScreenLauncherTheme {
  /// Creates a theme override for [ScreenLauncher].
  const ScreenLauncherTheme({
    this.backgroundColor,
    this.searchFieldColor,
    this.tileColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.groupHeaderTextStyle,
    this.trailingIcon = Icons.chevron_right,
    this.searchIcon = Icons.search,
    this.contentPadding,
  });

  /// Scaffold background color.
  final Color? backgroundColor;

  /// Fill color of the search field.
  final Color? searchFieldColor;

  /// Background color of each list tile.
  final Color? tileColor;

  /// Text style for the primary tile label.
  final TextStyle? titleTextStyle;

  /// Text style for the secondary tile label (route name).
  final TextStyle? subtitleTextStyle;

  /// Text style for group section headers.
  final TextStyle? groupHeaderTextStyle;

  /// Trailing icon shown on each tile.
  final IconData trailingIcon;

  /// Leading icon of the search field.
  final IconData searchIcon;

  /// Padding applied to the list contents.
  final EdgeInsetsGeometry? contentPadding;
}
