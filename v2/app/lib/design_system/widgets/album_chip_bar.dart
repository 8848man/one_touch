import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';

class AlbumChipItem {
  const AlbumChipItem({required this.id, required this.label});

  final String id;
  final String label;
}

/// Horizontal album selector (reference 01_camera.png). The selected chip is
/// kept centered; after a swipe the chip nearest the center becomes selected.
class AlbumChipBar extends StatefulWidget {
  const AlbumChipBar({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelected,
    this.enabled = true,
    this.trailing,
  });

  final List<AlbumChipItem> items;

  /// Shown after the last chip (e.g. [AlbumAddChip]). Never auto-selected.
  final Widget? trailing;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  State<AlbumChipBar> createState() => _AlbumChipBarState();
}

class _AlbumChipBarState extends State<AlbumChipBar> {
  final _scroll = ScrollController();
  final _barKey = GlobalKey();
  final _keys = <String, GlobalKey>{};
  bool _programmatic = false;

  GlobalKey _keyFor(String id) => _keys.putIfAbsent(id, () => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected(animate: false));
  }

  @override
  void didUpdateWidget(AlbumChipBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final orderChanged = oldWidget.items.map((e) => e.id).join('|') != widget.items.map((e) => e.id).join('|');
    if (oldWidget.selectedId != widget.selectedId || orderChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _centerSelected({bool animate = true}) async {
    final id = widget.selectedId;
    if (!mounted || id == null) return;
    final ctx = _keys[id]?.currentContext;
    if (ctx == null) return;
    _programmatic = true;
    try {
      await Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: animate ? AppMotion.snap : Duration.zero,
        curve: Curves.easeOutCubic,
      );
    } finally {
      _programmatic = false;
    }
  }

  void _onScrollEnd() {
    if (_programmatic || !widget.enabled) return;
    final bar = _barKey.currentContext?.findRenderObject() as RenderBox?;
    if (bar == null || !bar.attached) return;
    final center = bar.size.width / 2;
    String? nearest;
    var best = double.infinity;
    for (final item in widget.items) {
      final box = _keys[item.id]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final dx = bar.globalToLocal(box.localToGlobal(Offset(box.size.width / 2, 0))).dx;
      final distance = (dx - center).abs();
      if (distance < best) {
        best = distance;
        nearest = item.id;
      }
    }
    if (nearest == null) return;
    if (nearest != widget.selectedId) {
      widget.onSelected(nearest);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected());
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double side = math.max(0.0, constraints.maxWidth / 2 - 24);
        return SizedBox(
          key: _barKey,
          height: AppSize.chipBarHeight,
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (_) {
              _onScrollEnd();
              return false;
            },
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              physics: widget.enabled ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: side),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final item in widget.items)
                    _AlbumChip(
                      key: _keyFor(item.id),
                      label: item.label,
                      selected: item.id == widget.selectedId,
                      onTap: widget.enabled ? () => widget.onSelected(item.id) : null,
                    ),
                  if (widget.trailing != null) widget.trailing!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "New album" chip at the end of the chip bar (screens.md §1).
class AlbumAddChip extends StatelessWidget {
  const AlbumAddChip({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = onTap == null ? AppColors.onCameraMuted.withValues(alpha: 0.4) : AppColors.onCamera;
    return Semantics(
      button: true,
      label: '새 앨범',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpace.s, right: 2, bottom: 2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_album_outlined, size: 16, color: color),
                const SizedBox(width: AppSpace.xs),
                Text('+', style: AppText.label.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 15, height: 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlbumChip extends StatelessWidget {
  const _AlbumChip({super.key, required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(10, 6),
              painter: _TrianglePainter(selected ? AppColors.chipSelected : Colors.transparent),
            ),
            AnimatedContainer(
              duration: AppMotion.fast,
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? AppColors.chipSelected : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                label,
                maxLines: 1,
                style: AppText.label.copyWith(
                  color: selected ? AppColors.onSurface : AppColors.onCameraMuted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => oldDelegate.color != color;
}
