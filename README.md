# Musix Player

Reproductor de música local para Android. Escanea la biblioteca del dispositivo (MediaStore), reproduce en segundo plano y organiza playlists, favoritos, historial y lista negra.

## Características

- Biblioteca local con búsqueda y ordenación
- Reproducción con notificación y controles de media
- Mini player + pantalla completa (temas claro/oscuro/pixel art)
- Cola con reordenar y gestos
- Playlists, favoritos, historial (con umbral de reproducción) y blacklist
- Edición de metadatos vía MediaStore (no ID3 del archivo)

## Stack

- Flutter + Riverpod + go_router
- just_audio + audio_service
- MethodChannel Kotlin → MediaStore
- SharedPreferences (playlists, favoritos, settings, historial)

## Requisitos

- Flutter SDK (ver `pubspec.yaml`)
- Android 8+ recomendado (permisos audio Android 13+)

## Ejecutar

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
flutter analyze
```

## Arquitectura (resumen)

```
UI (screens/widgets)
  → Riverpod providers
  → Services (audio, playlist, favorites, …)
  → SongRepository → MusicScanner (MethodChannel)
  → MainActivity MediaStore
```

La reproducción usa preferentemente `content://` URIs; el path de archivo es fallback.

## Limitaciones conocidas

- Solo Android (no iOS)
- Metadata edit actualiza MediaStore, no necesariamente tags del archivo
- Género no se edita (MediaStore limitado en el canal actual)
- Persistencia de playlists en SharedPreferences (adecuado a escala personal)

## Licencia

Proyecto personal / portafolio. `publish_to: none`.
