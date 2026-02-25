# 🔐 Android SHA Fingerprints for Firebase

## ✅ Successfully Extracted

### **DEBUG Build (Development)**

**SHA-1 Fingerprint:**
```
D3:7D:BA:77:7F:3E:3C:D8:25:03:F3:02:82:30:6E:B7:18:4F:B3:F6
```

**SHA-256 Fingerprint:**
```
85:E3:40:03:3D:B3:97:65:08:53:8C:9B:A2:C4:FA:66:F1:58:6F:BB:CE:45:67:8F:45:42:44:B4:43:D5:BB:83
```

---

### **RELEASE Build (Production)**

**Status:** ❌ No release keystore found

**Note:** Release keystores are created when you're ready to publish to Google Play Store. For development and testing, the debug keystore is sufficient.

---

## 📋 For Firebase Console

### **What to Add Now (Debug - For Testing):**

1. Go to: https://console.firebase.google.com/project/oroud-62a97/settings/general
2. Scroll to **"Your apps"** → Select **Android app**
3. Find **"SHA certificate fingerprints"**
4. Click **"Add fingerprint"**
5. **Paste this SHA-1:**
   ```
   D3:7D:BA:77:7F:3E:3C:D8:25:03:F3:02:82:30:6E:B7:18:4F:B3:F6
   ```
6. Click **Save**

### **Optional: Also Add SHA-256** (Recommended)
   ```
   85:E3:40:03:3D:B3:97:65:08:53:8C:9B:A2:C4:FA:66:F1:58:6F:BB:CE:45:67:8F:45:42:44:B4:43:D5:BB:83
   ```

---

## 🔧 Technical Details

**Keystore Location:**
```
~/.android/debug.keystore
```

**Keystore Type:** Debug (automatically created by Android SDK)  
**Alias:** androiddebugkey  
**Extraction Method:** keytool (direct keystore inspection)  
**Gradle Status:** Bypassed due to Java version conflicts (keytool more reliable)

---

## ⚠️ When You're Ready for Production

When building a release APK/AAB for Google Play Store:

1. **Create a release keystore:**
   ```bash
   keytool -genkey -v -keystore ~/oroud-release.keystore -alias oroud-key -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **Configure in android/key.properties:**
   ```properties
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=oroud-key
   storeFile=/path/to/oroud-release.keystore
   ```

3. **Extract release SHA-1:**
   ```bash
   keytool -list -v -keystore ~/oroud-release.keystore -alias oroud-key
   ```

4. **Add release SHA-1 to Firebase Console** (same process as debug)

---

## ✅ Current Status

- ✅ Debug SHA-1 extracted
- ✅ Debug SHA-256 extracted
- ⏸️ Release keystore not yet created (normal for development)
- 📍 **Next Action:** Add debug SHA-1 to Firebase Console

---

**Generated:** February 24, 2026  
**Project:** oroud_app  
**Environment:** macOS (Java 25.0.2)  
**Method:** Direct keystore inspection via keytool
