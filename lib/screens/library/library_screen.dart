import 'package:flutter/material.dart';
import '../../core/widgets/empty_state.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyState(
        icon: Icons.library_music_rounded,
        title: 'Tu biblioteca',
        subtitle: 'Las canciones de tu dispositivo aparecerán aquí',
      ),
    );
  }
}
