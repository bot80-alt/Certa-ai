package com.example.certa_ai

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage
import io.flutter.plugin.common.MethodChannel

class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val CHANNEL_NAME = "certa_ai/sms"
        private var methodChannel: MethodChannel? = null
        
        fun setMethodChannel(channel: MethodChannel?) {
            methodChannel = channel
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            
            for (message in messages) {
                val messageData = mapOf(
                    "id" to System.currentTimeMillis().toString(),
                    "body" to message.messageBody,
                    "address" to message.originatingAddress,
                    "timestamp" to System.currentTimeMillis()
                )
                
                methodChannel?.invokeMethod("onSmsReceived", messageData)
            }
        }
    }
}
