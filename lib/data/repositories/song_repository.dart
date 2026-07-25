import '../models/song_model.dart';
import '../../services/scanner/music_scanner_service.dart';
import '../../services/permission/permission_service.dart';

class SongRepository {
  SongRepository({
    MusicScannerService? scannerService,
    PermissionService? permissionService,
  })  : _scannerService = scannerService ?? MusicScannerService(),
        _permissionService = permissionService ?? PermissionService();

  final MusicScannerService _scannerService;
  final PermissionService _permissionService;

  List<SongModel> _cachedSongs = [];

  List<SongModel> get cachedSongs => List.unmodifiable(_cachedSongs);

  Future<List<SongModel>> loadSongs({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedSongs.isNotEmpty) {
      return _cachedSongs;
    }

    final hasPermission = await _permissionService.requestAudioPermission();
    if (!hasPermission) {
      throw SongsLoadException(
        'Permiso de almacenamiento no concedido',
      );
    }

    final songs = await _scannerService.scanForSongs();
    _cachedSongs = songs;
    return songs;
  }

  Future<bool> hasPermission() async {
    return _permissionService.isAudioPermissionGranted();
  }

  Future<void> openSettings() async {
    await _permissionService.openAppSettingsIfDenied();
  }
}

class SongsLoadException implements Exception {
  final String message;
  const SongsLoadException(this.message);

  @override
  String toString() => message;
}
