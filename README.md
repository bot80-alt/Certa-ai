# Certa-AI — Notification Fraud Detector (Flutter)

**Certa-AI — Go safe with every notification.**

A Flutter demo app that listens for incoming SMS and notification (WhatsApp, etc.) messages on Android, scans them for fraud indicators (rule-based + optional AI/backend classification), and surfaces alerts in a polished UI. Designed for quick demos and hackathon submissions (Google Gen AI Exchange).

## Features

- ✅ Real-time listening for incoming SMS (Android)
- ✅ Notification listener captures WhatsApp and other app notifications
- ✅ Fast rule-based fraud detection (configurable keywords and regex)
- ✅ Clean, card-based UI with status banner and smooth animations
- ✅ Optional configuration to forward suspicious text to a secure backend for AI-based classification
- ✅ Minimal, hackathon-ready codebase suitable for demoing in under 5 minutes

## Important Notes & Privacy

- **Android only** (full features). iOS does not allow background SMS access or cross-app notification interception
- **WhatsApp chat content is not readable**. The app can only access notification text posted by WhatsApp if the user grants Notification Access
- **User consent and disclosure**. If you capture notification text or SMS, explicitly disclose what is collected and why
- **Do not store secrets in the client**. API keys (for Gemini or other services) must be stored only on a secure backend

## Quick Start

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Android Studio / Android SDK
- Android device or emulator (API level 21+)

### Create Project

```bash
git clone <your-repo-url>
cd Certa-ai
flutter pub get
```

### Install Dependencies

```bash
flutter pub get
```

### Run on Device

```bash
flutter run
```

## Android Setup

### AndroidManifest.xml Changes

The app requires several permissions that are already configured:

```xml
<!-- SMS permissions -->
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.READ_SMS" />

<!-- Notification access permission -->
<uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />

<!-- Internet permission for backend integration -->
<uses-permission android:name="android.permission.INTERNET" />
```

### Request Runtime Permissions

The app will automatically request permissions when you first launch it:

1. **SMS Permission**: Allows reading incoming SMS messages
2. **Notification Access**: Allows monitoring notifications from other apps

### Notification Access (User Action)

For notification access, users need to manually enable it in Android Settings:

1. Go to Settings > Apps > Special app access > Notification access
2. Find "Certa-AI" and enable it

## Architecture & Detection Workflow

```
Incoming Message → SMS/Notification Service → Fraud Detection Engine → UI Alert
                                    ↓
                            Backend AI Service (Optional)
```

### Fraud Detection Engine

The app uses a multi-layered approach:

1. **Rule-based Detection**: Keyword matching, pattern recognition, urgency indicators
2. **AI Classification**: Optional backend integration for advanced analysis
3. **User Feedback**: False positive/true positive reporting for model improvement

### Detection Patterns

- **Phishing**: Banking keywords + urgency + suspicious patterns
- **Smishing**: SMS-specific phishing attacks
- **Vishing**: Voice call-related fraud attempts
- **Impersonation**: Fake organization messages
- **Urgency Scams**: Time-pressure tactics
- **Suspicious Links**: URL shorteners, suspicious domains

## Optional: Backend + AI (Gemini) Integration

To enable AI-powered fraud detection:

1. Set up a secure backend service
2. Update `BackendService` class with your API endpoint
3. Implement Gemini API integration on the backend
4. Never store API keys in the client app

Example backend endpoint:

```dart
POST /analyze
{
  "message": "Your account will be suspended...",
  "sender": "+1234567890",
  "type": "sms"
}
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── message.dart
│   ├── fraud_result.dart
│   └── app_state.dart
├── services/                    # Business logic
│   ├── fraud_detection_engine.dart
│   ├── sms_service.dart
│   ├── notification_service.dart
│   └── backend_service.dart
├── providers/                   # State management
│   └── app_state_provider.dart
├── screens/                     # UI screens
│   ├── home_screen.dart
│   └── permission_setup_screen.dart
└── widgets/                     # Reusable widgets
    ├── status_banner.dart
    └── message_card.dart
```

## Environment Files & Secrets

Create a `.env` file for configuration:

```env
BACKEND_URL=https://your-backend.com
API_KEY=your-secure-api-key
ENABLE_AI_ANALYSIS=true
```

## Troubleshooting

### Common Issues

1. **SMS not detected**: Ensure SMS permission is granted
2. **Notifications not detected**: Enable notification access in Android settings
3. **App crashes on startup**: Check Android API level compatibility
4. **Backend connection fails**: Verify network connectivity and API endpoint

### Debug Mode

Enable debug logging:

```dart
// In main.dart
import 'package:flutter/foundation.dart';

void main() {
  debugPrint('Certa-AI Debug Mode');
  runApp(const CertaAIApp());
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built for Google Gen AI Exchange Hackathon**

_Protecting users from fraud, one notification at a time._
