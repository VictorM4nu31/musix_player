import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme_catalog.dart';
import '../../app/theme/theme_tokens.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../providers/blacklist_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/songs_provider.dart';
import '../../services/settings/settings_service.dart';
import '../../visual/models/animation_preset.dart';
import '../../visual/models/progress_style.dart';
import '../../visual/models/visual_quality.dart';
import '../../visual/models/visualizer_type.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themePref =
        ref.watch(themePreferenceProvider).valueOrNull ?? ThemePreference.system;
    final sortPreference =
        ref.watch(sortPreferenceProvider).valueOrNull ?? SortPreference.title;
    final visual = ref.watch(visualSettingsProvider);

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
                subtitle: _getThemeName(themePref),
                onTap: () => _showThemeDialog(context, ref, themePref),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            theme,
            title: 'Visualización',
            children: [
              _SettingsTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Preset',
                subtitle: visual.preset.displayName,
                onTap: () => _showPresetDialog(context, ref, visual.preset),
              ),
              _SettingsTile(
                icon: Icons.animation_rounded,
                title: 'Visualizador',
                subtitle: visual.visualizerType.displayName,
                onTap: () =>
                    _showVisualizerDialog(context, ref, visual.visualizerType),
              ),
              _SettingsTile(
                icon: Icons.high_quality_rounded,
                title: 'Calidad visual',
                subtitle: visual.quality.displayName,
                onTap: () => _showQualityDialog(context, ref, visual.quality),
              ),
              _SettingsTile(
                icon: Icons.graphic_eq_outlined,
                title: 'Barra de progreso',
                subtitle: visual.progressStyle.displayName,
                onTap: () =>
                    _showProgressStyleDialog(context, ref, visual.progressStyle),
              ),
              SwitchListTile(
                secondary: Icon(
                  Icons.motion_photos_on_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Animaciones'),
                subtitle: const Text('Activar efectos del reproductor'),
                value: visual.animationsEnabled,
                onChanged: (v) {
                  ref.read(settingsServiceProvider).setAnimationsEnabled(v);
                },
              ),
              SwitchListTile(
                secondary: Icon(
                  Icons.graphic_eq_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Reacción al audio'),
                subtitle: const Text('Movimiento pseudo-rítmico (sin FFT)'),
                value: visual.audioReactive,
                onChanged: visual.animationsEnabled
                    ? (v) {
                        ref.read(settingsServiceProvider).setAudioReactive(v);
                      }
                    : null,
              ),
              _IntensityTile(
                value: visual.intensity,
                enabled: visual.animationsEnabled,
                onCommit: (v) {
                  ref.read(settingsServiceProvider).setVisualIntensity(v);
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
                subtitle: _getSortName(sortPreference),
                onTap: () => _showSortDialog(context, ref, sortPreference),
              ),
              _SettingsTile(
                icon: Icons.block_rounded,
                title: 'Lista negra',
                subtitle: _getBlacklistCount(ref),
                onTap: () => context.push('/blacklist'),
              ),
              _SettingsTile(
                icon: Icons.history_rounded,
                title: 'Historial',
                subtitle: 'Canciones reproducidas recientemente',
                onTap: () => context.push('/history'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            theme,
            title: 'Datos',
            children: [
              _SettingsTile(
                icon: Icons.delete_sweep_rounded,
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
                title: AppConstants.appName,
                subtitle: 'Versión ${AppConstants.appVersion}',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeName(ThemeId pref) => pref.displayName;

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
    }
  }

  String _getBlacklistCount(WidgetRef ref) {
    final blacklistIds = ref.watch(blacklistIdsProvider);
    final count = blacklistIds.valueOrNull?.length ?? 0;
    if (count == 0) return 'Sin canciones bloqueadas';
    return '$count canciones bloqueadas';
  }

  void _showVisualizerDialog(
    BuildContext context,
    WidgetRef ref,
    VisualizerType current,
  ) {
    final settings = ref.read(settingsServiceProvider);

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Visualizador'),
        children: VisualizerType.values.map((type) {
          return _SortOption(
            title: type.displayName,
            isSelected: current == type,
            onTap: () {
              settings.setVisualizerType(type);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showPresetDialog(
    BuildContext context,
    WidgetRef ref,
    AnimationPreset current,
  ) {
    final settings = ref.read(settingsServiceProvider);

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Preset visual'),
        children: AnimationPreset.values.map((preset) {
          return _SortOption(
            title: preset.displayName,
            isSelected: current == preset,
            onTap: () {
              settings.applyAnimationPreset(preset);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showQualityDialog(
    BuildContext context,
    WidgetRef ref,
    VisualQuality current,
  ) {
    final settings = ref.read(settingsServiceProvider);

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Calidad visual'),
        children: VisualQuality.values.map((quality) {
          return _SortOption(
            title: quality.displayName,
            isSelected: current == quality,
            onTap: () {
              settings.setVisualQuality(quality);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showProgressStyleDialog(
    BuildContext context,
    WidgetRef ref,
    ProgressStyle current,
  ) {
    final settings = ref.read(settingsServiceProvider);

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Barra de progreso'),
        children: ProgressStyle.values.map((style) {
          return _SortOption(
            title: style.displayName,
            isSelected: current == style,
            onTap: () {
              settings.setProgressStyle(style);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeId currentPref,
  ) {
    final settings = ref.read(settingsServiceProvider);
    final ids = ThemeCatalog.selectableIds;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final tokens = theme.extension<MusixThemeTokens>();
        final sheetRadius = tokens?.radiusLg ?? 20;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: BottomSheetDragHandle()),
                    const SizedBox(height: 16),
                    Text('Experiencia visual', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Cada tema cambia colores, tipografía y estilo de controles.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        itemCount: ids.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.92,
                        ),
                        itemBuilder: (context, index) {
                          final id = ids[index];
                          return _ThemeExperienceCard(
                            id: id,
                            isSelected: currentPref == id,
                            borderRadius: sheetRadius,
                            onTap: () {
                              settings.setThemePreference(id);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSortDialog(
    BuildContext context,
    WidgetRef ref,
    SortPreference currentSort,
  ) {
    final settings = ref.read(settingsServiceProvider);

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Orden predeterminado'),
        children: SortPreference.values.map((sort) {
          return _SortOption(
            title: _getSortName(sort),
            isSelected: currentSort == sort,
            onTap: () {
              settings.setSortPreference(sort);
              ref.read(songsProvider.notifier).setSortOption(
                    sortOptionFromPreference(sort),
                  );
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

  Widget _buildSection(
    ThemeData theme, {
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

    final radius = context.musixThemeOrNull?.radiusMd ?? 16;
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _IntensityTile extends StatefulWidget {
  const _IntensityTile({
    required this.value,
    required this.enabled,
    required this.onCommit,
  });

  final double value;
  final bool enabled;
  final ValueChanged<double> onCommit;

  @override
  State<_IntensityTile> createState() => _IntensityTileState();
}

class _IntensityTileState extends State<_IntensityTile> {
  late double _local;

  @override
  void initState() {
    super.initState();
    _local = widget.value;
  }

  @override
  void didUpdateWidget(covariant _IntensityTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _local = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
      title: const Text('Intensidad'),
      subtitle: Slider(
        value: _local,
        onChanged: widget.enabled
            ? (v) => setState(() => _local = v)
            : null,
        onChangeEnd: widget.enabled ? widget.onCommit : null,
      ),
    );
  }
}

class _ThemeExperienceCard extends StatelessWidget {
  const _ThemeExperienceCard({
    required this.id,
    required this.isSelected,
    required this.onTap,
    this.borderRadius = 16,
  });

  final ThemeId id;
  final bool isSelected;
  final VoidCallback onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final hostTheme = Theme.of(context);
    final colors = ThemeCatalog.previewColors(id);
    final primary = colors[0];
    final background = colors.length > 1 ? colors[1] : hostTheme.scaffoldBackgroundColor;
    final onBg = colors.length > 2 ? colors[2] : hostTheme.colorScheme.onSurface;
    final radius = id == ThemeId.pixelArt
        ? 2.0
        : id == ThemeId.cyberpunk
            ? 8.0
            : id == ThemeId.minimal
                ? 8.0
                : 14.0;
    final titleFamily = switch (id) {
      ThemeId.pixelArt => 'PressStart2P',
      ThemeId.cyberpunk => 'Orbitron',
      _ => null,
    };
    final bodyFamily = switch (id) {
      ThemeId.pixelArt || ThemeId.cyberpunk => 'ShareTechMono',
      _ => null,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: hostTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isSelected
                  ? hostTheme.colorScheme.primary
                  : hostTheme.dividerColor,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: hostTheme.colorScheme.primary.withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: background,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(ThemeCatalog.iconOf(id), size: 16, color: primary),
                          const Spacer(),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded,
                                size: 16, color: primary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        id.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primary,
                          fontSize: titleFamily == 'PressStart2P' ? 8 : 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: titleFamily,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Aa Bb 123',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: onBg.withAlpha(200),
                          fontSize: 11,
                          fontFamily: bodyFamily,
                        ),
                      ),
                      const Spacer(),
                      // Mini-player mock
                      Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: primary.withAlpha(28),
                          borderRadius: BorderRadius.circular(radius),
                          border: id == ThemeId.pixelArt || id == ThemeId.cyberpunk
                              ? Border.all(color: primary.withAlpha(160), width: 1.2)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: primary.withAlpha(90),
                                borderRadius: BorderRadius.circular(
                                  id == ThemeId.pixelArt ? 2 : 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: onBg.withAlpha(90),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.play_arrow_rounded, size: 18, color: primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                ),
              ),
            ],
          ),
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
            Icon(Icons.check_rounded, color: theme.colorScheme.primary),
          ],
        ],
      ),
    );
  }
}
