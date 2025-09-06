package com.example.certa_ai

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "certa_ai/sms"
    private val NOTIFICATION_CHANNEL = "certa_ai/notifications"
    
    private val SMS_PERMISSION_REQUEST_CODE = 1001
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1002

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // SMS Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasSmsPermission" -> {
                    result.success(hasSmsPermission())
                }
                "requestSmsPermission" -> {
                    requestSmsPermission()
                    result.success(hasSmsPermission())
                }
                "startSmsListening" -> {
                    SmsReceiver.setMethodChannel(MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL))
                    result.success(null)
                }
                "stopSmsListening" -> {
                    SmsReceiver.setMethodChannel(null)
                    result.success(null)
                }
                "getRecentMessages" -> {
                    result.success(getRecentSmsMessages())
                }
                else -> result.notImplemented()
            }
        }
        
        // Notification Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasNotificationPermission" -> {
                    result.success(hasNotificationPermission())
                }
                "requestNotificationPermission" -> {
                    requestNotificationPermission()
                    result.success(hasNotificationPermission())
                }
                "startNotificationListening" -> {
                    NotificationListenerService.setMethodChannel(MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_CHANNEL))
                    result.success(null)
                }
                "stopNotificationListening" -> {
                    NotificationListenerService.setMethodChannel(null)
                    result.success(null)
                }
                "getRecentNotifications" -> {
                    result.success(getRecentNotifications())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasSmsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED &&
               ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestSmsPermission() {
        val permissions = arrayOf(
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS
        )
        ActivityCompat.requestPermissions(this, permissions, SMS_PERMISSION_REQUEST_CODE)
    }

    private fun hasNotificationPermission(): Boolean {
        return NotificationListenerService.isNotificationServiceEnabled(this)
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_PERMISSION_REQUEST_CODE)
        } else {
            // For older Android versions, open notification listener settings
            val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    private fun getRecentSmsMessages(): List<Map<String, Any>> {
        // This would typically query the SMS content provider
        // For demo purposes, returning empty list
        return emptyList()
    }

    private fun getRecentNotifications(): List<Map<String, Any>> {
        // This would typically query recent notifications
        // For demo purposes, returning empty list
        return emptyList()
    }
}
