import 'dart:convert';

class ProgressPhoto {
  final String imagePath;
  final DateTime date;
  final String label;

  ProgressPhoto({
    required this.imagePath,
    required this.date,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'date': date.toIso8601String(),
        'label': label,
      };

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) => ProgressPhoto(
        imagePath: json['imagePath'],
        date: DateTime.parse(json['date']),
        label: json['label'] ?? '',
      );

  static String listToJson(List<ProgressPhoto> list) =>
      jsonEncode(list.map((i) => i.toJson()).toList());

  static List<ProgressPhoto> listFromJson(String json) {
    final List<dynamic> decoded = jsonDecode(json);
    return decoded.map((i) => ProgressPhoto.fromJson(i)).toList();
  }
}
