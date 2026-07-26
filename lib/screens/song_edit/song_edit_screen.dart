import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/service_locator.dart';
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
    _yearController = TextEditingController();
    _trackController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _yearController.dispose();
    _trackController.dispose();
    super.dispose();
  }

  void _loadSong(WidgetRef ref, List<SongModel> songs) {
    if (_song != null) return;
    SongModel? song = songs.where((s) => s.id == widget.songId).firstOrNull;
    song ??= ref
        .read(songRepositoryProvider)
        .cachedSongs
        .where((s) => s.id == widget.songId)
        .firstOrNull;
    if (song != null) {
      _song = song;
      _titleController.text = song.title;
      _artistController.text = song.artist;
      _albumController.text = song.album;
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

        if (audioService.currentSong?.id == widget.songId) {
          final updatedSong = _song!.copyWith(
            title: _titleController.text.trim(),
            artist: _artistController.text.trim(),
            album: _albumController.text.trim(),
            year: int.tryParse(_yearController.text.trim()) ?? 0,
            track: int.tryParse(_trackController.text.trim()) ?? 0,
          );
          audioHandler.mediaItem.add(audioHandler.mediaItem.value?.copyWith(
            title: updatedSong.title,
            artist: updatedSong.artist,
            album: updatedSong.album,
          ));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Metadatos actualizados en la biblioteca del sistema',
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudieron guardar. En algunos dispositivos solo se puede editar la base MediaStore, no las etiquetas del archivo.',
            ),
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
        _loadSong(ref, songs);
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Los cambios se aplican a la biblioteca del sistema (MediaStore), no necesariamente a las etiquetas ID3 del archivo. La portada no es editable aquí.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildField('Título', _titleController, theme),
                const SizedBox(height: 14),
                _buildField('Artista', _artistController, theme),
                const SizedBox(height: 14),
                _buildField('Álbum', _albumController, theme),
                const SizedBox(height: 14),
                _buildField(
                  'Año',
                  _yearController,
                  theme,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                _buildField(
                  'Número de pista',
                  _trackController,
                  theme,
                  keyboardType: TextInputType.number,
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
