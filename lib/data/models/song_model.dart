class SongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String filePath;
  final String? contentUri;
  final int albumId;
  final int size;
  final int year;
  final int track;
  final String? genre;
  final String? artworkUri;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    this.contentUri,
    required this.albumId,
    required this.size,
    required this.year,
    required this.track,
    this.genre,
    this.artworkUri,
  });

  /// Preferred URI for playback (content:// first, then file path).
  Uri get playbackUri {
    final content = contentUri?.trim();
    if (content != null && content.isNotEmpty) {
      return Uri.parse(content);
    }
    if (filePath.isNotEmpty) {
      return Uri.file(filePath);
    }
    throw StateError('Song $id has no playable URI');
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: (map['id'] as num).toInt(),
      title: map['title'] as String? ?? 'Desconocido',
      artist: map['artist'] as String? ?? 'Desconocido',
      album: map['album'] as String? ?? 'Desconocido',
      duration: Duration(milliseconds: (map['duration'] as num?)?.toInt() ?? 0),
      filePath: map['filePath'] as String? ?? '',
      contentUri: map['contentUri'] as String?,
      albumId: (map['albumId'] as num?)?.toInt() ?? 0,
      size: (map['size'] as num?)?.toInt() ?? 0,
      year: (map['year'] as num?)?.toInt() ?? 0,
      track: (map['track'] as num?)?.toInt() ?? 0,
      genre: map['genre'] as String?,
      artworkUri: map['artworkUri'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration.inMilliseconds,
      'filePath': filePath,
      'contentUri': contentUri,
      'albumId': albumId,
      'size': size,
      'year': year,
      'track': track,
      'genre': genre,
      'artworkUri': artworkUri,
    };
  }

  SongModel copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? filePath,
    String? contentUri,
    int? albumId,
    int? size,
    int? year,
    int? track,
    String? genre,
    String? artworkUri,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      contentUri: contentUri ?? this.contentUri,
      albumId: albumId ?? this.albumId,
      size: size ?? this.size,
      year: year ?? this.year,
      track: track ?? this.track,
      genre: genre ?? this.genre,
      artworkUri: artworkUri ?? this.artworkUri,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SongModel(id: $id, title: $title, artist: $artist)';
}
