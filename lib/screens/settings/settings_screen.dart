import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/service_locator.dart';
import '../../services/settings/settings_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(currentThemeModeProvider);
    final sortPreference = ref.watch(sortPreferenceProvider);

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
                subtitle: _getThemeName(themeMode),
                onTap: () => _showThemeDialog(context, ref, themeMode),
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
                subtitle: _getSortName(sortPreference),
                onTap: () => _showSortDialog(context, ref, sortPreference),
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
                onTap: () => _showClearHistoryDialog(context, ref),
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

  String _getThemeName(ThemeMode mode) {
    final pref = settingsService.themePreference;
    if (pref == ThemePreference.pixelArt) return 'Pixel Art';
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  String _getSortName(SortPreference sort) {
    switch (sort) {
      case SortPreference.title:
        return 'Por título';
      case SortPreference.artist:
        return 'Por artista';
      case SortPreference.album:
        return 'Por álbum';
      case SortPreference.duration:
        return 'Por duración';
      case SortPreference.dateAdded:
        return 'Por fecha';
    }
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    final currentPref = settingsService.themePreference;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Seleccionar tema',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ThemePreviewCard(
                        icon: Icons.brightness_auto_rounded,
                        label: 'Sistema',
                        isSelected: currentPref == ThemePreference.system,
                        colors: const [
                          Color(0xFF5C6BC0),
                          Color(0xFFFFFFFF),
                          Color(0xFF1A1B4B),
                        ],
                        onTap: () {
                          settingsService.setThemePreference(ThemePreference.system);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ThemePreviewCard(
                        icon: Icons.light_mode_rounded,
                        label: 'Claro',
                        isSelected: currentPref == ThemePreference.light,
                        colors: const [
                          Color(0xFF5C6BC0),
                          Color(0xFFF5F6FA),
                          Color(0xFF1A1B4B),
                        ],
                        onTap: () {
                          settingsService.setThemePreference(ThemePreference.light);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ThemePreviewCard(
                        icon: Icons.dark_mode_rounded,
                        label: 'Oscuro',
                        isSelected: currentPref == ThemePreference.dark,
                        colors: const [
                          Color(0xFF9FA8DA),
                          Color(0xFF161726),
                          Color(0xFFE8E9F3),
                        ],
                        onTap: () {
                          settingsService.setThemePreference(ThemePreference.dark);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ThemePreviewCard(
                        icon: Icons.videogame_asset_rounded,
                        label: 'Pixel Art',
                        isSelected: currentPref == ThemePreference.pixelArt,
                        colors: const [
                          Color(0xFF00FF41),
                          Color(0xFF0D1117),
                          Color(0xFFE6EDF3),
                        ],
                        onTap: () {
                          settingsService.setThemePreference(ThemePreference.pixelArt);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortDialog(
    BuildContext context,
    WidgetRef ref,
    SortPreference currentSort,
  ) {
    final settingsService = ref.read(settingsServiceProvider);

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Orden predeterminado'),
        children: SortPreference.values.map((sort) {
          return _SortOption(
            title: _getSortName(sort),
            isSelected: currentSort == sort,
            onTap: () {
              settingsService.setSortPreference(sort);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todo el historial de reproducción?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(historyServiceProvider).clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial eliminado')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
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

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
            ),
            const SizedBox(height: 8),
            Container(
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.primary
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              )
            else
              const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SimpleDialogOption(
      onPressed: onTap,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.primary : null,
              fontWeight: isSelected ? FontWeight.w600 : null,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(
              Icons.check_rounded,
              color: theme.colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}
