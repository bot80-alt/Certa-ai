package com.example.certa_ai

import android.app.Notification
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.MethodChannel

class NotificationListenerService : NotificationListenerService() {
    companion object {
        private const val CHANNEL_NAME = "certa_ai/notifications"
        private var methodChannel: MethodChannel? = null
        
        fun setMethodChannel(channel: MethodChannel?) {
            methodChannel = channel
        }
        
        fun isNotificationServiceEnabled(context: Context): Boolean {
            val pkgName = context.packageName
            val flat = ComponentName(pkgName, NotificationListenerService::class.java.name)
            val enabled = context.packageManager.getComponentEnabledSetting(flat)
            return enabled == PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)
        
        val notification = sbn.notification
        val extras = notification.extras
        
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString() ?: ""
        
        val fullText = when {
            text.isNotEmpty() -> text
            subText.isNotEmpty() -> subText
            title.isNotEmpty() -> title
            else -> ""
        }
        
        if (fullText.isNotEmpty()) {
            val messageData = mapOf(
                "id" to System.currentTimeMillis().toString(),
                "text" to fullText,
                "sender" to sbn.packageName,
                "appName" to getAppName(sbn.packageName),
                "timestamp" to System.currentTimeMillis()
            )
            
            methodChannel?.invokeMethod("onNotificationReceived", messageData)
        }
    }

    private fun getAppName(packageName: String): String {
        return try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(applicationInfo).toString()
        } catch (e: Exception) {
            packageName
        }
    }
}
