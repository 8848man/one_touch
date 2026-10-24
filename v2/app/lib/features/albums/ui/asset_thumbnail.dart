import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../design_system/tokens.dart';

/// Loads and caches one thumbnail for [asset].
class AssetThumbnail extends StatefulWidget {
  const AssetThumbnail({super.key, required this.asset, this.size = 240, this.showVideoBadge = false});

  final AssetEntity asset;
  final int size;
  final bool showVideoBadge;

  @override
  State<AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail> {
  late Future<Uint8List?> _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AssetThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id) _load();
  }

  void _load() {
    _bytes = widget.asset.thumbnailDataWithSize(ThumbnailSize.square(widget.size));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _bytes,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (data == null)
              const ColoredBox(color: AppColors.placeholder)
            else
              Image.memory(data, fit: BoxFit.cover, gaplessPlayback: true),
            if (widget.showVideoBadge && widget.asset.type == AssetType.video)
              const Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(AppSpace.xs),
                  child: Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
                ),
              ),
          ],
        );
      },
    );
  }
}
