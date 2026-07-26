import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/seeded_stream.dart';
import '../data/models/song_model.dart';
import '../services/history/history_service.dart';
import '../core/service_locator.dart' as locator;
import 'repository_providers.dart';

final historyServiceProvider = Provider<HistoryService>((ref) {
  return locator.historyService;
});

final historyProvider = StreamProvider<List<HistoryEntry>>((ref) {
  final service = ref.watch(historyServiceProvider);
  return seededStream(service.entries, service.historyStream);
});

final recentSongsProvider = Provider<List<SongModel>>((ref) {
  final historyAsync = ref.watch(historyProvider);
  final repo = ref.watch(songRepositoryProvider);
  final songs = repo.cachedSongs;

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
