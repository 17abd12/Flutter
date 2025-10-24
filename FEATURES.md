# AI Meal Planner - Modern Flutter Frontend

## 🌟 Overview
A modern, feature-rich nutrition tracking and meal planning app with a beautiful green-themed UI. This app provides a comprehensive dashboard with multiple screens for tracking calories, recipes, workouts, sleep, and AI-powered insights.

## ✨ Key Features Implemented

### 1. **Dashboard Screen (Home)**
- **Calorie Card**: Circular progress indicator showing daily calorie goal with breakdown
  - Base Goal display
  - Food consumed tracking
  - Exercise burned tracking
  - Remaining calories calculation
- **Habit Card**: Encourages users to start new habits (BETA feature)
- **Dashboard Grid**: Quick view of Steps and Exercise
  - Steps tracking card with connection status
  - Exercise summary with calories and duration
- **Weight Card**: Line chart showing weight progress over 90 days
  - Goal line visualization
  - Actual weight tracking
  - Custom painted chart
- **Discover Section**: 2x2 grid of feature cards
  - Sleep tracking
  - Recipes
  - Workouts
  - Sync devices

### 2. **Recipes Screen**
- Beautiful recipe cards with:
  - Visual emoji icons
  - Calorie information
  - Cooking time
  - Difficulty level
  - Protein content
  - Ingredient lists
- Filter and search functionality (UI ready)

### 3. **Workouts Screen**
- Today's workout summary:
  - Total calories burned
  - Duration tracked
  - Number of workouts
- Recommended workouts library:
  - Morning Yoga
  - HIIT Cardio
  - Strength Training
- Each workout shows:
  - Duration
  - Calories burned
  - Type (Flexibility, Cardio, Strength)
  - Play button for quick start

### 4. **Sleep Screen**
- Sleep duration tracking with circular progress
- Last night's sleep summary
- Sleep quality indicator
- Sleep schedule (bedtime & wake-up time)
- Sleep tips and recommendations

### 5. **AI Learning Engine**
- AI-powered pattern recognition:
  - Protein preferences
  - Dietary patterns
  - Meal timing insights
  - Cuisine preferences
- Confidence percentage for each insight
- Personalized AI recommendations:
  - Morning meal suggestions
  - Lunch prep tips
  - Evening meal balance

### 6. **Bottom Navigation**
- 4 main tabs:
  - 🏠 Home (Dashboard)
  - 🍽️ Recipes
  - 💪 Workouts
  - 🧠 AI Insights
- Smooth tab switching
- Active tab highlighting in green

### 7. **Navigation Drawer**
- User profile section
- Menu items:
  - Profile
  - Settings
  - Notifications
  - Login
  - Sign Up
  - Help & Support
  - About
- Green-themed icons matching app color scheme

## 📁 Project Structure

```
lib/
├── models/
│   └── mock_data.dart          # Comprehensive mock data for all features
├── screens/
│   ├── ai_learning_screen.dart # AI insights and patterns
│   ├── dashboard_screen.dart   # Main dashboard (Today view)
│   ├── home_screen.dart        # Bottom nav container
│   ├── recipes_screen.dart     # Recipe browser
│   ├── sleep_screen.dart       # Sleep tracking
│   ├── workouts_screen.dart    # Workout library
│   ├── login_screen.dart       # Login form
│   ├── signup_screen.dart      # Registration form
│   └── main_page.dart          # Legacy feature list (kept)
├── widgets/
│   ├── calorie_card.dart       # Calorie tracking widget
│   ├── dashboard_grid.dart     # Steps & Exercise grid
│   ├── discover_section.dart   # Feature discovery cards
│   ├── habit_card.dart         # Habit suggestion card
│   ├── weight_card.dart        # Weight chart widget
│   ├── custom_textfield.dart   # Styled input field
│   └── feature_template.dart   # Legacy template (kept)
├── main.dart                   # App entry point
└── theme.dart                  # Green color scheme & theme
```

## 🎨 Design Features

### Color Scheme
- **Primary Green**: `#4CAF50` - Fresh, organic green
- **Secondary Green**: `#8BC34A` - Light green accent
- **Accent**: `#33691E` - Deep leaf green
- **Background**: `#F1F8E9` - Soft pale green
- **Card**: `#E8F5E9` - Card background

### UI Components
- **Rounded corners**: 12-20px border radius
- **Shadows**: Soft elevation with subtle shadows
- **Icons**: Material icons with custom colors
- **Gradients**: Green gradients for headers
- **Charts**: Custom painted weight chart
- **Progress indicators**: Circular and linear

### Typography
- **Large titles**: 22-28px, bold
- **Body text**: 14-16px
- **Small text**: 12-13px
- **Font weight**: Medium to bold for emphasis

## 📊 Mock Data Included

The app includes comprehensive mock data for:
- User profile (name, age, weight, goals)
- Calorie tracking (goal, consumed, burned)
- Steps tracking
- Exercise data
- Weight history (90 days)
- Meal history (breakfast, lunch, dinner)
- Recipe library (with nutrition info)
- Workout routines (with durations and calories)
- Sleep data (duration, quality, schedule)
- Nutrient alerts (vitamins, protein, fiber)
- AI learning insights (with confidence scores)
- Habit tracking

## 🚀 Getting Started

1. **Run the app**:
   ```bash
   flutter run
   ```

2. **Build for release**:
   ```bash
   flutter build apk
   ```

3. **Format code**:
   ```bash
   dart format .
   ```

4. **Analyze code**:
   ```bash
   flutter analyze
   ```

## 📱 App Navigation Flow

```
HomeScreen (Bottom Navigation)
├── Dashboard Screen (Tab 1) ← DEFAULT
│   ├── Calorie Card
│   ├── Habit Card
│   ├── Steps & Exercise Grid
│   ├── Weight Chart
│   └── Discover Section
├── Recipes Screen (Tab 2)
│   └── Recipe Cards List
├── Workouts Screen (Tab 3)
│   ├── Today's Summary
│   └── Recommended Workouts
└── AI Learning Screen (Tab 4)
    ├── Pattern Analysis
    └── AI Recommendations

Navigation Drawer (accessible from all tabs)
├── Profile
├── Settings
├── Notifications
├── Login
├── Sign Up
├── Help & Support
└── About
```

## 🎯 Features Summary

### ✅ Implemented
- ✅ Modern dashboard with calorie tracking
- ✅ Weight progress chart
- ✅ Steps and exercise tracking UI
- ✅ Recipe browser with nutrition info
- ✅ Workout library with details
- ✅ Sleep tracking interface
- ✅ AI pattern recognition display
- ✅ Bottom navigation (4 tabs)
- ✅ Navigation drawer with menu
- ✅ Comprehensive mock data
- ✅ Green theme throughout
- ✅ Responsive layouts
- ✅ Custom widgets and cards

### 🔄 Future Enhancements (Backend Integration)
- Firebase Authentication
- Real-time calorie tracking
- Food logging with database
- Exercise tracking with timer
- Sleep tracking integration
- Wearable device sync
- Recipe search and filters
- Meal planning calendar
- Nutrition analysis API
- AI recommendations backend
- User preferences storage
- Progress charts and analytics

## 🎨 Design Philosophy

The app follows modern design principles:
- **Clean & Minimalist**: Focus on content without clutter
- **Consistent**: Same design language across all screens
- **Intuitive**: Easy navigation with familiar patterns
- **Accessible**: Good contrast and readable text
- **Organic**: Green color scheme representing health and nature
- **Engaging**: Visual feedback and delightful animations

## 📝 Notes

- All data is currently mock data stored in `models/mock_data.dart`
- The app is frontend-only - backend integration is pending
- Color scheme maintains green theme throughout
- Charts use custom painting for better performance
- All screens are fully functional with navigation
- Login/Signup screens are UI-only (no authentication yet)

## 🔧 Technical Details

- **Flutter SDK**: ^3.9.2
- **Dart**: Latest stable
- **Dependencies**: Flutter core + Cupertino icons
- **Architecture**: Widget-based with stateful/stateless components
- **State Management**: Local state (StatefulWidget)
- **Navigation**: Material navigation with bottom nav bar
- **Theme**: Centralized theme configuration

---

**Version**: 1.0.0  
**Last Updated**: October 21, 2025  
**Status**: Frontend Complete ✅
