# Gemma4 Chat

![Flutter](https://img.shields.io/badge/Flutter-3.11.5-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11.5-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iOS-FF713B?logo=apple)

A Flutter chat application powered by local LLMs via LM Studio, with token usage tracking and future database support.

## Features

- **Local LLM Integration** - Connect to LM Studio running locally
- **Token Usage Tracking** - Real-time display of prompt/completion/total tokens
- **Context Length Monitoring** - Progress bar showing context fill level (max 131,072 tokens)
- **Cross-Platform** - macOS and iOS support
- **Provider State Management** - Clean architecture with ChangeNotifier
- **Isar Database Ready** - Pre-configured for future local storage

## Architecture

```
lib/
├── data/
│   ├── db_models/       # Database models (Isar)
│   └── models/          # API request/response models
├── presentation/
│   ├── chat/           # Chat page and widgets
│   │   └── widgets/    # ChatInput, TokenUsageInfo
│   ├── start/          # Start page
│   └── view_models/    # ChatViewModel
├── router/             # GoRouter configuration
└── service/
    └── api/            # GemmaApiService (OpenAI-compatible API)
```

## Tech Stack

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `go_router` | Navigation |
| `http` | HTTP client for API calls |
| `isar_community` | Local database (future) |
| `path_provider` | File system access |
| `uuid` | Unique identifiers |

## Getting Started

### Prerequisites

- Flutter SDK 3.11.5+
- LM Studio with a local server running on `http://localhost:1234`

### Installation

```bash
flutter pub get
flutter run -d macos  # or flutter run -d ios
```

### Configuration

The API base URL is configured in `lib/service/api/gemma_api_service.dart`:

```dart
static const String _baseUrl = "http://localhost:1234";
```

## Current Implementation

### Chat Functionality
- Send messages to local LLM via OpenAI-compatible API
- Display conversation history
- Loading indicator during API calls

### Token Tracking
- `promptTokens` - Tokens in user request
- `completionTokens` - Tokens in model response
- `totalTokens` - Sum of all tokens used
- Progress bar with color indicators (green/orange/red)

### macOS Entitlements
Network client permissions are configured in:
`macos/Runner/DebugProfile.entitlements`

## Roadmap

- [ ] **Database Integration** - Persist chat history with Isar
- [ ] **Multiple Chat Sessions** - Support for multiple conversations
- [ ] **Message Editing** - Edit previously sent messages
- [ ] **Chat Export** - Export conversation history
- [ ] **Settings Page** - Configure model, temperature, API endpoint
- [ ] **Streaming Responses** - Real-time token streaming

## License

MIT
