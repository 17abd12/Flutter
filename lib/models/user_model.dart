class UserModel {
  final String uid;
  final String email;
  final String name;
  final int age;
  final double currentWeight;
  final double targetWeight;
  final double height;
  final String gender;
  final String goal; // Lose Weight, Build Muscle, Stay Fit
  final String activityLevel; // Low, Moderate, High
  final String duration; // 1 Month, 3 Months, etc.
  final int calorieIntakeGoal; // Daily calorie consumption goal
  final int calorieBurnGoal; // Daily calorie burn goal from exercise
  final String motivation;
  final String? mealPreference; // Dietary preferences (e.g., Vegetarian, Vegan, Keto, etc.)
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.currentWeight,
    required this.targetWeight,
    required this.height,
    required this.gender,
    required this.goal,
    required this.activityLevel,
    required this.duration,
    required this.calorieIntakeGoal,
    required this.calorieBurnGoal,
    required this.motivation,
    this.mealPreference,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'height': height,
      'gender': gender,
      'goal': goal,
      'activityLevel': activityLevel,
      'duration': duration,
      'calorieIntakeGoal': calorieIntakeGoal,
      'calorieBurnGoal': calorieBurnGoal,
      'motivation': motivation,
      'mealPreference': mealPreference,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      currentWeight: (map['currentWeight'] ?? 0).toDouble(),
      targetWeight: (map['targetWeight'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
      gender: map['gender'] ?? 'Male',
      goal: map['goal'] ?? 'Stay Fit',
      activityLevel: map['activityLevel'] ?? 'Moderate',
      duration: map['duration'] ?? '3 Months',
      calorieIntakeGoal: map['calorieIntakeGoal'] ?? 2000,
      calorieBurnGoal: map['calorieBurnGoal'] ?? 300,
      motivation: map['motivation'] ?? '',
      mealPreference: map['mealPreference'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    int? age,
    double? currentWeight,
    double? targetWeight,
    double? height,
    String? gender,
    String? goal,
    String? activityLevel,
    String? duration,
    int? calorieIntakeGoal,
    int? calorieBurnGoal,
    String? motivation,
    String? mealPreference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      duration: duration ?? this.duration,
      calorieIntakeGoal: calorieIntakeGoal ?? this.calorieIntakeGoal,
      calorieBurnGoal: calorieBurnGoal ?? this.calorieBurnGoal,
      motivation: motivation ?? this.motivation,
      mealPreference: mealPreference ?? this.mealPreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate BMI
  double get bmi => currentWeight / ((height / 100) * (height / 100));

  // Calculate remaining weight to lose/gain
  double get remainingWeight => (targetWeight - currentWeight).abs();
}
