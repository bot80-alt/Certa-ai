import 'package:json_annotation/json_annotation.dart';

part 'app_state.g.dart';

@JsonSerializable()
class AppState {
  final bool isListening;
  final bool hasSmsPermission;
  final bool hasNotificationPermission;
  final int totalMessagesScanned;
  final int fraudDetected;
  final DateTime? lastScanTime;
  final List<String> recentAlerts;

  const AppState({
    this.isListening = false,
    this.hasSmsPermission = false,
    this.hasNotificationPermission = false,
    this.totalMessagesScanned = 0,
    this.fraudDetected = 0,
    this.lastScanTime,
    this.recentAlerts = const [],
  });

  factory AppState.fromJson(Map<String, dynamic> json) => _$AppStateFromJson(json);
  Map<String, dynamic> toJson() => _$AppStateToJson(this);

  AppState copyWith({
    bool? isListening,
    bool? hasSmsPermission,
    bool? hasNotificationPermission,
    int? totalMessagesScanned,
    int? fraudDetected,
    DateTime? lastScanTime,
    List<String>? recentAlerts,
  }) {
    return AppState(
      isListening: isListening ?? this.isListening,
      hasSmsPermission: hasSmsPermission ?? this.hasSmsPermission,
      hasNotificationPermission: hasNotificationPermission ?? this.hasNotificationPermission,
      totalMessagesScanned: totalMessagesScanned ?? this.totalMessagesScanned,
      fraudDetected: fraudDetected ?? this.fraudDetected,
      lastScanTime: lastScanTime ?? this.lastScanTime,
      recentAlerts: recentAlerts ?? this.recentAlerts,
    );
  }

  double get fraudRate {
    if (totalMessagesScanned == 0) return 0.0;
    return fraudDetected / totalMessagesScanned;
  }

  bool get isFullyConfigured => hasSmsPermission && hasNotificationPermission;
}

