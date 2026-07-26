import 'package:flutter_test/flutter_test.dart';
import 'package:musix_player/data/models/song_model.dart';
import 'package:musix_player/services/history/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

SongModel _song(int id) => SongModel(
      id: id,
      title: 'T$id',
      artist: 'A',
      album: 'Al',
      duration: const Duration(seconds: 30),
      filePath: '/x/$id.mp3',
      albumId: 1,
      size: 1,
      year: 0,
      track: 0,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('dedupes rapid repeats of the same song', () async {
    final service = HistoryService();
    await service.init();

    await service.addEntry(_song(1));
    await service.addEntry(_song(1));
    expect(service.entries, hasLength(1));

    await service.addEntry(_song(2));
    expect(service.entries, hasLength(2));
    expect(service.entries.first.song.id, 2);

    await service.dispose();
  });
}
