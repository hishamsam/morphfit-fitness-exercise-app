import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme.dart';
import '../state_manager.dart';
import '../models/run_session.dart';
import '../widgets/kinetic_button.dart';
import 'package:gal/gal.dart';

class RunSummaryScreen extends StatefulWidget {
  final RunSession session;
  const RunSummaryScreen({super.key, required this.session});

  @override
  State<RunSummaryScreen> createState() => _RunSummaryScreenState();
}

class _RunSummaryScreenState extends State<RunSummaryScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final MapController _mapController = MapController();
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;
  bool _showWatermark = true;

  // Stat overlay toggles
  bool _showDistance = true;
  bool _showPace = true;
  bool _showTime = true;

  // Transparent PNG mode
  bool _transparentMode = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _pickedImagePath = image.path);
    }
  }

  Future<void> _shareResult() async {
    final image = await _screenshotController.capture();
    if (image == null) return;

    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/morphfit_run_${widget.session.id}.png').create();
    await imagePath.writeAsBytes(image);

    await Share.shareXFiles([XFile(imagePath.path)], text: 'My MorphFit Kinetic Path: ${widget.session.formattedDistance} KM in ${widget.session.formattedDuration}!');
  }

  Future<void> _saveToGallery() async {
    // 1. Check/Request Permissions
    bool hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      hasAccess = await Gal.requestAccess();
    }
    
    if (!hasAccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GALLERY ACCESS DENIED')),
        );
      }
      return;
    }

    // 2. Capture and Save
    final image = await _screenshotController.capture();
    if (image == null) return;

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/morphfit_save_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = await File(path).writeAsBytes(image);

    try {
      await Gal.putImage(file.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RESULT SAVED TO SYSTEM GALLERY'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      debugPrint('SAVE ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('DEVICE FAILED TO SAVE COMPOSITION')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    _showWatermark = state.watermarkEnabled;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 32),
                  _buildPreviewHeader(),
                  const SizedBox(height: 16),
                  _buildShareablePreview(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('PROTOCOL RECAP', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2)),
        centerTitle: true,
      ),
      leading: IconButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        icon: const Icon(Icons.close),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('DISTANCE', widget.session.formattedDistance, 'KM'),
          _buildStat('TIME', widget.session.formattedDuration, 'MIN'),
          _buildStat('PACE', widget.session.avgPace.split(' ').first, 'PACE'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(unit, style: GoogleFonts.spaceGrotesk(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPreviewHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SHARE PREVIEW', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.onSurfaceVariant)),
            Row(
              children: [
                Text('WATERMARK', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppColors.onSurfaceVariant)),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: _showWatermark,
                    onChanged: (v) {
                      AppStateProvider.of(context).toggleWatermark();
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Stat toggles + transparent mode
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildToggleChip('DISTANCE', _showDistance, (v) => setState(() => _showDistance = v)),
            _buildToggleChip('PACE', _showPace, (v) => setState(() => _showPace = v)),
            _buildToggleChip('TIME', _showTime, (v) => setState(() => _showTime = v)),
            _buildToggleChip('TRANSPARENT', _transparentMode, (v) => setState(() => _transparentMode = v), icon: Icons.layers_clear),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleChip(String label, bool value, ValueChanged<bool> onChanged, {IconData? icon}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: value ? AppColors.primary : AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: value ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              size: 14,
              color: value ? AppColors.primary : AppColors.onSurfaceVariant.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareablePreview() {
    final bool anyStatVisible = _showDistance || _showPace || _showTime;
    final bool hasPickedImage = _pickedImagePath != null;

    return Screenshot(
      controller: _screenshotController,
      child: AspectRatio(
        aspectRatio: 1, // Square for social
        child: Container(
          decoration: BoxDecoration(
            color: _transparentMode ? Colors.transparent : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
            border: _transparentMode ? null : Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Layer 1: Background — picked image, dark gradient, or nothing (transparent)
                if (!_transparentMode && !hasPickedImage)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF1A1B21),
                            Color(0xFF0D0E13),
                            Color(0xFF0A0B0F),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (hasPickedImage)
                  Positioned.fill(
                    child: Image.file(File(_pickedImagePath!), fit: BoxFit.cover),
                  ),

                // Layer 2: Map route overlay (only when NO picked image — FlutterMap blocks images)
                if (!hasPickedImage)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          backgroundColor: Colors.transparent,
                          initialCenter: _calculateCenter(widget.session.path),
                          initialZoom: 14,
                          onMapReady: () {
                            if (widget.session.path.isNotEmpty) {
                              final bounds = LatLngBounds.fromPoints(widget.session.path);
                              _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)));
                            }
                          },
                        ),
                        children: [
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: widget.session.path,
                                color: AppColors.primary.withOpacity(0.15),
                                strokeWidth: 16,
                              ),
                              Polyline(
                                points: widget.session.path,
                                color: AppColors.primary.withOpacity(0.3),
                                strokeWidth: 8,
                              ),
                              Polyline(
                                points: widget.session.path,
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ],
                          ),
                          if (widget.session.path.isNotEmpty)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: widget.session.path.first,
                                  width: 12,
                                  height: 12,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                                Marker(
                                  point: widget.session.path.last,
                                  width: 12,
                                  height: 12,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                // Layer 2b: Painted route overlay (when image IS picked — lightweight, no FlutterMap)
                if (hasPickedImage && widget.session.path.length > 1)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RouteOverlayPainter(
                        path: widget.session.path,
                        strokeColor: Colors.white,
                        glowColor: AppColors.primary,
                      ),
                    ),
                  ),

                // Layer 3: Stats overlay
                if (anyStatVisible)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(_transparentMode ? 0.0 : 0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: _transparentMode ? null : Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_showDistance)
                            Text('${widget.session.formattedDistance} KM', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                          if (_showDistance && (_showTime || _showPace))
                            const SizedBox(height: 2),
                          if (_showTime || _showPace)
                            Text(
                              [
                                if (_showTime) widget.session.formattedDuration,
                                if (_showPace) widget.session.avgPace,
                              ].join(' | '),
                              style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                  ),
                // Layer 4: Watermark
                if (_showWatermark)
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.fitness_center, color: AppColors.primary, size: 24),
                        Text('MORPHFIT', style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LatLng _calculateCenter(List<LatLng> path) {
    if (path.isEmpty) return const LatLng(0, 0);
    double lat = 0;
    double lng = 0;
    for (var p in path) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / path.length, lng / path.length);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KineticButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, size: 20, color: AppColors.onPrimaryFixed),
                    const SizedBox(width: 8),
                    Text('GALLERY', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: AppColors.onPrimaryFixed, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KineticButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 20, color: AppColors.onPrimaryFixed),
                    const SizedBox(width: 8),
                    Text('CAMERA', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: AppColors.onPrimaryFixed, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KineticButton(
                onPressed: _saveToGallery,
                isPrimary: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('SAVE', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: KineticButton(
                onPressed: _shareResult,
                isPrimary: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, size: 20, color: AppColors.onPrimaryFixed),
                    const SizedBox(width: 8),
                    Text('SHARE RESULTS', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: AppColors.onPrimaryFixed, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Draws the GPS route as a painted path on top of a photo background.
class _RouteOverlayPainter extends CustomPainter {
  final List<LatLng> path;
  final Color strokeColor;
  final Color glowColor;

  _RouteOverlayPainter({
    required this.path,
    required this.strokeColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    double minLat = path.first.latitude, maxLat = path.first.latitude;
    double minLng = path.first.longitude, maxLng = path.first.longitude;
    for (final p in path) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latRange = (maxLat - minLat) == 0 ? 0.001 : (maxLat - minLat);
    final lngRange = (maxLng - minLng) == 0 ? 0.001 : (maxLng - minLng);
    const padFactor = 0.15;
    minLat -= latRange * padFactor;
    maxLat += latRange * padFactor;
    minLng -= lngRange * padFactor;
    maxLng += lngRange * padFactor;

    Offset toPixel(LatLng p) {
      final x = ((p.longitude - minLng) / (maxLng - minLng)) * size.width;
      final y = ((maxLat - p.latitude) / (maxLat - minLat)) * size.height;
      return Offset(x, y);
    }

    final points = path.map(toPixel).toList();
    final pathObj = ui.Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      pathObj.lineTo(points[i].dx, points[i].dy);
    }

    // Outer glow
    canvas.drawPath(pathObj, Paint()
      ..color = glowColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Mid glow
    canvas.drawPath(pathObj, Paint()
      ..color = glowColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Main stroke
    canvas.drawPath(pathObj, Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Start dot (cyan)
    canvas.drawCircle(points.first, 6, Paint()..color = const Color(0xFF00E3FD));
    canvas.drawCircle(points.first, 6, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

    // End dot (green)
    canvas.drawCircle(points.last, 6, Paint()..color = const Color(0xFFF3FFCA));
    canvas.drawCircle(points.last, 6, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _RouteOverlayPainter oldDelegate) => oldDelegate.path != path;
}
