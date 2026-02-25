#!/bin/bash

# 🔥 Firebase Authentication - Quick Setup Script
# Run this after completing Firebase Console configuration

echo ""
echo "🔥 Firebase Auth - Quick Setup Verification"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check backend server
echo "📡 Checking backend server..."
BACKEND_STATUS=$(curl -s http://localhost:3000/api/health 2>/dev/null)
if [[ $BACKEND_STATUS == *"ok"* ]]; then
    echo -e "${GREEN}✅ Backend server is running${NC}"
else
    echo -e "${RED}❌ Backend server is NOT running${NC}"
    echo "   Start it with: cd /Users/shadi/Desktop/oroud && npm run start:dev"
fi

echo ""

# Check Firebase packages
echo "📦 Checking Flutter Firebase packages..."
cd /Users/shadi/Desktop/oroud_app

if grep -q "firebase_auth:" pubspec.yaml; then
    echo -e "${GREEN}✅ firebase_auth installed${NC}"
else
    echo -e "${RED}❌ firebase_auth NOT installed${NC}"
fi

if grep -q "google_sign_in:" pubspec.yaml; then
    echo -e "${GREEN}✅ google_sign_in installed${NC}"
else
    echo -e "${RED}❌ google_sign_in NOT installed${NC}"
fi

if grep -q "sign_in_with_apple:" pubspec.yaml; then
    echo -e "${GREEN}✅ sign_in_with_apple installed${NC}"
else
    echo -e "${RED}❌ sign_in_with_apple NOT installed${NC}"
fi

echo ""

# Check google-services.json
echo "🔧 Checking google-services.json..."
if [ -f "android/app/google-services.json" ]; then
    echo -e "${GREEN}✅ google-services.json exists${NC}"
else
    echo -e "${RED}❌ google-services.json NOT found${NC}"
    echo "   Download it from Firebase Console → Project Settings → Your apps"
fi

echo ""

# Check GoogleService-Info.plist (iOS)
echo "🍎 Checking iOS configuration..."
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${GREEN}✅ GoogleService-Info.plist exists${NC}"
else
    echo -e "${YELLOW}⚠️  GoogleService-Info.plist NOT found (iOS only)${NC}"
fi

echo ""

# Next steps
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. Configure Firebase Console (15 minutes)"
echo "   - Enable Email/Password authentication"
echo "   - Enable Google Sign-In"
echo "   - Enable Apple Sign-In (iOS)"
echo "   - Add SHA-1 certificate for Android"
echo ""
echo "2. Get SHA-1 certificate:"
echo "   ${YELLOW}cd /Users/shadi/Desktop/oroud_app/android && ./gradlew signingReport${NC}"
echo ""
echo "3. Download updated google-services.json from Firebase Console"
echo ""
echo "4. Test the app:"
echo "   ${YELLOW}cd /Users/shadi/Desktop/oroud_app && flutter run${NC}"
echo ""
echo "📖 Read the full guide: FIREBASE_AUTH_COMPLETE_SETUP.md"
echo ""
