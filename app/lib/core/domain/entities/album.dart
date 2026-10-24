/// Shared kernel entity — see sdd/core/data/data-model.md and
/// architecture/folder_structure.md (core/domain/ is used by more than one
/// concern: capture needs the selected album, gallery owns album lifecycle).
class Album {
  const Album({
    required this.name,
    required this.assetCount,
    this.isPending = false,
    this.isVisibleInLoop = true,
  });

  final String name;
  final int assetCount;

  /// True until the first photo is written — see sdd/core/domain/domain-rules.md DR-9.
  final bool isPending;

  /// Controls carousel presence only — never deletes the underlying device
  /// album or its photos. See sdd/core/domain/domain-rules.md DR-11/DR-14:
  /// hidden albums are excluded from the carousel but still listed in Album
  /// Management, and are never a valid save target.
  final bool isVisibleInLoop;

  Album copyWith({
    String? name,
    int? assetCount,
    bool? isPending,
    bool? isVisibleInLoop,
  }) =>
      Album(
        name: name ?? this.name,
        assetCount: assetCount ?? this.assetCount,
        isPending: isPending ?? this.isPending,
        isVisibleInLoop: isVisibleInLoop ?? this.isVisibleInLoop,
      );
}
