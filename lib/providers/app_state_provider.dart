import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_state.dart';
import '../models/message.dart';
import '../models/fraud_result.dart';
import '../services/sms_service.dart';
import '../services/notification_service.dart';
import '../services/backend_service.dart';

class AppStateProvider extends ChangeNotifier {
  AppState _state = const AppState();
  List<Message> _messages = [];
  List<FraudResult> _fraudResults = [];
  Timer? _permissionTimer;
  
  StreamSubscription<Message>? _smsSubscription;
  StreamSubscription<Message>? _notificationSubscription;
  StreamSubscription<FraudResult>? _smsFraudSubscription;
  StreamSubscription<FraudResult>? _notificationFraudSubscription;

  AppState get state => _state;
  List<Message> get messages => List.unmodifiable(_messages);
  List<FraudResult> get fraudResults => List.unmodifiable(_fraudResults);
  
  List<FraudResult> get recentFraudAlerts => _fraudResults
      .where((result) => result.isFraudulent)
      .take(10)
      .toList();

  Future<void> initialize() async {
    await _checkPermissions();
    await _loadRecentData();
    
    // Set up periodic permission checking
    _startPermissionChecker();
  }

  void _startPermissionChecker() {
    // Check permissions every 2 seconds when app is active
    _permissionTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final smsPermission = await SmsService.hasPermission();
      final notificationPermission = await NotificationService.hasPermission();
      
      // Only update if permissions have changed
      if (smsPermission != _state.hasSmsPermission || 
          notificationPermission != _state.hasNotificationPermission) {
        _state = _state.copyWith(
          hasSmsPermission: smsPermission,
          hasNotificationPermission: notificationPermission,
        );
        notifyListeners();
      }
    });
  }

  Future<void> _checkPermissions() async {
    final smsPermission = await SmsService.hasPermission();
    final notificationPermission = await NotificationService.hasPermission();
    
    _state = _state.copyWith(
      hasSmsPermission: smsPermission,
      hasNotificationPermission: notificationPermission,
    );
    notifyListeners();
  }

  Future<void> _loadRecentData() async {
    try {
      final recentSms = await SmsService.getRecentMessages(limit: 20);
      final recentNotifications = await NotificationService.getRecentNotifications(limit: 20);
      
      _messages = [...recentSms, ...recentNotifications];
      _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load recent data: $e');
    }
  }

  Future<bool> requestSmsPermission() async {
    final granted = await SmsService.requestPermission();
    _state = _state.copyWith(hasSmsPermission: granted);
    notifyListeners();
    return granted;
  }

  Future<bool> requestNotificationPermission() async {
    final granted = await NotificationService.requestPermission();
    
    // If not granted, show a dialog explaining how to enable notification access
    if (!granted) {
      _showNotificationAccessDialog();
    }
    
    _state = _state.copyWith(hasNotificationPermission: granted);
    notifyListeners();
    return granted;
  }

  void _showNotificationAccessDialog() {
    // This would need to be called from a BuildContext
    // For now, we'll handle this in the UI layer
  }

  Future<void> startListening() async {
    if (_state.isListening) return;

    try {
      // Start SMS listening if permission is granted
      if (_state.hasSmsPermission) {
        await SmsService.startListening();
        _smsSubscription = SmsService.messageStream.listen(_onMessageReceived);
        _smsFraudSubscription = SmsService.fraudStream.listen(_onFraudDetected);
      }

      // Start notification listening if permission is granted
      if (_state.hasNotificationPermission) {
        await NotificationService.startListening();
        _notificationSubscription = NotificationService.messageStream.listen(_onMessageReceived);
        _notificationFraudSubscription = NotificationService.fraudStream.listen(_onFraudDetected);
      }

      _state = _state.copyWith(isListening: true);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to start listening: $e');
    }
  }

  Future<void> stopListening() async {
    if (!_state.isListening) return;

    try {
      await SmsService.stopListening();
      await NotificationService.stopListening();
      
      await _smsSubscription?.cancel();
      await _notificationSubscription?.cancel();
      await _smsFraudSubscription?.cancel();
      await _notificationFraudSubscription?.cancel();
      
      _smsSubscription = null;
      _notificationSubscription = null;
      _smsFraudSubscription = null;
      _notificationFraudSubscription = null;

      _state = _state.copyWith(isListening: false);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to stop listening: $e');
    }
  }

  void _onMessageReceived(Message message) {
    _messages.insert(0, message);
    if (_messages.length > 100) {
      _messages = _messages.take(100).toList();
    }
    
    _state = _state.copyWith(
      totalMessagesScanned: _state.totalMessagesScanned + 1,
      lastScanTime: DateTime.now(),
    );
    
    notifyListeners();
  }

  void _onFraudDetected(FraudResult fraudResult) {
    _fraudResults.insert(0, fraudResult);
    if (_fraudResults.length > 50) {
      _fraudResults = _fraudResults.take(50).toList();
    }

    if (fraudResult.isFraudulent) {
      _state = _state.copyWith(
        fraudDetected: _state.fraudDetected + 1,
        recentAlerts: [fraudResult.fraudType.displayName, ..._state.recentAlerts.take(4)],
      );
    }
    
    notifyListeners();
  }

  Future<void> analyzeWithAI(Message message) async {
    try {
      final aiResult = await BackendService.analyzeWithAI(message);
      _fraudResults.insert(0, aiResult);
      
      if (aiResult.isFraudulent) {
        _state = _state.copyWith(
          fraudDetected: _state.fraudDetected + 1,
          recentAlerts: [aiResult.fraudType.displayName, ..._state.recentAlerts.take(4)],
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('AI analysis failed: $e');
    }
  }

  void reportFalsePositive(String messageId) {
    BackendService.reportFalsePositive(messageId);
  }

  void reportTruePositive(String messageId) {
    BackendService.reportTruePositive(messageId);
  }

  void clearAlerts() {
    _fraudResults.clear();
    _state = _state.copyWith(
      fraudDetected: 0,
      recentAlerts: [],
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _permissionTimer?.cancel();
    stopListening();
    SmsService.dispose();
    NotificationService.dispose();
    super.dispose();
  }
}
