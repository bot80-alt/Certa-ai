import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/message.dart';
import '../models/fraud_result.dart';
import 'fraud_detection_engine.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel('certa_ai/sms');
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
        final result = await _channel.invokeMethod('hasSmsPermission');
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
        final result = await _channel.invokeMethod('requestSmsPermission');
        return result as bool;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  static Future<void> startListening() async {
    if (_isListening) return;
    
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('startSmsListening');
        _isListening = true;
        
        // Listen for incoming SMS messages
        _channel.setMethodCallHandler(_handleMethodCall);
      } catch (e) {
        throw Exception('Failed to start SMS listening: $e');
      }
    }
  }

  static Future<void> stopListening() async {
    if (!_isListening) return;
    
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('stopSmsListening');
        _isListening = false;
      } catch (e) {
        throw Exception('Failed to stop SMS listening: $e');
      }
    }
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onSmsReceived':
        final Map<dynamic, dynamic> data = call.arguments;
        final message = Message(
          id: data['id'] as String,
          content: data['body'] as String,
          sender: data['address'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
          type: MessageType.sms,
        );
        
        _messageController?.add(message);
        
        // Analyze for fraud
        final fraudResult = FraudDetectionEngine.analyzeMessage(message);
        _fraudController?.add(fraudResult);
        break;
    }
  }

  static Future<List<Message>> getRecentMessages({int limit = 50}) async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod('getRecentMessages', {'limit': limit});
        final List<dynamic> messages = result as List<dynamic>;
        
        return messages.map((data) {
          final Map<dynamic, dynamic> messageData = data as Map<dynamic, dynamic>;
          return Message(
            id: messageData['id'] as String,
            content: messageData['body'] as String,
            sender: messageData['address'] as String,
            timestamp: DateTime.fromMillisecondsSinceEpoch(messageData['timestamp'] as int),
            type: MessageType.sms,
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
