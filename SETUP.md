# 🔐 Project Setup Guide

This guide will help you set up your own Firebase project and configure the app for development or deployment.

## 🚨 Important Security Notice

**NEVER commit the following files to GitHub:**
- `lib/firebase_options.dart` (contains Firebase API keys)
- `android/app/google-services.json` (Android Firebase config)
- `ios/Runner/GoogleService-Info.plist` (iOS Firebase config)
- `.env` files (environment variables)

These files are already added to `.gitignore` to prevent accidental commits.

---

## 📋 Prerequisites

- Flutter SDK (latest stable version)
- Firebase account (free tier is sufficient)
- Code editor (VS Code recommended)
- Git

---

## 🔥 Firebase Setup

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name (e.g., "my-meal-planner")
4. Follow the setup wizard (you can disable Google Analytics if not needed)

### Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable the following sign-in methods:
   - **Email/Password** (required)
   - **Google** (optional)
4. Configure email verification settings if needed

### Step 3: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose **Start in production mode** (we have custom rules)
4. Select your preferred region
5. Copy the security rules from `firestore.rules` and paste them in the Rules tab

### Step 4: Set Up Firestore Indexes

Run the provided script to set up required indexes:

**On Windows:**
```bash
.\setup-indexes.bat
```

**On Mac/Linux:**
```bash
chmod +x setup-indexes.sh
./setup-indexes.sh
```

Or manually create indexes from `firestore.indexes.json` in Firebase Console.

### Step 5: Set Up Storage

1. In Firebase Console, go to **Storage**
2. Click "Get started"
3. Choose **Start in production mode**
4. Copy the security rules from `firestore.rules` (storage section) to Storage Rules

---

## 📱 Platform Configuration

### For Android

1. In Firebase Console, click **Add app** → **Android**
2. Enter package name: `com.example.my_app` (or your custom package)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### For iOS

1. In Firebase Console, click **Add app** → **iOS**
2. Enter bundle ID: `com.example.myApp` (or your custom bundle ID)
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### For Web

1. In Firebase Console, click **Add app** → **Web**
2. Register your app
3. Copy the Firebase configuration

---

## 🛠️ Flutter Configuration

### Step 1: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Step 2: Generate firebase_options.dart

```bash
flutterfire configure
```

This will:
- Detect your Firebase projects
- Let you select which project to use
- Automatically generate `lib/firebase_options.dart` with your Firebase config

### Step 3: Configure API Base URL

Choose one of these methods:

#### Option A: Using dart-define (Recommended for CI/CD)

Run your app with:
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

Build with:
```bash
flutter build apk --dart-define=API_BASE_URL=https://your-api.com
```

#### Option B: Update EnvConfig directly

Edit `lib/config/env_config.dart` and change the `defaultValue`:
```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'YOUR_API_URL_HERE',  // Change this
);
```

---

## 🚀 Running the App

### Development Mode

```bash
# Run with local API
flutter run --dart-define=API_BASE_URL=http://localhost:8000

# Run with production API
flutter run --dart-define=API_BASE_URL=https://your-api.com --dart-define=ENVIRONMENT=production
```

### Building for Production

```bash
# Android
flutter build apk --dart-define=API_BASE_URL=https://your-api.com --dart-define=ENVIRONMENT=production

# iOS
flutter build ios --dart-define=API_BASE_URL=https://your-api.com --dart-define=ENVIRONMENT=production

# Web
flutter build web --dart-define=API_BASE_URL=https://your-api.com --dart-define=ENVIRONMENT=production
```

---

## 🔧 Backend API Setup

This app requires a FastAPI backend. You have two options:

### Option 1: Local Development

1. See `API_IMPLEMENTATION_ROADMAP.md` for API specifications
2. Run your FastAPI server locally (usually on `http://localhost:8000`)
3. Configure the app to use local API:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://localhost:8000
   ```

### Option 2: Deploy to Cloud

Deploy your FastAPI backend to:
- Google Cloud Run
- AWS Lambda
- Heroku
- DigitalOcean
- Or any cloud provider

Then update the API_BASE_URL to your deployed URL.

---

## 📦 Dependencies

Install Flutter dependencies:

```bash
flutter pub get
```

Key packages used:
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage
- `http` - API calls
- `provider` - State management

---

## ✅ Verification Checklist

Before running the app, ensure:

- [ ] Firebase project created
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore database created with security rules
- [ ] Firestore indexes created
- [ ] Storage enabled with security rules
- [ ] Platform-specific Firebase configs added:
  - [ ] `google-services.json` for Android
  - [ ] `GoogleService-Info.plist` for iOS
- [ ] `firebase_options.dart` generated via FlutterFire CLI
- [ ] API base URL configured
- [ ] All sensitive files are in `.gitignore`
- [ ] `flutter pub get` completed successfully

---

## 🐛 Troubleshooting

### "FirebaseOptions have not been configured"
- Run `flutterfire configure` to generate Firebase configuration

### "API connection failed"
- Check if your backend API is running
- Verify API_BASE_URL is correct
- Check network connectivity

### "Authentication failed"
- Ensure Email/Password auth is enabled in Firebase Console
- Check Firebase security rules

### Android build fails
- Ensure `google-services.json` is in `android/app/`
- Check package name matches Firebase config

### iOS build fails
- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Check bundle ID matches Firebase config

---

## 🤝 Contributing

When contributing to this project:

1. **Never commit sensitive files** - they're in `.gitignore`
2. Use your own Firebase project for testing
3. Document any configuration changes
4. Test on multiple platforms before submitting PR

---

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Flutter Documentation](https://flutter.dev/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

---

## 🔒 Security Best Practices

1. **API Keys in Firebase**: Firebase API keys for client apps are safe to include in code as they're protected by Firebase security rules
2. **Backend API Keys**: Any backend API keys (OpenAI, payment processors, etc.) should ONLY be on the server
3. **Environment Variables**: Use `--dart-define` for sensitive configuration
4. **Security Rules**: Always set up proper Firestore and Storage security rules
5. **HTTPS**: Always use HTTPS for production APIs

---

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Firebase Console for any errors
3. Check API server logs
4. Create an issue in the repository (without sensitive information!)

---

**Happy Coding! 🎉**
