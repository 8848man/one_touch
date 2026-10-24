import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/album.dart';

/// Album records as JSON in shared_preferences (data-model.md).
class AlbumStore {
  AlbumStore(this._prefs);

  static const _key = 'v2.albums';
  final SharedPreferences _prefs;

  List<Album> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [for (final item in list) Album.fromJson(item as Map<String, dynamic>)];
    } catch (_) {
      // Corrupt data should not brick the app; start over with an empty list.
      return [];
    }
  }

  Future<void> save(List<Album> albums) =>
      _prefs.setString(_key, jsonEncode([for (final a in albums) a.toJson()]));
}

/// Small app-level preferences (data-model.md › AppPrefs).
class AppPrefs {
  AppPrefs(this._prefs);

  static const _selectedKey = 'v2.selectedAlbumId';
  static const _premiumKey = 'v2.premium';
  static const _galleryImportedKey = 'v2.galleryImported';
  static const _dismissedKey = 'v2.dismissedFolders';
  final SharedPreferences _prefs;

  String? get selectedAlbumId => _prefs.getString(_selectedKey);

  Future<void> setSelectedAlbumId(String? id) =>
      id == null ? _prefs.remove(_selectedKey) : _prefs.setString(_selectedKey, id);

  bool get premium => _prefs.getBool(_premiumKey) ?? false;

  Future<void> setPremium(bool value) => _prefs.setBool(_premiumKey, value);

  /// V16 — true once the first gallery import has run.
  bool get galleryImported => _prefs.getBool(_galleryImportedKey) ?? false;

  Future<void> setGalleryImported() => _prefs.setBool(_galleryImportedKey, true);

  /// V18 — folder names of imported albums the user deleted.
  Set<String> get dismissedFolders => (_prefs.getStringList(_dismissedKey) ?? const <String>[]).toSet();

  Future<void> setDismissedFolders(Set<String> names) => _prefs.setStringList(_dismissedKey, names.toList());
}
