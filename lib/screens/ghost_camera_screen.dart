import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';

class GhostCameraScreen extends StatefulWidget {
  const GhostCameraScreen({super.key});

  @override
  State<GhostCameraScreen> createState() => _GhostCameraScreenState();
}

class _GhostCameraScreenState extends State<GhostCameraScreen> {
  double _opacity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Stack(
              children: [
                // Live Camera Feed Simulation
                _buildCameraFeed(),
                
                // Mirror Tech Overlay (Ghost Frame)
                _buildGhostOverlay(),
                
                // Viewfinder Grid Lines
                _buildViewfinderGrid(),
                
                // Corner Accents
                _buildCornerAccents(),
                
                // Tech Overlay HUD
                _buildHUDControls(context),
                
                // Opacity Slider
                _buildOpacitySlider(context),
                
                // Bottom cluster
                _buildBottomControls(context),
              ],
            ),
          ),
          // Footer separation
          Container(height: 1, color: AppColors.surfaceContainerLow),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.primary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'MORPHFIT',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CameraPulseIndicator(),
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
              const SizedBox(width: 8),
              const Icon(Icons.security, color: AppColors.primary, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraFeed() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.6,
        child: CachedNetworkImage(
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBSUr97jif9Ytc29rzR-OcbIKaXWXj_KLCXIe05aTXoO62T3GAyOQZjiqjXdCP6xV07zPg0H5ljkgUaSX1pvejr1G5e7e_83tvCgunR-BqWT9dOn6BR4ozuLLGirQY4Jg0ZejdTHxi37onQCGLO2uDC0L_lgoAt8yidLD8Yn4hQb1hywokr-_Kk_kI5PpjqqJfpgddb8R0VsSeX3vIiTDfNIzAin6Zp00eCQiyFBOGqh3xEmmW4J4EFSsOtWNZNWrw3DDfcuW3NW-FD',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildGhostOverlay() {
    return Positioned.fill(
      child: Center(
        child: Opacity(
          opacity: _opacity * 0.4,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: CachedNetworkImage(
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDHbVdtmVgRi3MuT7gdCeP-1uaP689Uy6A39vtd-Vavo4IIk9QEZieGkDuGKyONkKNFYn9WlSPV4xvjvSX9HyUWJdE5tJZOpn_bI8f_Tm-b5Kiw6NaKuuve0JWcypiyYDbKwMrQGBvUuKG0G2i2ASFfmiqipaE-znhlG-44iaDQkfysuPGm6BYQ19pVl_A-ZpF9HhcApm5wlXGqCNbwem8-ZzxKdNdp8A7NLirwf7fufmJ6cfRmYCwm7cRNR_51Ig40MODOMxLBWOLc',
              fit: BoxFit.contain,
              colorBlendMode: BlendMode.screen,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewfinderGrid() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ViewfinderGridPainter(),
      ),
    );
  }

  Widget _buildCornerAccents() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.primary, width: 2),
                    left: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.primary, width: 2),
                    right: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.primary, width: 2),
                    left: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.primary, width: 2),
                    right: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUDControls(BuildContext context) {
    return Positioned(
      top: 24,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildHUDButton(Icons.flash_on),
              const SizedBox(height: 16),
              _buildHUDButton(Icons.flip_camera_ios),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'REF POSITION',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary.withOpacity(0.6),
                        fontSize: 8,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'LATERAL RAISE',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.66,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUDButton(IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Icon(icon, color: AppColors.primary, size: 30),
    );
  }

  Widget _buildOpacitySlider(BuildContext context) {
    return Positioned(
      right: 24,
      top: 0,
      bottom: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 256,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    top: 48,
                    left: -40,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'MIRROR OPACITY',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                height: constraints.maxHeight * _opacity,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              Positioned(
                                bottom: constraints.maxHeight * _opacity - 16,
                                child: GestureDetector(
                                  onVerticalDragUpdate: (details) {
                                    setState(() {
                                      _opacity = (_opacity - details.delta.dy / constraints.maxHeight).clamp(0.0, 1.0);
                                    });
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                      border: Border.all(color: AppColors.surface, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.4),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.drag_handle, size: 12, color: AppColors.onPrimaryFixed),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${(_opacity * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_library, color: AppColors.onSurfaceVariant, size: 14),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                    children: const [
                      TextSpan(text: 'Photos are saved to '),
                      TextSpan(text: 'local gallery only', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircularButton(Icons.timer),
              const SizedBox(width: 48),
              _buildShutterButton(),
              const SizedBox(width: 48),
              _buildCircularButton(Icons.visibility, isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, {bool isPrimary = false}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainerLow,
        border: isPrimary ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
      ),
      child: Icon(icon, color: isPrimary ? AppColors.primary : AppColors.onSurfaceVariant, size: 30),
    );
  }

  Widget _buildShutterButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 3),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
          ),
        ),
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.kineticGradient,
            boxShadow: [
              BoxShadow(color: AppColors.primary, blurRadius: 30, spreadRadius: -10),
            ],
          ),
        ),
      ],
    );
  }
}

class ViewfinderGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..strokeWidth = 1;

    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * i / 3, 0),
        Offset(size.width * i / 3, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 3),
        Offset(size.width, size.height * i / 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CameraPulseIndicator extends StatefulWidget {
  const CameraPulseIndicator({super.key});

  @override
  State<CameraPulseIndicator> createState() => _CameraPulseIndicatorState();
}

class _CameraPulseIndicatorState extends State<CameraPulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(_controller.value),
                blurRadius: 8,
              ),
            ],
          ),
        );
      },
    );
  }
}
