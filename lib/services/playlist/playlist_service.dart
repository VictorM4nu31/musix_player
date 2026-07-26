import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/playlist_model.dart';

class PlaylistService {
  static const _key = 'playlists';
  final _controller = StreamController<List<PlaylistModel>>.broadcast();
  List<PlaylistModel> _playlists = [];

  Stream<List<PlaylistModel>> get playlistsStream => _controller.stream;
  List<PlaylistModel> get playlists => List.unmodifiable(_playlists);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = jsonDecode(json) as List;
      _playlists = list.map((e) => PlaylistModel.fromMap(e)).toList();
    }
    _controller.add(_playlists);
  }

  PlaylistModel? getPlaylist(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> createPlaylist(String name, {String? description}) async {
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      songIds: [],
    );
    _playlists.add(playlist);
    await _save();
    _controller.add(_playlists);
  }

  Future<void> updatePlaylist(String id, {String? name, String? description}) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return;

    _playlists[index] = _playlists[index].copyWith(
      name: name,
      description: description,
    );
    await _save();
    _controller.add(_playlists);
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _save();
    _controller.add(_playlists);
  }

  Future<void> addSongToPlaylist(String playlistId, int songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    if (!_playlists[index].songIds.contains(songId)) {
      _playlists[index] = _playlists[index].copyWith(
        songIds: [..._playlists[index].songIds, songId],
      );
      await _save();
      _controller.add(_playlists);
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, int songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final newSongIds = List<int>.from(_playlists[index].songIds)
      ..remove(songId);
    _playlists[index] = _playlists[index].copyWith(songIds: newSongIds);
    await _save();
    _controller.add(_playlists);
  }

  Future<void> reorderPlaylistSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final songIds = List<int>.from(_playlists[index].songIds);
    if (oldIndex < 0 || oldIndex >= songIds.length) return;
    if (newIndex < 0 || newIndex >= songIds.length) return;

    final songId = songIds.removeAt(oldIndex);
    songIds.insert(newIndex, songId);
    _playlists[index] = _playlists[index].copyWith(songIds: songIds);
    await _save();
    _controller.add(_playlists);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_playlists.map((p) => p.toMap()).toList());
    await prefs.setString(_key, json);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
