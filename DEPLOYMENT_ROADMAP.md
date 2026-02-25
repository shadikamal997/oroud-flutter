# 🚀 Deployment & Launch Roadmap

**Current Status:** Backend production-ready, Flutter claim UI implemented  
**Estimated Time to Production:** 1-2 weeks  
**Last Updated:** February 23, 2026

---

## ✅ Completed Tasks

- [x] Backend security fixes (17 fixes applied - 95/100 score)
- [x] Claim management system implemented (backend)
- [x] Token expiry reset to 15m (production value)
- [x] CORS origins updated (current device IP)
- [x] Flutter claim UI implemented (My Claims screen)
- [x] Navigation routes added
- [x] API endpoints connected
- [x] Backend restarted with production config

---

## 📋 Remaining Tasks (In Priority Order)

### **1. Manual Navigation Stress Test** ⏳ (15 minutes)

**Goal:** Verify token refresh works during rapid tab switching

**Steps:**
1. Read [NAVIGATION_STRESS_TEST_GUIDE.md](NAVIGATION_STRESS_TEST_GUIDE.md)
2. Run Flutter app on device
3. Login and wait 2 minutes
4. Rapidly switch tabs 50+ times
5. Test Claims screen functionality
6. Document findings

**Success Criteria:**
- ✅ No crashes
- ✅ No unexpected logouts
- ✅ Claims screen loads data
- ✅ Navigation smooth

**Time:** 15 minutes  
**Blocker:** NO - Can continue with staging prep in parallel

---

### **2. Staging Environment Setup** ⏳ (2-3 hours)

**Prerequisites:**
- Staging server access
- Database credentials
- Domain/subdomain configured

**Steps:**

#### **2.1 Backend Deployment**
```bash
# On staging server
cd /var/www/oroud-backend
git pull origin main
npm install --production
cp .env.example .env.staging

# Update .env.staging with staging credentials
nano .env.staging
```

**Required Environment Variables:**
```bash
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://user:pass@db-host:5432/oroud_staging
JWT_SECRET=[GENERATE_NEW]
ACCESS_TOKEN_EXPIRES=15m
REFRESH_TOKEN_EXPIRES=7d
CORS_ORIGINS=https://staging.oroud.com,https://app-staging.oroud.com
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
TAP_SECRET_KEY=sk_test_XXXXXXX  # Keep test key for staging
FRONTEND_URL=https://app-staging.oroud.com
```

#### **2.2 Database Migration**
```bash
# Run migrations
npx prisma migrate deploy

# Verify migration
npx prisma migrate status
# Should show: Database schema is up to date!

# Verify ClaimStatus enum exists
npx prisma db execute --stdin <<EOF
SELECT enumlabel FROM pg_enum
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
WHERE pg_type.typname = 'ClaimStatus';
EOF
# Expected: ACTIVE, REDEEMED, EXPIRED
```

#### **2.3 Start Backend**
```bash
# Using PM2
pm2 start npm --name "oroud-staging" -- run start:prod

# Or systemd
sudo systemctl restart oroud-backend

# Verify health
curl https://api-staging.oroud.com/health
# Expected: {"status":"ok","timestamp":"..."}
```

#### **2.4 Flutter App Build**
```bash
cd /Users/shadi/Desktop/oroud_app

# Update API URL for staging
# Edit lib/core/config/app_config.dart
# Change baseUrl to: "https://api-staging.oroud.com/api"

# Build Android APK
flutter build apk --release --flavor staging

# Or build iOS
flutter build ios --release --flavor staging

# Output: build/app/outputs/flutter-apk/app-staging-release.apk
```

---

### **3. Beta Testing** ⏳ (1 week)

**Goal:** Real users test the app, gather feedback

#### **3.1 Beta Tester Recruitment**
- Invite 10-15 real users (friends, family, colleagues)
- Mix of shop owners (3-5) and regular users (7-10)
- Provide test credentials for staging environment

#### **3.2 Beta Test Checklist**

**Test Scenarios for Users:**
- [ ] Create account
- [ ] Browse offers
- [ ] Save offers
- [ ] Claim offers
- [ ] View "My Claims" screen
- [ ] Follow shops
- [ ] Rate and review shops
- [ ] Receive notifications

**Test Scenarios for Shop Owners:**
- [ ] Create shop
- [ ] Create offers (different types)
- [ ] View shop dashboard
- [ ] Check analytics
- [ ] View who claimed offers
- [ ] Test claim redemption

#### **3.3 Feedback Collection**
Create Google Form with these questions:
1. Did you encounter any crashes? (Yes/No + details)
2. Were all features working? (List any broken features)
3. Was navigation smooth? (1-5 rating)
4. Did you successfully claim offers? (Yes/No)
5. Did "My Claims" screen work? (Yes/No)
6. Any confusing UI elements? (Free text)
7. Overall experience rating (1-5 stars)
8. Suggestions for improvement (Free text)

#### **3.4 Monitoring During Beta**
```bash
# Monitor backend logs for errors
pm2 logs oroud-staging --lines 100

# Check error rates
grep "ERROR" /var/log/oroud-backend/staging.log | wc -l

# Monitor database performance
psql -h db-host -U oroud_staging -d oroud_staging <<EOF
SELECT
  schemaname,
  tablename,
  n_tup_ins as inserts,
  n_tup_upd as updates,
  n_tup_del as deletes
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY n_tup_ins + n_tup_upd + n_tup_del DESC
LIMIT 10;
EOF
```

---

### **4. Production Deployment** ⏳ (4 hours)

**Prerequisites:**
- Beta testing complete with NO critical bugs
- 2 consecutive successful navigation stress tests
- All feedback addressed
- Production server ready

#### **4.1 Final Pre-Production Checklist**

**Security:**
- [ ] Generate new JWT_SECRET for production
- [ ] Update to LIVE Tap Payments key (sk_live_...)
- [ ] Production Cloudinary credentials configured
- [ ] CORS origins restricted to production domains only
- [ ] HTTPS/SSL certificates installed and verified
- [ ] Database backups automated (daily)
- [ ] Rate limiting appropriate for production traffic

**Environment:**
- [ ] NODE_ENV=production
- [ ] DATABASE_URL points to production database
- [ ] All sensitive credentials in environment variables (not .env file)
- [ ] Error logging configured (Sentry/LogRocket)
- [ ] Performance monitoring set up (New Relic/Datadog)

**Database:**
- [ ] Production database created with backups
- [ ] Migrations tested on staging
- [ ] Seed data ready (cities, categories)
- [ ] Connection pooling configured (30-50 connections)

**Frontend:**
- [ ] API URL set to production (https://api.oroud.com/api)
- [ ] App signed with production keys
- [ ] Version number incremented (1.0.0)
- [ ] Store listings prepared (Google Play, App Store)

#### **4.2 Production Deployment Steps**

```bash
# 1. Backup production database
pg_dump -h prod-db -U oroud_prod oroud_production > backup_$(date +%Y%m%d_%H%M%S).sql

# 2. Deploy backend
cd /var/www/oroud-backend
git pull origin main
npm install --production
npx prisma migrate deploy
pm2 restart oroud-production

# 3. Verify health
curl https://api.oroud.com/health
curl https://api.oroud.com/offers | jq '. | length'

# 4. Monitor logs
pm2 logs oroud-production --lines 50
```

#### **4.3 Post-Deployment Verification**

**Critical Endpoint Tests:**
```bash
# Health Check
curl https://api.oroud.com/health

# Authentication
curl -X POST https://api.oroud.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Offers Feed
curl https://api.oroud.com/offers/feed

# My Claims (requires auth)
curl https://api.oroud.com/offers/my-claims \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Results:**
- ✅ All endpoints return 200 OK
- ✅ No 500 errors in logs
- ✅ Response times < 200ms
- ✅ Claims endpoint returns data or empty array

---

### **5. Production Launch** 🎉 (Day 1)

#### **5.1 Launch Day Schedule**

**Morning (9 AM - 12 PM):**
- Final smoke tests
- Monitor logs continuously
- Team on standby for issues

**Afternoon (12 PM - 6 PM):**
- Soft launch (invite selected users)
- Monitor performance metrics
- Track error rates
- Watch for race conditions

**Evening (6 PM - 11 PM):**
- Review metrics
- Address any urgent bugs
- Prepare hotfix if needed

#### **5.2 Monitoring Metrics**

**Must Track:**
- Active users (target: 50+ on day 1)
- Offer creation rate (target: 10+ offers)
- Claim conversion rate (target: 20%+)
- Error rate (target: < 0.5%)
- Average response time (target: < 200ms)
- Crashes (target: 0)

**Tools:**
```bash
# Active users (last 24h)
psql -h prod-db -U oroud_prod oroud_production <<EOF
SELECT COUNT(DISTINCT user_id) as active_users
FROM user_sessions
WHERE last_active > NOW() - INTERVAL '24 hours';
EOF

# Offer creation rate
psql -h prod-db -U oroud_prod oroud_production <<EOF
SELECT COUNT(*) as offers_created_today
FROM offers
WHERE created_at::date = CURRENT_DATE;
EOF

# Claim conversion rate
psql -h prod-db -U oroud_prod oroud_production <<EOF
SELECT
  COUNT(DISTINCT offer_id) as offers_with_claims,
  COUNT(*) as total_claims,
  ROUND(COUNT(DISTINCT offer_id) * 100.0 / 
    (SELECT COUNT(*) FROM offers WHERE is_active = true), 2) as conversion_rate
FROM user_offer_claims
WHERE created_at::date = CURRENT_DATE;
EOF
```

---

## 📊 Success Metrics (First Month)

### **Week 1 Goals:**
- 100+ registered users
- 50+ shops onboarded
- 200+ offers created
- 500+ claims made
- 0 critical bugs
- 99%+ uptime

### **Week 2-4 Goals:**
- 500+ registered users
- 100+ shops onboarded
- 1,000+ offers created
- 3,000+ claims made
- 70%+ redemption rate
- Customer satisfaction > 4.5/5

---

## 🚨 Rollback Plan

**If critical issues occur:**

```bash
# 1. Revert to previous deployment
cd /var/www/oroud-backend
git revert HEAD
git push origin main
pm2 restart oroud-production

# 2. Rollback database migrations (if needed)
npx prisma migrate resolve --rolled-back 20260223164600_add_claim_status

# 3. Restore database from backup (LAST RESORT)
psql -h prod-db -U oroud_prod oroud_production < backup_YYYYMMDD_HHMMSS.sql

# 4. Notify users via:
# - In-app notification
# - Email
# - Social media status update
```

---

## 📞 Emergency Contacts

**Technical Lead:** [Your Name] - [Phone]  
**DevOps:** [Contact] - [Phone]  
**Database Admin:** [Contact] - [Phone]  
**On-Call Schedule:** [Link to PagerDuty/schedule]

**Emergency Hotline:** [Phone Number]  
**Slack Channel:** #oroud-production-alerts

---

## 🎯 Current Status Summary

| Task | Status | Time Estimate | Blocker |
|------|--------|---------------|---------|
| Flutter Claim UI | ✅ DONE | - | None |
| Navigation Stress Test | ⏳ PENDING | 15 min | None |
| Staging Deployment | ⏳ PENDING | 2-3 hrs | None |
| Beta Testing | ⏳ PENDING | 1 week | Staging deployment |
| Production Launch | ⏳ PENDING | 1 day | Beta testing |

**Overall Progress:** 60% complete  
**Estimated Time to Production:** 1-2 weeks  
**Current Blockers:** None (all tasks can proceed)

---

**Next Immediate Action:** Run Navigation Stress Test (15 minutes)

**Commands to execute:**
```bash
# 1. Verify backend running
curl http://localhost:3000/api/health

# 2. Launch Flutter app
cd /Users/shadi/Desktop/oroud_app && flutter run -d CPH2237

# 3. Follow NAVIGATION_STRESS_TEST_GUIDE.md
```

🚀 **You're 1-2 weeks away from production launch!**
