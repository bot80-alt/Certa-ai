import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/fraud_result.dart';
import '../services/fraud_detection_engine.dart';

class TestFraudDetection extends StatelessWidget {
  const TestFraudDetection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Fraud Detection'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Fraud Detection Engine',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap any test message to see fraud detection results:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildTestMessage(
                    context,
                    'Phishing Test',
                    // 'Your bank account will be suspended immediately. Click here to verify: http://fake-bank.com',
                    'Dear Customer, We detected unusual activity in your account. For your security, we have temporarily limited access. To restore full access, please verify your account information within the next 24 hours. 👉 Click here to verify your account Failure to do so may result in permanent suspension of your account. Thank you for your prompt attention.',
                    '+1234567890',
                    MessageType.sms,
                  ),
                  _buildTestMessage(
                    context,
                    'Urgency Scam',
                    'URGENT: Your payment is overdue. Call now to avoid service suspension!',
                    '+9876543210',
                    MessageType.sms,
                  ),
                  _buildTestMessage(
                    context,
                    'WhatsApp Phishing',
                    'Congratulations! You won \$1000. Click bit.ly/fake-link to claim your prize now!',
                    'WhatsApp',
                    MessageType.notification,
                    appName: 'WhatsApp',
                  ),
                  _buildTestMessage(
                    context,
                    'Safe Message',
                    'Hi, just wanted to check if you\'re free for lunch tomorrow?',
                    '+1111111111',
                    MessageType.sms,
                  ),
                  _buildTestMessage(
                    context,
                    'Banking Phishing',
                    'Security Alert: Unusual activity detected. Verify your account immediately at secure-bank-verify.com',
                    '+5555555555',
                    MessageType.sms,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestMessage(
    BuildContext context,
    String title,
    String content,
    String sender,
    MessageType type, {
    String? appName,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(content),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showFraudAnalysis(context, content, sender, type, appName),
      ),
    );
  }

  void _showFraudAnalysis(
    BuildContext context,
    String content,
    String sender,
    MessageType type,
    String? appName,
  ) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: sender,
      timestamp: DateTime.now(),
      type: type,
      appName: appName,
    );

    final fraudResult = FraudDetectionEngine.analyzeMessage(message);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fraud Analysis: ${fraudResult.fraudType.displayName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnalysisRow('Message:', content),
              _buildAnalysisRow('Sender:', sender),
              _buildAnalysisRow('Type:', type.displayName),
              _buildAnalysisRow('Fraudulent:', fraudResult.isFraudulent ? 'YES' : 'NO'),
              _buildAnalysisRow('Confidence:', '${(fraudResult.confidence * 100).toInt()}%'),
              _buildAnalysisRow('Fraud Type:', fraudResult.fraudType.displayName),
              if (fraudResult.detectedPatterns.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Detected Patterns:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...fraudResult.detectedPatterns.map((pattern) => Text('• $pattern')),
              ],
              if (fraudResult.explanation != null) ...[
                const SizedBox(height: 8),
                const Text('Explanation:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(fraudResult.explanation!),
              ],
            ],
          ),
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

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
