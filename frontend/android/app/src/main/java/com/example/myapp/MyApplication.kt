package com.example.myapp

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // 1) Instantiate a single FlutterEngine
        val flutterEngine = FlutterEngine(this)

        // 2) Start executing Dart's default entrypoint (main.dart → main())
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        // 3) Register all generated plugins (including MethodChannel, flutter_stripe, etc.)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // 4) Put this engine into the cache under a known key
        FlutterEngineCache
            .getInstance()
            .put("my_shared_engine_id", flutterEngine)
    }
}
