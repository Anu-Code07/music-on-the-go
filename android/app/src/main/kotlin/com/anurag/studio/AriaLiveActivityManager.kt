package com.anurag.studio

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import com.example.live_activities.LiveActivityManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

class AriaLiveActivityManager(context: Context) : LiveActivityManager(context) {
    private val appContext: Context = context.applicationContext

    private val pendingIntent = PendingIntent.getActivity(
        appContext,
        200,
        Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private val remoteViews = RemoteViews(
        appContext.packageName,
        R.layout.live_activity,
    )

    private suspend fun loadBitmap(pathOrUrl: String?): Bitmap? {
        if (pathOrUrl.isNullOrEmpty()) return null
        return withContext(Dispatchers.IO) {
            try {
                val file = File(pathOrUrl)
                if (file.exists()) {
                    return@withContext BitmapFactory.decodeFile(file.absolutePath)
                }
                if (!pathOrUrl.startsWith("http")) return@withContext null
                val connection = URL(pathOrUrl).openConnection() as HttpURLConnection
                connection.doInput = true
                connection.connectTimeout = 3000
                connection.readTimeout = 3000
                connection.connect()
                connection.inputStream.use { BitmapFactory.decodeStream(it) }
            } catch (_: Exception) {
                null
            }
        }
    }

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>,
    ): Notification {
        val title = data["title"] as? String ?: "Aria"
        val artist = data["artist"] as? String ?: ""
        val isPlaying = when (val raw = data["isPlaying"]) {
            is Boolean -> raw
            is String -> raw.equals("true", ignoreCase = true)
            else -> false
        }
        val status = data["status"] as? String ?: if (isPlaying) "Playing" else "Paused"

        remoteViews.setTextViewText(R.id.live_title, title)
        remoteViews.setTextViewText(R.id.live_artist, artist)
        remoteViews.setTextViewText(R.id.live_status, status)

        if (event == "create") {
            val art = (data["artworkPath"] as? String).takeUnless { it.isNullOrEmpty() }
                ?: data["artworkUrl"] as? String
            loadBitmap(art)?.let { bitmap ->
                remoteViews.setImageViewBitmap(R.id.live_artwork, bitmap)
            }
        }

        return notification
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentTitle(title)
            .setContentText("$artist · $status")
            .setContentIntent(pendingIntent)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setPriority(Notification.PRIORITY_LOW)
            .setCategory(Notification.CATEGORY_TRANSPORT)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
    }
}
