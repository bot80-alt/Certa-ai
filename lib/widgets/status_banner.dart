import 'package:flutter/material.dart';
import '../models/app_state.dart';

class StatusBanner extends StatelessWidget {
  final AppState state;
  final VoidCallback? onStartListening;
  final VoidCallback? onStopListening;
  final VoidCallback? onRequestPermissions;

  const StatusBanner({
    super.key,
    required this.state,
    this.onStartListening,
    this.onStopListening,
    this.onRequestPermissions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStatusSubtitle(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButton(context),
            ],
          ),
          if (state.isListening) ...[
            const SizedBox(height: 12),
            _buildStatsRow(),
          ],
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (state.isListening) {
      return [Colors.green.shade600, Colors.green.shade400];
    } else if (state.isFullyConfigured) {
      return [Colors.blue.shade600, Colors.blue.shade400];
    } else {
      return [Colors.orange.shade600, Colors.orange.shade400];
    }
  }

  IconData _getStatusIcon() {
    if (state.isListening) {
      return Icons.security;
    } else if (state.isFullyConfigured) {
      return Icons.check_circle;
    } else {
      return Icons.warning;
    }
  }

  String _getStatusTitle() {
    if (state.isListening) {
      return 'Protection Active';
    } else if (state.isFullyConfigured) {
      return 'Ready to Start';
    } else {
      return 'Setup Required';
    }
  }

  String _getStatusSubtitle() {
    if (state.isListening) {
      return 'Monitoring SMS and notifications for fraud';
    } else if (state.isFullyConfigured) {
      return 'All permissions granted. Tap to start monitoring.';
    } else {
      return 'Grant permissions to start fraud detection';
    }
  }

  Widget _buildActionButton(BuildContext context) {
    if (state.isListening) {
      return IconButton(
        onPressed: onStopListening,
        icon: const Icon(Icons.stop, color: Colors.white),
        tooltip: 'Stop Monitoring',
      );
    } else if (state.isFullyConfigured) {
      return IconButton(
        onPressed: onStartListening,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        tooltip: 'Start Monitoring',
      );
    } else {
      return IconButton(
        onPressed: onRequestPermissions,
        icon: const Icon(Icons.settings, color: Colors.white),
        tooltip: 'Setup Permissions',
      );
    }
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.message,
          label: 'Scanned',
          value: state.totalMessagesScanned.toString(),
        ),
        _buildStatItem(
          icon: Icons.warning,
          label: 'Threats',
          value: state.fraudDetected.toString(),
        ),
        _buildStatItem(
          icon: Icons.trending_up,
          label: 'Rate',
          value: '${(state.fraudRate * 100).toStringAsFixed(1)}%',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
