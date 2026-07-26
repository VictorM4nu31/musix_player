import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
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
      song: SongModel.fromMap(
        Map<String, dynamic>.from(map['song'] as Map),
      ),
      playedAt: DateTime.parse(map['playedAt'] as String),
    );
  }
}

class HistoryService {
  static const _key = 'playback_history';
  final _controller = StreamController<List<HistoryEntry>>.broadcast();
  List<HistoryEntry> _entries = [];

  /// Tracks last recorded play per song for dedupe window.
  final Map<int, DateTime> _lastRecordedAt = {};

  Stream<List<HistoryEntry>> get historyStream => _controller.stream;
  List<HistoryEntry> get entries => List.unmodifiable(_entries);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _entries = list
            .map((e) => HistoryEntry.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        for (final entry in _entries) {
          _lastRecordedAt[entry.song.id] = entry.playedAt;
        }
      } catch (_) {
        _entries = [];
      }
    }
    _controller.add(_entries);
  }

  /// Records a play if outside the dedupe window for the same song.
  Future<void> addEntry(SongModel song) async {
    final now = DateTime.now();
    final last = _lastRecordedAt[song.id];
    if (last != null &&
        now.difference(last) < AppConstants.historyDedupeWindow) {
      return;
    }

    _lastRecordedAt[song.id] = now;
    _entries.insert(0, HistoryEntry(song: song, playedAt: now));

    if (_entries.length > AppConstants.maxHistoryEntries) {
      _entries = _entries.sublist(0, AppConstants.maxHistoryEntries);
    }

    await _save();
    _controller.add(_entries);
  }

  Future<void> clearHistory() async {
    _entries.clear();
    _lastRecordedAt.clear();
    await _save();
    _controller.add(_entries);
  }

  Future<void> removeEntry(int songId) async {
    _entries.removeWhere((e) => e.song.id == songId);
    _lastRecordedAt.remove(songId);
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
