import 'dart:convert';
import 'package:latlong2/latlong.dart';

class RunSession {
  final String id;
  final DateTime date;
  final Duration duration;
  final double distance; // in meters
  final String avgPace; // e.g., "5:30 min/km"
  final List<LatLng> path;
  final String? backgroundImage;
  final bool watermarkEnabled;

  const RunSession({
    required this.id,
    required this.date,
    required this.duration,
    required this.distance,
    required this.avgPace,
    required this.path,
    this.backgroundImage,
    this.watermarkEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'duration_ms': duration.inMilliseconds,
        'distance': distance,
        'avgPace': avgPace,
        'path': path.map((point) => {
          'lat': double.parse(point.latitude.toStringAsFixed(5)),
          'lng': double.parse(point.longitude.toStringAsFixed(5))
        }).toList(),
        'backgroundImage': backgroundImage,
        'watermarkEnabled': watermarkEnabled,
      };

  // Helper for Ramer-Douglas-Peucker algorithm to reduce points on export if needed
  static List<LatLng> simplifyPath(List<LatLng> points, double toleranceSq) {
    if (points.length < 3) return points;
    double maxDist = 0;
    int index = 0;

    for (int i = 1; i < points.length - 1; i++) {
        double dist = _pointLineDistanceSq(points[i], points.first, points.last);
        if (dist > maxDist) {
            index = i;
            maxDist = dist;
        }
    }

    if (maxDist > toleranceSq) {
        final rec1 = simplifyPath(points.sublist(0, index + 1), toleranceSq);
        final rec2 = simplifyPath(points.sublist(index, points.length), toleranceSq);
        return rec1.sublist(0, rec1.length - 1)..addAll(rec2);
    } else {
        return [points.first, points.last];
    }
  }

  static double _pointLineDistanceSq(LatLng p, LatLng a, LatLng b) {
      double dx = b.longitude - a.longitude;
      double dy = b.latitude - a.latitude;
      double lenSq = dx * dx + dy * dy;
      if (lenSq == 0) return _distSq(p, a); // a == b
      double t = ((p.longitude - a.longitude) * dx + (p.latitude - a.latitude) * dy) / lenSq;
      t = t.clamp(0.0, 1.0);
      LatLng proj = LatLng(a.latitude + t * dy, a.longitude + t * dx);
      return _distSq(p, proj);
  }

  static double _distSq(LatLng p1, LatLng p2) {
      double dx = p1.longitude - p2.longitude;
      double dy = p1.latitude - p2.latitude;
      return dx * dx + dy * dy;
  }

  factory RunSession.fromJson(Map<String, dynamic> json) => RunSession(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        duration: Duration(milliseconds: json['duration_ms'] as int),
        distance: (json['distance'] as num).toDouble(),
        avgPace: json['avgPace'] as String,
        path: (json['path'] as List<dynamic>)
            .map((p) => LatLng(p['lat'] as double, p['lng'] as double))
            .toList(),
        backgroundImage: json['backgroundImage'] as String?,
        watermarkEnabled: json['watermarkEnabled'] as bool? ?? true,
      );

  static List<RunSession> listFromJson(String jsonString) {
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => RunSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<RunSession> sessions) {
    return jsonEncode(sessions.map((e) => e.toJson()).toList());
  }

  String get formattedDistance => (distance / 1000).toStringAsFixed(2);
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
