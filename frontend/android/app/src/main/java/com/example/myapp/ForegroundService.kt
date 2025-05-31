package com.example.myapp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class ForegroundService : Service() {

    private val CHANNEL_ID = "ForegroundServiceChannel"
    private val CHANNEL_NAME = "SocketServiceChannel"
    private val METHOD_CHANNEL = "com.example.myapp/service"

    // Retrieve the exact same FlutterEngine that MyApplication put into the cache
    private val sharedEngine: FlutterEngine?
        get() = FlutterEngineCache.getInstance().get("my_shared_engine_id")

    override fun onCreate() {
        super.onCreate()

        // As soon as the service is created, tell Dart: "startSocketService"
        sharedEngine?.let { engine ->
            MethodChannel(
                engine.dartExecutor.binaryMessenger,
                METHOD_CHANNEL
            ).invokeMethod("startSocketService", null)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()

        // Build a simple foreground notification
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE
        )

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Service Running")
            .setContentText("Socket service is active")
            .setSmallIcon(R.drawable.ic_notification) // ← your drawable here
            .setContentIntent(pendingIntent)
            .build()

        startForeground(1, notification)
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        // Do NOT destroy the engine here, because we want to keep the app’s main Dart isolate alive.
        // If you really wanted to tear down, you could call sharedEngine?.destroy(), but then your UI quits.
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }
}
