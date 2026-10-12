package com.example.brandswitcher

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val brand by lazy { BrandSwitcher(applicationContext) }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        // Name and icon live on the same alias, so one handler serves both.
        MethodChannel(messenger, "app/name").setMethodCallHandler(brand)
        MethodChannel(messenger, "app/icon").setMethodCallHandler(brand)
    }

    // Apply staged switches only when the app leaves the foreground.
    override fun onStop() {
        super.onStop()
        brand.applyPending()
    }
}
