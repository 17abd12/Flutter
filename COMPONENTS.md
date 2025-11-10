# Frontend Components Documentation 🎨

## Project Structure Overview

```
lib/
├── main.dart                          # App entry point
├── theme.dart                         # Global theming and colors
├── models/
│   └── mock_data.dart                # Sample data for development
├── screens/                          # Main application screens
│   ├── home_screen.dart              # Bottom navigation container
│   ├── dashboard_screen.dart         # Main dashboard view
│   ├── login_screen.dart             # User authentication
│   ├── signup_screen.dart            # User registration
│   ├── goal_setup_screen.dart        # Goal configuration
│   ├── recipes_screen.dart           # Recipe library browser
│   ├── recipe_detail_screen.dart     # Individual recipe view
│   ├── smart_recipe_generator_screen.dart    # AI recipe generation
│   └── real_time_meal_adjustment_screen.dart # Meal logging
└── widgets/                          # Reusable UI components
    ├── calorie_card.dart             # Daily calorie display
    ├── weight_card.dart              # Weight tracking chart
    ├── dashboard_grid.dart           # Weight + Exercise cards
    ├── discover_section_new.dart     # Featured content carousel
    └── custom_textfield.dart         # Themed input field
```

---

## 🎨 Core Theme System

### **File:** `theme.dart`

**Purpose:** Centralized styling and color management

**Key Components:**

#### Gradients:
```dart
boldGradient       // Primary bold gradient (purple-pink-orange)
sunsetGradient     // Warm sunset colors
oceanGradient      // Cool blue tones
purpleGradient     // Rich purple shades
calmGradient       // Soft blue-green
organicGradient    // Background gradient
```

#### Colors:
```dart
primary            // Main brand color (#4CAF50 green)
secondary          // Accent color (#66BB6A lime)
accent             // Highlight color (#FFC107 amber)
textDark           // Dark text (#1B5E20)
textLight          // Light text (white)
card               // Card background (#F1F8E9)
```

#### Text Styles:
```dart
heading1           // Size 36, Weight 900
heading2           // Size 28, Weight 800  
heading3           // Size 22, Weight 700
```

**Usage:**
```dart
// Apply gradient
Container(decoration: BoxDecoration(gradient: AppTheme.boldGradient))

// Use colors
Text('Hello', style: TextStyle(color: AppTheme.primary))

// Apply text style
Text('Title', style: AppTheme.heading1)
```

---

## 📱 Screen Components

### 1. **HomeScreen** (`home_screen.dart`)

**Purpose:** Main navigation container with bottom tabs

**Structure:**
```dart
Scaffold
├── body: _screens[_selectedIndex]
└── bottomNavigationBar
    ├── Dashboard
    ├── Recipes
    ├── Smart Generator
    └── Meal Adjustment
```

**State Management:**
- `_selectedIndex`: Current tab index
- `_screens`: List of screen widgets
- `_onItemTapped()`: Tab switching logic

**Navigation Items:**
1. Dashboard (home icon)
2. Recipes (book icon)
3. Generator (auto_awesome icon)
4. Meal Log (restaurant icon)

---

### 2. **DashboardScreen** (`dashboard_screen.dart`)

**Purpose:** Main overview with metrics and quick actions

**Layout Structure:**
```
AppBar (Gradient)
  └── "Today" title with ShaderMask
ListView
  ├── Login/Signup Buttons
  ├── CalorieCard
  ├── DashboardGrid (Weight + Exercise)
  ├── WeightCard (Chart)
  └── DiscoverSection
```

**Key Features:**
- Gradient AppBar with bold title effect
- Responsive padding for small screens
- Scroll view for all content
- Quick access buttons at top

**Methods:**
- `_navigateToLogin()`: Navigate to login screen
- `_navigateToSignup()`: Navigate to signup screen

---

### 3. **LoginScreen** (`login_screen.dart`)

**Purpose:** User authentication interface

**Layout:**
```
Scaffold
└── Container (Gradient background)
    └── SafeArea
        ├── Home IconButton (top-left)
        └── Center
            └── SingleChildScrollView
                └── Card
                    ├── Title
                    ├── Email TextField
                    ├── Password TextField
                    ├── Login Button
                    └── Sign Up Link
```

**Form Validation:**
- Email format check
- Password minimum length (6 chars)
- Form key for validation

**Navigation:**
- Home button → Returns to Dashboard
- Login success → Navigate to HomeScreen
- Sign up link → Navigate to SignupScreen

---

### 4. **SignupScreen** (`signup_screen.dart`)

**Purpose:** User registration interface

**Layout:** Similar to LoginScreen with additional fields:
```
Card
├── Title: "Create Account"
├── Email TextField
├── Password TextField
├── Confirm Password TextField
├── Sign Up Button
└── Home Button (top-left)
```

**Validation:**
- Email format
- Password length (6+ chars)
- Password match confirmation

**Post-Signup:**
- Navigate to GoalSetupScreen for profile completion

---

### 5. **RecipesScreen** (`recipes_screen.dart`)

**Purpose:** Browse recipe library by category

**Structure:**
```
Scaffold (Gradient AppBar)
└── ListView
    ├── Search Bar
    ├── Category Filters (Chips)
    └── Recipe Grid
        └── Recipe Cards
```

**Categories:**
- All, Breakfast, Lunch, Dinner, Snacks, Smoothies, Salads

**Recipe Card:**
- Gradient background
- Image placeholder
- Recipe name
- Calories
- Cook time
- Tap → Navigate to RecipeDetailScreen

**State:**
- `_selectedCategory`: Current filter
- Filtered recipe list based on category

---

### 6. **RecipeDetailScreen** (`recipe_detail_screen.dart`)

**Purpose:** Show complete recipe information

**Layout:**
```
Scaffold (Gradient AppBar)
└── SingleChildScrollView
    ├── Image (Hero animation ready)
    ├── Title Section
    │   ├── Recipe Name
    │   └── Stats (Calories, Time)
    ├── Ingredients Section
    │   └── Bulleted List
    └── Instructions Section
        └── Numbered Steps
```

**Sections:**
1. **Hero Image**: Large recipe photo
2. **Info Card**: Calories + Time with icons
3. **Ingredients**: List with bullet points
4. **Instructions**: Step-by-step numbered list

---

### 7. **SmartRecipeGeneratorScreen** (`smart_recipe_generator_screen.dart`)

**Purpose:** AI-powered recipe creation

**Form Structure:**
```
Form
├── Ingredients TextField
├── Dietary Preference Dropdown
│   └── Options: Vegetarian, Vegan, Keto, etc.
├── Cuisine Type Dropdown
│   └── Options: Italian, Mexican, Asian, etc.
└── Generate Button
```

**Process Flow:**
1. User enters ingredients
2. Selects dietary preference
3. Chooses cuisine style
4. Taps generate
5. AI creates custom recipe
6. Display with ingredients + instructions

**State:**
- `_ingredientsController`: Text input
- `_selectedDiet`: Dietary choice
- `_selectedCuisine`: Cuisine choice
- `_generatedRecipe`: AI output

---

### 8. **RealTimeMealAdjustmentScreen** (`real_time_meal_adjustment_screen.dart`)

**Purpose:** Log meals with manual or AI-estimated calories

**Layout:**
```
Form
├── Radio Buttons
│   ├── "I know the calories"
│   └── "Estimate from description"
├── Meal Name TextField
├── [Conditional Display]
│   ├── Calories TextField (if manual)
│   └── Description TextField (if AI)
└── Action Button
    ├── "Log Meal" (manual)
    └── "Estimate & Log" (AI)
```

**Two Input Modes:**

**Manual Mode:**
- Enter meal name
- Input known calorie count
- Direct logging

**AI Estimation Mode:**
- Enter meal name
- Provide detailed description
- AI calculates calories
- Display estimate
- Confirm to log

**State:**
- `_selectedOption`: 'manual' or 'ai'
- `_mealNameController`: Meal name
- `_caloriesController`: Manual calories
- `_descriptionController`: AI description

---

## 🧩 Widget Components

### 1. **CalorieCard** (`calorie_card.dart`)

**Purpose:** Display daily calorie tracking

**Visual Design:**
- White card with gradient background
- Bold gradient heading "Calories"
- Large calorie numbers
- Progress indicator
- Goal vs consumed display

**Props:**
- Responsive sizing based on screen width
- Uses MockData for calorie values

**Layout:**
```
Container (White + Gradient)
├── "Calories" (Gradient text)
├── Progress Bar
├── Consumed / Goal
└── Decorative shadows
```

---

### 2. **WeightCard** (`weight_card.dart`)

**Purpose:** Weight tracking chart visualization

**Components:**
- Header with title and date range selector
- Line chart with CustomPainter
- Legend (Goal vs Actual)
- Responsive sizing

**Chart Features:**
- Blue line: Goal weight
- Green line: Actual weight
- Data points with dots (6px + shadow)
- X-axis: Dates
- Y-axis: Weight values
- Padding for labels (30px left, 20px bottom)

**CustomPainter:** `WeightChartPainter`
- Draws goal line (horizontal)
- Plots actual weight line
- Adds circular markers
- Paints axis labels

---

### 3. **DashboardGrid** (`dashboard_grid.dart`)

**Purpose:** Side-by-side Weight + Exercise cards

**Structure:**
```
Row
├── Expanded: Weight Card
│   ├── Scale Icon
│   ├── Title
│   ├── Description
│   └── Add Button
└── Expanded: Exercise Card
    ├── Fitness Icon
    ├── Title
    ├── Calories Burned
    ├── Duration
    └── Add Button
```

**Card Styling:**
- Fixed height: 190px (normal), 170px (small)
- Equal width via Expanded
- Gradient backgrounds (blue/orange)
- Rounded corners (20px)
- Elevated shadows

**Features:**
- Tap cards to add data
- Modal dialogs for input
- Balanced layout with icons
- Responsive text sizing

---

### 4. **DiscoverSection** (`discover_section_new.dart`)

**Purpose:** Featured content carousel

**Layout:**
```
Column
├── "Discover" Heading
└── Horizontal ListView
    ├── Recipe Generator Card
    └── Meal Adjustment Card
```

**Card Design:**
- Gradient background with colored shadows
- Icon at top
- Title with gradient text
- Description text
- Tap → Navigate to feature

**Gradients:**
- Recipe Generator: Purple gradient
- Meal Adjustment: Green gradient

---

### 5. **CustomTextField** (`custom_textfield.dart`)

**Purpose:** Themed, reusable form input

**Features:**
- Organic theme styling
- Prefix icon
- Label text
- Optional obscure text (passwords)
- Built-in validation
- Rounded borders
- Focus state handling

**Props:**
```dart
controller      // TextEditingController
label          // Field label
icon           // Prefix icon
obscureText    // Password visibility
validator      // Validation function
```

---

## 📦 Data Models

### **MockData** (`models/mock_data.dart`)

**Purpose:** Sample data for development and testing

**Data Structures:**

```dart
userProfile
├── name: String
├── currentWeight: double
├── goalWeight: double
├── dailyCalories: int
└── caloriesConsumed: int

weightHistory: List<Map>
├── date: String
└── weight: double

exerciseData: Map
├── caloriesBurned: int
└── duration: String

recipes: List<Map>
├── name: String
├── calories: int
├── time: String
├── category: String
├── ingredients: List<String>
└── instructions: List<String>
```

---

## 🎭 Design Patterns Used

### 1. **Stateful vs Stateless**
- Stateful: Forms, navigation, user input
- Stateless: Display-only components

### 2. **Responsive Design**
```dart
final isSmallScreen = MediaQuery.of(context).size.width < 360;
// Adjust padding, font sizes, heights
```

### 3. **Gradient Text Effect**
```dart
ShaderMask(
  shaderCallback: (bounds) => gradient.createShader(bounds),
  child: Text(text, style: TextStyle(color: Colors.white))
)
```

### 4. **Navigator Patterns**
```dart
// Push new screen
Navigator.push(context, MaterialPageRoute(builder: (context) => NewScreen()))

// Replace current screen  
Navigator.pushReplacement(context, MaterialPageRoute(...))

// Return to home
Navigator.of(context).popUntil((route) => route.isFirst)
```

---

## 🎨 Color Psychology

| Color | Usage | Meaning |
|-------|-------|---------|
| Blue | Weight tracking | Trust, stability |
| Orange | Exercise | Energy, enthusiasm |
| Green | Goals, primary | Health, growth |
| Purple | AI features | Innovation, creativity |
| White | Card backgrounds | Clarity, simplicity |

---

## 📐 Sizing Guidelines

### Text Sizes:
- **Headings**: 22-36px
- **Body**: 14-16px
- **Small text**: 11-13px

### Padding:
- **Card padding**: 14-16px
- **Screen padding**: 12-20px
- **Element spacing**: 8-16px

### Card Heights:
- **Dashboard cards**: 190px (170px small)
- **Discover cards**: Auto-sizing
- **Recipe cards**: ~200px

### Border Radius:
- **Cards**: 20-25px
- **Buttons**: 12-15px
- **Icons**: 12-14px

---

## 🔄 State Management

Currently using **StatefulWidget** with `setState()`:

```dart
class _ScreenState extends State<Screen> {
  int _variable = 0;
  
  void _updateState() {
    setState(() {
      _variable = newValue;
    });
  }
}
```

**Future Enhancement:** Consider Provider, Riverpod, or Bloc for complex state.

---

## 🧪 Testing Approach

1. **Widget Tests**: Test individual components
2. **Integration Tests**: Test screen navigation
3. **Golden Tests**: Visual regression testing

Example structure:
```dart
testWidgets('CalorieCard displays correctly', (tester) async {
  await tester.pumpWidget(MaterialApp(home: CalorieCard()));
  expect(find.text('Calories'), findsOneWidget);
});
```

---

## 🚀 Performance Optimizations

### Implemented:
- `const` constructors where possible
- Efficient `CustomPainter` for charts
- SingleChildScrollView for long content
- Responsive image loading (future)

### Recommended:
- Image caching
- Lazy loading for recipe list
- State persistence
- API response caching

---

## 📱 Responsive Breakpoints

```dart
final screenWidth = MediaQuery.of(context).size.width;

// Extra Small
if (screenWidth < 360) { }

// Small  
if (screenWidth < 600) { }

// Medium
if (screenWidth < 960) { }

// Large
if (screenWidth >= 960) { }
```

---

## 🎯 Component Reusability

### Highly Reusable:
- CustomTextField
- CalorieCard (with props)
- Theme system

### Screen-Specific:
- Dashboard layout
- Recipe browser
- Form screens

### Potential Extraction:
- Button styles → CustomButton widget
- Card containers → CustomCard widget
- Dialog patterns → Reusable dialog builder

---

## 🔮 Future Component Ideas

1. **CustomButton** - Themed button variants
2. **StatCard** - Generic metric display
3. **ChartWidget** - Reusable chart component
4. **LoadingState** - Consistent loading UI
5. **ErrorState** - Error message display
6. **EmptyState** - Empty list placeholder
7. **FilterChips** - Reusable filter UI

---

## 📚 Learning Resources

### Flutter Documentation:
- [Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Material Design](https://material.io/design)
- [Layout Guide](https://flutter.dev/docs/development/ui/layout)

### Best Practices:
- Keep widgets small and focused
- Use const constructors
- Separate business logic from UI
- Follow Flutter style guide
- Write meaningful variable names

---

*This documentation reflects the current frontend architecture of the AI Meal Planner app.*  
*Last updated: November 2025*
