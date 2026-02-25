# 🔥 Firebase Console Setup Guide
## Complete Configuration in 15 Minutes

---

## 📱 Your SHA-1 Certificate (Ready to Use!)

```
SHA1: D3:7D:BA:77:7F:3E:3C:D8:25:03:F3:02:82:30:6E:B7:18:4F:B3:F6
```

**You'll need this in Step 3 below** ⬇️

---

## Step 1: Enable Authentication Methods (5 minutes)

### 1.1 Open Firebase Console
1. Go to: https://console.firebase.google.com
2. Select your project: **oroud-62a97**

### 1.2 Navigate to Authentication
1. In the left sidebar, click **Build**
2. Click **Authentication**
3. Click the **Sign-in method** tab

### 1.3 Enable Email/Password
1. Click on **Email/Password** in the providers list
2. Toggle **Enable** to ON (should turn blue)
3. **Optional:** Toggle "Email link (passwordless sign-in)" if you want passwordless login
4. Click **Save**

✅ **You should see:** Email/Password shows "Enabled" in green

### 1.4 Enable Google Sign-In
1. Click on **Google** in the providers list
2. Toggle **Enable** to ON
3. **Project support email:** Enter your email (required)
   - Example: `your.email@gmail.com`
4. Click **Save**

✅ **You should see:** Google shows "Enabled" in green

### 1.5 Enable Apple Sign-In (iOS)
1. Click on **Apple** in the providers list
2. Toggle **Enable** to ON
3. Click **Save**

✅ **You should see:** Apple shows "Enabled" in green

**Note:** For production Apple Sign-In on iOS, you'll need additional configuration in your Apple Developer account.

### 1.6 Enable Phone Authentication (Optional)
1. Click on **Phone** in the providers list
2. Toggle **Enable** to ON
3. Click **Save**

✅ **You should see:** Phone shows "Enabled" in green

**Note:** Phone auth requires reCAPTCHA configuration for web, but works automatically on mobile.

---

## Step 2: Configure Project Settings (2 minutes)

### 2.1 Open Project Settings
1. Click the **⚙️ gear icon** in the left sidebar (next to "Project Overview")
2. Click **Project settings**

### 2.2 Verify Your Apps
Scroll down to **Your apps** section. You should see:
- 📱 **Android app** (e.g., `com.example.oroud_app`)
- 🍎 **iOS app** (if you've added it)

**If you don't see your Android app:**
1. Click **Add app** → Select **Android**
2. **Android package name:** Find it in `/Users/shadi/Desktop/oroud_app/android/app/build.gradle`
   - Look for `applicationId "com.example.oroud_app"` (or similar)
3. **App nickname:** `Oroud Android` (optional)
4. Click **Register app**
5. Download `google-services.json` (you'll need this in Step 3)

---

## Step 3: Add SHA-1 Certificate (5 minutes)

This is **CRITICAL** for Google Sign-In to work!

### 3.1 Add SHA-1 to Firebase
1. Still in **Project settings**
2. Scroll to **Your apps** → Select your **Android app**
3. Scroll down to **SHA certificate fingerprints**
4. Click **Add fingerprint**
5. **Paste your SHA-1:**
   ```
   D3:7D:BA:77:7F:3E:3C:D8:25:03:F3:02:82:30:6E:B7:18:4F:B3:F6
   ```
6. Click **Save**

✅ **You should see:** Your SHA-1 appears in the fingerprints list

### 3.2 Download Updated google-services.json
**IMPORTANT:** After adding SHA-1, you MUST download the updated config file!

1. Still on the same page (Your Android app settings)
2. Scroll down and click **google-services.json** (download button)
3. Save the file to your computer

### 3.3 Replace google-services.json
**Replace the file in your project:**

**Option A - Using Finder:**
1. Open Finder
2. Navigate to: `/Users/shadi/Desktop/oroud_app/android/app/`
3. **Delete** the old `google-services.json` (if exists)
4. **Copy** the new `google-services.json` you just downloaded
5. **Paste** it into `/Users/shadi/Desktop/oroud_app/android/app/`

**Option B - Using Terminal:**
```bash
# Assuming you downloaded to ~/Downloads
cp ~/Downloads/google-services.json /Users/shadi/Desktop/oroud_app/android/app/google-services.json
```

✅ **Verify:** File exists at `/Users/shadi/Desktop/oroud_app/android/app/google-services.json`

---

## Step 4: iOS Configuration (Optional - 10 minutes)

**Note:** Only needed if you plan to release on iOS. Skip for now if testing on Android only.

### 4.1 Download GoogleService-Info.plist
1. In Firebase Console → **Project settings**
2. Under **Your apps**, select your **iOS app** (or add one if not exists)
3. Download **GoogleService-Info.plist**

### 4.2 Add to Xcode Project
1. Open Xcode: `/Users/shadi/Desktop/oroud_app/ios/Runner.xcworkspace`
2. Right-click on **Runner** folder in Xcode
3. Select **Add Files to "Runner"...**
4. Select `GoogleService-Info.plist`
5. Make sure **Copy items if needed** is checked
6. Click **Add**

### 4.3 Enable Sign in with Apple Capability
1. In Xcode, select **Runner** (the project, not the folder)
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for **Sign in with Apple**
6. Click to add it

✅ **You should see:** "Sign in with Apple" in the capabilities list

---

## Step 5: Verification Checklist

Before testing, verify all these boxes are checked:

### Firebase Console
- [ ] Email/Password authentication enabled
- [ ] Google Sign-In enabled
- [ ] Apple Sign-In enabled
- [ ] Phone authentication enabled (optional)
- [ ] SHA-1 certificate added to Android app
- [ ] google-services.json downloaded and replaced

### Project Files
- [ ] `/Users/shadi/Desktop/oroud_app/android/app/google-services.json` exists
- [ ] Backend server running on http://localhost:3000
- [ ] Flutter packages installed (`firebase_auth`, `google_sign_in`, `sign_in_with_apple`)

### Optional (iOS)
- [ ] GoogleService-Info.plist added to Xcode project
- [ ] Sign in with Apple capability enabled in Xcode

---

## Step 6: Testing! 🎉

Now you're ready to test the authentication!

### 6.1 Start Backend Server (if not running)
```bash
cd /Users/shadi/Desktop/oroud
npm run start:dev
```

Wait for: `Application is running on http://localhost:3000`

### 6.2 Run Flutter App
```bash
cd /Users/shadi/Desktop/oroud_app
flutter run
```

Or if you have a specific device:
```bash
flutter run -d CPH2237  # Your device ID
```

### 6.3 Test Each Authentication Method

#### Test 1: Email/Password Registration (Firebase)
1. Open the app → Go to **Register** screen
2. Fill in all fields (name, email, password, etc.)
3. Click **Join the Community**
4. ✅ **Expected:** Account created, email verification sent, logged in

#### Test 2: Google Sign-In
1. On **Login** or **Register** screen
2. Click **Continue with Google** button
3. Select your Google account
4. ✅ **Expected:** Google picker appears, sign-in successful, logged in

**Troubleshooting:**
- If you see "Error 10" or "Sign-in failed":
  - Verify SHA-1 is added to Firebase Console
  - Verify google-services.json is updated
  - Run: `flutter clean && flutter run`

#### Test 3: Apple Sign-In (iOS only)
1. On **Login** or **Register** screen
2. Click **Continue with Apple** button
3. Authenticate with Face ID/Touch ID
4. ✅ **Expected:** Apple ID prompt, sign-in successful, logged in

**Note:** Won't work on Android - that's normal!

#### Test 4: Traditional Email/Password (JWT - Legacy)
1. On **Login** screen
2. Enter email and password (existing user)
3. Click **Sign In**
4. ✅ **Expected:** Login successful (using JWT token)

This verifies **hybrid authentication** is working!

---

## 🐛 Common Issues & Solutions

### Issue 1: "Error 10" during Google Sign-In
**Cause:** SHA-1 not configured or google-services.json not updated

**Solution:**
1. Verify SHA-1 is in Firebase Console
2. Download fresh google-services.json
3. Replace the file in `android/app/`
4. Run:
   ```bash
   cd /Users/shadi/Desktop/oroud_app
   flutter clean
   flutter pub get
   flutter run
   ```

### Issue 2: "Backend authentication failed"
**Cause:** Backend server not running or wrong URL

**Solution:**
1. Check backend is running:
   ```bash
   curl http://localhost:3000/api/health
   ```
2. If not running:
   ```bash
   cd /Users/shadi/Desktop/oroud
   npm run start:dev
   ```

### Issue 3: "Firebase token verification failed"
**Cause:** Firebase service account not configured

**Solution:**
1. Verify `config/firebase-service-account.json` exists in backend
2. Restart backend server

### Issue 4: Apple Sign-In not working
**Cause:** iOS-only feature

**Solution:**
- Test on iOS device or iOS simulator
- Won't work on Android (expected behavior)

### Issue 5: "PlatformException" during Google Sign-In
**Cause:** Package version incompatibility

**Solution:**
```bash
cd /Users/shadi/Desktop/oroud_app
flutter clean
flutter pub get
```

---

## 📊 What to Expect

### Successful Google Sign-In Flow:
```
Click "Continue with Google"
         ↓
Google account picker appears
         ↓
Select account
         ↓
"Signing in..." loading
         ↓
Firebase authentication complete
         ↓
Backend creates/links account
         ↓
Navigate to home screen
         ↓
Success! 🎉
```

### Backend Logs (Successful Auth):
```
🔥 Firebase token received
✅ Firebase UID verified: abc123...
🔗 Linking Firebase UID to user...
✅ User authenticated successfully
```

### Flutter Logs (Successful Auth):
```
🔵 Starting Google Sign-In...
✅ Google user selected: user@gmail.com
🔑 Google credentials obtained, signing in to Firebase...
✅ Google Sign-In successful: user@gmail.com
🔗 Authenticating with backend using Firebase token...
✅ Backend authentication successful!
```

---

## 🎯 Success Criteria

You'll know everything is working when:

1. ✅ **Email/Password Registration:**
   - Creates account in Firebase
   - Sends email verification
   - Creates user in your database
   - Logs in successfully

2. ✅ **Google Sign-In:**
   - Shows Google account picker
   - Signs in to Firebase
   - Creates/links backend user
   - Navigates to home screen

3. ✅ **Apple Sign-In:** (iOS only)
   - Shows Apple ID prompt
   - Signs in to Firebase
   - Creates/links backend user
   - Navigates to home screen

4. ✅ **Hybrid Auth:**
   - Existing JWT users can still login
   - Firebase users get Firebase tokens
   - Both work with all API endpoints

---

## 📞 Need Help?

### Check Backend Status:
```bash
curl http://localhost:3000/api/health
```

### Check Backend Logs:
```bash
tail -f /tmp/oroud-backend.log
```

### Check Flutter Logs:
Enable verbose logging in your IDE or terminal

### Verify Firebase Configuration:
```bash
cd /Users/shadi/Desktop/oroud_app
cat android/app/google-services.json | grep project_id
# Should show: "project_id": "oroud-62a97"
```

---

## 🎉 You're Done!

Once all tests pass, your Firebase Authentication is **fully configured and working**!

### What You've Accomplished:
- ✅ Full social login integration (Google, Apple)
- ✅ Email/Password with email verification
- ✅ Phone authentication (optional)
- ✅ Hybrid authentication (backward compatible)
- ✅ Secure token management
- ✅ Beautiful UI with social buttons
- ✅ Production-ready authentication system

**Congratulations!** 🎊

---

**Setup Date:** February 24, 2026  
**Status:** Ready for Testing  
**Estimated Time:** 15 minutes  
**Difficulty:** Easy (just follow the steps!)
