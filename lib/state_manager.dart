import 'package:flutter/material.dart';
import 'models/exercise_session.dart';
import 'models/run_session.dart';
import 'models/user_profile.dart';
import 'models/progress_photo.dart';
import 'services/vault_service.dart';

class AppState extends ChangeNotifier {
  final VaultService _vault = VaultService();

  bool _biometricVaultEnabled = true;
  bool get biometricVaultEnabled => _biometricVaultEnabled;

  bool _isMetric = true;
  bool get isMetric => _isMetric;

  bool _watermarkEnabled = true;
  bool get watermarkEnabled => _watermarkEnabled;

  List<ExerciseSession> _sessions = [];
  List<ExerciseSession> get allSessions => List.unmodifiable(_sessions);

  List<RunSession> _runSessions = [];
  List<RunSession> get allRunSessions => List.unmodifiable(_runSessions);

  List<ProgressPhoto> _progressPhotos = [];
  List<ProgressPhoto> get progressPhotos => List.unmodifiable(_progressPhotos);

  UserProfile? _profile;
  UserProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void>? _initFuture;
  Future<void> get initializationDone => _initFuture ?? Future.value();

  /// Call once at startup. Can be called without await to avoid blocking UI.
  Future<void> init() {
    _initFuture = _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    try {
      await _vault.init();
      _biometricVaultEnabled = _vault.getBiometricEnabled();
      _isMetric = _vault.getIsMetric();
      _watermarkEnabled = _vault.getWatermarkEnabled();
      _sessions = _vault.loadAllSessions();
      _runSessions = _vault.loadAllRunSessions();
      _profile = _vault.loadProfile();
      _progressPhotos = _vault.loadProgressPhotos();
    } catch (e) {
      debugPrint('AppState(_doInit) non-fatal error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // ─── Profile ────────────────────────────────────────────────────────────────

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _vault.saveProfile(profile);
    notifyListeners();
  }

  Future<void> updateWeight(double newWeightKg) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(weightKg: newWeightKg);
    await _vault.saveProfile(_profile!);
    notifyListeners();
  }

  // ─── Settings ──────────────────────────────────────────────────────────────

  void toggleBiometrics() {
    _biometricVaultEnabled = !_biometricVaultEnabled;
    _vault.setBiometricEnabled(_biometricVaultEnabled);
    notifyListeners();
  }

  void toggleUnits() {
    _isMetric = !_isMetric;
    _vault.setIsMetric(_isMetric);
    notifyListeners();
  }

  void toggleWatermark() {
    _watermarkEnabled = !_watermarkEnabled;
    _vault.setWatermarkEnabled(_watermarkEnabled);
    notifyListeners();
  }

  // ─── Sessions ──────────────────────────────────────────────────────────────

  Future<void> saveSession(ExerciseSession session) async {
    await _vault.saveSession(session);
    _sessions = _vault.loadAllSessions();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _vault.clearAll();
    _sessions = [];
    _runSessions = [];
    notifyListeners();
  }

  // ─── Run Sessions ──────────────────────────────────────────────────────────

  Future<void> saveRunSession(RunSession session) async {
    await _vault.saveRunSession(session);
    _runSessions = _vault.loadAllRunSessions();
    notifyListeners();
  }

  // ─── Derived Stats ─────────────────────────────────────────────────────────

  int getPersonalRecord(String exercise) => _vault.getPersonalRecord(exercise);

  int getTotalVolume() => _vault.getTotalVolume();

  double getTotalRunDistance() => _vault.getTotalRunDistance();

  int todaySessionCount() => _vault.todaySessionCount();

  int todayRunCount() => _vault.todayRunCount();

  /// Daily progress as 0.0–1.0 based on how many of Big 6 done today (cap at 1.0)
  double getDailyProgress() {
    final done = todaySessionCount().clamp(0, bigSixExercises.length);
    return done / bigSixExercises.length;
  }

  List<int> last7DayCounts() => _vault.last7DayCounts();

  List<double> prProgressionLast7Days(String exercise) =>
      _vault.prProgressionLast7Days(exercise);

  List<double> last7DayVolume() => _vault.last7DayVolume();

  List<double> last7DayRunDistance() => _vault.last7DayRunDistance();

  String exportToJson() => _vault.exportToJson();

  String? getPhotoPath(String slot) =>
      _vault.getPhotoPath(slot == 'day1' ? _vault.photo1Key : _vault.photo2Key);

  Future<void> savePhotoPath(String slot, String path) =>
      _vault.savePhotoPath(slot == 'day1' ? _vault.photo1Key : _vault.photo2Key, path);

  // ─── Progress Photos ───────────────────────────────────────────────────────

  Future<void> addProgressPhoto(ProgressPhoto photo) async {
    await _vault.saveProgressPhoto(photo);
    _progressPhotos = _vault.loadProgressPhotos();
    notifyListeners();
  }

  Future<void> removeProgressPhoto(int index) async {
    await _vault.deleteProgressPhoto(index);
    _progressPhotos = _vault.loadProgressPhotos();
    notifyListeners();
  }

  List<ExerciseSession> getSessionsFor(String exercise) =>
      _sessions.where((s) => s.exercise == exercise).toList();
}

// ─── InheritedWidget Provider ─────────────────────────────────────────────────

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
        .notifier!;
  }
}
