import 'package:json_annotation/json_annotation.dart';

part 'fraud_result.g.dart';

@JsonSerializable()
class FraudResult {
  final String messageId;
  final bool isFraudulent;
  final double confidence;
  final List<String> detectedPatterns;
  final FraudType fraudType;
  final String? explanation;
  final DateTime detectedAt;

  const FraudResult({
    required this.messageId,
    required this.isFraudulent,
    required this.confidence,
    required this.detectedPatterns,
    required this.fraudType,
    this.explanation,
    required this.detectedAt,
  });

  factory FraudResult.fromJson(Map<String, dynamic> json) => _$FraudResultFromJson(json);
  Map<String, dynamic> toJson() => _$FraudResultToJson(this);

  FraudResult copyWith({
    String? messageId,
    bool? isFraudulent,
    double? confidence,
    List<String>? detectedPatterns,
    FraudType? fraudType,
    String? explanation,
    DateTime? detectedAt,
  }) {
    return FraudResult(
      messageId: messageId ?? this.messageId,
      isFraudulent: isFraudulent ?? this.isFraudulent,
      confidence: confidence ?? this.confidence,
      detectedPatterns: detectedPatterns ?? this.detectedPatterns,
      fraudType: fraudType ?? this.fraudType,
      explanation: explanation ?? this.explanation,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }
}

enum FraudType {
  phishing,
  smishing,
  vishing,
  impersonation,
  urgency,
  suspiciousLink,
  unknown,
}

extension FraudTypeExtension on FraudType {
  String get displayName {
    switch (this) {
      case FraudType.phishing:
        return 'Phishing';
      case FraudType.smishing:
        return 'Smishing';
      case FraudType.vishing:
        return 'Vishing';
      case FraudType.impersonation:
        return 'Impersonation';
      case FraudType.urgency:
        return 'Urgency Scam';
      case FraudType.suspiciousLink:
        return 'Suspicious Link';
      case FraudType.unknown:
        return 'Unknown Threat';
    }
  }

  String get description {
    switch (this) {
      case FraudType.phishing:
        return 'Attempting to steal personal information through deceptive messages';
      case FraudType.smishing:
        return 'SMS-based phishing attack targeting mobile users';
      case FraudType.vishing:
        return 'Voice-based phishing attack';
      case FraudType.impersonation:
        return 'Pretending to be a trusted organization or person';
      case FraudType.urgency:
        return 'Creating false urgency to pressure quick action';
      case FraudType.suspiciousLink:
        return 'Contains suspicious or malicious links';
      case FraudType.unknown:
        return 'Potential threat detected but type unclear';
    }
  }
}
