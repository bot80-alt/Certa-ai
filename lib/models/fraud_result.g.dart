// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fraud_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FraudResult _$FraudResultFromJson(Map<String, dynamic> json) => FraudResult(
  messageId: json['messageId'] as String,
  isFraudulent: json['isFraudulent'] as bool,
  confidence: (json['confidence'] as num).toDouble(),
  detectedPatterns: (json['detectedPatterns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  fraudType: $enumDecode(_$FraudTypeEnumMap, json['fraudType']),
  explanation: json['explanation'] as String?,
  detectedAt: DateTime.parse(json['detectedAt'] as String),
);

Map<String, dynamic> _$FraudResultToJson(FraudResult instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'isFraudulent': instance.isFraudulent,
      'confidence': instance.confidence,
      'detectedPatterns': instance.detectedPatterns,
      'fraudType': _$FraudTypeEnumMap[instance.fraudType]!,
      'explanation': instance.explanation,
      'detectedAt': instance.detectedAt.toIso8601String(),
    };

const _$FraudTypeEnumMap = {
  FraudType.phishing: 'phishing',
  FraudType.smishing: 'smishing',
  FraudType.vishing: 'vishing',
  FraudType.impersonation: 'impersonation',
  FraudType.urgency: 'urgency',
  FraudType.suspiciousLink: 'suspiciousLink',
  FraudType.unknown: 'unknown',
};
