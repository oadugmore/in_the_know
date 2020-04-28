package com.example.in_the_know

import androidx.annotation.NonNull;
//import android.app.NotificationManager
//import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        // The following is code to delete a notification channel.
        // Uncomment the NotificationManager and Context imports above.
        //val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        //val id: String = "channel id"
        // notificationManager.deleteNotificationChannel(id)
    }
}
