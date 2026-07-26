package com.example.musix_player

import android.content.ContentUris
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceFragmentActivity

class MainActivity : AudioServiceFragmentActivity() {

    private val CHANNEL = "com.musix_player/music_scanner"
    private val MIN_DURATION_MS = 30_000L

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
                    val albumId = call.argument<Number>("albumId")?.toLong()
                    if (albumId != null && albumId > 0) {
                        result.success(getArtworkUri(albumId))
                    } else {
                        result.success(null)
                    }
                }
                "getArtworkBytes" -> {
                    val albumId = call.argument<Number>("albumId")?.toLong()
                    if (albumId != null && albumId > 0) {
                        result.success(getArtworkBytes(albumId))
                    } else {
                        result.success(null)
                    }
                }
                "updateSongMetadata" -> {
                    val songId = call.argument<Number>("songId")?.toLong()
                    val title = call.argument<String>("title")
                    val artist = call.argument<String>("artist")
                    val album = call.argument<String>("album")
                    val year = call.argument<Number>("year")?.toInt()
                    val track = call.argument<Number>("track")?.toInt()
                    if (songId != null) {
                        result.success(
                            updateSongMetadata(songId, title, artist, album, year, track)
                        )
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

        try {
            contentResolver.query(uri, projection, selection, null, sortOrder)?.use { c ->
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
                    val duration = c.getLong(durationColumn)
                    if (duration <= MIN_DURATION_MS) continue

                    val albumId = c.getLong(albumIdColumn)
                    val contentUri = ContentUris.withAppendedId(
                        MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                        id
                    ).toString()

                    val artworkUri = if (albumId > 0) {
                        ContentUris.withAppendedId(
                            Uri.parse("content://media/external/audio/albumart"),
                            albumId
                        ).toString()
                    } else {
                        null
                    }

                    songs.add(
                        mapOf(
                            "id" to id,
                            "title" to (c.getString(titleColumn) ?: "Desconocido"),
                            "artist" to (c.getString(artistColumn) ?: "Desconocido"),
                            "album" to (c.getString(albumColumn) ?: "Desconocido"),
                            "duration" to duration,
                            "filePath" to (c.getString(dataColumn) ?: ""),
                            "contentUri" to contentUri,
                            "albumId" to albumId,
                            "size" to c.getLong(sizeColumn),
                            "year" to c.getInt(yearColumn),
                            "track" to c.getInt(trackColumn),
                            "genre" to null,
                            "artworkUri" to artworkUri,
                        )
                    )
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return songs
    }

    private fun getArtworkUri(albumId: Long): String? {
        return try {
            ContentUris.withAppendedId(
                Uri.parse("content://media/external/audio/albumart"),
                albumId
            ).toString()
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

            if (values.size() == 0) return false
            val updated = contentResolver.update(songUri, values, null, null)
            updated > 0
        } catch (e: Exception) {
            false
        }
    }
}
