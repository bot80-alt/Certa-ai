
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/message.dart';
import '../models/fraud_result.dart';
import 'fraud_detection_engine.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('certa_ai/notifications');
  static StreamController<Message>? _messageController;
  static StreamController<FraudResult>? _fraudController;
  static bool _isListening = false;

  static Stream<Message> get messageStream {
    _messageController ??= StreamController<Message>.broadcast();
    return _messageController!.stream;
  }

  static Stream<FraudResult> get fraudStream {
    _fraudController ??= StreamController<FraudResult>.broadcast();
    return _fraudController!.stream;
  }

  static Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod('hasNotificationPermission');
        return result as bool;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod('requestNotificationPermission');
        return result as bool;
      } catch (e) {
        // If the method call fails, assume we need to open settings manually
        return false;
      }
    }
    return false;
  }

  static Future<void> startListening() async {
    if (_isListening) return;
    
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('startNotificationListening');
        _isListening = true;
        
        // Listen for incoming notifications
        _channel.setMethodCallHandler(_handleMethodCall);
      } catch (e) {
        throw Exception('Failed to start notification listening: $e');
      }
    }
  }

  static Future<void> stopListening() async {
    if (!_isListening) return;
    
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('stopNotificationListening');
        _isListening = false;
      } catch (e) {
        throw Exception('Failed to stop notification listening: $e');
      }
    }
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNotificationReceived':
        final Map<dynamic, dynamic> data = call.arguments;
        final message = Message(
          id: data['id'] as String,
          content: data['text'] as String,
          sender: data['sender'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
          type: MessageType.notification,
          appName: data['appName'] as String?,
        );
        
        _messageController?.add(message);
        
        // Analyze for fraud
        final fraudResult = FraudDetectionEngine.analyzeMessage(message);
        _fraudController?.add(fraudResult);
        break;
    }
  }

  static Future<List<Message>> getRecentNotifications({int limit = 50}) async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod('getRecentNotifications', {'limit': limit});
        final List<dynamic> notifications = result as List<dynamic>;
        
        return notifications.map((data) {
          final Map<dynamic, dynamic> notificationData = data as Map<dynamic, dynamic>;
          return Message(
            id: notificationData['id'] as String,
            content: notificationData['text'] as String,
            sender: notificationData['sender'] as String,
            timestamp: DateTime.fromMillisecondsSinceEpoch(notificationData['timestamp'] as int),
            type: MessageType.notification,
            appName: notificationData['appName'] as String?,
          );
        }).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static void dispose() {
    _messageController?.close();
    _fraudController?.close();
    _messageController = null;
    _fraudController = null;
  }
}
