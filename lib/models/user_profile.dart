import 'dart:convert';

class UserProfile {
  final String name;
  final int age;
  final String gender;       // 'Male', 'Female', 'Other'
  final double heightCm;     // Always stored in cm
  final double weightKg;     // Always stored in kg
  final String fitnessLevel; // 'Beginner', 'Intermediate', 'Advanced'
  final String goal;         // 'Build Strength', 'Lose Weight', 'Get Fit', 'Endurance'
  final DateTime createdAt;

  const UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.fitnessLevel,
    required this.goal,
    required this.createdAt,
  });

  /// BMI = weight(kg) / height(m)^2
  double get bmi {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  String get bmiCategory {
    final v = bmi;
    if (v < 18.5) return 'Underweight';
    if (v < 25.0) return 'Normal';
    if (v < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Days since the user created their profile
  int get daysSinceStart => DateTime.now().difference(createdAt).inDays;

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? fitnessLevel,
    String? goal,
    DateTime? createdAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'gender': gender,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'fitnessLevel': fitnessLevel,
    'goal': goal,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String,
    age: json['age'] as int,
    gender: json['gender'] as String,
    heightCm: (json['heightCm'] as num).toDouble(),
    weightKg: (json['weightKg'] as num).toDouble(),
    fitnessLevel: json['fitnessLevel'] as String,
    goal: json['goal'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  String toJsonString() => jsonEncode(toJson());

  static UserProfile? fromJsonString(String raw) {
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
