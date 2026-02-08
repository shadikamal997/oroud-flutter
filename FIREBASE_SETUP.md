# Firebase Push Notifications Setup Guide

## ✅ Code Integration Complete

The Flutter app is now configured for Firebase Cloud Messaging:
- ✅ Notification service created
- ✅ Device token registration implemented
- ✅ Foreground/background message handlers ready
- ✅ Backend endpoint connected (`/notifications/register-device`)

## 🔧 Firebase Console Setup (Required Steps)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it: **Oroud**
4. Follow the wizard (disable Google Analytics if not needed)

### Step 2: Add Android App

1. In Firebase project, click "Add app" → Android icon
2. **Package name**: Check `android/app/build.gradle` for `applicationId`
   - Usually: `com.example.oroud_app` or similar
3. **App nickname**: Oroud Android
4. **SHA-1**: Optional for now (needed for Google Sign-In)
5. Click "Register app"

### Step 3: Download Configuration File

1. Download `google-services.json`
2. Place it in: `android/app/google-services.json`

### Step 4: Update Android Build Files

**In `android/build.gradle`** (project-level):
```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath 'com.google.gms:google-services:4.3.15'  // Add this line
    }
}
```

**In `android/app/build.gradle`** (app-level):
Add at the **bottom** of the file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 5: Test Notification

After completing setup:
```bash
cd /Users/shadi/Desktop/oroud_app
flutter run
```

Device token will be printed in console:
```
Device token registered: eXaMpLeToKeN123...
```

## 🔔 Backend Integration

The app automatically:
1. **On launch** → Requests permission → Gets FCM token
2. **Sends token** → `POST /notifications/register-device`
3. **Token refresh** → Re-sends to backend
4. **Receives notifications** → Handles foreground/background

### Backend Can Now:
- Send city-based notifications
- Push Crazy Deals at 7 PM
- Target specific users
- Admin broadcast messages

## 📱 Notification Types Supported

### Foreground (App Open)
Currently prints to console. Later add in-app banner.

### Background (App Minimized)
Handled by system notification tray.

### Terminated (App Closed)
User taps notification → app opens.

## 🧪 Testing from Backend

Use your NestJS admin endpoint:
```bash
curl -X POST http://localhost:3000/api/admin/notify \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Notification",
    "body": "Firebase is working!",
    "cityId": "1"
  }'
```

## 🚀 Next Steps

1. **Complete Firebase setup** (above steps)
2. **Test device registration** (check console logs)
3. **Send test notification** from Firebase Console
4. **Verify backend integration** works
5. **Add in-app notification banner** (optional enhancement)

## 🔐 iOS Setup (Future)

When ready for iOS:
1. Add iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Place in `ios/Runner/`
4. Update iOS capabilities for push notifications

---

**Current Status**: Flutter code ready ✅ | Firebase setup required 🔧
