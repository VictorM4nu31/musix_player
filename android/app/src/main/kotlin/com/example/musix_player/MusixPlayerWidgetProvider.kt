package com.example.musix_player

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.KeyEvent
import android.view.View
import android.widget.RemoteViews
import com.ryanheise.audioservice.MediaButtonReceiver
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

open class MusixPlayerWidgetProvider : HomeWidgetProvider() {

    protected open val layoutId: Int = R.layout.musix_player_widget

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = buildViews(context, widgetData)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun buildViews(context: Context, widgetData: SharedPreferences): RemoteViews {
        val views = RemoteViews(context.packageName, layoutId)

        val title = widgetData.getString("title", null) ?: context.getString(R.string.widget_default_title)
        val artist = widgetData.getString("artist", null) ?: context.getString(R.string.widget_default_artist)
        val playing = widgetData.getBoolean("playing", false)
        val artPath = widgetData.getString("artPath", null)

        views.setTextViewText(R.id.widget_title, title)
        views.setTextViewText(R.id.widget_artist, artist)

        views.setImageViewResource(
            R.id.widget_play_pause,
            if (playing) android.R.drawable.ic_media_pause
            else android.R.drawable.ic_media_play
        )

        var artSet = false
        if (!artPath.isNullOrEmpty()) {
            val file = File(artPath)
            if (file.exists()) {
                val bmp = BitmapFactory.decodeFile(artPath)
                if (bmp != null) {
                    views.setImageViewBitmap(R.id.widget_artwork, bmp)
                    views.setViewVisibility(R.id.widget_artwork, View.VISIBLE)
                    views.setViewVisibility(R.id.widget_artwork_placeholder, View.GONE)
                    artSet = true
                }
            }
        }
        if (!artSet) {
            views.setImageViewResource(R.id.widget_artwork, R.mipmap.ic_launcher)
            views.setViewVisibility(R.id.widget_artwork, View.VISIBLE)
            views.setViewVisibility(R.id.widget_artwork_placeholder, View.GONE)
        }

        val openIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java
        )
        views.setOnClickPendingIntent(R.id.widget_root, openIntent)
        views.setOnClickPendingIntent(R.id.widget_artwork, openIntent)

        views.setOnClickPendingIntent(
            R.id.widget_play_pause,
            mediaButtonPendingIntent(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE, 100 + layoutId)
        )
        views.setOnClickPendingIntent(
            R.id.widget_prev,
            mediaButtonPendingIntent(context, KeyEvent.KEYCODE_MEDIA_PREVIOUS, 200 + layoutId)
        )
        views.setOnClickPendingIntent(
            R.id.widget_next,
            mediaButtonPendingIntent(context, KeyEvent.KEYCODE_MEDIA_NEXT, 300 + layoutId)
        )

        return views
    }

    private fun mediaButtonPendingIntent(
        context: Context,
        keyCode: Int,
        requestCode: Int
    ): PendingIntent {
        val down = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
            setClass(context, MediaButtonReceiver::class.java)
            putExtra(
                Intent.EXTRA_KEY_EVENT,
                KeyEvent(KeyEvent.ACTION_DOWN, keyCode)
            )
        }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            down,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}

class MusixPlayerWidgetSmallProvider : MusixPlayerWidgetProvider() {
    override val layoutId: Int = R.layout.musix_player_widget_small
}

class MusixPlayerWidgetLargeProvider : MusixPlayerWidgetProvider() {
    override val layoutId: Int = R.layout.musix_player_widget_large
}
