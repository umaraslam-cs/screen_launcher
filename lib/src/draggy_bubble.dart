import 'package:flutter/material.dart';

/// A draggable, floating circular button that stays on top of the app.
///
/// This mirrors the classic "debug bubble" pattern: a small translucent button
/// you can drag anywhere on screen and tap to open a developer menu (such as
/// [ScreenLauncher]). When released, it animates to the nearest left/right
/// edge and stays clear of system insets (notches, status bar).
///
/// Prefer [showDraggyBubble] to insert one into the app's [Overlay]; use this
/// widget directly only when you want to embed it in your own [Stack].
class DraggyBubble extends StatefulWidget {
  /// Creates a draggable bubble.
  const DraggyBubble({
    super.key,
    required this.onTap,
    this.onLongPress,
    this.icon = Icons.rocket_launch,
    this.backgroundColor = const Color(0xFFFF9800),
    this.foregroundColor = Colors.white,
    this.size = 48,
    this.opacity = 0.7,
    this.initialOffset,
  });

  /// Called when the bubble is tapped.
  final VoidCallback onTap;

  /// Called when the bubble is long-pressed.
  final VoidCallback? onLongPress;

  /// Icon rendered inside the bubble.
  final IconData icon;

  /// Bubble background color.
  final Color backgroundColor;

  /// Color of the [icon].
  final Color foregroundColor;

  /// Diameter of the bubble.
  final double size;

  /// Bubble opacity (0–1).
  final double opacity;

  /// Optional starting position. Defaults to the upper-right corner.
  final Offset? initialOffset;

  @override
  State<DraggyBubble> createState() => _DraggyBubbleState();
}

class _DraggyBubbleState extends State<DraggyBubble>
    with SingleTickerProviderStateMixin {
  /// Gap kept between the bubble and the screen edges.
  static const double _edgeMargin = 8;

  /// Drives the snap-to-edge animation after a drag ends.
  late final AnimationController _snapController;
  Animation<Offset>? _snapAnimation;

  /// Current top-left position of the bubble. Only the [Positioned] listens to
  /// this, so dragging never rebuilds the bubble's visual subtree.
  final ValueNotifier<Offset> _position = ValueNotifier<Offset>(Offset.zero);

  Size _screen = Size.zero;
  EdgeInsets _padding = EdgeInsets.zero;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..addListener(() {
        final animation = _snapAnimation;
        if (animation != null) _position.value = animation.value;
      });
  }

  @override
  void dispose() {
    _snapController.dispose();
    _position.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.of(context);
    final screenChanged = media.size != _screen;
    _screen = media.size;
    _padding = media.padding;

    if (!_initialized) {
      _initialized = true;
      final start = widget.initialOffset ??
          Offset(_screen.width - widget.size, _screen.height * 0.1);
      _position.value = _clamp(start);
    } else if (screenChanged) {
      // Keep the bubble on-screen and re-anchored after rotation/resize.
      _position.value = _clamp(_position.value);
      _snapToNearestEdge();
    }
  }

  double get _minX => _padding.left + _edgeMargin;
  double get _maxX =>
      _screen.width - widget.size - _padding.right - _edgeMargin;
  double get _minY => _padding.top + _edgeMargin;
  double get _maxY =>
      _screen.height - widget.size - _padding.bottom - _edgeMargin;

  Offset _clamp(Offset offset) => Offset(
        offset.dx.clamp(_minX, _maxX),
        offset.dy.clamp(_minY, _maxY),
      );

  void _onPanStart(DragStartDetails _) => _snapController.stop();

  void _onPanUpdate(DragUpdateDetails details) {
    _position.value = _clamp(_position.value + details.delta);
  }

  void _onPanEnd(DragEndDetails _) => _snapToNearestEdge();

  void _snapToNearestEdge() {
    final current = _position.value;
    final center = current.dx + widget.size / 2;
    final goLeft = center < _screen.width / 2;
    final target =
        Offset(goLeft ? _minX : _maxX, current.dy.clamp(_minY, _maxY));

    if (target == current) return;

    _snapAnimation = Tween<Offset>(begin: current, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController
      ..value = 0
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final bubble = GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Opacity(
        opacity: widget.opacity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor,
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
            child: Icon(widget.icon, color: widget.foregroundColor),
          ),
        ),
      ),
    );

    return ValueListenableBuilder<Offset>(
      valueListenable: _position,
      child: bubble,
      builder: (context, offset, child) => Positioned(
        left: offset.dx,
        top: offset.dy,
        child: child!,
      ),
    );
  }
}

/// A handle to a [DraggyBubble] inserted via [showDraggyBubble].
class DraggyBubbleHandle {
  DraggyBubbleHandle._(this._entry);

  final OverlayEntry _entry;
  bool _removed = false;

  /// Whether the bubble has been removed from the overlay.
  bool get isRemoved => _removed;

  /// Removes the bubble from the overlay.
  void remove() {
    if (_removed) return;
    _removed = true;
    _entry.remove();
  }
}

/// Inserts a [DraggyBubble] into the app's root [Overlay] and returns a handle
/// you can use to remove it later.
///
/// ```dart
/// final handle = showDraggyBubble(
///   context,
///   onTap: () => /* open your debug menu */,
/// );
/// // later:
/// handle.remove();
/// ```
DraggyBubbleHandle showDraggyBubble(
  BuildContext context, {
  required VoidCallback onTap,
  VoidCallback? onLongPress,
  IconData icon = Icons.rocket_launch,
  Color backgroundColor = const Color(0xFFFF9800),
  Color foregroundColor = Colors.white,
  double size = 48,
  double opacity = 0.7,
  Offset? initialOffset,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(
    builder: (_) => DraggyBubble(
      onTap: onTap,
      onLongPress: onLongPress,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      size: size,
      opacity: opacity,
      initialOffset: initialOffset,
    ),
  );
  overlay.insert(entry);
  return DraggyBubbleHandle._(entry);
}
