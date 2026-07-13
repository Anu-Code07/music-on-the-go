package com.anurag.studio

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class StudioPlayerWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.studio_player_widget).apply {
                setTextViewText(
                    R.id.widget_title,
                    widgetData.getString("title", "Aria") ?: "Aria",
                )
                setTextViewText(
                    R.id.widget_artist,
                    widgetData.getString("artist", "Not playing") ?: "Not playing",
                )
                val playing = widgetData.getBoolean("isPlaying", false)
                val status = widgetData.getString("status", null)
                    ?: if (playing) "Playing" else "Paused"
                setTextViewText(R.id.widget_status, status)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
