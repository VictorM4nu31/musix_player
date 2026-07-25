class PlaylistModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final List<int> songIds;

  const PlaylistModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.songIds,
  });

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    List<int>? songIds,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      songIds: songIds ?? this.songIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'songIds': songIds,
    };
  }

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    return PlaylistModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      songIds: List<int>.from(map['songIds'] as List),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PlaylistModel(id: $id, name: $name)';
}
