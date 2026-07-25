import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildSection(
            theme,
            title: 'Apariencia',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                title: 'Tema',
                subtitle: 'Claro',
                onTap: () {
                  // TODO: Theme selection
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            theme,
            title: 'Reproducción',
            children: [
              _SettingsTile(
                icon: Icons.sort_rounded,
                title: 'Orden predeterminado',
                subtitle: 'Por título',
                onTap: () {
                  // TODO: Default sort order
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            theme,
            title: 'Datos',
            children: [
              _SettingsTile(
                icon: Icons.history_rounded,
                title: 'Limpiar historial',
                subtitle: 'Eliminar todo el historial de reproducción',
                onTap: () {
                  // TODO: Clear history
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            theme,
            title: 'Acerca de',
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Musix Player',
                subtitle: 'Versión 1.0.0',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: theme.dividerColor,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
