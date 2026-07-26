import '../services/audio/audio_player_service.dart';
import '../services/audio/audio_handler.dart';
import '../services/blacklist/blacklist_service.dart';
import '../services/favorites/favorites_service.dart';
import '../services/history/history_service.dart';
import '../services/playlist/playlist_service.dart';
import '../services/settings/settings_service.dart';
import '../services/widget/home_widget_service.dart';

late AudioPlayerService audioService;
late MusixAudioHandler audioHandler;
late HistoryService historyService;
late SettingsService settingsService;
late BlacklistService blacklistService;
late FavoritesService favoritesService;
late PlaylistService playlistService;
HomeWidgetService? homeWidgetService;
