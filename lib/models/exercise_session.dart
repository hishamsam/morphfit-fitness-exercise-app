import 'dart:convert';

class ExerciseSession {
  final String id;
  final String exercise;
  final String type; // 'REP' or 'SEC'
  final int value; // reps or seconds
  final DateTime date;

  const ExerciseSession({
    required this.id,
    required this.exercise,
    required this.type,
    required this.value,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'exercise': exercise,
        'type': type,
        'value': value,
        'date': date.toIso8601String(),
      };

  factory ExerciseSession.fromJson(Map<String, dynamic> json) =>
      ExerciseSession(
        id: json['id'] as String,
        exercise: json['exercise'] as String,
        type: json['type'] as String,
        value: json['value'] as int,
        date: DateTime.parse(json['date'] as String),
      );

  static List<ExerciseSession> listFromJson(String jsonString) {
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => ExerciseSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<ExerciseSession> sessions) {
    return jsonEncode(sessions.map((e) => e.toJson()).toList());
  }
}

/// The Big 6 exercise definitions
class ExerciseDef {
  final String name;
  final String type; // 'REP' or 'SEC'
  final String subtitle;

  const ExerciseDef({
    required this.name,
    required this.type,
    required this.subtitle,
  });
}

const List<ExerciseDef> bigSixExercises = [
  ExerciseDef(name: 'Push-ups', type: 'REP', subtitle: 'Upper body push'),
  ExerciseDef(name: 'Body Squats', type: 'REP', subtitle: 'Kinetic foundation'),
  ExerciseDef(name: 'Lunges', type: 'REP', subtitle: 'Unilateral leg'),
  ExerciseDef(name: 'Sit-ups', type: 'REP', subtitle: 'Core stability'),
  ExerciseDef(name: 'Wall Sit', type: 'SEC', subtitle: 'Isometric hold'),
  ExerciseDef(name: 'Plank', type: 'SEC', subtitle: 'Core mastery'),
];
