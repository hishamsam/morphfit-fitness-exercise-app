import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme.dart';
import '../state_manager.dart';
import '../models/user_profile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 5;

  // ─── Collected data ─────────────────────────────────────────────────────────
  String _name = '';
  int _age = 25;
  String _gender = 'Male';
  double _heightCm = 170;
  double _weightKg = 70;
  String _fitnessLevel = 'Beginner';
  String _goal = 'Get Fit';

  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '70');

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_currentPage == 0) _name = _nameController.text.trim();
    if (_currentPage == 1) {
      _age = int.tryParse(_ageController.text) ?? 25;
    }
    if (_currentPage == 2) {
      _heightCm = double.tryParse(_heightController.text) ?? 170;
      _weightKg = double.tryParse(_weightController.text) ?? 70;
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _saveProfile();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _saveProfile() async {
    final profile = UserProfile(
      name: _name,
      age: _age,
      gender: _gender,
      heightCm: _heightCm,
      weightKg: _weightKg,
      fitnessLevel: _fitnessLevel,
      goal: _goal,
      createdAt: DateTime.now(),
    );

    final state = AppStateProvider.of(context);
    await state.saveProfile(profile);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildNamePage(),
                  _buildAgePage(),
                  _buildBodyPage(),
                  _buildLevelPage(),
                  _buildGoalPage(),
                ],
              ),
            ),
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  // ─── Progress Bar ───────────────────────────────────────────────────────────

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP ${_currentPage + 1} OF $_totalPages',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
              ),
              Text(
                '${((_currentPage + 1) / _totalPages * 100).round()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                widthFactor: (_currentPage + 1) / _totalPages,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: AppColors.kineticGradient,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Page: Name ─────────────────────────────────────────────────────────────

  Widget _buildNamePage() {
    return _buildPageFrame(
      icon: Icons.person_outline,
      label: 'IDENTITY',
      title: 'What should we call you?',
      subtitle: 'This will be your profile name in the Vault.',
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: TextField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            hintText: 'Your Name',
            hintStyle: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant.withOpacity(0.2),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          ),
        ),
      ),
    );
  }

  // ─── Page: Age & Gender ─────────────────────────────────────────────────────

  Widget _buildAgePage() {
    final genders = ['Male', 'Female', 'Other'];
    return _buildPageFrame(
      icon: Icons.cake_outlined,
      label: 'BIOMETRICS',
      title: 'Age & Gender',
      subtitle: 'Helps calibrate expectations for your fitness journey.',
      child: Column(
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.spaceGrotesk(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                suffixText: 'years',
                suffixStyle: TextStyle(
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
            child: Row(
              children: genders.map((g) {
                final selected = _gender == g;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _gender = g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.outlineVariant.withOpacity(0.1),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            g.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page: Height & Weight ──────────────────────────────────────────────────

  Widget _buildBodyPage() {
    return _buildPageFrame(
      icon: Icons.straighten_outlined,
      label: 'MORPHOMETRICS',
      title: 'Your Body',
      subtitle: 'We\'ll track BMI and progress over time.',
      child: FadeInUp(
        duration: const Duration(milliseconds: 400),
        child: Row(
          children: [
            Expanded(
              child: _buildMetricField(
                controller: _heightController,
                label: 'HEIGHT',
                unit: 'cm',
                icon: Icons.height,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricField(
                controller: _weightController,
                label: 'WEIGHT',
                unit: 'kg',
                icon: Icons.monitor_weight_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixText: unit,
              suffixStyle: TextStyle(
                color: AppColors.onSurfaceVariant.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page: Fitness Level ────────────────────────────────────────────────────

  Widget _buildLevelPage() {
    final levels = [
      ('Beginner', 'Just starting my fitness journey', Icons.emoji_people),
      ('Intermediate', 'I exercise regularly and know the basics', Icons.directions_run),
      ('Advanced', 'Experienced athlete pushing limits', Icons.bolt),
    ];
    return _buildPageFrame(
      icon: Icons.speed_outlined,
      label: 'ASSESSMENT',
      title: 'Fitness Level',
      subtitle: 'Helps us calibrate your experience.',
      child: Column(
        children: levels.asMap().entries.map((entry) {
          final i = entry.key;
          final (label, desc, icon) = entry.value;
          final selected = _fitnessLevel == label;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FadeInUp(
              delay: Duration(milliseconds: 100 * i),
              duration: const Duration(milliseconds: 400),
              child: GestureDetector(
                onTap: () => setState(() => _fitnessLevel = label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.outlineVariant.withOpacity(0.1),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          color: selected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Page: Goal ─────────────────────────────────────────────────────────────

  Widget _buildGoalPage() {
    final goals = [
      ('Build Strength', Icons.fitness_center, AppColors.primary),
      ('Lose Weight', Icons.local_fire_department, AppColors.error),
      ('Get Fit', Icons.self_improvement, AppColors.secondary),
      ('Endurance', Icons.timer, AppColors.tertiary),
    ];
    return _buildPageFrame(
      icon: Icons.flag_outlined,
      label: 'MISSION',
      title: 'What\'s your goal?',
      subtitle: 'We\'ll adapt your experience accordingly.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: goals.asMap().entries.map((entry) {
          final i = entry.key;
          final (label, icon, color) = entry.value;
          final selected = _goal == label;
          return FadeInUp(
            delay: Duration(milliseconds: 80 * i),
            duration: const Duration(milliseconds: 400),
            child: GestureDetector(
              onTap: () => setState(() => _goal = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: (MediaQuery.of(context).size.width - 60) / 2,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withOpacity(0.12)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? color
                        : AppColors.outlineVariant.withOpacity(0.1),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: selected ? color : AppColors.onSurfaceVariant, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      label.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: selected ? color : AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (selected)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Icon(Icons.check_circle, color: color, size: 18),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Page Frame ─────────────────────────────────────────────────────────────

  Widget _buildPageFrame({
    required IconData icon,
    required String label,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(height: 20),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 400),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
            child: Text(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 250),
            duration: const Duration(milliseconds: 400),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ),
          const SizedBox(height: 36),
          child,
        ],
      ),
    );
  }

  // ─── Nav Buttons ────────────────────────────────────────────────────────────

  Widget _buildNavButtons() {
    final isLast = _currentPage == _totalPages - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevPage,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'BACK',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 56),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'START EVOLUTION' : 'CONTINUE',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(isLast ? Icons.rocket_launch : Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
