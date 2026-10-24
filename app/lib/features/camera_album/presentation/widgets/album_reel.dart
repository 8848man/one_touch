import 'package:flutter/material.dart';

import '../../../../core/domain/entities/album.dart';

/// Horizontal, loop-style album carousel — see sdd/feature/album/album-loop.md
/// and sdd/fe/widgets/widget-inventory.md (AlbumReel/AlbumChip).
///
/// The centered chip is always the active save target. Swiping moves the
/// selection by one; tapping a non-centered chip re-centers (and thus
/// selects) it. The loop wraps via modulo indexing over a large virtual
/// page count — sdd/core/domain/domain-rules.md DR-6 explicitly treats
/// "infinite loop" as a non-permanent MVP structure, so this is a pragmatic
/// approximation rather than a true unbounded loop.
///
/// No per-chip thumbnail: sdd/fe/widgets/widget-inventory.md's AlbumChip and
/// the camera.html reference are both text-only (name + distance-based
/// fade/scale styling). Asset count is included since it's already part of
/// the Album entity and doesn't conflict with that spec.
///
/// Single-album case: with exactly one album, `virtualIndex % 1` is 0 for
/// every page, so a PageView-based loop would render the same Album on
/// every page — visually indistinguishable from data duplication even
/// though the list has exactly one entry. See `build()`: a loop of one item
/// isn't a loop, so that case renders a static chip instead of a PageView.
class AlbumReel extends StatefulWidget {
  const AlbumReel({
    super.key,
    required this.albums,
    required this.selectedAlbumName,
    required this.onSelect,
  });

  final List<Album> albums;
  final String selectedAlbumName;
  final ValueChanged<String> onSelect;

  @override
  State<AlbumReel> createState() => _AlbumReelState();
}

class _AlbumReelState extends State<AlbumReel> {
  static const _loopMultiplier = 5000;

  late PageController _controller;
  late int _virtualCount;

  @override
  void initState() {
    super.initState();
    _setUpController();
  }

  @override
  void didUpdateWidget(covariant AlbumReel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final albumsChanged = oldWidget.albums.length != widget.albums.length ||
        !_sameNames(oldWidget.albums, widget.albums);
    // Re-center on the current selection if the list changed shape (e.g. a
    // pending album became persisted) or the selection moved externally
    // (e.g. restored from AppSettings) without a swipe/tap in this widget.
    if (albumsChanged || _currentCenteredName() != widget.selectedAlbumName) {
      final oldController = _controller;
      _setUpController();
      oldController.dispose();
    }
  }

  bool _sameNames(List<Album> a, List<Album> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i].name != b[i].name) return false;
    }
    return true;
  }

  String? _currentCenteredName() {
    if (widget.albums.isEmpty || !_controller.hasClients) return null;
    final page = _controller.page?.round() ?? _controller.initialPage;
    return widget.albums[page % widget.albums.length].name;
  }

  void _setUpController() {
    final count = widget.albums.length;
    _virtualCount = count == 0 ? 0 : count * _loopMultiplier;
    final selectedIndex = count == 0
        ? 0
        : widget.albums.indexWhere((a) => a.name == widget.selectedAlbumName);
    final base = count == 0 ? 0 : (_virtualCount ~/ 2) - ((_virtualCount ~/ 2) % count);
    final initialPage = count == 0 ? 0 : base + (selectedIndex < 0 ? 0 : selectedIndex);
    _controller = PageController(viewportFraction: 0.3, initialPage: initialPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSettle(int virtualIndex) {
    if (widget.albums.isEmpty) return;
    final album = widget.albums[virtualIndex % widget.albums.length];
    if (album.name != widget.selectedAlbumName) {
      widget.onSelect(album.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.albums.isEmpty) {
      // shooting-flow.md AC4: zero albums is a valid (if open) empty state —
      // render it explicitly rather than an empty/broken-looking carousel.
      return const SizedBox(
        height: 72,
        child: Center(
          child: Text(
            'No albums yet — create one to start capturing.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (widget.albums.length == 1) {
      // Degenerate case for the modulo-based virtual-index loop: with a
      // single album, `virtualIndex % 1` is 0 for every page, so every page
      // in an infinite PageView renders the same Album — visually
      // indistinguishable from "the list duplicated" even though the
      // underlying data is a single, correct entry. A loop of one item is
      // not a loop, so render it as a static, non-swipeable chip instead of
      // going through PageView/virtual indexing at all.
      final album = widget.albums.single;
      return SizedBox(
        height: 72,
        child: Center(
          child: _AlbumChip(album: album, isSelected: true, onTap: () {}),
        ),
      );
    }
    return SizedBox(
      height: 72,
      child: PageView.builder(
        controller: _controller,
        itemCount: _virtualCount,
        onPageChanged: _handleSettle,
        itemBuilder: (context, virtualIndex) {
          final album = widget.albums[virtualIndex % widget.albums.length];
          final isSelected = album.name == widget.selectedAlbumName;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              var distance = 0.0;
              if (_controller.hasClients && _controller.position.haveDimensions) {
                final page = _controller.page ?? _controller.initialPage.toDouble();
                distance = (virtualIndex - page).abs();
              }
              final opacity = (1 - distance * 0.35).clamp(0.15, 1.0);
              final scale = (1 - distance * 0.15).clamp(0.65, 1.0);
              return Opacity(
                opacity: opacity,
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: _AlbumChip(
              album: album,
              isSelected: isSelected,
              onTap: () => _controller.animateToPage(
                virtualIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AlbumChip extends StatelessWidget {
  const _AlbumChip({
    required this.album,
    required this.isSelected,
    required this.onTap,
  });

  final Album album;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest;
    final foreground = isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: theme.colorScheme.onPrimary, width: 1.5) : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              album.isPending ? '${album.name} •' : album.name,
              style: TextStyle(
                color: foreground,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (!album.isPending)
              Text(
                '${album.assetCount}',
                style: TextStyle(fontSize: 10, color: foreground.withValues(alpha: 0.75)),
              ),
          ],
        ),
      ),
    );
  }
}
