import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/status_banner.dart';
import '../widgets/message_card.dart';
import '../models/fraud_result.dart';
import 'permission_setup_screen.dart';
import 'test_fraud_detection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bannerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _bannerAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    
    _bannerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _bannerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bannerAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOut,
    ));
    
    _bannerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _bannerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Certa-AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TestFraudDetection()),
            ),
            icon: const Icon(Icons.bug_report),
            tooltip: 'Test Fraud Detection',
          ),
          Consumer<AppStateProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      provider.clearAlerts();
                      break;
                    case 'settings':
                      _showSettings(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear Alerts'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, provider, child) {
          final state = provider.state;
          
          if (!state.isFullyConfigured) {
            return PermissionSetupScreen(
              hasSmsPermission: state.hasSmsPermission,
              hasNotificationPermission: state.hasNotificationPermission,
              onRequestSmsPermission: () => provider.requestSmsPermission(),
              onRequestNotificationPermission: () => _requestNotificationPermission(provider),
              onRefresh: () => provider.initialize(),
              onContinue: () {
                Navigator.of(context).pop();
                provider.startListening();
              },
            );
          }
          
          return Column(
            children: [
              AnimatedBuilder(
                animation: _bannerAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bannerAnimation.value,
                    child: Opacity(
                      opacity: _bannerAnimation.value,
                      child: StatusBanner(
                        state: state,
                        onStartListening: () => provider.startListening(),
                        onStopListening: () => provider.stopListening(),
                        onRequestPermissions: () => _showPermissionSetup(context),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _cardAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _cardAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - _cardAnimation.value)),
                        child: _buildMessageList(provider),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageList(AppStateProvider provider) {
    final messages = provider.messages;
    final fraudResults = provider.fraudResults;
    
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Messages will appear here once monitoring starts',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        FraudResult? fraudResult;
        try {
          fraudResult = fraudResults.firstWhere(
            (result) => result.messageId == message.id,
          );
        } catch (e) {
          fraudResult = null;
        }
        
        return MessageCard(
          message: message,
          fraudResult: fraudResult,
          onAnalyzeWithAI: fraudResult == null 
              ? () => provider.analyzeWithAI(message)
              : null,
          onReportFalsePositive: fraudResult != null && fraudResult.isFraudulent
              ? () => provider.reportFalsePositive(message.id)
              : null,
          onReportTruePositive: fraudResult != null && fraudResult.isFraudulent
              ? () => provider.reportTruePositive(message.id)
              : null,
        );
      },
    );
  }

  void _showPermissionSetup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PermissionSetupScreen(
          hasSmsPermission: context.read<AppStateProvider>().state.hasSmsPermission,
          hasNotificationPermission: context.read<AppStateProvider>().state.hasNotificationPermission,
          onRequestSmsPermission: () => context.read<AppStateProvider>().requestSmsPermission(),
          onRequestNotificationPermission: () => context.read<AppStateProvider>().requestNotificationPermission(),
          onContinue: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _requestNotificationPermission(AppStateProvider provider) async {
    final granted = await provider.requestNotificationPermission();
    
    if (!granted) {
      _showNotificationAccessDialog();
    }
  }

  void _showNotificationAccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Notification Access'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To monitor notifications for fraud detection:'),
            SizedBox(height: 12),
            Text('1. Go to Android Settings'),
            Text('2. Navigate to Apps & notifications'),
            Text('3. Select "Special app access"'),
            Text('4. Choose "Notification access"'),
            Text('5. Find "Certa-AI" and enable it'),
            SizedBox(height: 12),
            Text('This allows the app to monitor incoming notifications from WhatsApp and other apps to detect fraud patterns.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Fraud Detection'),
              subtitle: const Text('Rule-based + AI analysis'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement settings toggle
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Alert Notifications'),
              subtitle: const Text('Get notified of threats'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement settings toggle
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
