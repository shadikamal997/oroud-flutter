# 🔥 Firebase Console Setup - Step by Step Checklist

## Step 1: Configure Firebase Console ⏱️ 5 minutes

### Current Task: Enable Authentication Methods

**Firebase Console URL:** https://console.firebase.google.com/project/oroud-62a97/authentication/providers

---

## ✅ Task 1.1: Enable Email/Password Authentication

**Instructions:**
1. [ ] You should see a list of "Sign-in providers"
2. [ ] Find **Email/Password** in the list
3. [ ] Click on **Email/Password** row
4. [ ] Toggle the **Enable** switch to ON (should turn blue)
5. [ ] (Optional) Toggle "Email link (passwordless sign-in)" if you want passwordless login
6. [ ] Click **Save** button at the bottom
7. [ ] Verify: Status shows "Enabled" in green

**Status:** ⬜ Not Started / ⏳ In Progress / ✅ Complete

---

## ✅ Task 1.2: Enable Google Sign-In

**Instructions:**
1. [ ] In the same "Sign-in providers" list
2. [ ] Find **Google** in the list
3. [ ] Click on **Google** row
4. [ ] Toggle the **Enable** switch to ON
5. [ ] **IMPORTANT:** Enter "Project support email"
   - Use your Google email address
   - Example: `your.email@gmail.com`
6. [ ] Click **Save** button
7. [ ] Verify: Status shows "Enabled" in green

**Status:** ⬜ Not Started / ⏳ In Progress / ✅ Complete

---

## ✅ Task 1.3: Enable Apple Sign-In

**Instructions:**
1. [ ] In the same "Sign-in providers" list
2. [ ] Find **Apple** in the list
3. [ ] Click on **Apple** row
4. [ ] Toggle the **Enable** switch to ON
5. [ ] Click **Save** button
6. [ ] Verify: Status shows "Enabled" in green

**Note:** For production iOS apps, additional Apple Developer setup is needed, but we can enable it now.

**Status:** ⬜ Not Started / ⏳ In Progress / ✅ Complete

---

## ✅ Task 1.4: Enable Phone Authentication (Optional)

**Instructions:**
1. [ ] In the same "Sign-in providers" list
2. [ ] Find **Phone** in the list
3. [ ] Click on **Phone** row
4. [ ] Toggle the **Enable** switch to ON
5. [ ] Click **Save** button
6. [ ] Verify: Status shows "Enabled" in green

**Note:** This is optional - only enable if you want SMS-based authentication.

**Status:** ⬜ Not Started / ⏳ In Progress / ✅ Complete

---

## 📸 What You Should See

After completing all tasks, the "Sign-in providers" page should show:

- ✅ **Email/Password** - Enabled
- ✅ **Google** - Enabled  
- ✅ **Apple** - Enabled
- ✅ **Phone** - Enabled (if you enabled it)

---

## ⏭️ What's Next?

Once you've completed Step 1, we'll move to:

**Step 2: Add SHA-1 Certificate**
- Add your Android app's SHA-1 fingerprint to Firebase
- This is required for Google Sign-In to work

**Your SHA-1 (ready to use):**
```
D3:7D:BA:77:7F:3E:3C:D8:25:03:F3:02:82:30:6E:B7:18:4F:B3:F6
```

---

## 💡 Tips

1. **Can't find the providers?** 
   - Make sure you're on the "Sign-in method" tab
   - URL should be: `.../authentication/providers`

2. **Save button not working?**
   - Make sure you filled in all required fields
   - For Google: Support email is required

3. **Already enabled some providers?**
   - That's fine! Just enable the ones you need
   - You can skip already enabled providers

---

## 🎯 Progress Tracker

**Step 1: Configure Firebase Console** ✅ COMPLETE
- [x] Email/Password enabled
- [x] Google Sign-In enabled
- [x] Apple Sign-In enabled
- [ ] Phone Auth enabled (optional - skip if not needed)

---

# 🔑 Step 2: Add SHA-1 Certificate ⏱️ 3 minutes

**Firebase Console URL:** https://console.firebase.google.com/project/oroud-62a97/settings/general

## Task 2.1: Navigate to Android App Settings

**Instructions:**
1. [ ] You should now see **Project settings** page
2. [ ] Scroll down to the **"Your apps"** section
3. [ ] Find and click on your **Android app** (📱 icon)
   - Package name should be something like `com.example.oroud_app`
4. [ ] The Android app settings will expand

**Status:** ⬜ Not Started / ⏳ In Progress / ✅ Complete

---

## Task 2.2: Add SHA-1 Fingerprint

**Instructions:**
1. [ ] Scroll down in your Android app settings
2. [ ] Find the section: **"SHA certificate fingerprints"**
3. [ ] Click the **"Add fingerprint"** button
4. [ ] Copy and paste this SHA-1 certificate:

```
D3:7D:BA:77:7F:3E:3C:D8:25:03:F3:02:82:30:6E:B7:18:4F:B3:F6
```

5. [ ] Click **Save** or press Enter
6. [ ] Verify: The SHA-1 appears in the fingerprints list

**Status:** ⬜ Not Started / ⏳ In Progress / ✅ Complete

---

## Task 2.3: Download Updated google-services.json

**⚠️ CRITICAL:** After adding SHA-1, you MUST download the new config file!

**Instructions:**
1. [ ] Still on the same Android app settings page
2. [ ] Look for the **"google-services.json"** download button
3. [ ] Click to download the file
4. [ ] Save it to your Downloads folder

**Status:** ⬜ Not Started / ⏳ In Progress / ✅ Complete

---

## Task 2.4: Replace google-services.json in Your Project

**Instructions:**
1. [ ] Open Finder
2. [ ] Navigate to: `/Users/shadi/Desktop/oroud_app/android/app/`
3. [ ] Delete the old `google-services.json` (if exists)
4. [ ] Copy the NEW `google-services.json` from your Downloads
5. [ ] Paste it into `/Users/shadi/Desktop/oroud_app/android/app/`

**Alternative (Terminal):**
```bash
cp ~/Downloads/google-services.json /Users/shadi/Desktop/oroud_app/android/app/google-services.json
```

**Status:** ⬜ Not Started / ⏳ In Progress / ✅ Complete

---

**Last Updated:** Step 2 In Progress
**Estimated Time:** 3 minutes
**Next:** Step 3 - Test the App!
