import 'package:flutter_test/flutter_test.dart';
import 'package:musix_player/services/playlist/playlist_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('create, add song, reorder and delete playlist', () async {
    final service = PlaylistService();
    await service.init();

    await service.createPlaylist('Rock', description: 'Best');
    expect(service.playlists, hasLength(1));
    expect(service.playlists.first.name, 'Rock');

    final id = service.playlists.first.id;
    await service.addSongToPlaylist(id, 10);
    await service.addSongToPlaylist(id, 20);
    await service.addSongToPlaylist(id, 10); // duplicate ignored
    expect(service.getPlaylist(id)!.songIds, [10, 20]);

    await service.reorderPlaylistSongs(id, 0, 1);
    expect(service.getPlaylist(id)!.songIds, [20, 10]);

    await service.removeSongFromPlaylist(id, 20);
    expect(service.getPlaylist(id)!.songIds, [10]);

    await service.deletePlaylist(id);
    expect(service.playlists, isEmpty);

    await service.dispose();
  });
}
