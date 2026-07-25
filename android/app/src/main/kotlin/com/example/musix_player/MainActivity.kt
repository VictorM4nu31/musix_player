package com.example.musix_player

import android.content.ContentUris
import android.database.Cursor
import android.net.Uri
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

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
}
