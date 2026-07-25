import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import '../services/history/history_service.dart';
import '../core/service_locator.dart' as locator;

final historyServiceProvider = Provider<HistoryService>((ref) {
  return locator.historyService;
});

final historyProvider = StreamProvider<List<HistoryEntry>>((ref) {
  final service = ref.watch(historyServiceProvider);
  return service.historyStream;
});

final recentSongsProvider = Provider<List<SongModel>>((ref) {
  final historyAsync = ref.watch(historyProvider);
  return historyAsync.when(
    data: (entries) => entries.map((e) => e.song).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});
