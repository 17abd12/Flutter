#!/bin/bash
# Firebase Firestore Indexes Setup Script
# Usage: ./setup-indexes.sh
# This script deploys all required Firestore indexes

echo "🔥 Firebase Firestore Indexes Setup"
echo "======================================"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found!"
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

echo "✅ Firebase CLI found"
echo ""

# Check if logged in
echo "🔐 Checking Firebase authentication..."
if ! firebase projects:list > /dev/null 2>&1; then
    echo "⚠️  Not authenticated. Running: firebase login"
    firebase login
fi

echo "✅ Authenticated to Firebase"
echo ""

# Get current project
PROJECT_ID=$(firebase use --add 2>/dev/null | tail -n 1)
if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID=$(grep -m 1 "projects" .firebaserc 2>/dev/null | grep -o '"[^"]*"' | tr -d '"' | head -n 1)
fi

echo "📦 Project ID: $PROJECT_ID"
echo ""

# Check if firestore.indexes.json exists
if [ ! -f "firestore.indexes.json" ]; then
    echo "❌ firestore.indexes.json not found in current directory!"
    echo "Make sure you're in the project root directory"
    exit 1
fi

echo "📄 Using indexes from: firestore.indexes.json"
echo ""

# Deploy indexes
echo "🚀 Deploying Firestore indexes..."
echo "This may take 2-5 minutes. Please wait..."
echo ""

firebase deploy --only firestore:indexes

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Indexes deployed successfully!"
    echo ""
    echo "📊 Next steps:"
    echo "1. Go to https://console.firebase.google.com"
    echo "2. Select project: $PROJECT_ID"
    echo "3. Navigate to Firestore → Indexes"
    echo "4. Verify all indexes show status: 'Enabled'"
    echo ""
    echo "⏱️  Estimated time: 2-5 minutes"
    echo ""
    echo "🎉 Your app should now run much faster!"
else
    echo ""
    echo "❌ Deployment failed!"
    echo "Try one of these solutions:"
    echo "1. Check project ID is correct: firebase use"
    echo "2. Update Firebase CLI: npm install -g firebase-tools@latest"
    echo "3. Deploy manually via Firebase Console"
    exit 1
fi
