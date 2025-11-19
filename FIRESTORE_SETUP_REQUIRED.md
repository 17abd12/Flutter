# 🔥 CRITICAL: Deploy Firestore Security Rules

## Problem
Your app cannot save data to Firestore because security rules are not configured. This is why:
- You can login (Authentication works)
- But no data appears in Firestore Console
- Profile shows "No profile data found"
- Meals show as mock data

## Solution - Deploy Security Rules (Takes 2 minutes)

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com
2. Select your project: **ai-meal-planner-b1713**

### Step 2: Navigate to Firestore Rules
1. Click **Firestore Database** in left sidebar
2. Click **Rules** tab at the top
3. You'll see the current rules (probably blocking all writes)

### Step 3: Copy & Paste New Rules
**Delete everything** in the rules editor and replace with this:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection - users can only access their own data
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update, delete: if isOwner(userId);
    }
    
    // Meals collection - users can only access their own meals
    match /meals/{mealId} {
      allow read, write: if isAuthenticated() && 
                            (resource == null || resource.data.uid == request.auth.uid) &&
                            request.resource.data.uid == request.auth.uid;
    }
    
    // Exercises collection - users can only access their own exercises
    match /exercises/{exerciseId} {
      allow read, write: if isAuthenticated() && 
                            (resource == null || resource.data.uid == request.auth.uid) &&
                            request.resource.data.uid == request.auth.uid;
    }
    
    // Weight history collection - users can only access their own weight history
    match /weight_history/{entryId} {
      allow read, write: if isAuthenticated() && 
                            (resource == null || resource.data.uid == request.auth.uid) &&
                            request.resource.data.uid == request.auth.uid;
    }
  }
}
```

### Step 4: Publish Rules
1. Click **Publish** button (blue button in top right)
2. Wait for "Rules published successfully" message
3. **Done!** 🎉

### Step 5: Test Your App
1. In your Flutter app, **logout** if you're logged in
2. **Create a new account** (or login with existing account)
3. Fill out the goal setup form completely
4. Click "Save & Continue"
5. You should see: "Profile saved successfully! 🎉"
6. Go to **Profile tab** (bottom navigation, last icon)
7. You should now see all your personal information!

### Step 6: Verify in Firebase Console
1. Go back to Firebase Console
2. Click **Data** tab in Firestore Database
3. You should now see collections:
   - `users` - Your profile data
   - `meals` - When you add meals
   - `exercises` - When you log exercises
   - `weight_history` - When you track weight

## What Changed in the App

### ✅ Fixed Issues:
1. **Logout Button**: Added to Profile screen with confirmation dialog
2. **Real Calorie Data**: Dashboard now shows actual calories from your meals/exercises (not mock data)
3. **Profile Data**: Profile screen now loads your actual data from Firestore
4. **Better Error Messages**: App will show clear error messages if data fails to save
5. **Security Rules**: Created `firestore.rules` file (you need to deploy it above)

### 🎯 Features Now Working:
- **Profile Screen**: Shows all your personal info (age, weight, goals, BMI, etc.)
- **Logout**: Red button at bottom of profile with confirmation
- **Real Data**: All cards show actual data from Firestore when logged in
- **Mock Data**: Shows sample data when logged out (so app looks good for visitors)

## Troubleshooting

### If data still doesn't save after deploying rules:
1. **Check browser console** (Press F12 in Chrome)
2. Look for Firebase errors in Console tab
3. Common issues:
   - Rules not published (wait 30 seconds and try again)
   - User not authenticated (logout and login again)
   - Network issues (check internet connection)

### If profile shows "No profile data found":
1. Your old account might not have data saved (rules were blocking)
2. **Solution**: Create a NEW account after deploying rules
3. Or logout, login again, and the app will try to create profile

## Next Steps
After deploying rules and testing:
1. Add meals using the dashboard
2. Log exercises
3. Track weight changes
4. Everything will be saved to YOUR Firestore database
5. Data persists across logins
6. Each user only sees their own data (secure!)
