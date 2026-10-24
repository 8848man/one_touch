import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../core/data/media_gallery.dart';
import '../../../core/domain/album.dart';
import '../../../core/providers.dart';
import '../../../design_system/design_system.dart';
import '../application/albums_controller.dart';
import '../application/media_providers.dart';
import 'asset_thumbnail.dart';

/// Album media grid (screens.md §4). Long-press starts multi-select; the
/// selection can be moved to another album or sent to the trash.
class AlbumMediaScreen extends ConsumerStatefulWidget {
  const AlbumMediaScreen({super.key, required this.album});

  final Album album;

  @override
  ConsumerState<AlbumMediaScreen> createState() => _AlbumMediaScreenState();
}

class _AlbumMediaScreenState extends ConsumerState<AlbumMediaScreen> {
  final _selected = <String>{};
  bool _working = false;

  bool get _selecting => _selected.isNotEmpty;

  /// The album as it is now (it may have been renamed meanwhile).
  Album get _album {
    for (final a in ref.read(albumsProvider).albums) {
      if (a.id == widget.album.id) return a;
    }
    return widget.album;
  }

  void _toggle(AssetEntity asset) {
    setState(() {
      if (!_selected.remove(asset.id)) _selected.add(asset.id);
    });
  }

  void _clear() => setState(_selected.clear);

  List<AssetEntity> _chosen(List<AssetEntity> items) => [for (final a in items) if (_selected.contains(a.id)) a];

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() job) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await job();
    } catch (_) {
      if (mounted) _snack('처리하지 못했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _move(List<AssetEntity> items) async {
    final current = _album;
    final targets = [for (final a in ref.read(albumsProvider).albums) if (a.id != current.id) a];
    if (targets.isEmpty) {
      _snack('옮길 다른 앨범이 없어요.');
      return;
    }
    final target = await _pickAlbum(context, targets);
    if (target == null || !mounted) return;
    final chosen = _chosen(items);
    await _run(() async {
      final outcome = await ref.read(mediaGalleryProvider).moveAssets(chosen, target.savePath);
      if (!mounted) return;
      switch (outcome.status) {
        case MoveStatus.moved:
          _clear();
          refreshMediaFrom(ref);
          _snack('${outcome.count}개를 ${target.displayName}(으)로 옮겼어요.');
        case MoveStatus.empty:
          break;
        case MoveStatus.denied:
          _snack('옮기지 못했어요. 확인 창에서 허용해 주세요.');
        case MoveStatus.unsupported:
          _snack('이 기기(Android 10 이하)에서는 앨범 이동을 지원하지 않아요.');
      }
    });
  }

  Future<void> _delete(List<AssetEntity> items) async {
    final chosen = _chosen(items);
    await _run(() async {
      final gallery = ref.read(mediaGalleryProvider);
      final outcome = await gallery.trash(chosen);
      var count = outcome.count;
      var permanent = false;
      if (outcome.unsupported) {
        // Android 10 and below: no trash, so confirm a permanent delete first.
        if (!mounted) return;
        final ok = await showConfirmDialog(
          context,
          title: '사진 삭제',
          message: '${chosen.length}개 항목을 삭제할까요?',
          note: '이 기기에는 휴지통이 없어 바로 삭제돼요.',
          confirmLabel: '삭제',
        );
        if (!ok) return;
        count = await gallery.deletePermanently(chosen);
        permanent = true;
      }
      if (!mounted || count == 0) return;
      _clear();
      refreshMediaFrom(ref);
      _snack(permanent ? '$count개를 삭제했어요.' : '$count개를 휴지통으로 옮겼어요. 30일 안에 갤러리 앱에서 복원할 수 있어요.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final album = ref.watch(albumsProvider.select((s) {
      for (final a in s.albums) {
        if (a.id == widget.album.id) return a;
      }
      return widget.album;
    }));
    final media = ref.watch(albumMediaProvider(album.folderName));
    final items = media.valueOrNull ?? const <AssetEntity>[];
    // Drop selections whose items disappeared (moved or deleted elsewhere).
    if (media.hasValue && !media.isLoading) {
      final ids = {for (final a in items) a.id};
      _selected.removeWhere((id) => !ids.contains(id));
    }
    final allSelected = items.isNotEmpty && _selected.length == items.length;

    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _clear();
      },
      child: Scaffold(
        appBar: _selecting
            ? AppBar(
                backgroundColor: AppColors.primaryTint,
                leading: IconButton(icon: const Icon(Icons.close), tooltip: '선택 취소', onPressed: _clear),
                title: Text('${_selected.length}개 선택'),
                actions: [
                  TextButton(
                    onPressed: () => setState(() {
                      if (allSelected) {
                        _selected.clear();
                      } else {
                        _selected.addAll(items.map((a) => a.id));
                      }
                    }),
                    child: Text(allSelected ? '선택 해제' : '전체 선택'),
                  ),
                ],
              )
            : AppBar(title: Text(album.displayName)),
        bottomNavigationBar: _selecting
            ? _SelectionBar(
                working: _working,
                onMove: () => _move(items),
                onDelete: () => _delete(items),
              )
            : null,
        body: media.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('사진을 불러오지 못했어요.', style: AppText.body)),
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text('아직 찍은 사진이 없어요.', style: AppText.body));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final asset = items[i];
                final selected = _selected.contains(asset.id);
                return GestureDetector(
                  onTap: _selecting
                      ? () => _toggle(asset)
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => _MediaViewer(asset: asset)),
                          ),
                  onLongPress: () {
                    if (!selected) _toggle(asset);
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedPadding(
                        duration: AppMotion.fast,
                        padding: EdgeInsets.all(selected ? 8 : 0),
                        child: AssetThumbnail(asset: asset, showVideoBadge: true),
                      ),
                      if (_selecting)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpace.xs),
                            child: _SelectMark(selected: selected),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SelectMark extends StatelessWidget {
  const _SelectMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.black26,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.working, required this.onMove, required this.onDelete});

  final bool working;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSpace.s),
        child: SizedBox(
          height: 64,
          child: working
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Expanded(
                      child: _BarAction(icon: Icons.drive_file_move_outline, label: '앨범 이동', onTap: onMove),
                    ),
                    Expanded(
                      child: _BarAction(
                        icon: Icons.delete_outline,
                        label: '삭제',
                        color: AppColors.primary,
                        onTap: onDelete,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({required this.icon, required this.label, required this.onTap, this.color = AppColors.onSurface});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 2),
          Text(label, style: AppText.label.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Album picker for "앨범 이동".
Future<Album?> _pickAlbum(BuildContext context, List<Album> albums) {
  return showModalBottomSheet<Album>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpace.l, 0, AppSpace.l, AppSpace.s),
              child: Text('어느 앨범으로 옮길까요?', style: AppText.title),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final a in albums)
                    ListTile(
                      leading: Icon(
                        Icons.photo_album_outlined,
                        color: a.isVisible ? AppColors.primary : AppColors.onSurfaceMuted,
                      ),
                      title: Text(a.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(_trimSlash(a.savePath), style: AppText.caption),
                      onTap: () => Navigator.pop(ctx, a),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _trimSlash(String path) => path.endsWith('/') ? path.substring(0, path.length - 1) : path;

class _MediaViewer extends StatelessWidget {
  const _MediaViewer({required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    final isVideo = asset.type == AssetType.video;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: isVideo
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(dimension: 240, child: AssetThumbnail(asset: asset, size: 480)),
                  const SizedBox(height: AppSpace.l),
                  const Text('동영상은 갤러리 앱에서 재생해 주세요.', style: TextStyle(color: Colors.white70)),
                ],
              )
            : FutureBuilder<File?>(
                future: asset.file,
                builder: (context, snapshot) {
                  final file = snapshot.data;
                  if (file == null) return const CircularProgressIndicator();
                  return InteractiveViewer(child: Image.file(file));
                },
              ),
      ),
    );
  }
}
