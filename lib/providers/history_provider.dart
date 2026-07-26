import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import '../services/history/history_service.dart';
import '../core/service_locator.dart' as locator;
import 'songs_provider.dart';

final historyServiceProvider = Provider<HistoryService>((ref) {
  return locator.historyService;
});

final historyProvider = StreamProvider<List<HistoryEntry>>((ref) {
  final service = ref.watch(historyServiceProvider);
  return _seededHistoryStream(service.entries, service.historyStream);
});

/// Emits the current value immediately, then forwards all stream events.
Stream<List<HistoryEntry>> _seededHistoryStream(
  List<HistoryEntry> currentValue,
  Stream<List<HistoryEntry>> stream,
) async* {
  yield currentValue;
  yield* stream;
}

final recentSongsProvider = Provider<List<SongModel>>((ref) {
  final historyAsync = ref.watch(historyProvider);
  final songsAsync = ref.watch(songsProvider);
  final songs = songsAsync.valueOrNull ?? [];

  return historyAsync.when(
    data: (entries) {
      return entries.map((e) {
        final current = songs.where((s) => s.id == e.song.id).firstOrNull;
        return current ?? e.song;
      }).toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
});
