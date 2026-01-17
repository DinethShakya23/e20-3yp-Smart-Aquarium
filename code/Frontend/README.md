# AquaSense Frontend

A Flutter-based mobile application for the AquaSense Smart Aquarium Monitoring & Control System.

## Features

- 📱 Real-time sensor data monitoring (pH, temperature, turbidity)
- 📹 Live video streaming from aquarium
- 🎮 Remote control of feeding and temperature systems
- 📊 Historical data visualization and trends
- 🔔 Push notifications for alerts
- 👤 User authentication and profile management

## Prerequisites

- **Flutter SDK** (v3.0 or higher)
- **Dart** (v2.17 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)

## Installation

### 1. Install Flutter SDK

Follow the official Flutter installation guide:
- [Windows](https://docs.flutter.dev/get-started/install/windows)
- [macOS](https://docs.flutter.dev/get-started/install/macos)
- [Linux](https://docs.flutter.dev/get-started/install/linux)

Verify installation:
```bash
flutter doctor
```

### 2. Clone and Setup

```bash
cd code/Frontend
flutter pub get
```

### 3. Configure Backend Connection

Update the API base URL in `lib/services/api_service.dart`:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:3001/api';

// For Physical Device (replace with your computer's IP)
static const String baseUrl = 'http://192.168.1.100:3001/api';

// For iOS Simulator
static const String baseUrl = 'http://localhost:3001/api';
```

## Project Structure

```
Frontend/
├── lib/
│   ├── main.dart              # Application entry point
│   ├── screens/               # UI screens
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── sensors_screen.dart
│   │   ├── control_screen.dart
│   │   └── profile_screen.dart
│   ├── widgets/               # Reusable UI components
│   │   ├── custom_button.dart
│   │   ├── sensor_card.dart
│   │   └── chart_widget.dart
│   ├── services/              # Backend API integration
│   │   ├── api_service.dart
│   │   └── auth_service.dart
│   ├── models/                # Data models
│   │   ├── user.dart
│   │   └── sensor_data.dart
│   └── utils/                 # Utility functions
│       └── constants.dart
├── android/                   # Android-specific files
├── ios/                       # iOS-specific files
├── pubspec.yaml               # Dependencies configuration
└── README.md
```

## Running the App

### Development Mode

```bash
# List available devices
flutter devices

# Run on connected device or emulator
flutter run

# Run with hot reload
flutter run --debug

# Run on specific device
flutter run -d <device_id>
```

### Build Release Version

#### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Dependencies

Key packages used in this project:

- `http` - HTTP requests to backend API
- `provider` - State management
- `shared_preferences` - Local storage
- `fl_chart` - Data visualization charts
- `video_player` - Video streaming
- `firebase_messaging` - Push notifications

See `pubspec.yaml` for complete list.

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Troubleshooting

### Common Issues

#### "Flutter command not found"
- Ensure Flutter SDK is in your PATH
- Run `flutter doctor` to diagnose

#### "Gradle build failed"
- Clean project: `flutter clean`
- Clear Gradle cache: `cd android && ./gradlew clean`
- Check JDK version (JDK 11 recommended)

#### "Unable to connect to backend"
- Verify backend is running at configured URL
- Check firewall settings
- For emulator, use `10.0.2.2` instead of `localhost`

#### "Packages get failed"
- Check internet connection
- Try `flutter pub cache repair`
- Delete `pubspec.lock` and run `flutter pub get` again

#### Hot reload not working
- Stop app and run `flutter clean`
- Restart IDE
- Check for syntax errors

## Development Guidelines

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Keep files under 500 lines
- Extract reusable widgets

### State Management
- Use Provider for global state
- Use StatefulWidget for local component state
- Avoid setState for complex state logic

### API Integration
- All API calls should go through `services/api_service.dart`
- Handle errors gracefully with user-friendly messages
- Implement loading states for async operations

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Material Design Guidelines](https://material.io/design)

## Support

For issues specific to the frontend:
1. Check existing issues in the repository
2. Review Flutter doctor output: `flutter doctor -v`
3. Contact development team
