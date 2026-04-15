import 'dart:io';
import 'dart:ui' show lerpDouble, ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../state_manager.dart';
import '../widgets/glass_panel.dart';
import '../widgets/kinetic_button.dart';
import '../models/progress_photo.dart';
import 'physical_evolution_screen.dart';

class ProgressMirrorScreen extends StatefulWidget {
  const ProgressMirrorScreen({super.key});

  @override
  State<ProgressMirrorScreen> createState() => _ProgressMirrorScreenState();
}

class _ProgressMirrorScreenState extends State<ProgressMirrorScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickPhoto(String slot) async {
    // Legacy mapping for other parts if still used, otherwise will be cleaned up
  }

  Future<ImageSource?> _showSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: AppColors.primary),
              ),
              title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Use camera now'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library, color: AppColors.secondary),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Pick existing photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                _buildHeader(context, state),
                const SizedBox(height: 32),
                _buildEvolutionEntry(context, state),
                const SizedBox(height: 32),
                _buildPowerBento(context, state),
                const SizedBox(height: 48),
                _buildVelocityMetrics(context, state),
                const SizedBox(height: 32),
                _buildRunHistory(context, state),
                const SizedBox(height: 32),
                _buildDataIntegrityBadge(context),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      toolbarHeight: 72,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceContainerHigh,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: const Icon(Icons.person, color: AppColors.primary, size: 20),
        ),
      ),
      title: Text(
        'MORPHFIT',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: AppColors.primary,
          letterSpacing: 2.0,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'VAULT ON',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.security, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    final sessionCount = state.allSessions.length;
    final totalVol = state.getTotalVolume();
    final volDisplay = totalVol >= 1000
        ? '${(totalVol / 1000).toStringAsFixed(1)}k'
        : totalVol.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE ARCHIVES',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                'Progress Gallery',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatBox(context, 'SESSIONS', '$sessionCount'),
                _buildStatBox(context, 'DISTANCE', state.getTotalRunDistance().toStringAsFixed(1), unit: 'km'),
                _buildStatBox(context, 'VOLUME', volDisplay, unit: 'rep'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, String label, String value, {String? unit}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 7,
                  letterSpacing: 1.0,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              if (unit != null)
                Text(
                  unit,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Removed _buildMorphSlider

  Widget _buildEvolutionEntry(BuildContext context, AppState state) {
    final photos = state.progressPhotos;
    final count = photos.length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PhysicalEvolutionScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                gradient: AppColors.kineticGradient,
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.onPrimaryFixed, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'PHYSICAL EVOLUTION',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onPrimaryFixed,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimaryFixed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count PHOTOS',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryFixed,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stacked thumbnail preview
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      children: [
                        // Back card (placeholder or 3rd photo)
                        if (count >= 3)
                          Positioned(
                            top: 8,
                            left: 8,
                            right: 0,
                            bottom: 0,
                            child: _evolutionThumbnail(photos[2]),
                          )
                        else
                          Positioned(
                            top: 8,
                            left: 8,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        // Middle card (2nd photo)
                        if (count >= 2)
                          Positioned(
                            top: 4,
                            left: 4,
                            right: 4,
                            bottom: 4,
                            child: _evolutionThumbnail(photos[1]),
                          )
                        else
                          Positioned(
                            top: 4,
                            left: 4,
                            right: 4,
                            bottom: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        // Front card (most recent)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 8,
                          bottom: 8,
                          child: count > 0
                              ? _evolutionThumbnail(photos.first)
                              : Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.outlineVariant
                                            .withOpacity(0.3)),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.add_a_photo_outlined,
                                        color: AppColors.onSurfaceVariant, size: 24),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          count == 0
                              ? 'Start your journey'
                              : count == 1
                                  ? 'Your journey begins'
                                  : 'Track your transformation',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          count == 0
                              ? 'Add your first progress photo to begin comparing your physical transformation over time.'
                              : 'Compare photos side-by-side, browse your timeline, and track your physical evolution.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: AppColors.kineticGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.compare,
                                      color: AppColors.onPrimaryFixed, size: 13),
                                  const SizedBox(width: 6),
                                  Text(
                                    count == 0 ? 'GET STARTED' : 'VIEW EVOLUTION',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.onPrimaryFixed,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 10),
                              Text(
                                '${count} entries',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
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

  Widget _evolutionThumbnail(ProgressPhoto photo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(photo.imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surfaceContainerHigh,
            ),
          ),
          // Gradient for text readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          // Date overlay
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Text(
              '${photo.date.day}/${photo.date.month}',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(String message, IconData icon) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant.withOpacity(0.3), size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportFlow(BuildContext context) {
    final state = AppStateProvider.of(context);
    final profile = state.profile;
    final totalVol = state.getTotalVolume();
    final totalSessions = state.allSessions.length;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            const Icon(Icons.share, color: AppColors.secondary, size: 48),
            const SizedBox(height: 24),
            Text('VAULT EXTRACTION', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            const SizedBox(height: 12),
            Text(
              'Generating performance snapshot for ${profile?.name ?? "Athlete"}...\n$totalSessions Sessions | $totalVol Reps Total',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const Spacer(),
            KineticButton(
              onPressed: () {
                Navigator.pop(ctx);
                final summary = '''
⚡ MORPHFIT EVOLUTION REPORT ⚡
Athlete: ${profile?.name ?? "User"}
Total Sessions: $totalSessions
Total Volume: $totalVol reps
Current BMI: ${profile?.bmi.toStringAsFixed(1) ?? "N/A"}
Goal: ${profile?.goal ?? "Fitness"}

Sent from MorphFit Vault.
''';
                Share.share(summary, subject: 'My Performance Protocol');
              },
              child: const Text('SHARE TO WHATSAPP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerBento(BuildContext context, AppState state) {
    final sessionCount = state.allSessions.length;
    final totalVol = state.getTotalVolume();
    final isNarrow = MediaQuery.of(context).size.width < 380;
    final children = [
      Expanded(
        flex: 5,
        child: Container(
          height: 170,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.bolt, color: AppColors.secondary, size: 28),
                  Text(
                    'PEAK POWER',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 7,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$sessionCount',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'total sessions logged',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 4,
        child: Container(
          height: 170,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BODY COMP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 7,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildCompRow(context, 'Total Volume', '${totalVol}rep', AppColors.primary, totalVol == 0 ? 0.01 : (totalVol / (totalVol + 500)).clamp(0.05, 1.0)),
              const SizedBox(height: 12),
              _buildCompRow(context, 'Sessions', '$sessionCount done', AppColors.secondary, sessionCount == 0 ? 0.01 : (sessionCount / 10).clamp(0.05, 1.0)),
            ],
          ),
        ),
      ),
    ];
    return isNarrow
        ? Column(children: [
            children[0] as Widget,
            const SizedBox(height: 12),
            children[2] as Widget,
          ])
        : Row(children: children);
  }

  Widget _buildCompRow(BuildContext context, String label, String value, Color color, double percent) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ],
    );
  }

  Widget _buildVelocityMetrics(BuildContext context, AppState state) {
    final isNarrow = MediaQuery.of(context).size.width < 400;
    
    // Session Log (Bar Chart)
    final sessionData = state.last7DayCounts();
    final maxSessions = sessionData.isEmpty ? 1 : sessionData.reduce((a, b) => a > b ? a : b);
    final sessionHeights = sessionData.map((c) => maxSessions == 0 ? 0.05 : (c / maxSessions).clamp(0.05, 1.0)).toList();

    // Training Density (Line Chart)
    final volumeData = state.last7DayVolume();
    final maxVol = volumeData.isEmpty ? 1.0 : volumeData.reduce((a, b) => a > b ? a : b);
    final volumeHeights = volumeData.map((v) => maxVol == 0 ? 0.05 : (v / maxVol).clamp(0.05, 1.0)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Text(
              'Velocity Metrics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: [
                _buildToggle('1 Month', true),
                _buildToggle('All Time', false),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        isNarrow
            ? Column(
                children: [
                  _buildChartCard(context, 'Session Log', 'Last 7 Days', true, data: sessionHeights),
                  const SizedBox(height: 16),
                  _buildChartCard(context, 'Training Density', 'Relative Intensity', false, data: volumeHeights),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildChartCard(context, 'Session Log', 'Last 7 Days', true, data: sessionHeights)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildChartCard(context, 'Training Density', 'Relative Intensity', false, data: volumeHeights)),
                ],
              ),
      ],
    );
  }

  Widget _buildToggle(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: isActive ? AppColors.onPrimaryFixed : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, String label, String title, bool isBarChart, {required List<double> data}) {
    // Labels for last 7 weekdays
    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return ['M','T','W','T','F','S','S'][day.weekday - 1];
    });
    return Container(
      padding: const EdgeInsets.all(20),
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontSize: 8, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(isBarChart ? Icons.bar_chart : Icons.analytics, color: isBarChart ? AppColors.primary : AppColors.secondary, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          const Spacer(),
          SizedBox(
            height: 110,
            child: isBarChart
                ? BarChartPainter(heights: data)
                : LineChartPainter(data: data),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: (isBarChart ? dayLabels : ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              .map((e) => Text(e, style: const TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)))
              .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRunHistory(BuildContext context, AppState state) {
    final runs = state.allRunSessions;
    if (runs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kinetic Path Archive',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${runs.length} RUNS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.0),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: runs.length > 5 ? 5 : runs.length, // Show last 5
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final run = runs[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_run, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${run.formattedDistance} KM Run',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${run.date.day}/${run.date.month}/${run.date.year} • ${run.formattedDuration}',
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        run.avgPace.split(' ').first,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                      const Text(
                        'MIN/KM',
                        style: TextStyle(fontSize: 8, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        if (runs.length > 5) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {}, // Future: show full log
              child: Text(
                'VIEW ALL RECORDS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDataIntegrityBadge(BuildContext context) {
    return Column(
      children: [
        Text(
          'BMI CALCULATED VIA MEDICAL STANDARD: KG / M²',
          style: TextStyle(
            fontSize: 7,
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
            ),
            child: Wrap(
              spacing: 32,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildBadgeCircle(Icons.lock, AppColors.primary, AppColors.onPrimaryFixed),
                    Positioned(
                      left: 12,
                      child: _buildBadgeCircle(Icons.sync, AppColors.secondary, AppColors.onSecondary),
                    ),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('END-TO-END ENCRYPTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    Text('All metrics are synced locally.', style: TextStyle(fontSize: 8, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCircle(IconData icon, Color bg, Color iconColor) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg, border: Border.all(color: AppColors.background, width: 2)),
      child: Icon(icon, color: iconColor, size: 12),
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
            selectedIndex: 3,
            onDestinationSelected: (index) {
              if (index == 0) Navigator.pushReplacementNamed(context, '/home');
              if (index == 1) Navigator.pushReplacementNamed(context, '/run');
              if (index == 2) Navigator.pushReplacementNamed(context, '/workout');
              if (index == 4) Navigator.pushReplacementNamed(context, '/settings');
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: 'HOME',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                label: 'RUN',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                label: 'WORKOUT',
              ),
              NavigationDestination(
                icon: Icon(Icons.leaderboard),
                selectedIcon: Icon(Icons.leaderboard, color: AppColors.onPrimaryFixed),
                label: 'PROGRESS',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: 'SETTINGS',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarChartPainter extends StatelessWidget {
  final List<double> heights;
  const BarChartPainter({super.key, required this.heights});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights.asMap().entries.map((e) {
        final isToday = e.key == heights.length - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              height: 110 * e.value,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                gradient: isToday ? AppColors.kineticGradient : null,
                color: isToday ? null : AppColors.surfaceContainerHighest.withOpacity(0.3 + (e.value * 0.5)),
                boxShadow: isToday ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10)] : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class LineChartPainter extends StatelessWidget {
  final List<double> data;
  const LineChartPainter({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _LinePainter(data: data),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> data;
  _LinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height * (1.0 - data[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Simple smoothing between points
        final prevX = (i - 1) * stepX;
        final prevY = size.height * (1.0 - data[i - 1]);
        path.cubicTo(
          prevX + stepX / 2, prevY,
          x - stepX / 2, y,
          x, y,
        );
      }
    }

    canvas.drawPath(path, paint);

    // Fill
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Reuse GlassPanel paddings
extension on GlassPanel {
  GlassPanel copyWith({EdgeInsetsGeometry? padding}) {
    return GlassPanel(
      blur: blur,
      opacity: opacity,
      color: color,
      borderRadius: borderRadius,
      border: border,
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}

// Helper to add padding to GlassPanel since I forgot it in the base class
class GlassPanelWithPadding extends GlassPanel {
  final EdgeInsetsGeometry padding;
  const GlassPanelWithPadding({
    super.key,
    required super.child,
    this.padding = EdgeInsets.zero,
    super.blur,
    super.opacity,
    super.color,
    super.borderRadius,
    super.border,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      blur: blur,
      opacity: opacity,
      color: color,
      borderRadius: borderRadius,
      border: border,
      child: Padding(padding: padding, child: child),
    );
  }
}
