import 'dart:math';
import '../models/message.dart';
import '../models/fraud_result.dart';

class FraudDetectionEngine {
  static const List<String> _phishingKeywords = [
    'urgent', 'immediately', 'verify', 'confirm', 'suspended', 'locked',
    'expired', 'security', 'breach', 'unauthorized', 'fraudulent',
    'click here', 'verify now', 'act now', 'limited time'
  ];

  static const List<String> _suspiciousPatterns = [
    r'\b\d{4,}\b', // Long numbers
    r'http[s]?://[^\s]+', // URLs
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', // Email addresses
    r'\$\d+', // Dollar amounts
    r'\b\d{3}-\d{3}-\d{4}\b', // Phone numbers
  ];

  static const List<String> _bankingKeywords = [
    'bank', 'account', 'card', 'pin', 'password', 'login', 'balance',
    'transfer', 'payment', 'transaction', 'withdraw', 'deposit'
  ];

  static const List<String> _urgencyKeywords = [
    'urgent', 'immediately', 'asap', 'now', 'today', 'expires',
    'limited time', 'act now', 'don\'t wait', 'hurry'
  ];

  static FraudResult analyzeMessage(Message message) {
    final content = message.content.toLowerCase();
    final detectedPatterns = <String>[];
    double confidence = 0.0;
    FraudType fraudType = FraudType.unknown;

    // Check for phishing keywords
    int phishingScore = 0;
    for (final keyword in _phishingKeywords) {
      if (content.contains(keyword.toLowerCase())) {
        phishingScore++;
        detectedPatterns.add('Phishing keyword: "$keyword"');
      }
    }

    // Check for suspicious patterns
    for (final pattern in _suspiciousPatterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(message.content)) {
        detectedPatterns.add('Suspicious pattern detected');
      }
    }

    // Check for banking-related content
    bool hasBankingContent = false;
    for (final keyword in _bankingKeywords) {
      if (content.contains(keyword.toLowerCase())) {
        hasBankingContent = true;
        detectedPatterns.add('Banking-related content');
        break;
      }
    }

    // Check for urgency indicators
    bool hasUrgency = false;
    for (final keyword in _urgencyKeywords) {
      if (content.contains(keyword.toLowerCase())) {
        hasUrgency = true;
        detectedPatterns.add('Urgency indicator');
        break;
      }
    }

    // Determine fraud type and confidence
    if (phishingScore >= 3 && hasBankingContent) {
      fraudType = FraudType.phishing;
      confidence = min(0.9, 0.5 + (phishingScore * 0.1));
    } else if (message.type == MessageType.sms && phishingScore >= 2) {
      fraudType = FraudType.smishing;
      confidence = min(0.8, 0.4 + (phishingScore * 0.1));
    } else if (hasUrgency && phishingScore >= 1) {
      fraudType = FraudType.urgency;
      confidence = min(0.7, 0.3 + (phishingScore * 0.1));
    } else if (detectedPatterns.isNotEmpty) {
      fraudType = FraudType.suspiciousLink;
      confidence = 0.4;
    }

    // Additional checks
    if (content.contains('bit.ly') || content.contains('tinyurl') || content.contains('short.link')) {
      detectedPatterns.add('URL shortener detected');
      confidence = max(confidence, 0.6);
    }

    if (content.contains('call') && content.contains('immediately')) {
      fraudType = FraudType.vishing;
      confidence = max(confidence, 0.7);
    }

    final isFraudulent = confidence >= 0.4;
    final explanation = _generateExplanation(fraudType, detectedPatterns, confidence);

    return FraudResult(
      messageId: message.id,
      isFraudulent: isFraudulent,
      confidence: confidence,
      detectedPatterns: detectedPatterns,
      fraudType: fraudType,
      explanation: explanation,
      detectedAt: DateTime.now(),
    );
  }

  static String _generateExplanation(FraudType fraudType, List<String> patterns, double confidence) {
    final buffer = StringBuffer();
    
    buffer.writeln('${fraudType.displayName} detected with ${(confidence * 100).toInt()}% confidence.');
    
    if (patterns.isNotEmpty) {
      buffer.writeln('\nDetected indicators:');
      for (final pattern in patterns.take(5)) {
        buffer.writeln('• $pattern');
      }
    }
    
    buffer.writeln('\nRecommendation: ${_getRecommendation(fraudType)}');
    
    return buffer.toString();
  }

  static String _getRecommendation(FraudType fraudType) {
    switch (fraudType) {
      case FraudType.phishing:
        return 'Do not click any links or provide personal information. Contact the organization directly through official channels.';
      case FraudType.smishing:
        return 'Delete this message immediately. Do not respond or click any links.';
      case FraudType.vishing:
        return 'Do not call the provided number. Hang up if you receive such calls.';
      case FraudType.impersonation:
        return 'Verify the sender\'s identity through official channels before taking any action.';
      case FraudType.urgency:
        return 'Take time to verify the information. Legitimate organizations rarely create artificial urgency.';
      case FraudType.suspiciousLink:
        return 'Avoid clicking any links in this message.';
      case FraudType.unknown:
        return 'Exercise caution and verify the information through official channels.';
    }
  }

  static List<String> getFraudKeywords() => List.unmodifiable(_phishingKeywords);
  static List<String> getSuspiciousPatterns() => List.unmodifiable(_suspiciousPatterns);
}

