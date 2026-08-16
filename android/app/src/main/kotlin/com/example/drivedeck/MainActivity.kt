package com.example.drivedeck

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.drivedeck/share"
    private var sharedText: String? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
        sharedText?.let { text ->
            methodChannel?.invokeMethod("onSharedText", text)
        }
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        val type = intent.type

        if (Intent.ACTION_SEND == action && type != null) {
            if (type.startsWith("text/")) {
                sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
            } else if (type == "application/pdf" || type.startsWith("application/")) {
                val uri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                uri?.let {
                    try {
                        contentResolver.openInputStream(it)?.use { stream ->
                            val bytes = stream.readBytes()
                            sharedText = String(bytes, Charsets.UTF_8)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
        } else if (Intent.ACTION_PROCESS_TEXT == action) {
            sharedText = intent.getStringExtra(Intent.EXTRA_PROCESS_TEXT)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "getInitialSharedText") {
                val text = sharedText
                sharedText = null
                result.success(text)
            } else {
                result.notImplemented()
            }
        }
    }
}
