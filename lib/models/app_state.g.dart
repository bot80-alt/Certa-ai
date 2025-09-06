// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) => AppState(
  isListening: json['isListening'] as bool? ?? false,
  hasSmsPermission: json['hasSmsPermission'] as bool? ?? false,
  hasNotificationPermission:
      json['hasNotificationPermission'] as bool? ?? false,
  totalMessagesScanned: (json['totalMessagesScanned'] as num?)?.toInt() ?? 0,
  fraudDetected: (json['fraudDetected'] as num?)?.toInt() ?? 0,
  lastScanTime: json['lastScanTime'] == null
      ? null
      : DateTime.parse(json['lastScanTime'] as String),
  recentAlerts:
      (json['recentAlerts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$AppStateToJson(AppState instance) => <String, dynamic>{
  'isListening': instance.isListening,
  'hasSmsPermission': instance.hasSmsPermission,
  'hasNotificationPermission': instance.hasNotificationPermission,
  'totalMessagesScanned': instance.totalMessagesScanned,
  'fraudDetected': instance.fraudDetected,
  'lastScanTime': instance.lastScanTime?.toIso8601String(),
  'recentAlerts': instance.recentAlerts,
};
