import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/repositories/settings_repository.dart';

const _lastUsedAlbumKey = 'last_used_album';

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<String?> getLastUsedAlbum() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUsedAlbumKey);
  }

  @override
  Future<void> setLastUsedAlbum(String albumName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUsedAlbumKey, albumName);
  }
}
