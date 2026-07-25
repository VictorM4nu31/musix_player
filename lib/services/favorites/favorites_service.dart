import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_song_ids';
  final _controller = StreamController<Set<int>>.broadcast();
  Set<int> _favoriteIds = {};

  Stream<Set<int>> get favoritesStream => _controller.stream;
  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    _favoriteIds = ids.map(int.parse).toSet();
    _controller.add(_favoriteIds);
  }

  bool isFavorite(int songId) => _favoriteIds.contains(songId);

  Future<void> toggleFavorite(int songId) async {
    if (_favoriteIds.contains(songId)) {
      _favoriteIds.remove(songId);
    } else {
      _favoriteIds.add(songId);
    }
    await _save();
    _controller.add(_favoriteIds);
  }

  Future<void> addFavorite(int songId) async {
    if (!_favoriteIds.contains(songId)) {
      _favoriteIds.add(songId);
      await _save();
      _controller.add(_favoriteIds);
    }
  }

  Future<void> removeFavorite(int songId) async {
    if (_favoriteIds.contains(songId)) {
      _favoriteIds.remove(songId);
      await _save();
      _controller.add(_favoriteIds);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _favoriteIds.map((id) => id.toString()).toList(),
    );
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
