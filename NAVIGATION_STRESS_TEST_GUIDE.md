# 🧪 Manual Navigation Stress Test Guide

**Purpose:** Verify token refresh behavior works correctly during rapid tab switching  
**Duration:** 10-15 minutes  
**Required:** Flutter app running on physical device (CPH2237)

---

## 🎯 Test Objectives

1. **Token Expiry Handling**: Verify app refreshes tokens automatically
2. **Navigation Stability**: Ensure no crashes during rapid tab switching  
3. **UI Responsiveness**: Check for blank screens or infinite loaders
4. **State Persistence**: Verify data doesn't disappear unexpectedly

---

## 📝 Test Procedure

### **Step 1: Preparation (2 minutes)**

```bash
# 1. Ensure backend is running with 15m token expiry
cd /Users/shadi/Desktop/oroud
lsof -ti:3000 | xargs kill -9 2>/dev/null || echo "Port 3000 free"
npm run start:dev > /tmp/oroud-backend.log 2>&1 &

# 2. Check backend health
sleep 10
curl http://localhost:3000/api/health

# 3. Verify token expiry is 15m
grep "ACCESS_TOKEN_EXPIRES" .env
# Should show: ACCESS_TOKEN_EXPIRES=15m
```

### **Step 2: Launch Flutter App (1 minute)**

```bash
cd /Users/shadi/Desktop/oroud_app
flutter run -d CPH2237
```

Wait for app to load on device.

### **Step 3: Login & Wait (2 minutes)**

**On Device:**
1. Open the app
2. Login with test credentials:
   - **Email:** `test@test.com`
   - **Password:** `test`
3. Wait on the home screen for **2 full minutes**
   - This allows time to get closer to token expiry
   - Don't touch the app during this wait

### **Step 4: Rapid Tab Switching (5 minutes)**

**Execute these rapid tab switches (spend 2-3 seconds on each tab):**

1. **Home** → **Categories** → **My Shop** → **Profile**
2. **Profile** → **Home** → **Categories** → **My Shop**
3. **My Shop** → **Profile** → **Home** → **Categories**
4. **Categories** → **My Shop** → **Profile** → **Home**

**Repeat this cycle 12-15 times** (approximately 50+ tab switches total)

**Watch For:**
- ✅ **Normal**: Smooth transitions, data loads quickly
- ⚠️ **Warning Signs**: Brief loading spinners (normal)
- ❌ **Failures**: 
  - Blank white screens
  - Infinite loading spinners
  - "Unauthorized" errors
  - App crashes
  - Forced logout

### **Step 5: Profile Actions Test (3 minutes)**

While continuing to switch tabs, also tap these profile actions:

1. Tap **"Claims"** → Should show My Claims screen → Back button
2. Tap **"Saved"** → Should show Saved Offers → Back button
3. Tap **"Following"** → Should show Following Shops → Back button
4. Tap **"Notifications"** → Should show Notifications → Back button

**Continue rapid tab switching between these screens**

### **Step 6: Offer Interaction Test (2 minutes)**

1. Go to **Home** tab
2. Scroll through offers
3. Tap an offer → View details
4. Back button → Home
5. Immediately switch to **Profile** tab
6. Switch to **Categories** tab
7. Switch back to **Home** tab
8. Tap a different offer

**Repeat 5-7 times** with different offers

---

## ✅ Success Criteria

The test **PASSES** if:
- ✅ No app crashes
- ✅ No forced logouts
- ✅ No blank screens (except brief loading states < 3 seconds)
- ✅ Profile data loads correctly after tab switches
- ✅ Claims screen works (shows data or empty state)
- ✅ Offer details load correctly
- ✅ Navigation feels smooth and responsive

The test **FAILS** if:
- ❌ App crashes during navigation
- ❌ User is logged out unexpectedly
- ❌ Blank screens persist > 5 seconds
- ❌ "Token expired" or "Unauthorized" errors appear
- ❌ Data disappears after tab switches
- ❌ Multiple token refresh calls triggered simultaneously

---

## 📊 Monitoring Backend Logs

**In a separate terminal, monitor backend logs during the test:**

```bash
# Watch backend logs for token refresh requests
tail -f /tmp/oroud-backend.log | grep -i "refresh\|token\|auth"
```

**Expected Behavior:**
- You should see occasional refresh token requests
- No error logs
- No 401 Unauthorized responses
- No infinite refresh loops

**Red Flags:**
```
❌ "Token expired" errors
❌ "Invalid refresh token"
❌ Multiple refresh calls in quick succession
❌ 500 Internal Server Error
❌ "Too many requests" (rate limiting)
```

---

## 🐛 Troubleshooting

### **Issue: App logs out during test**
**Cause:** Token refresh failed  
**Fix:** Check backend logs for errors, verify refresh token endpoint working

### **Issue: Blank screens appear**
**Cause:** API calls failing or state not persisting  
**Fix:** Check network connectivity, verify API responses

### **Issue: Claims screen shows error**
**Cause:** Backend endpoint not connected  
**Fix:** Verify backend is running, check `/api/offers/my-claims` endpoint

### **Issue: Too fast tab switching causes white flashes**
**Cause:** Normal Flutter behavior during rapid navigation  
**Action:** Not a failure, continue testing

---

## 📝 Test Report Template

**After completing the test, document your findings:**

```markdown
# Navigation Stress Test Report

**Date:** [Insert Date]
**Tester:** [Your Name]
**Device:** CPH2237 (OPPO)
**Backend:** localhost:3000
**Token Expiry:** 15 minutes

## Test Results

### Overall Status: [PASS / FAIL / PARTIAL]

### Tab Switching (50+ cycles)
- Crashes: [Yes/No]
- Logouts: [Yes/No]
- Blank screens: [Yes/No]
- Performance: [Smooth / Sluggish / Choppy]

### Profile Actions
- Claims screen: [✅ Working / ❌ Error / ⚠️ Slow]
- Saved offers: [✅ Working / ❌ Error / ⚠️ Slow]
- Following shops: [✅ Working / ❌ Error / ⚠️ Slow]
- Notifications: [✅ Working / ❌ Error / ⚠️ Slow]

### Token Refresh Behavior
- Automatic refresh: [✅ Yes / ❌ No]
- Refresh errors: [None / List errors]
- Multiple calls: [No / Yes - describe]

### Issues Found
1. [List any issues with severity: Critical/High/Medium/Low]
2. ...

### Recommendations
- [Actions needed before production]

## Verdict
[Ready for staging / Needs fixes / Not ready]
```

---

## 🎬 Next Steps After Test

### **If Test PASSES:**
1. ✅ Mark test as complete
2. 📋 Proceed to staging deployment
3. 🚀 Prepare for beta testing

### **If Test FAILS:**
1. ❌ Document all failures
2. 🔧 Fix critical issues
3. 🔄 Re-run test after fixes
4. ⏸️ Hold staging deployment

---

## 🚀 Quick Start Commands

```bash
# Complete test setup in one go
cd /Users/shadi/Desktop/oroud && lsof -ti:3000 | xargs kill -9 2>/dev/null; npm run start:dev > /tmp/oroud-backend.log 2>&1 & sleep 10 && curl http://localhost:3000/api/health && cd /Users/shadi/Desktop/oroud_app && flutter run -d CPH2237
```

---

**Test Duration:** 15 minutes  
**Frequency:** Before each major deployment  
**Required Passes:** 2 consecutive passes before production launch
