# Task Manager App - Release Build Guide

## Prerequisites
Before building for release, ensure you have:
- Android SDK and tools installed
- Java Development Kit (JDK)
- Flutter installed and updated

## Step 1: Update App Details (pubspec.yaml)

Current version: **1.0.0+1**

You can update the version before release:
```yaml
version: 1.0.0+1  # version_name+build_number
```

## Step 2: Create a Keystore (First Time Only)

Generate a signing key for your app:

```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Windows** (run in PowerShell):
```powershell
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You'll be prompted for:
- Password (remember it!)
- Name, organization, etc.

## Step 3: Create Key Properties File

Create `android/key.properties`:

```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=upload
storeFile=<path_to_keystore>
```

**Example for Windows:**
```properties
storePassword=mypassword123
keyPassword=mypassword123
keyAlias=upload
storeFile=C:\\Users\\DV.PRASAD\\upload-keystore.jks
```

## Step 4: Configure Android Build (build.gradle)

The file `android/app/build.gradle.kts` should already have signing configured.
Make sure it references your key.properties file.

## Step 5: Build Release APK

Run in terminal:

```bash
flutter build apk --release
```

**Output location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

This APK can be:
- Installed on devices for testing
- Distributed directly to users
- Uploaded to Play Store (less preferred, use AAB instead)

## Step 6: Build Android App Bundle (AAB) - Recommended for Play Store

```bash
flutter build appbundle --release
```

**Output location:**
```
build/app/outputs/bundle/release/app-release.aab
```

This is the **recommended format** for Google Play Store submission.

## Step 7: Sign the Release (if not auto-signed)

If not signed automatically, sign it manually:

```bash
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore <keystore_path> app-release.apk <alias>
```

## Play Store Submission Steps

1. **Create Google Play Developer Account** - $25 one-time fee
2. **Create App on Google Play Console**
3. **Upload AAB file** to Play Store
4. **Fill app details:**
   - App name: Task Manager
   - Short description
   - Full description
   - Screenshots
   - Category: Productivity
   - Content rating
   - Privacy policy
5. **Set pricing** (Free/Paid)
6. **Review and publish**

## Quick Build Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build APK (for direct installation/testing)
flutter build apk --release

# Build AAB (for Play Store)
flutter build appbundle --release

# Build both
flutter build apk --release && flutter build appbundle --release
```

## App Information

- **App Name:** Task Manager
- **Package Name:** com.example.my_first_flutter_app
- **Version:** 1.0.0 (build 1)
- **Min SDK:** Check android/app/build.gradle.kts
- **Target SDK:** Check android/app/build.gradle.kts

## Troubleshooting

**"key.properties not found"**
- Create android/key.properties with correct paths

**"Keystore password incorrect"**
- Re-enter the correct password in key.properties

**"App signing failed"**
- Ensure keystore file exists at the specified path
- Check that passwords are correct

**"Build fails with gradle error"**
- Run: `flutter clean`
- Run: `flutter pub get`
- Try building again

## Security Notes

⚠️ **Never commit key.properties or keystore to version control!**

Add to `.gitignore`:
```
android/key.properties
*.jks
*.keystore
```

## What's Next?

After building:
1. Test APK on real devices
2. Get feedback from testers
3. Upload AAB to Play Store
4. Monitor reviews and ratings
5. Plan updates for future versions
