import 'package:flutter/material.dart';

import '../tokens.dart';

/// Floating pill button ("+ 새로운 앨범 추가", reference 05_list_edit.png).
class PillButton extends StatelessWidget {
  const PillButton({super.key, required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySoft,
      shape: const StadiumBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.onSurface),
              const SizedBox(width: AppSpace.s),
              Text(label, style: AppText.body),
            ],
          ),
        ),
      ),
    );
  }
}

class SwipeAction {
  const SwipeAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.iconColor = AppColors.onSurface,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;
}

/// Row that reveals action buttons when swiped left (reference
/// 06_list_edit_swipe.png). Rows sharing [openId] close each other so only
/// one row is open at a time.
class SwipeActionRow extends StatefulWidget {
  const SwipeActionRow({
    super.key,
    required this.id,
    required this.openId,
    required this.actions,
    required this.child,
    this.enabled = true,
  });

  final Object id;
  final ValueNotifier<Object?> openId;
  final List<SwipeAction> actions;
  final Widget child;
  final bool enabled;

  @override
  State<SwipeActionRow> createState() => _SwipeActionRowState();
}

class _SwipeActionRowState extends State<SwipeActionRow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: AppMotion.swipe);

  double get _actionsWidth => widget.actions.length * (AppSize.swipeActionWidth + AppSpace.xs) + AppSpace.xs;

  @override
  void initState() {
    super.initState();
    widget.openId.addListener(_onOpenChanged);
  }

  @override
  void didUpdateWidget(SwipeActionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.openId != widget.openId) {
      oldWidget.openId.removeListener(_onOpenChanged);
      widget.openId.addListener(_onOpenChanged);
    }
    if (!widget.enabled && _controller.value > 0) _controller.value = 0;
  }

  @override
  void dispose() {
    widget.openId.removeListener(_onOpenChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onOpenChanged() {
    if (widget.openId.value != widget.id && _controller.value > 0) {
      _controller.animateTo(0, curve: Curves.easeOut);
    }
  }

  void _open() {
    widget.openId.value = widget.id;
    _controller.animateTo(1, curve: Curves.easeOut);
  }

  void _close() {
    if (widget.openId.value == widget.id) widget.openId.value = null;
    _controller.animateTo(0, curve: Curves.easeOut);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final double delta = details.primaryDelta ?? 0.0;
    _controller.value = (_controller.value - delta / _actionsWidth).clamp(0.0, 1.0).toDouble();
  }

  void _onDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0.0;
    if (velocity < -300 || (velocity <= 300 && _controller.value > 0.5)) {
      _open();
    } else {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: widget.enabled ? _onDragUpdate : null,
      onHorizontalDragEnd: widget.enabled ? _onDragEnd : null,
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final t = _controller.value;
          return Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpace.xs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final action in widget.actions)
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpace.xs),
                            child: _ActionButton(
                              action: action,
                              onTap: () {
                                _close();
                                action.onPressed();
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(-t * _actionsWidth, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.lerp(AppColors.surface, AppColors.primaryTint, t),
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.onTap});

  final SwipeAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: action.label,
      child: Material(
        color: action.color,
        borderRadius: BorderRadius.circular(AppRadius.m),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.m),
          onTap: onTap,
          child: SizedBox(
            width: AppSize.swipeActionWidth,
            height: AppSize.listRowHeight - AppSpace.s,
            child: Icon(action.icon, color: action.iconColor),
          ),
        ),
      ),
    );
  }
}
