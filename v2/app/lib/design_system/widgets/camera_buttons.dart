import 'package:flutter/material.dart';

import '../tokens.dart';

/// Dark top bar used on the camera screen (reference 01_camera.png).
class CameraTopBar extends StatelessWidget {
  const CameraTopBar({super.key, required this.leading, required this.trailing});

  final List<Widget> leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.cameraSurface,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppSize.topBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
            child: Row(children: [...leading, const Spacer(), ...trailing]),
          ),
        ),
      ),
    );
  }
}

/// Plain white icon button sitting on a camera surface.
class BarIconButton extends StatelessWidget {
  const BarIconButton({super.key, required this.icon, required this.tooltip, this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      color: AppColors.onCamera,
      disabledColor: AppColors.onCameraMuted,
      onPressed: onPressed,
    );
  }
}

/// Dark round button with a thin outline (camera flip).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.tooltip, this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFF2F2A2A),
        shape: const CircleBorder(side: BorderSide(color: Color(0xFF4F4A4A))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: AppSize.sideButtonSize,
            child: Icon(icon, size: 22, color: enabled ? AppColors.onCamera : AppColors.onCameraMuted),
          ),
        ),
      ),
    );
  }
}

/// White ring + disc. While recording the disc becomes a red rounded square.
class ShutterButton extends StatelessWidget {
  const ShutterButton({
    super.key,
    required this.onPressed,
    this.recording = false,
    this.enabled = true,
    this.size = AppSize.shutterSize,
  });

  final VoidCallback onPressed;
  final bool recording;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final active = enabled || recording;
    final ringColor = active ? AppColors.onCamera : AppColors.onCameraMuted;
    final inner = recording ? size * 0.38 : size - 18;
    return Semantics(
      button: true,
      enabled: active,
      label: recording ? '녹화 정지' : '촬영',
      child: GestureDetector(
        onTap: active ? onPressed : null,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: AppSize.shutterRing),
          ),
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            width: inner,
            height: inner,
            decoration: BoxDecoration(
              color: recording ? AppColors.recording : ringColor,
              borderRadius: BorderRadius.circular(recording ? 6 : size),
            ),
          ),
        ),
      ),
    );
  }
}

/// Photo / video switch (reference: pink circle behind the selected icon).
class ModeToggle extends StatelessWidget {
  const ModeToggle({super.key, required this.isVideo, required this.onChanged, this.enabled = true});

  final bool isVideo;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeIcon(
          icon: Icons.photo_camera,
          label: '사진',
          selected: !isVideo,
          onTap: enabled ? () => onChanged(false) : null,
        ),
        const SizedBox(width: AppSpace.m),
        _ModeIcon(
          icon: Icons.videocam,
          label: '동영상',
          selected: isVideo,
          onTap: enabled ? () => onChanged(true) : null,
        ),
      ],
    );
  }
}

class _ModeIcon extends StatelessWidget {
  const _ModeIcon({required this.icon, required this.label, required this.selected, this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.primary : Colors.transparent,
          ),
          child: Icon(icon, size: 18, color: AppColors.onCamera),
        ),
      ),
    );
  }
}
