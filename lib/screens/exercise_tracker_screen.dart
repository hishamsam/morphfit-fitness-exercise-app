import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../state_manager.dart';
import '../models/exercise_session.dart';
import '../widgets/kinetic_button.dart';

class ExerciseTrackerScreen extends StatefulWidget {
  final String exercise;
  final String type; // 'REP' or 'SEC'

  const ExerciseTrackerScreen({
    super.key,
    required this.exercise,
    required this.type,
  });

  @override
  State<ExerciseTrackerScreen> createState() => _ExerciseTrackerScreenState();
}

class _ExerciseTrackerScreenState extends State<ExerciseTrackerScreen>
    with SingleTickerProviderStateMixin {
  // ─── Rep mode state ─────────────────────────────────────────────────────────
  int _repCount = 0;

  // ─── Timer mode state ───────────────────────────────────────────────────────
  int _elapsedSeconds = 0;
  bool _timerRunning = false;
  Timer? _timer;

  // ─── Shared ─────────────────────────────────────────────────────────────────
  bool _sessionSaved = false;
  int _currentPR = 0;
  bool _isNewPR = false;

  // ─── Stopwatch (both modes) ─────────────────────────────────────────────────
  int _stopwatchSeconds = 0;
  Timer? _stopwatch;

  late AnimationController _pulseController;

  bool get isRepMode => widget.type == 'REP';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = AppStateProvider.of(context);
      setState(() {
        _currentPR = state.getPersonalRecord(widget.exercise);
      });
      if (isRepMode) {
        _startStopwatch();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Stopwatch (for rep mode elapsed time) ──────────────────────────────────
  void _startStopwatch() {
    _stopwatch = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _stopwatchSeconds++);
    });
  }

  // ─── Timer controls (for SEC mode) ──────────────────────────────────────────
  void _startTimer() {
    setState(() => _timerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
    if (_stopwatch == null) _startStopwatch();
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _timerRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    _stopwatch?.cancel();
    setState(() {
      _elapsedSeconds = 0;
      _stopwatchSeconds = 0;
      _timerRunning = false;
      _sessionSaved = false;
      _isNewPR = false;
    });
  }

  // ─── Rep controls ────────────────────────────────────────────────────────────
  void _increment() {
    setState(() {
      _repCount++;
      _isNewPR = _repCount > _currentPR && _currentPR > 0;
    });
  }

  void _decrement() {
    if (_repCount > 0) {
      setState(() {
        _repCount--;
        _isNewPR = _repCount > _currentPR && _currentPR > 0;
      });
    }
  }

  // ─── Save session ────────────────────────────────────────────────────────────
  Future<void> _saveSession() async {
    final value = isRepMode ? _repCount : _elapsedSeconds;
    if (value == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Record at least 1 rep or 1 second first.'),
          backgroundColor: AppColors.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final state = AppStateProvider.of(context);
    final isNewPR = value > _currentPR;

    final session = ExerciseSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exercise: widget.exercise,
      type: widget.type,
      value: value,
      date: DateTime.now(),
    );

    await state.saveSession(session);
    if (!mounted) return;

    setState(() {
      _sessionSaved = true;
      _isNewPR = isNewPR;
      if (isNewPR) _currentPR = value;
    });

    // Pause timer after save
    _timer?.cancel();
    _stopwatch?.cancel();
    setState(() => _timerRunning = false);

    if (isNewPR) {
      _showNewPRCelebration();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.exercise} session saved to vault! ($value ${widget.type.toLowerCase()}s)'),
          backgroundColor: AppColors.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showNewPRCelebration() {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (b) => AppColors.kineticGradient.createShader(b),
                child: Text(
                  '🏆',
                  style: GoogleFonts.spaceGrotesk(fontSize: 64),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'NEW PERSONAL RECORD!',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.exercise}: $_currentPR ${widget.type == 'REP' ? 'reps' : 'seconds'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              KineticButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'LOCK IT IN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.onPrimaryFixed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Format helpers ──────────────────────────────────────────────────────────
  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _primaryDisplay {
    if (isRepMode) return _repCount.toString();
    return _formatTime(_elapsedSeconds);
  }

  String get _primaryLabel => isRepMode ? 'TOTAL REPS' : 'TIME HELD';
  String get _unitLabel => isRepMode ? 'REPS' : 'TIME';

  @override
  Widget build(BuildContext context) {
    final pr = _currentPR;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopNav(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(context),
                  const SizedBox(height: 24),
                  _buildPRBadge(context, pr),
                  const SizedBox(height: 24),
                  _buildMainCounter(context),
                  const SizedBox(height: 20),
                  _buildSecondaryMetrics(context),
                  const SizedBox(height: 32),
                  _buildControls(context),
                  const SizedBox(height: 24),
                  if (_sessionSaved) _buildSavedBanner(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'MORPHFIT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRepMode ? Icons.repeat : Icons.timer,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.type,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVE SESSION',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                letterSpacing: 3.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.exercise.toUpperCase(),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
        ),
      ],
    );
  }

  Widget _buildPRBadge(BuildContext context, int pr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isNewPR
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.outlineVariant.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isNewPR ? Icons.emoji_events : Icons.military_tech,
            color: _isNewPR ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            pr == 0
                ? 'No PR yet — set your first!'
                : 'Current PR: $pr ${isRepMode ? 'reps' : 'sec'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isNewPR ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontWeight: _isNewPR ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          if (_isNewPR) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: AppColors.kineticGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'NEW PR!',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimaryFixed,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainCounter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
        border: _isNewPR
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Watermark
          Positioned(
            bottom: -12,
            right: -8,
            child: Text(
              _unitLabel,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 100,
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                _primaryLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary.withOpacity(0.5),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                    ),
              ),
              const SizedBox(height: 8),
              // Big number / time display
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  _primaryDisplay,
                  key: ValueKey(_primaryDisplay),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: isRepMode ? 110 : 80,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -4,
                    color: _isNewPR ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              ),
              // Rep mode: +/- buttons
              if (isRepMode) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCounterBtn(Icons.remove, _decrement),
                    const SizedBox(width: 24),
                    _buildCounterBtn(Icons.add, _increment, isPrimary: true),
                  ],
                ),
              ],
              // Timer mode: status indicator
              if (!isRepMode) ...[
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Opacity(
                    opacity: _timerRunning
                        ? 0.4 + _pulseController.value * 0.6
                        : 0.4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: _timerRunning
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _timerRunning ? '● RECORDING' : '○ PAUSED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _timerRunning
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBtn(IconData icon, VoidCallback onTap,
      {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isPrimary ? AppColors.kineticGradient : null,
          color: isPrimary ? null : AppColors.surfaceContainerHigh,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isPrimary ? AppColors.onPrimaryFixed : AppColors.onSurface,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSecondaryMetrics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricBox(
            context,
            label: 'ELAPSED',
            value: _formatTime(_stopwatchSeconds),
            icon: Icons.timer_outlined,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricBox(
            context,
            label: 'PERSONAL BEST',
            value: _currentPR == 0
                ? '—'
                : '$_currentPR ${isRepMode ? 'rep' : 'sec'}',
            icon: Icons.military_tech_outlined,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: color.withOpacity(0.4), width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    if (isRepMode) {
      // Rep mode: just Save button
      return Column(
        children: [
          KineticButton(
            onPressed: _sessionSaved ? () {} : _saveSession,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _sessionSaved ? Icons.check_circle : Icons.save_alt,
                  color: AppColors.onPrimaryFixed,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  _sessionSaved ? 'SESSION SAVED' : 'SAVE SESSION',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 2.0,
                    color: AppColors.onPrimaryFixed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildEndSessionBtn(context),
        ],
      );
    } else {
      // Timer mode: Start / Pause / Resume + Save
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KineticButton(
                  onPressed: _timerRunning ? _pauseTimer : _startTimer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _timerRunning ? Icons.pause : Icons.play_arrow,
                        color: AppColors.onPrimaryFixed,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _timerRunning
                            ? 'PAUSE'
                            : (_elapsedSeconds > 0 ? 'RESUME' : 'START'),
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2.0,
                          color: AppColors.onPrimaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _resetTimer,
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.refresh, color: AppColors.onSurfaceVariant, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          KineticButton(
            onPressed: _sessionSaved ? () {} : _saveSession,
            isPrimary: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _sessionSaved ? Icons.check_circle : Icons.save_alt,
                  color: _sessionSaved ? AppColors.secondary : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  _sessionSaved ? 'SESSION SAVED' : 'SAVE SESSION',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 2.0,
                    color: _sessionSaved ? AppColors.secondary : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildEndSessionBtn(context),
        ],
      );
    }
  }

  Widget _buildEndSessionBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.errorContainer.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stop_circle, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Text(
              'END SESSION',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 2.0,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: AppColors.secondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOCKED IN VAULT',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                ),
                Text(
                  'Session saved to your local encrypted vault.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceVariant.withOpacity(0.15))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: NavigationBar(
            backgroundColor: AppColors.background.withOpacity(0.7),
            indicatorColor: AppColors.primary,
            selectedIndex: 1,
            onDestinationSelected: (index) {
              if (index == 0) Navigator.pushReplacementNamed(context, '/home');
              if (index == 2) Navigator.pushReplacementNamed(context, '/progress');
              if (index == 3) Navigator.pushReplacementNamed(context, '/settings');
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'HOME'),
              NavigationDestination(
                icon: Icon(Icons.fitness_center),
                selectedIcon: Icon(Icons.fitness_center, color: AppColors.onPrimaryFixed),
                label: 'WORKOUT',
              ),
              NavigationDestination(icon: Icon(Icons.leaderboard_outlined), label: 'PROGRESS'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'SETTINGS'),
            ],
          ),
        ),
      ),
    );
  }
}
