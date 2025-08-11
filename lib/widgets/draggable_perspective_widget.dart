import 'dart:math';

import 'package:flutter/material.dart';

class DraggablePerspectiveWidget extends StatefulWidget {
  final bool enabled;
  final Widget? child;

  const DraggablePerspectiveWidget({
    super.key,
    this.enabled = true,
    this.child,
  });

  @override
  State<DraggablePerspectiveWidget> createState() =>
      _DraggablePerspectiveWidgetState();
}

class _DraggablePerspectiveWidgetState extends State<DraggablePerspectiveWidget>
    with TickerProviderStateMixin {
  final _key = GlobalKey();

  Size? _size;
  Offset _dragStart = Offset.zero;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = _key.currentContext?.findRenderObject();
      if (renderBox != null && renderBox is RenderBox) _size = renderBox.size;
    });
  }

  Offset _calculateOffset(
    Offset localPosition, {
    Offset subtract = Offset.zero,
  }) {
    if (_size == null) return Offset.zero;

    const double max = 0.7;
    double centerWidth = _size!.width / 2;
    double centerHeight = _size!.height / 2;

    double dx = (localPosition.dx - centerWidth) / centerWidth;
    dx = dx.clamp(-max, max);

    double dy = (localPosition.dy - centerHeight) / centerHeight;
    dy = dy.clamp(-max, max);

    double distance = sqrt(dx * dx + dy * dy);
    if (distance > max) {
      double scale = max / distance;
      dx *= scale;
      dy *= scale;
    }

    // dx = Curves.easeOutQuart.transform(dx.abs() / max) * max * dx.sign;
    // dy = Curves.easeOutQuart.transform(dy.abs() / max) * max * dy.sign;

    return Offset(dx, dy) - subtract;
  }

  void _animateOut() {
    final animation = Tween<Offset>(begin: _offset, end: Offset.zero).animate(
      CurvedAnimation(
        parent: AnimationController(vsync: this, duration: Durations.medium1)
          ..forward(),
        curve: Curves.easeOut,
      ),
    );
    animation.addListener(() => setState(() => _offset = animation.value));
  }

  void _handlePointer(Offset localPosition, {bool isStart = false}) {
    if (isStart) _dragStart = _calculateOffset(localPosition);
    _offset = _calculateOffset(localPosition, subtract: _dragStart);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child ?? const SizedBox.shrink();

    // not finished yet
    // ignore: dead_code
    return Listener(
      onPointerUp: (_) => _animateOut(),
      onPointerCancel: (_) => _animateOut(),
      onPointerDown: (e) => _handlePointer(e.localPosition, isStart: true),
      onPointerMove: (e) => _handlePointer(e.localPosition),
      child: Transform(
        key: _key,
        alignment: Alignment.center,
        transform:
            Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_offset.dy * 0.1)
              ..rotateY(-_offset.dx * 0.1),
        child: widget.child,
      ),
    );
  }
}
