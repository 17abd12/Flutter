# 🔐 Security & Setup Information

## ⚠️ Important: Before Using This Project

This project contains **template configuration files only**. You must set up your own Firebase project and API backend to use this app.

### 🚨 Files NOT Included (You Must Create)

The following files are **required** but **not included** in this repository for security reasons:

- `lib/firebase_options.dart` - Your Firebase configuration
- `android/app/google-services.json` - Android Firebase config  
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config
- `.env` - Your environment variables

### 📋 Quick Start

1. **Read the setup guide**: See [SETUP.md](SETUP.md) for detailed instructions
2. **Create Firebase project**: Follow the Firebase setup section
3. **Generate configuration**: Run `flutterfire configure`
4. **Configure API**: Set your API base URL using `--dart-define`
5. **Run the app**: `flutter run --dart-define=API_BASE_URL=http://localhost:8000`

### 🔒 Security Features

✅ Firebase API keys protected by `.gitignore`  
✅ Environment-based configuration  
✅ Template files for reference  
✅ Secure by default setup  
✅ Open-source friendly structure  

### 📚 Documentation

- [SETUP.md](SETUP.md) - Complete setup guide
- [API_IMPLEMENTATION_ROADMAP.md](API_IMPLEMENTATION_ROADMAP.md) - API specifications
- `.env.example` - Environment variables template

---

**Note**: If you cloned this repository, you'll need to create your own Firebase project and configuration files before the app will work. See [SETUP.md](SETUP.md) for instructions.
