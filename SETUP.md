# AgriConnect — Flutter App Setup Guide

## Project structure
```
agriconnect_flutter/
├── pubspec.yaml
├── android/
│   ├── build.gradle               ← root gradle with google-services
│   └── app/
│       ├── build.gradle           ← app gradle with Firebase deps
│       ├── google-services.json   ← ⚠️  YOU ADD THIS
│       └── src/main/
│           └── AndroidManifest.xml
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist  ← ⚠️  YOU ADD THIS
└── lib/
    ├── main.dart
    ├── utils/
    │   ├── app_theme.dart
    │   └── app_router.dart
    ├── models/models.dart
    ├── providers/
    │   ├── auth_provider.dart
    │   ├── marketplace_provider.dart
    │   ├── orders_provider.dart
    │   ├── prices_provider.dart
    │   └── advisory_provider.dart
    ├── services/
    │   └── notification_service.dart
    ├── widgets/common_widgets.dart
    └── screens/
        ├── auth/login_screen.dart
        ├── auth/register_screen.dart
        ├── dashboard/dashboard_screen.dart
        ├── marketplace/marketplace_screen.dart
        ├── marketplace/add_listing_screen.dart
        ├── advisory/advisory_screen.dart
        ├── orders/orders_screen.dart
        ├── trends/price_trends_screen.dart
        └── profile/profile_screen.dart
```

---

## Step 1 — Install Flutter
Download from https://docs.flutter.dev/get-started/install
Verify installation:
```bash
flutter doctor
```

---

## Step 2 — Create Firebase project

1. Go to https://console.firebase.google.com
2. Click "Add project" → name it `agriconnect`
3. Enable Google Analytics (optional)
4. Click "Continue" → project is created

### Enable Firebase services:
- **Authentication** → Sign-in method → Email/Password → Enable
- **Firestore Database** → Create database → Start in test mode → choose region
- **Storage** → Get started → test mode
- **Cloud Messaging** → already enabled by default

---

## Step 3 — Add Firebase to Android

1. In Firebase console → Project settings → Your apps → Add app → Android
2. Android package name: `com.agriconnect.app`
3. Download `google-services.json`
4. Place it at: `android/app/google-services.json`

---

## Step 4 — Add Firebase to iOS

1. In Firebase console → Project settings → Your apps → Add app → iOS
2. iOS bundle ID: `com.agriconnect.app`
3. Download `GoogleService-Info.plist`
4. Open Xcode: `open ios/Runner.xcworkspace`
5. Drag `GoogleService-Info.plist` into the `Runner` folder in Xcode
6. Make sure "Copy items if needed" is checked

---

## Step 5 — Add API keys

### Gemini AI (for Smart Advisory)
1. Go to https://makersuite.google.com/app/apikey
2. Click "Create API key"
3. Open `lib/providers/advisory_provider.dart`
4. Replace: `const _geminiKey = 'YOUR_GEMINI_API_KEY';`

### OpenWeatherMap (for weather in Advisory)
1. Go to https://openweathermap.org/api → Sign up free
2. Go to API keys → copy your key
3. Open `lib/providers/advisory_provider.dart`
4. Replace: `const _weatherKey = 'YOUR_OPENWEATHER_API_KEY';`

---

## Step 6 — Install dependencies and run

```bash
# Navigate to project folder
cd agriconnect_flutter

# Install all packages
flutter pub get

# Run on connected device or emulator
flutter run

# Build APK for release
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## Step 7 — Firestore security rules

In Firebase console → Firestore → Rules → paste:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isOwner(uid) { return request.auth.uid == uid; }

    match /users/{uid} {
      allow read: if isSignedIn();
      allow create, update: if isOwner(uid);
    }
    match /listings/{id} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && resource.data.farmerId == request.auth.uid;
    }
    match /orders/{id} {
      allow read: if isSignedIn() &&
        (resource.data.buyerId == request.auth.uid ||
         resource.data.farmerId == request.auth.uid);
      allow create: if isSignedIn();
      allow update: if isSignedIn();
    }
    match /prices/{id} {
      allow read: if isSignedIn();
      allow write: if false;
    }
    match /advisory/{id} {
      allow read, write: if isSignedIn();
    }
  }
}
```

---

## Step 8 — Firestore indexes (required for queries)

Go to Firebase console → Firestore → Indexes → Add index:

| Collection | Fields                          | Query scope |
|------------|----------------------------------|-------------|
| listings   | status ASC, createdAt DESC       | Collection  |
| orders     | buyerId ASC, createdAt DESC      | Collection  |
| orders     | farmerId ASC, createdAt DESC     | Collection  |
| prices     | updatedAt DESC                   | Collection  |

---

## Common errors & fixes

| Error | Fix |
|-------|-----|
| `google-services.json not found` | Add the file to `android/app/` |
| `minSdk version too low` | Set `minSdk 21` in `android/app/build.gradle` |
| `Firebase not initialized` | Call `await Firebase.initializeApp()` before `runApp()` |
| `PigeonUserDetails error` | Run `flutter clean && flutter pub get` |
| `Firestore permission denied` | Check security rules — use test mode during dev |
| `Gemini 403 error` | API key not set or quota exceeded |
| `Weather API 401` | OpenWeather key not set or not activated yet (takes 2hrs) |

---

## API keys summary

| Key | File | Where to get |
|-----|------|-------------|
| Gemini AI | `advisory_provider.dart` | makersuite.google.com |
| OpenWeather | `advisory_provider.dart` | openweathermap.org/api |
| google-services.json | `android/app/` | Firebase console |
| GoogleService-Info.plist | `ios/Runner/` | Firebase console |
