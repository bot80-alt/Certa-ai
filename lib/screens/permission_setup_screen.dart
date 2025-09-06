import 'package:flutter/material.dart';

class PermissionSetupScreen extends StatelessWidget {
  final bool hasSmsPermission;
  final bool hasNotificationPermission;
  final VoidCallback? onRequestSmsPermission;
  final VoidCallback? onRequestNotificationPermission;
  final VoidCallback? onContinue;
  final VoidCallback? onRefresh;

  const PermissionSetupScreen({
    super.key,
    required this.hasSmsPermission,
    required this.hasNotificationPermission,
    this.onRequestSmsPermission,
    this.onRequestNotificationPermission,
    this.onContinue,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = hasSmsPermission && hasNotificationPermission;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Permissions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Permissions',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Enable Fraud Detection',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Grant permissions to monitor SMS and notifications for fraud detection.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),
            
            _buildPermissionCard(
              context,
              icon: Icons.message,
              title: 'SMS Access',
              description: 'Monitor incoming SMS messages for fraud patterns',
              isGranted: hasSmsPermission,
              onRequest: onRequestSmsPermission,
            ),
            
            const SizedBox(height: 16),
            
            _buildPermissionCard(
              context,
              icon: Icons.notifications,
              title: 'Notification Access',
              description: 'Monitor app notifications (WhatsApp, etc.) for threats',
              isGranted: hasNotificationPermission,
              onRequest: onRequestNotificationPermission,
            ),
            
            const Spacer(),
            
            if (isComplete) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All permissions granted! You\'re ready to start monitoring.',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Monitoring',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    VoidCallback? onRequest,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isGranted ? Colors.green.shade300 : Colors.grey.shade300,
          width: isGranted ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isGranted 
                    ? Colors.green.shade100 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isGranted 
                    ? Colors.green.shade600 
                    : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isGranted) ...[
              Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 24,
              ),
            ] else ...[
              TextButton(
                onPressed: onRequest,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade600,
                ),
                child: const Text('Grant'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

