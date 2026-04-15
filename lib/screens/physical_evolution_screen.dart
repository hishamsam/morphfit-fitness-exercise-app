import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../models/progress_photo.dart';
import '../state_manager.dart';
import '../theme.dart';

class PhysicalEvolutionScreen extends StatefulWidget {
  const PhysicalEvolutionScreen({super.key});

  @override
  State<PhysicalEvolutionScreen> createState() =>
      _PhysicalEvolutionScreenState();
}

class _PhysicalEvolutionScreenState extends State<PhysicalEvolutionScreen>
    with TickerProviderStateMixin {
  final _picker = ImagePicker();
  final ScreenshotController _screenshotController = ScreenshotController();

  // The reference photo currently shown on the LEFT
  int _referenceIndex = 0;

  // Global watermark toggle
  bool _showWatermark = true;

  // For the "TODAY" right side — always the first/most-recent photo
  // (or a separate picked photo)
  String? _todayPhotoPath;
  DateTime? _todayDate;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    // Load watermark setting from state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = AppStateProvider.of(context);
      setState(() {
        _showWatermark = state.watermarkEnabled;
        // Pre-select today's photo as the newest in the vault
        if (state.progressPhotos.isNotEmpty) {
          _todayPhotoPath = state.progressPhotos.first.imagePath;
          _todayDate = state.progressPhotos.first.date;
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ─── Photo picking ──────────────────────────────────────────────────────────

  Future<void> _addNewPhoto() async {
    final source = await _showSourceDialog();
    if (source == null) return;
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null || !mounted) return;

    final labelController = TextEditingController();
    // Label dialog
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Label this photo',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: labelController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Day 1, Week 4, Month 3...',
            hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: AppColors.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, ''),
            child: const Text('SKIP'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, labelController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimaryFixed,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('SAVE',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    final state = AppStateProvider.of(context);
    final photo = ProgressPhoto(
      imagePath: picked.path,
      date: DateTime.now(),
      label: (label == null || label.isEmpty)
          ? _autoLabel(state.progressPhotos.length)
          : label,
    );
    await state.addProgressPhoto(photo);

    // Refresh today's photo to the newest
    if (mounted) {
      setState(() {
        _todayPhotoPath = state.progressPhotos.first.imagePath;
        _todayDate = state.progressPhotos.first.date;
        _referenceIndex = state.progressPhotos.length > 1 ? 1 : 0;
      });
    }
  }

  String _autoLabel(int existingCount) {
    if (existingCount == 0) return 'Day 1';
    final weeks = existingCount;
    return 'Week $weeks';
  }

  Future<void> _setTodayPhoto() async {
    final source = await _showSourceDialog();
    if (source == null) return;
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _todayPhotoPath = picked.path;
      _todayDate = DateTime.now();
    });
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
                color: AppColors.outlineVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: AppColors.primary),
              ),
              title: Text('Take Photo',
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
              subtitle: const Text('Use camera now'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.photo_library, color: AppColors.secondary),
              ),
              title: Text('Choose from Gallery',
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
              subtitle: const Text('Pick existing photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToGallery() async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final image = await _screenshotController.capture(
          delay: const Duration(milliseconds: 10));
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/morphfit_evolution_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await imagePath.writeAsBytes(image);

      await Gal.putImage(imagePath.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.onPrimaryFixed, size: 20),
                const SizedBox(width: 12),
                Text('Saved to gallery!', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final photos = state.progressPhotos;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildSectionLabel('PHYSICAL EVOLUTION'),
                    const SizedBox(height: 4),
                    Text(
                      'Track your transformation journey.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    // Global controls row
                    _buildControlsRow(state, photos),
                    const SizedBox(height: 20),
                    // Main comparison view
                    _buildComparisonView(context, photos),
                    const SizedBox(height: 20),
                    // Filmstrip timeline
                    if (photos.isNotEmpty) ...[
                      _buildSectionLabel('TIMELINE'),
                      const SizedBox(height: 12),
                      _buildFilmstrip(context, photos),
                    ],
                    const SizedBox(height: 32),
                    // Add photo button
                    _buildAddPhotoButton(),
                    SizedBox(height: 32 + bottomPad),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      toolbarHeight: 64,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primary, size: 16),
        ),
      ),
      title: Text(
        'PHYSICAL EVOLUTION',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
          letterSpacing: 2,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildWatermarkToggle(),
        ),
      ],
    );
  }

  // ─── Controls row ───────────────────────────────────────────────────────────

  Widget _buildControlsRow(AppState state, List<ProgressPhoto> photos) {
    return Row(
      children: [
        // Photo count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined,
                  color: AppColors.secondary, size: 16),
              const SizedBox(width: 8),
              Text(
                '${photos.length} Photos',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Watermark label
        Text('Watermark',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        _buildWatermarkToggle(),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            if (photos.isNotEmpty) {
              _saveToGallery();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add photos first!')),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Icon(Icons.download, color: AppColors.primary, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildWatermarkToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => _showWatermark = !_showWatermark);
        AppStateProvider.of(context).toggleWatermark();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: _showWatermark ? AppColors.kineticGradient : null,
          color: _showWatermark ? null : AppColors.surfaceContainerHigh,
          border: Border.all(
            color: _showWatermark
                ? Colors.transparent
                : AppColors.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment:
              _showWatermark ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _showWatermark
                  ? AppColors.onPrimaryFixed
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Main comparison (side-by-side) ─────────────────────────────────────────

  Widget _buildComparisonView(
      BuildContext context, List<ProgressPhoto> photos) {
    final screenW = MediaQuery.of(context).size.width - 32;
    final height = screenW * 0.7;

    final ProgressPhoto? refPhoto =
        photos.isNotEmpty ? photos[_referenceIndex] : null;
    final todayPath = _todayPhotoPath;
    final todayDate = _todayDate;

    return LayoutBuilder(builder: (context, constraints) {
      return Screenshot(
        controller: _screenshotController,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.15), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // LEFT — Reference photo
            Expanded(
              child: _buildPhotoPanel(
                label: refPhoto?.label ?? 'REFERENCE',
                imagePath: refPhoto?.imagePath,
                date: refPhoto?.date,
                isLeft: true,
                onTap: photos.isEmpty ? _addNewPhoto : null,
                emptyHint:
                    photos.isEmpty ? 'Add first\nphoto' : 'Tap timeline',
              ),
            ),
            // Divider
            Container(
              width: 2,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.0),
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerHigh,
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.compare_arrows,
                      color: AppColors.primary, size: 16),
                ),
              ),
            ),
            // RIGHT — Today's photo
            Expanded(
              child: _buildPhotoPanel(
                label: 'TODAY',
                imagePath: todayPath,
                date: todayDate,
                isLeft: false,
                onTap: _setTodayPhoto,
                emptyHint: 'Tap to add\ntoday\'s photo',
              ),
            ),
          ],
        ),
      ),
      );
    });
  }

  Widget _buildPhotoPanel({
    required String label,
    required String? imagePath,
    required DateTime? date,
    required bool isLeft,
    required VoidCallback? onTap,
    required String emptyHint,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo or placeholder
          imagePath != null
              ? Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _emptyPanel(emptyHint),
                )
              : _emptyPanel(emptyHint),

          // Bottom gradient for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.65),
                  ],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),

          // Watermark overlay
          if (_showWatermark && date != null)
            Positioned(
              top: 10,
              left: isLeft ? 10 : null,
              right: isLeft ? null : 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          // Label chip at bottom
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: isLeft
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: isLeft ? null : AppColors.kineticGradient,
                    color: isLeft
                        ? AppColors.surfaceContainerHigh.withOpacity(0.85)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: isLeft
                        ? Border.all(
                            color: AppColors.outlineVariant.withOpacity(0.3))
                        : null,
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isLeft
                          ? AppColors.onSurface
                          : AppColors.onPrimaryFixed,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tap hint when empty
          if (imagePath == null && onTap != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_a_photo_outlined,
                    color: AppColors.primary, size: 28),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyPanel(String hint) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: Center(
        child: Text(
          hint,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ─── Filmstrip ──────────────────────────────────────────────────────────────

  Widget _buildFilmstrip(BuildContext context, List<ProgressPhoto> photos) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: photos.length,
        itemBuilder: (ctx, i) => _buildFilmstripThumbnail(photos[i], i),
      ),
    );
  }

  Widget _buildFilmstripThumbnail(ProgressPhoto photo, int index) {
    final isSelected = index == _referenceIndex;

    return GestureDetector(
      onTap: () => setState(() {
        _referenceIndex = index;
        _fadeController
          ..reset()
          ..forward();
      }),
      onLongPress: () => _showDeleteConfirm(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 2.5 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail image
            Image.file(
              File(photo.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.broken_image,
                    color: AppColors.onSurfaceVariant, size: 24),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Date watermark
            if (_showWatermark)
              Positioned(
                top: 6,
                left: 4,
                right: 4,
                child: Text(
                  DateFormat('dd MMM').format(photo.date),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            // Label at bottom
            Positioned(
              bottom: 6,
              left: 4,
              right: 4,
              child: Text(
                photo.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Selected check
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: AppColors.onPrimaryFixed, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirm(int index) async {
    final state = AppStateProvider.of(context);
    final photo = state.progressPhotos[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Remove Photo?',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        content: Text(
          'Remove "${photo.label}" from your timeline?',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('REMOVE',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await state.removeProgressPhoto(index);
      setState(() {
        final photos = state.progressPhotos;
        _referenceIndex = _referenceIndex.clamp(
            0, photos.isEmpty ? 0 : photos.length - 1);
      });
    }
  }

  // ─── Add photo CTA ──────────────────────────────────────────────────────────

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _addNewPhoto,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppColors.kineticGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined,
                color: AppColors.onPrimaryFixed, size: 20),
            const SizedBox(width: 12),
            Text(
              'ADD PROGRESS PHOTO',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.onPrimaryFixed,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 3,
      ),
    );
  }
}
