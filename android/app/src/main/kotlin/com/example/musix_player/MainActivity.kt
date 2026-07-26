package com.example.musix_player

import android.content.ContentUris
import android.content.ContentValues
import android.database.Cursor
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceFragmentActivity

class MainActivity : AudioServiceFragmentActivity() {

    private val CHANNEL = "com.musix_player/music_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAllSongs" -> {
                    result.success(getAllSongs())
                }
                "getSongArtwork" -> {
                    val albumId = call.argument<Long>("albumId")
                    if (albumId != null && albumId > 0) {
                        result.success(getArtworkUri(albumId))
                    } else {
                        result.success(null)
                    }
                }
                "getArtworkBytes" -> {
                    val albumId = call.argument<Long>("albumId")
                    if (albumId != null && albumId > 0) {
                        val bytes = getArtworkBytes(albumId)
                        result.success(bytes)
                    } else {
                        result.success(null)
                    }
                }
                "updateSongMetadata" -> {
                    val songId = call.argument<Long>("songId")
                    val title = call.argument<String>("title")
                    val artist = call.argument<String>("artist")
                    val album = call.argument<String>("album")
                    val year = call.argument<Int>("year")
                    val track = call.argument<Int>("track")
                    if (songId != null) {
                        val success = updateSongMetadata(songId, title, artist, album, year, track)
                        result.success(success)
                    } else {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getAllSongs(): List<Map<String, Any?>> {
        val songs = mutableListOf<Map<String, Any?>>()

        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.YEAR,
            MediaStore.Audio.Media.TRACK,
        )
        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val sortOrder = "${MediaStore.Audio.Media.TITLE} ASC"

        var cursor: Cursor? = null
        try {
            cursor = contentResolver.query(uri, projection, selection, null, sortOrder)

            cursor?.use { c ->
                val idColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                val titleColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
                val artistColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
                val albumColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
                val durationColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
                val dataColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
                val albumIdColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
                val sizeColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
                val yearColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.YEAR)
                val trackColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.TRACK)

                while (c.moveToNext()) {
                    val id = c.getLong(idColumn)
                    val title = c.getString(titleColumn) ?: "Desconocido"
                    val artist = c.getString(artistColumn) ?: "Desconocido"
                    val album = c.getString(albumColumn) ?: "Desconocido"
                    val duration = c.getLong(durationColumn)
                    val data = c.getString(dataColumn) ?: ""
                    val albumId = c.getLong(albumIdColumn)
                    val size = c.getLong(sizeColumn)
                    val year = c.getInt(yearColumn)
                    val track = c.getInt(trackColumn)
                    val genre = getGenre(id)

                    // Only include files that look like music (duration > 30 seconds)
                    if (duration > 30000) {
                        val artworkUri = if (albumId > 0) {
                            getArtworkUri(albumId)
                        } else {
                            null
                        }

                        songs.add(
                            mapOf(
                                "id" to id,
                                "title" to title,
                                "artist" to artist,
                                "album" to album,
                                "duration" to duration,
                                "filePath" to data,
                                "albumId" to albumId,
                                "size" to size,
                                "year" to year,
                                "track" to track,
                                "genre" to genre,
                                "artworkUri" to artworkUri,
                            )
                        )
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            cursor?.close()
        }

        return songs
    }

    private fun getArtworkUri(albumId: Long): String? {
        return try {
            val artworkUri = ContentUris.withAppendedId(
                Uri.parse("content://media/external/audio/albumart"),
                albumId
            )
            // Verify the artwork exists by checking with a query
            contentResolver.query(artworkUri, null, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    artworkUri.toString()
                } else {
                    null
                }
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun getGenre(audioId: Long): String? {
        return try {
            val genreUri = MediaStore.Audio.Genres.getContentUriForAudioId(
                "external",
                audioId.toInt()
            )
            var genre: String? = null
            contentResolver.query(genreUri, null, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val genreColumn = cursor.getColumnIndex(MediaStore.Audio.Genres.NAME)
                    if (genreColumn >= 0) {
                        genre = cursor.getString(genreColumn)
                    }
                }
            }
            genre
        } catch (e: Exception) {
            null
        }
    }

    private fun getArtworkBytes(albumId: Long): ByteArray? {
        return try {
            val artworkUri = ContentUris.withAppendedId(
                Uri.parse("content://media/external/audio/albumart"),
                albumId
            )
            contentResolver.openInputStream(artworkUri)?.use { inputStream ->
                inputStream.readBytes()
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun updateSongMetadata(
        songId: Long,
        title: String?,
        artist: String?,
        album: String?,
        year: Int?,
        track: Int?
    ): Boolean {
        return try {
            val songUri = ContentUris.withAppendedId(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                songId
            )
            val values = ContentValues()
            title?.let { values.put(MediaStore.Audio.Media.TITLE, it) }
            artist?.let { values.put(MediaStore.Audio.Media.ARTIST, it) }
            album?.let { values.put(MediaStore.Audio.Media.ALBUM, it) }
            year?.let { values.put(MediaStore.Audio.Media.YEAR, it) }
            track?.let { values.put(MediaStore.Audio.Media.TRACK, it) }

            val updated = contentResolver.update(songUri, values, null, null)
            updated > 0
        } catch (e: Exception) {
            false
        }
    }
}
