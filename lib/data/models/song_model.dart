class SongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String filePath;
  final int albumId;
  final int size;
  final int year;
  final int track;
  final String? artworkUri;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    required this.albumId,
    required this.size,
    required this.year,
    required this.track,
    this.artworkUri,
  });

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] as int,
      title: map['title'] as String? ?? 'Desconocido',
      artist: map['artist'] as String? ?? 'Desconocido',
      album: map['album'] as String? ?? 'Desconocido',
      duration: Duration(milliseconds: (map['duration'] as int?) ?? 0),
      filePath: map['filePath'] as String? ?? '',
      albumId: (map['albumId'] as num?)?.toInt() ?? 0,
      size: (map['size'] as num?)?.toInt() ?? 0,
      year: (map['year'] as num?)?.toInt() ?? 0,
      track: (map['track'] as num?)?.toInt() ?? 0,
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
      'albumId': albumId,
      'size': size,
      'year': year,
      'track': track,
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
    int? albumId,
    int? size,
    int? year,
    int? track,
    String? artworkUri,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      albumId: albumId ?? this.albumId,
      size: size ?? this.size,
      year: year ?? this.year,
      track: track ?? this.track,
      artworkUri: artworkUri ?? this.artworkUri,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SongModel(id: $id, title: $title, artist: $artist)';
}
