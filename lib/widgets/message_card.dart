import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/fraud_result.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final FraudResult? fraudResult;
  final VoidCallback? onAnalyzeWithAI;
  final VoidCallback? onReportFalsePositive;
  final VoidCallback? onReportTruePositive;

  const MessageCard({
    super.key,
    required this.message,
    this.fraudResult,
    this.onAnalyzeWithAI,
    this.onReportFalsePositive,
    this.onReportTruePositive,
  });

  @override
  Widget build(BuildContext context) {
    final isFraudulent = fraudResult?.isFraudulent ?? false;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isFraudulent ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isFraudulent 
            ? BorderSide(color: Colors.red.shade300, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isFraudulent 
              ? LinearGradient(
                  colors: [Colors.red.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildContent(context),
              if (fraudResult != null) ...[
                const SizedBox(height: 12),
                _buildFraudAlert(context),
              ],
              if (onAnalyzeWithAI != null || onReportFalsePositive != null || onReportTruePositive != null) ...[
                const SizedBox(height: 12),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTypeColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.type.displayName,
            style: TextStyle(
              color: _getTypeColor(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (message.appName != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.appName!,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        const Spacer(),
        Text(
          _formatTime(message.timestamp),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.sender,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            height: 1.4,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFraudAlert(BuildContext context) {
    if (fraudResult == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fraudResult!.isFraudulent 
            ? Colors.red.shade100 
            : Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: fraudResult!.isFraudulent 
              ? Colors.red.shade300 
              : Colors.green.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                fraudResult!.isFraudulent 
                    ? Icons.warning 
                    : Icons.check_circle,
                color: fraudResult!.isFraudulent 
                    ? Colors.red.shade700 
                    : Colors.green.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                fraudResult!.isFraudulent 
                    ? 'THREAT DETECTED' 
                    : 'SAFE',
                style: TextStyle(
                  color: fraudResult!.isFraudulent 
                      ? Colors.red.shade700 
                      : Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${(fraudResult!.confidence * 100).toInt()}% confidence',
                style: TextStyle(
                  color: fraudResult!.isFraudulent 
                      ? Colors.red.shade600 
                      : Colors.green.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            fraudResult!.fraudType.displayName,
            style: TextStyle(
              color: fraudResult!.isFraudulent 
                  ? Colors.red.shade700 
                  : Colors.green.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (fraudResult!.explanation != null) ...[
            const SizedBox(height: 4),
            Text(
              fraudResult!.explanation!,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (onAnalyzeWithAI != null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAnalyzeWithAI,
              icon: const Icon(Icons.psychology, size: 16),
              label: const Text('AI Analysis'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade300),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (fraudResult?.isFraudulent == true) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onReportFalsePositive,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('False Alarm'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade300),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onReportTruePositive,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Correct'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getTypeColor() {
    switch (message.type) {
      case MessageType.sms:
        return Colors.blue.shade600;
      case MessageType.notification:
        return Colors.purple.shade600;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
