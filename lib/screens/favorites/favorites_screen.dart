import 'package:flutter/material.dart';
import '../../core/widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Sin favoritos',
        subtitle:
            'Marca tus canciones favoritas y aparecerán aquí',
      ),
    );
  }
}
