# Local Development Setup Guide

## Firebase Configuration (Development Only)

This repository excludes Firebase configuration files for security reasons. To run this project locally, you need to set up your own Firebase credentials.

### Prerequisites
- Flutter 3.10.8+
- Firebase account (https://console.firebase.google.com)

### Setup Steps

#### 1. Add Firebase to Your Project

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

When prompted:
- Select your Firebase project
- Choose platforms: **Android** and **Web** (and others as needed)

#### 2. What Gets Generated

The `flutterfire configure` command creates:
- `lib/firebase_options.dart` - Your Firebase configuration (automatically generated)
- `android/app/google-services.json` - Android Firebase credentials
- `GoogleService-Info.plist` - iOS Firebase credentials (if selected)

#### 3. Enable Authentication in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Authentication**
4. Click **Sign-in method**
5. Enable **Email / Password** provider
6. Click **Save**

#### 4. Running the App

```bash
# Android Emulator / Device
flutter run

# Web (Chrome)
flutter run -d chrome

# iOS (requires macOS)
flutter run -d ios

# Clean build
flutter clean
flutter pub get
flutter run
```

## Important Security Notes

⚠️ **NEVER commit these files:**
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`
- Any `.env` or `.env.local` files

These are automatically added to `.gitignore` to prevent accidental exposure of API keys.

## Features Included

✅ Firebase Authentication (Email/Password)
✅ Hive local database for task persistence
✅ User-specific task management
✅ Modern Material Design UI
✅ Cross-platform support (Android, iOS, Web, macOS, Windows, Linux)
✅ Task categorization and status tracking
✅ Beautiful animations and transitions

## Troubleshooting

### InvalidAPIKeyError on Web
- Ensure `lib/firebase_options.dart` is created
- Verify Firebase Web SDK is enabled in Firebase Console

### Cannot find google-services.json
- Run `flutterfire configure` with Android platform selected
- Check that file exists at `android/app/google-services.json`

### Authentication errors
- Enable Email/Password authentication in Firebase Console
- Check that `enableOfflineAddressImporter` is set correctly for your region

## Future Enhancements

- [ ] Google Sign-In
- [ ] Biometric authentication
- [ ] Cloud Firestore for cloud sync
- [ ] Offline support with sync
- [ ] Push notifications
- [ ] Dark mode

## Support

For issues or questions:
1. Check [Flutter Documentation](https://flutter.dev)
2. Visit [Firebase Documentation](https://firebase.google.com/docs)
3. Review [FlutterFire Setup Guide](https://firebase.flutter.dev)
