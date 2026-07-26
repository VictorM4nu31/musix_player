import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/artwork_image.dart';
import '../../data/models/song_model.dart';
import '../../providers/songs_provider.dart';
import '../../services/scanner/music_scanner_service.dart';

class SongEditScreen extends ConsumerStatefulWidget {
  const SongEditScreen({super.key, required this.songId});

  final int songId;

  @override
  ConsumerState<SongEditScreen> createState() => _SongEditScreenState();
}

class _SongEditScreenState extends ConsumerState<SongEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;
  late TextEditingController _genreController;
  late TextEditingController _yearController;
  late TextEditingController _trackController;
  bool _isSaving = false;
  SongModel? _song;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _artistController = TextEditingController();
    _albumController = TextEditingController();
    _genreController = TextEditingController();
    _yearController = TextEditingController();
    _trackController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _trackController.dispose();
    super.dispose();
  }

  void _loadSong(List<SongModel> songs) {
    if (_song != null) return;
    final song = songs.where((s) => s.id == widget.songId).firstOrNull;
    if (song != null) {
      _song = song;
      _titleController.text = song.title;
      _artistController.text = song.artist;
      _albumController.text = song.album;
      _genreController.text = song.genre ?? '';
      _yearController.text = song.year > 0 ? song.year.toString() : '';
      _trackController.text = song.track > 0 ? song.track.toString() : '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_song == null) return;

    setState(() => _isSaving = true);

    try {
      final scanner = MusicScannerService();
      final success = await scanner.updateSongMetadata(
        songId: widget.songId,
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        album: _albumController.text.trim(),
        year: int.tryParse(_yearController.text.trim()),
        track: int.tryParse(_trackController.text.trim()),
      );

      if (!mounted) return;

      if (success) {
        ref.read(songsProvider.notifier).loadSongs(forceRefresh: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Metadatos actualizados')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar los metadatos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final songsAsync = ref.watch(songsProvider);

    return songsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Editar información')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Editar información')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (songs) {
        _loadSong(songs);
        if (_song == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Editar información')),
            body: const Center(child: Text('Canción no encontrada')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Editar información'),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ArtworkImage(
                    imageUri: _song!.artworkUri,
                    albumId: _song!.albumId,
                    size: 160,
                    borderRadius: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'La portada no se puede modificar desde esta app',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                _buildField('Título', _titleController, theme),
                const SizedBox(height: 14),
                _buildField('Artista', _artistController, theme),
                const SizedBox(height: 14),
                _buildField('Álbum', _albumController, theme),
                const SizedBox(height: 14),
                _buildField('Género', _genreController, theme),
                const SizedBox(height: 14),
                _buildField('Año', _yearController, theme,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                _buildField('Número de pista', _trackController, theme,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 32),
                Text(
                  'Nota: Solo los metadatos de texto pueden editarse. '
                  'La portada del álbum no es modificable desde el dispositivo.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    ThemeData theme, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: theme.textTheme.bodyLarge,
      validator: label == 'Título'
          ? (v) => v == null || v.trim().isEmpty
              ? 'El título no puede estar vacío'
              : null
          : null,
    );
  }
}
