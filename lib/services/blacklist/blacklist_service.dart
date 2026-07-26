import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/song_model.dart';

class BlacklistService {
  static const String _storageKey = 'blacklisted_song_ids';

  final _controller = StreamController<Set<int>>.broadcast();
  Set<int> _blacklistedIds = {};

  Stream<Set<int>> get blacklistStream => _controller.stream;
  Set<int> get blacklistedIds => Set.unmodifiable(_blacklistedIds);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_storageKey) ?? [];
    _blacklistedIds = ids.map((id) => int.parse(id)).toSet();
    _controller.add(_blacklistedIds);
  }

  bool isBlacklisted(int songId) => _blacklistedIds.contains(songId);

  void toggleBlacklist(int songId) {
    if (isBlacklisted(songId)) {
      removeFromBlacklist(songId);
    } else {
      addToBlacklist(songId);
    }
  }

  void addToBlacklist(int songId) {
    if (_blacklistedIds.contains(songId)) return;
    _blacklistedIds.add(songId);
    _persist();
    _controller.add(_blacklistedIds);
  }

  void removeFromBlacklist(int songId) {
    if (!_blacklistedIds.contains(songId)) return;
    _blacklistedIds.remove(songId);
    _persist();
    _controller.add(_blacklistedIds);
  }

  List<SongModel> filterBlacklisted(List<SongModel> songs) {
    return songs.where((s) => !_blacklistedIds.contains(s.id)).toList();
  }

  Future<void> clearBlacklist() async {
    _blacklistedIds.clear();
    _persist();
    _controller.add(_blacklistedIds);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _blacklistedIds.map((id) => id.toString()).toList();
    await prefs.setStringList(_storageKey, ids);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
