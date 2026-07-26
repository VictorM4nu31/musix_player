import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/song_repository.dart';

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository();
});
