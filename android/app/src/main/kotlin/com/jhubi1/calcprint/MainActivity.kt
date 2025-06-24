package com.jhubi1.calcprint

import android.app.assist.AssistContent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.jhubi1.calcprint/recent"
    private var lastUrl: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateRecent" -> {
                    lastUrl = call.argument<String>("url")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onProvideAssistContent(outContent: AssistContent) {
        super.onProvideAssistContent(outContent)
        lastUrl
            ?.takeIf { it.isNotEmpty() }
            ?.let { outContent.webUri = Uri.parse(it) }
    }
}
