import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme.dart';
import '../state_manager.dart';
import '../models/run_session.dart';

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _path = [];
  bool _isTracking = false;
  final ValueNotifier<double> _distanceNotifier = ValueNotifier(0.0); // meters
  final ValueNotifier<Duration> _durationNotifier = ValueNotifier(Duration.zero);
  Timer? _timer;
  StreamSubscription<Position>? _positionStream;
  LatLng? _currentLocation;
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services.')),
        );
      }
      setState(() => _isLocating = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLocating = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLocating = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final point = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _currentLocation = point;
          _isLocating = false;
        });
        // Ensure map is rendered before moving
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(point, 16);
        });
      }
    } catch (e) {
      debugPrint('Error getting initial location: $e');
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  void dispose() {
    _stopTracking(save: false);
    super.dispose();
  }

  Future<void> _startTracking() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return;

    setState(() {
      _isTracking = true;
      _path.clear();
      _distanceNotifier.value = 0.0;
      _durationNotifier.value = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _durationNotifier.value += const Duration(seconds: 1);
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final newPoint = LatLng(position.latitude, position.longitude);
      setState(() {
        if (_path.isNotEmpty) {
          _distanceNotifier.value += Geolocator.distanceBetween(
            _path.last.latitude,
            _path.last.longitude,
            newPoint.latitude,
            newPoint.longitude,
          );
        }
        _path.add(newPoint);
        _currentLocation = newPoint;
      });
      _mapController.move(newPoint, 16);
    });
  }

  void _stopTracking({bool save = true}) async {
    _timer?.cancel();
    _positionStream?.cancel();
    
    if (save && _path.length > 1) {
      final state = AppStateProvider.of(context);
      final session = RunSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        duration: _durationNotifier.value,
        distance: _distanceNotifier.value,
        avgPace: _calculatePace(),
        path: List.from(_path),
      );
      await state.saveRunSession(session);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/run_summary', arguments: session);
      }
    } else {
      setState(() => _isTracking = false);
    }
  }

  String _calculatePace() {
    if (_distanceNotifier.value < 10) return "0:00";
    final km = _distanceNotifier.value / 1000;
    final paceDecimal = _durationNotifier.value.inMinutes / km;
    final minutes = paceDecimal.floor();
    final seconds = ((paceDecimal - minutes) * 60).round();
    return "$minutes:${seconds.toString().padLeft(2, '0')} min/km";
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RepaintBoundary(
            child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: 2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _path,
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ],
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: AppColors.secondary.withOpacity(0.5), blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          ),
          // Top Hud
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: Listenable.merge([_durationNotifier, _distanceNotifier]),
                builder: (context, _) => Row(
                  children: [
                    Expanded(child: _buildHudItem('DISTANCE', '${(_distanceNotifier.value / 1000).toStringAsFixed(2)} KM')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildHudItem('PACE', _calculatePace())),
                    const SizedBox(width: 8),
                    Expanded(child: _buildHudItem('TIME', _formatDuration(_durationNotifier.value))),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Controls — respects system nav bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                left: 32,
                right: 32,
                bottom: 32 + bottomPadding,
              ),
              child: _isTracking ? _buildStopButton() : _buildStartButton(),
            ),
          ),
          // Back Button — respects status bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  padding: const EdgeInsets.only(left: 8),
                ),
              ),
            ),
          ),
          // My Location Button — respects system nav bar
          if (!_isTracking)
            Positioned(
              right: 16,
              bottom: 140 + bottomPadding,
              child: FloatingActionButton.small(
                onPressed: () {
                  if (_currentLocation != null) {
                    _mapController.move(_currentLocation!, 16);
                  } else {
                    _initLocation();
                  }
                },
                backgroundColor: AppColors.surfaceContainerHigh.withOpacity(0.9),
                foregroundColor: AppColors.primary,
                child: const Icon(Icons.my_location),
              ),
            ),
          // Calibrating Overlay
          if (_isLocating)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 24),
                    Text('CALIBRATING GPS...',
                        style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHudItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 9, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    final size = MediaQuery.of(context).size.width * 0.21;
    final buttonSize = size.clamp(64.0, 96.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _startTracking,
        borderRadius: BorderRadius.circular(100),
        child: Ink(
          height: buttonSize,
          width: buttonSize,
          decoration: BoxDecoration(
            gradient: AppColors.kineticGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Icon(Icons.play_arrow_rounded,
              color: AppColors.onPrimaryFixed, size: buttonSize * 0.55),
        ),
      ),
    );
  }

  Widget _buildStopButton() {
    return GestureDetector(
      onLongPress: _stopTracking,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [BoxShadow(color: AppColors.error.withOpacity(0.3), blurRadius: 15)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stop, color: Colors.white),
            const SizedBox(width: 12),
            Text('HOLD TO STOP', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }
}
