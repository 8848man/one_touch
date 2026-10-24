import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/entities/album.dart';
import '../application/album_list_provider.dart';
import '../application/album_management_provider.dart';
import '../application/selected_album_provider.dart';

/// Album Management — sdd/feature/album/manage-album.md. Single entry point
/// for album creation (sdd/feature/album/create-album.md) and the only
/// surface for Show/Hide (DR-11/DR-14). Presented as a modal per
/// architecture/navigation_strategy.md — no routing package.
Future<void> showAlbumManagementSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _AlbumManagementSheet(),
  );
}

class _AlbumManagementSheet extends ConsumerWidget {
  const _AlbumManagementSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumListProvider);
    final selectedAlbum = ref.watch(selectedAlbumNotifierProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Album Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: () => _showCreateAlbumDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: albumsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load albums: $e'),
                ),
                data: (albums) {
                  // DR-14: every recognized album is listed here, visible or
                  // hidden — this is the one surface that never filters by
                  // isVisibleInLoop.
                  final effectiveAlbums = _withPendingSelection(albums, selectedAlbum);
                  if (effectiveAlbums.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No albums yet — tap Create to add one.'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: effectiveAlbums.length,
                    itemBuilder: (context, index) {
                      final album = effectiveAlbums[index];
                      return ListTile(
                        title: Text(album.isPending ? '${album.name} (pending)' : album.name),
                        subtitle: album.isPending ? null : Text('${album.assetCount} photos'),
                        trailing: album.isPending
                            ? null
                            : Switch(
                                value: album.isVisibleInLoop,
                                onChanged: (value) => ref
                                    .read(albumManagementNotifierProvider.notifier)
                                    .toggleVisibility(album, value),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Same reasoning as camera_album_screen.dart's helper of the same shape:
  // a pending selection may not exist in the fetched list yet (DR-9).
  List<Album> _withPendingSelection(List<Album> albums, String selectedAlbumName) {
    if (albums.any((a) => a.name == selectedAlbumName)) return albums;
    return [
      Album(name: selectedAlbumName, assetCount: 0, isPending: true),
      ...albums,
    ];
  }

  void _showCreateAlbumDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => const _CreateAlbumDialog(),
    );
  }
}

class _CreateAlbumDialog extends ConsumerStatefulWidget {
  const _CreateAlbumDialog();

  @override
  ConsumerState<_CreateAlbumDialog> createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends ConsumerState<_CreateAlbumDialog> {
  final _controller = TextEditingController();
  String? _errorText;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    final error =
        await ref.read(albumManagementNotifierProvider.notifier).createAlbum(_controller.text);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _errorText = error;
        _submitting = false;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 앨범 만들기'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 20,
        decoration: InputDecoration(
          hintText: 'Album name',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submitting ? null : _submit(),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: const Text('생성'),
        ),
      ],
    );
  }
}
