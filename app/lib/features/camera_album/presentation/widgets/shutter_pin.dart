import 'package:flutter/material.dart';

/// Single control that is both the current-album indicator and the shutter —
/// see sdd/feature/camera/shooting-flow.md AC1 ("there is exactly one
/// control for this, not two separate elements") and
/// sdd/fe/widgets/widget-inventory.md (ShutterPin).
///
/// Disabled (dimmed, non-interactive) when there are no albums to save into
/// or a capture is already in flight — sdd/feature/camera/shooting-flow.md
/// AC4 (no shutter action possible with zero albums visible in the loop).
class ShutterPin extends StatelessWidget {
  const ShutterPin({
    super.key,
    required this.selectedAlbumName,
    required this.enabled,
    required this.isBusy,
    required this.onCapture,
  });

  final String selectedAlbumName;
  final bool enabled;
  final bool isBusy;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInteractive = enabled && !isBusy;

    return GestureDetector(
      onTap: isInteractive ? onCapture : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary,
            border: Border.all(color: theme.colorScheme.onPrimary, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
          ),
          alignment: Alignment.center,
          child: isBusy
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : Text(
                  selectedAlbumName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
        ),
      ),
    );
  }
}
