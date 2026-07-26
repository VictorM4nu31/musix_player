import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/utils/page_transitions.dart';
import '../screens/library/library_screen.dart';
import '../screens/playlists/playlists_screen.dart';
import '../screens/playlists/playlist_detail_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/song_detail/song_detail_screen.dart';
import '../screens/song_edit/song_edit_screen.dart';
import '../screens/mini_player/mini_player_widget.dart';
import '../screens/player/player_screen.dart';
import '../screens/queue/queue_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/library',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: LibraryScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/playlists',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PlaylistsScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: FavoritesScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/player',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideFromBottom(
        child: const PlayerScreen(),
      ),
    ),
    GoRoute(
      path: '/queue',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideFromBottom(
        child: const QueueScreen(),
      ),
    ),
    GoRoute(
      path: '/playlists/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final playlistId = state.pathParameters['id']!;
        return PageTransitions.slideFromRight(
          child: PlaylistDetailScreen(playlistId: playlistId),
        );
      },
    ),
    GoRoute(
      path: '/history',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => PageTransitions.slideFromRight(
        child: const HistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/songs/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final songId = int.parse(state.pathParameters['id']!);
        return PageTransitions.slideFromRight(
          child: SongDetailScreen(songId: songId),
        );
      },
    ),
    GoRoute(
      path: '/songs/:id/edit',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final songId = int.parse(state.pathParameters['id']!);
        return PageTransitions.slideFromRight(
          child: SongEditScreen(songId: songId),
        );
      },
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  int get _currentIndex => navigationShell.currentIndex;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: navigationShell,
          ),
          const MiniPlayerWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_rounded),
            activeIcon: Icon(Icons.library_music_rounded),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue_music_rounded),
            activeIcon: Icon(Icons.queue_music_rounded),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
