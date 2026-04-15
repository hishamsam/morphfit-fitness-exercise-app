import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_session.dart';
import '../models/run_session.dart';
import '../models/user_profile.dart';
import '../models/progress_photo.dart';

class VaultService {
  static const _sessionsKey = 'morphfit_sessions';
  static const _biometricKey = 'morphfit_biometric';
  static const _metricKey = 'morphfit_metric';
  static const _profileKey = 'morphfit_user_profile';
  static const _runSessionsKey = 'morphfit_run_sessions';
  static const _watermarkKey = 'morphfit_watermark_enabled';
  static const _progressPhotosKey = 'morphfit_progress_photos';

  SharedPreferences? _prefs;
  List<ExerciseSession>? _sessionsCache;
  List<RunSession>? _runSessionsCache;

  /// Must be called before using the service
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // Pre-warm the cache synchronously (SharedPreferences data is small)
      loadAllSessions();
      loadAllRunSessions();
    } catch (e) {
      debugPrint('VaultService: SharedPreferences unavailable — $e');
      _prefs = null;
    }
  }

  static const _photo1Key = 'morphfit_photo_day1';
  static const _photo2Key = 'morphfit_photo_today';

  // ─── Settings ──────────────────────────────────────────────────────────────

  bool getBiometricEnabled() => _prefs?.getBool(_biometricKey) ?? true;

  Future<void> setBiometricEnabled(bool value) async =>
      _prefs?.setBool(_biometricKey, value);

  bool getIsMetric() => _prefs?.getBool(_metricKey) ?? true;

  Future<void> setIsMetric(bool value) async =>
      _prefs?.setBool(_metricKey, value);

  bool getWatermarkEnabled() => _prefs?.getBool(_watermarkKey) ?? true;

  Future<void> setWatermarkEnabled(bool value) async =>
      _prefs?.setBool(_watermarkKey, value);

  // ─── Transformation Photos ─────────────────────────────────────────────────

  String? getPhotoPath(String key) => _prefs?.getString(key);
  Future<void> savePhotoPath(String key, String path) async =>
      _prefs?.setString(key, path);
  Future<void> clearPhotoPath(String key) async => _prefs?.remove(key);

  String get photo1Key => _photo1Key;
  String get photo2Key => _photo2Key;

  List<ProgressPhoto> loadProgressPhotos() {
    if (_prefs == null) return [];
    final raw = _prefs!.getString(_progressPhotosKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return ProgressPhoto.listFromJson(raw);
    } catch (e) {
      debugPrint('VaultService: error loading progress photos: $e');
      return [];
    }
  }

  Future<void> saveProgressPhoto(ProgressPhoto photo) async {
    if (_prefs == null) return;
    final photos = loadProgressPhotos();
    photos.insert(0, photo); // newest first
    await _prefs!.setString(_progressPhotosKey, ProgressPhoto.listToJson(photos));
  }

  Future<void> deleteProgressPhoto(int index) async {
    if (_prefs == null) return;
    final photos = loadProgressPhotos();
    if (index >= 0 && index < photos.length) {
      photos.removeAt(index);
      await _prefs!.setString(_progressPhotosKey, ProgressPhoto.listToJson(photos));
    }
  }

  // ─── User Profile ──────────────────────────────────────────────────────────

  bool hasProfile() => _prefs?.containsKey(_profileKey) ?? false;

  UserProfile? loadProfile() {
    final raw = _prefs?.getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    return UserProfile.fromJsonString(raw);
  }

  Future<void> saveProfile(UserProfile profile) async =>
      _prefs?.setString(_profileKey, profile.toJsonString());

  Future<void> clearProfile() async => _prefs?.remove(_profileKey);


  List<ExerciseSession> loadAllSessions() {
    if (_sessionsCache != null) return _sessionsCache!;
    
    if (_prefs == null) return [];
    final raw = _prefs!.getString(_sessionsKey);
    if (raw == null || raw.isEmpty) {
      _sessionsCache = [];
      return [];
    }
    try {
      _sessionsCache = ExerciseSession.listFromJson(raw);
      return _sessionsCache!;
    } catch (_) {
      _sessionsCache = [];
      return [];
    }
  }

  Future<void> saveSession(ExerciseSession session) async {
    if (_prefs == null) return;
    final sessions = loadAllSessions();
    sessions.insert(0, session); // newest first
    _sessionsCache = sessions; // update cache
    await _prefs!.setString(_sessionsKey, ExerciseSession.listToJson(sessions));
  }

  Future<void> clearAll() async {
    await _prefs?.remove(_sessionsKey);
    await _prefs?.remove(_runSessionsKey);
    _sessionsCache = [];
    _runSessionsCache = [];
  }

  // ─── Run Sessions ──────────────────────────────────────────────────────────

  List<RunSession> loadAllRunSessions() {
    if (_runSessionsCache != null) return _runSessionsCache!;
    if (_prefs == null) return [];
    
    final raw = _prefs!.getString(_runSessionsKey);
    if (raw == null || raw.isEmpty) {
      _runSessionsCache = [];
      return [];
    }
    try {
      _runSessionsCache = RunSession.listFromJson(raw);
      return _runSessionsCache!;
    } catch (_) {
      _runSessionsCache = [];
      return [];
    }
  }

  Future<void> saveRunSession(RunSession session) async {
    if (_prefs == null) return;
    final sessions = loadAllRunSessions();
    sessions.insert(0, session);
    _runSessionsCache = sessions;

    // Simplify path before saving to keep size manageable
    final reducedSession = RunSession(
      id: session.id,
      date: session.date,
      duration: session.duration,
      distance: session.distance,
      avgPace: session.avgPace,
      path: RunSession.simplifyPath(session.path, 0.00001),
      backgroundImage: session.backgroundImage,
      watermarkEnabled: session.watermarkEnabled,
    );
    sessions[0] = reducedSession;
    await _prefs!.setString(_runSessionsKey, RunSession.listToJson(sessions));
  }

  // ─── Derived Stats ─────────────────────────────────────────────────────────

  /// Highest value ever recorded for a given exercise
  int getPersonalRecord(String exercise) {
    final sessions = loadAllSessions().where((s) => s.exercise == exercise);
    if (sessions.isEmpty) return 0;
    return sessions.map((s) => s.value).reduce((a, b) => a > b ? a : b);
  }

  /// Total reps (REP exercises only) across all sessions
  int getTotalVolume() {
    return loadAllSessions()
        .where((s) => s.type == 'REP')
        .fold(0, (sum, s) => sum + s.value);
  }

  /// Total KM across all run sessions
  double getTotalRunDistance() {
    return loadAllRunSessions()
        .fold(0.0, (sum, s) => sum + (s.distance / 1000.0));
  }

  /// Count sessions done today
  int todaySessionCount() {
    final today = DateTime.now();
    final sessions = loadAllSessions();
    return sessions
        .where((s) =>
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day)
        .length;
  }

  /// Count run sessions done today
  int todayRunCount() {
    final today = DateTime.now();
    final runs = loadAllRunSessions();
    return runs
        .where((s) =>
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day)
        .length;
  }

  /// Sessions per day for last 7 days (index 0 = 6 days ago, index 6 = today)
  List<int> last7DayCounts() {
    final now = DateTime.now();
    final sessions = loadAllSessions();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return sessions.where((s) {
        return s.date.year == day.year &&
            s.date.month == day.month &&
            s.date.day == day.day;
      }).length;
    });
  }

  /// PR progression over last 7 days for line chart
  List<double> prProgressionLast7Days(String exercise) {
    final now = DateTime.now();
    final sessions =
        loadAllSessions().where((s) => s.exercise == exercise).toList();
    double runningMax = 0;
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final daySessions = sessions.where((s) {
        return s.date.year == day.year &&
            s.date.month == day.month &&
            s.date.day == day.day;
      });
      if (daySessions.isNotEmpty) {
        final dayMax = daySessions
            .map((s) => s.value.toDouble())
            .reduce((a, b) => a > b ? a : b);
        if (dayMax > runningMax) runningMax = dayMax;
      }
      return runningMax;
    });
  }

  /// Total volume per day for last 7 days
  List<double> last7DayVolume() {
    final now = DateTime.now();
    final sessions = loadAllSessions();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return sessions.where((s) {
        return s.date.year == day.year &&
            s.date.month == day.month &&
            s.date.day == day.day;
      }).fold(0.0, (sum, s) => sum + s.value.toDouble());
    });
  }

  /// Running distance per day for last 7 days (in KM)
  List<double> last7DayRunDistance() {
    final now = DateTime.now();
    final runs = loadAllRunSessions();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return runs.where((s) {
        return s.date.year == day.year &&
            s.date.month == day.month &&
            s.date.day == day.day;
      }).fold(0.0, (sum, s) => sum + (s.distance / 1000.0));
    });
  }

  /// Export all sessions as formatted JSON string
  String exportToJson() {
    final sessions = loadAllSessions();
    final runs = loadAllRunSessions();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'exported_at': DateTime.now().toIso8601String(),
      'total_workout_sessions': sessions.length,
      'total_run_sessions': runs.length,
      'workout_sessions': sessions.map((s) => s.toJson()).toList(),
      'run_sessions': runs.map((s) => s.toJson()).toList(),
    });
  }
}
