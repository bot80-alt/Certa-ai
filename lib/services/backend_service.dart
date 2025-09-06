import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/fraud_result.dart';
import 'fraud_detection_engine.dart';

class BackendService {
  static const String _baseUrl = 'https://api.certa-ai.com'; // Replace with actual backend URL
  static const String _apiKey = 'your-api-key'; // This should be stored securely on backend
  
  static Future<FraudResult> analyzeWithAI(Message message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'message': message.content,
          'sender': message.sender,
          'type': message.type.name,
          'appName': message.appName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FraudResult(
          messageId: message.id,
          isFraudulent: data['isFraudulent'] as bool,
          confidence: (data['confidence'] as num).toDouble(),
          detectedPatterns: List<String>.from(data['patterns'] ?? []),
          fraudType: _parseFraudType(data['fraudType'] as String),
          explanation: data['explanation'] as String?,
          detectedAt: DateTime.now(),
        );
      } else {
        throw Exception('Backend analysis failed: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to rule-based detection if AI service is unavailable
      return FraudDetectionEngine.analyzeMessage(message);
    }
  }

  static FraudType _parseFraudType(String type) {
    switch (type.toLowerCase()) {
      case 'phishing':
        return FraudType.phishing;
      case 'smishing':
        return FraudType.smishing;
      case 'vishing':
        return FraudType.vishing;
      case 'impersonation':
        return FraudType.impersonation;
      case 'urgency':
        return FraudType.urgency;
      case 'suspicious_link':
        return FraudType.suspiciousLink;
      default:
        return FraudType.unknown;
    }
  }

  static Future<bool> isServiceAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<void> reportFalsePositive(String messageId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'messageId': messageId,
          'feedback': 'false_positive',
        }),
      );
    } catch (e) {
      // Silently fail for feedback
    }
  }

  static Future<void> reportTruePositive(String messageId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'messageId': messageId,
          'feedback': 'true_positive',
        }),
      );
    } catch (e) {
      // Silently fail for feedback
    }
  }
}
