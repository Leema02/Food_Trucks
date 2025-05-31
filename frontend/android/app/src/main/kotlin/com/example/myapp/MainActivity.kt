package com.example.myapp

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.myapp/service"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Note: No need to manually grab a FlutterEngine here,
        // because we only care about responding to the Dart → Android call:
        // platform.invokeMethod('startService') in Dart.
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "startService") {
                // Launch the ForegroundService on Android
                startService(Intent(this, ForegroundService::class.java))
                result.success("Service started")
            } else {
                result.notImplemented()
            }
        }
    }
}
