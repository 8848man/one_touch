/// Album entity — see v2/sdd_v2/data-model.md.
class Album {
  const Album({
    required this.id,
    required this.folderName,
    required this.displayName,
    required this.isVisible,
    required this.sortOrder,
    required this.createdAt,
    this.lastUsedAt,
    this.relativePath,
    this.isImported = false,
  });

  /// Stable id; survives renames.
  final String id;

  /// Gallery folder (bucket) name used to find this album's media.
  /// Changes together with the device folder on rename (V7).
  final String folderName;

  /// Name shown in the UI. This is what rename edits.
  final String displayName;

  /// Whether the album shows up in the camera chip bar (V3).
  final bool isVisible;

  final int sortOrder;
  final DateTime createdAt;

  /// Last successful capture into this album (V9, V11).
  final DateTime? lastUsedAt;

  /// Device path of an imported album, e.g. `DCIM/Camera/` (V1, V17).
  /// Null for albums created in the app.
  final String? relativePath;

  /// True for albums picked up from the device gallery (V15).
  final bool isImported;

  /// Where captures go: the original folder for imported albums,
  /// `Pictures/<folderName>` otherwise (V17).
  String get savePath => relativePath ?? 'Pictures/$folderName';

  /// Fallback when [savePath] is not writable (R3).
  String get fallbackSavePath => 'Pictures/$folderName';

  Album copyWith({
    String? folderName,
    String? relativePath,
    String? displayName,
    bool? isVisible,
    int? sortOrder,
    DateTime? lastUsedAt,
  }) {
    return Album(
      id: id,
      folderName: folderName ?? this.folderName,
      displayName: displayName ?? this.displayName,
      isVisible: isVisible ?? this.isVisible,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      relativePath: relativePath ?? this.relativePath,
      isImported: isImported,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'folderName': folderName,
        'displayName': displayName,
        'isVisible': isVisible,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
        'lastUsedAt': lastUsedAt?.toIso8601String(),
        'relativePath': relativePath,
        'isImported': isImported,
      };

  factory Album.fromJson(Map<String, dynamic> json) {
    final lastUsed = json['lastUsedAt'] as String?;
    return Album(
      id: json['id'] as String,
      folderName: json['folderName'] as String,
      displayName: json['displayName'] as String,
      isVisible: json['isVisible'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: lastUsed == null ? null : DateTime.parse(lastUsed),
      relativePath: json['relativePath'] as String?,
      isImported: json['isImported'] as bool? ?? false,
    );
  }
}
