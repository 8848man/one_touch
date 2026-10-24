import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/album.dart';
import '../../../core/domain/album_rules.dart';
import '../../../design_system/design_system.dart';
import '../application/albums_controller.dart';
import '../application/media_providers.dart';
import 'album_dialogs.dart';

/// Album list (screens.md §3, reference 05–12). Used as a pushed route on
/// phones and as the left pane of the foldable split view ([onClose] set).
class AlbumListScreen extends ConsumerStatefulWidget {
  const AlbumListScreen({super.key, required this.onOpenSettings, this.onClose});

  final VoidCallback onOpenSettings;
  final VoidCallback? onClose;

  @override
  ConsumerState<AlbumListScreen> createState() => _AlbumListScreenState();
}

class _AlbumListScreenState extends ConsumerState<AlbumListScreen> {
  final _openRow = ValueNotifier<Object?>(null);
  final _editController = TextEditingController();
  String? _editingId;
  bool _renaming = false;

  @override
  void initState() {
    super.initState();
    // V15 — pick up folders created outside the app since the last visit.
    Future.microtask(() async {
      await ref.read(albumsProvider.notifier).syncWithGallery();
      ref.invalidate(mediaCountsProvider);
    });
  }

  @override
  void dispose() {
    _openRow.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _startEdit(Album album) {
    setState(() {
      _editingId = album.id;
      _editController.text = album.displayName;
      _editController.selection = TextSelection(baseOffset: 0, extentOffset: album.displayName.length);
    });
  }

  void _cancelEdit() {
    if (_editingId != null && !_renaming) setState(() => _editingId = null);
  }

  /// V7 — also renames the device folder (one system confirmation).
  Future<void> _commitEdit(Album album) async {
    if (_renaming) return;
    final notifier = ref.read(albumsProvider.notifier);
    final value = _editController.text;
    if (normalizeAlbumName(value) == album.displayName) {
      _cancelEdit();
      return;
    }
    final error = notifier.validateName(value, exceptId: album.id);
    if (error != null) {
      _snack(error);
      return;
    }
    setState(() => _renaming = true);
    RenameResult result;
    try {
      result = await notifier.rename(album.id, value);
    } catch (_) {
      result = RenameResult.denied;
    }
    if (!mounted) return;
    setState(() {
      _renaming = false;
      if (result != RenameResult.denied) _editingId = null;
    });
    switch (result) {
      case RenameResult.renamed:
        break;
      case RenameResult.nameOnly:
        _snack('이 기기에서는 앱 속 이름만 바뀌어요. 갤러리 폴더 이름은 그대로예요.');
      case RenameResult.denied:
        _snack('갤러리 폴더 이름을 바꾸지 못했어요. 확인 창에서 허용해 주세요.');
    }
  }

  Future<void> _deleteFromEdit(Album album) async {
    await confirmDeleteAlbum(context, ref, album);
    if (mounted && !ref.read(albumsProvider).albums.any((a) => a.id == album.id)) {
      setState(() => _editingId = null);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(albumsProvider);
    final counts = ref.watch(mediaCountsProvider).valueOrNull ?? const <String, int>{};
    final notifier = ref.read(albumsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '뒤로',
          onPressed: widget.onClose ??
              () {
                Navigator.maybePop(context);
              },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), tooltip: '설정', onPressed: widget.onOpenSettings),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: PillButton(
        icon: Icons.add,
        label: '새로운 앨범 추가',
        onPressed: () => showCreateAlbumFlow(context, ref),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _openRow.value = null;
          _cancelEdit();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpace.l, AppSpace.xl, AppSpace.l, AppSpace.m),
              child: Text('앨범 리스트', style: AppText.title),
            ),
            Expanded(
              child: state.albums.isEmpty
                  ? const Center(
                      child: Text('아직 앨범이 없어요.', style: TextStyle(color: AppColors.onSurfaceMuted)),
                    )
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: state.albums.length,
                      onReorder: notifier.reorder,
                      itemBuilder: (context, index) {
                        final album = state.albums[index];
                        return _AlbumRow(
                          key: ValueKey(album.id),
                          index: index,
                          album: album,
                          countLabel: formatMediaCount(counts[album.folderName] ?? 0),
                          openRow: _openRow,
                          editing: album.id == _editingId,
                          editController: _editController,
                          busy: _renaming,
                          onToggle: (v) => toggleAlbumVisibility(context, ref, album, v),
                          onEdit: () => _startEdit(album),
                          onCommitEdit: () => _commitEdit(album),
                          onDelete: () => confirmDeleteAlbum(context, ref, album),
                          onDeleteFromEdit: () => _deleteFromEdit(album),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumRow extends StatelessWidget {
  const _AlbumRow({
    super.key,
    required this.index,
    required this.album,
    required this.countLabel,
    required this.openRow,
    required this.editing,
    required this.editController,
    required this.onToggle,
    required this.onEdit,
    required this.onCommitEdit,
    required this.onDelete,
    required this.onDeleteFromEdit,
    required this.busy,
  });

  final int index;
  final Album album;
  final String? countLabel;
  final ValueNotifier<Object?> openRow;
  final bool editing;
  final TextEditingController editController;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onCommitEdit;
  final VoidCallback onDelete;
  final VoidCallback onDeleteFromEdit;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs, vertical: 2),
      child: SwipeActionRow(
        id: album.id,
        openId: openRow,
        enabled: !editing,
        actions: [
          SwipeAction(icon: Icons.edit_outlined, label: '이름 편집', color: AppColors.primarySoft, onPressed: onEdit),
          SwipeAction(
            icon: Icons.delete_outline,
            label: '삭제',
            color: AppColors.primary,
            iconColor: Colors.white,
            onPressed: onDelete,
          ),
        ],
        child: SizedBox(
          height: AppSize.listRowHeight,
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpace.m),
            child: Row(
              children: [
                Switch(value: album.isVisible, onChanged: onToggle),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: editing
                      ? TextField(
                          controller: editController,
                          autofocus: true,
                          maxLength: kMaxAlbumNameLength,
                          textInputAction: TextInputAction.done,
                          enabled: !busy,
                          onSubmitted: (_) => onCommitEdit(),
                          style: AppText.body,
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.inputFill,
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(horizontal: AppSpace.s, vertical: AppSpace.s),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tapping exactly on the name starts editing (screens.md §3).
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onEdit,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  album.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.body,
                                ),
                              ),
                            ),
                            // Imported albums show where they live on the device (R2).
                            if (album.isImported && album.relativePath != null)
                              Text(
                                _trimSlash(album.relativePath!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.caption,
                              ),
                          ],
                        ),
                ),
                if (editing) ...[
                  const SizedBox(width: AppSpace.s),
                  busy
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton.filled(
                          tooltip: '저장',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.m)),
                          ),
                          icon: const Icon(Icons.check),
                          onPressed: onCommitEdit,
                        ),
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpace.xs, right: AppSpace.s),
                    child: IconButton(
                      tooltip: '앨범 삭제',
                      icon: const Icon(Icons.delete_outline, color: AppColors.primary),
                      onPressed: busy ? null : onDeleteFromEdit,
                    ),
                  ),
                ] else ...[
                  if (countLabel != null) Text(countLabel!, style: AppText.caption),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpace.m),
                      child: Icon(Icons.drag_handle, color: AppColors.onSurface),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _trimSlash(String path) => path.endsWith('/') ? path.substring(0, path.length - 1) : path;
