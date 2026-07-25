import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/song_model.dart';

class HistoryEntry {
  final SongModel song;
  final DateTime playedAt;

  const HistoryEntry({
    required this.song,
    required this.playedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'song': song.toMap(),
      'playedAt': playedAt.toIso8601String(),
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      song: SongModel.fromMap(map['song']),
      playedAt: DateTime.parse(map['playedAt'] as String),
    );
  }
}

class HistoryService {
  static const _key = 'playback_history';
  static const _maxEntries = 100;
  final _controller = StreamController<List<HistoryEntry>>.broadcast();
  List<HistoryEntry> _entries = [];

  Stream<List<HistoryEntry>> get historyStream => _controller.stream;
  List<HistoryEntry> get entries => List.unmodifiable(_entries);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = jsonDecode(json) as List;
      _entries = list.map((e) => HistoryEntry.fromMap(e)).toList();
    }
    _controller.add(_entries);
  }

  Future<void> addEntry(SongModel song) async {
    _entries.insert(0, HistoryEntry(song: song, playedAt: DateTime.now()));

    if (_entries.length > _maxEntries) {
      _entries = _entries.sublist(0, _maxEntries);
    }

    await _save();
    _controller.add(_entries);
  }

  Future<void> clearHistory() async {
    _entries.clear();
    await _save();
    _controller.add(_entries);
  }

  Future<void> removeEntry(int songId) async {
    _entries.removeWhere((e) => e.song.id == songId);
    await _save();
    _controller.add(_entries);
  }

  List<HistoryEntry> getRecentSongs({int limit = 20}) {
    return _entries.take(limit).toList();
  }

  bool hasPlayed(int songId) {
    return _entries.any((e) => e.song.id == songId);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_entries.map((e) => e.toMap()).toList());
    await prefs.setString(_key, json);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
