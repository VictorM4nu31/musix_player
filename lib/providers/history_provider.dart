import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song_model.dart';
import '../services/history/history_service.dart';
import '../main.dart' as main_app;

final historyServiceProvider = Provider<HistoryService>((ref) {
  return main_app.historyService;
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
