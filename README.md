# Certa-AI — Notification Fraud Detector (Flutter)

**Certa-AI** — Go safe with every notification.  
A Flutter demo app that listens for incoming SMS and notification (WhatsApp, etc.) messages on Android, scans them for fraud indicators (rule-based + optional AI/backend classification), and surfaces alerts in a polished UI. Designed for quick demos and hackathon submissions (Google Gen AI Exchange).

---

## Table of contents

- [Features](#features)  
- [Important notes & privacy](#important-notes--privacy)  
- [Quick start](#quick-start)  
  - [Prerequisites](#prerequisites)  
  - [Create project](#create-project)  
  - [Install dependencies](#install-dependencies)  
  - [Run on device](#run-on-device)  
- [Android setup](#android-setup)  
  - [AndroidManifest.xml changes](#androidmanifestxml-changes)  
  - [Request runtime permissions](#request-runtime-permissions)  
  - [Notification access (user action)](#notification-access-user-action)  
- [Architecture & detection workflow](#architecture--detection-workflow)  
- [Optional: Backend + AI (Gemini) integration](#optional-backend--ai-gemini-integration)  
- [Project structure](#project-structure)  
- [Environment files & secrets](#environment-files--secrets)  
- [Troubleshooting](#troubleshooting)  
- [Contributing](#contributing)  
- [License](#license)

---

## Features

- Real-time listening for incoming SMS (Android).  
- Notification listener captures WhatsApp and other app notifications (notification text).  
- Fast rule-based fraud detection (configurable keywords and regex).  
- Clean, card-based UI with status banner and simple animations.  
- Optional configuration to forward suspicious text to a secure backend for AI-based classification.  
- Minimal, hackathon-ready codebase suitable for demoing in under 5 minutes.

---

## Important notes & privacy

- **Android only (full features).** iOS does not allow background SMS access or cross-app notification interception; this project targets Android.  
- **WhatsApp chat content is not readable.** The app can only access notification text posted by WhatsApp if the user grants Notification Access. This may not include full message history.  
- **User consent and disclosure.** If you capture notification text or SMS, explicitly disclose what is collected and why. Do not store or transmit messages without user consent.  
- **Do not store secrets in the client.** API keys (for Gemini or other services) must be stored only on a secure backend, not embedded in the app.

---

## Quick start

### Prerequisites

- Flutter SDK (stable channel).  
- Android device or emulator (API 26+ recommended). Use a physical device for reliable notification/SMS testing.  
- `adb` configured for device debugging.

### Architecture & detection workflow

- App receives incoming SMS via telephony and incoming notifications via notifications_listener.
- Incoming text is passed to a local detection pipeline:

- Normalize text (trim, lower-case).

- Rule checks: keyword list, regex for URLs/shorteners, phone number patterns, currency mentions.

- Scoring: each rule assigns a score; high score = suspicious.

- If configured, suspicious text is forwarded to a secure backend (HTTPS) which runs an AI classifier (e.g., using Gemini) and returns a label/score. The backend holds the API key and applies rate limits / privacy controls.

App displays detection result (safe / suspicious / score) with suggested actions (do not reply, verify sender, block contact).
