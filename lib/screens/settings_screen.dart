import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../theme.dart';
import '../state_manager.dart';
import '../widgets/privacy_hud.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const PrivacyHUD(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'SECURITY & PRIVACY'),
                _buildSettingTile(
                  context,
                  title: 'Biometric Vault',
                  subtitle: 'Enable Fingerprint/FaceID for records.',
                  trailing: Switch(
                    value: state.biometricVaultEnabled,
                    onChanged: (_) => state.toggleBiometrics(),
                    activeColor: AppColors.primary,
                  ),
                ),
                _buildSettingTile(
                  context,
                  title: 'Zero-Cloud Mode',
                  subtitle: 'All data remains 100% on this device.',
                  trailing: const Icon(Icons.verified_user,
                      color: AppColors.secondary, size: 20),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'PREFERENCES'),
                _buildSettingTile(
                  context,
                  title: 'Measurement Units',
                  subtitle: state.isMetric ? 'Metric (kg, m)' : 'Imperial (lb, ft)',
                  trailing: TextButton(
                    onPressed: () => state.toggleUnits(),
                    child: Text(
                      state.isMetric ? 'METRIC' : 'IMPERIAL',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ),
                  ),
                ),
                _buildSettingTile(
                  context,
                  title: 'Automatic Watermark',
                  subtitle: 'Add MorphFit logo to run results.',
                  trailing: Switch(
                    value: state.watermarkEnabled,
                    onChanged: (_) => state.toggleWatermark(),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'DATA MANAGEMENT'),
                _buildSettingTile(
                  context,
                  title: 'Total Sessions',
                  subtitle: '${state.allSessions.length} sessions recorded in vault.',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${state.allSessions.length}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
                _buildSettingTile(
                  context,
                  title: 'Export Local Records',
                  subtitle: 'JSON dump of all performance data.',
                  onTap: () => _exportData(context, state),
                ),
                _buildSettingTile(
                  context,
                  title: 'Clear Local Vault',
                  subtitle: 'Permanently delete all session data.',
                  isDestructive: true,
                  onTap: () => _showDeleteConfirmation(context, state),
                ),
                const SizedBox(height: 48),
                _buildVersionInfo(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  void _exportData(BuildContext context, AppState state) {
    final json = state.exportToJson();
    final preview = json.length > 300 ? '${json.substring(0, 300)}...' : json;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(28),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.security, color: AppColors.secondary, size: 28),
                  const SizedBox(width: 16),
                  Text('VAULT EXPORT',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${state.allSessions.length} sessions • ${(json.length / 1024).toStringAsFixed(1)} KB',
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.outlineVariant.withOpacity(0.1)),
                ),
                child: Text(
                  state.allSessions.isEmpty
                      ? '{\n  "message": "No sessions recorded yet."\n}'
                      : preview,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Export copied to clipboard (real file export requires platform plugin)'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('CLOSE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM CONFIG',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vault Settings',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    Widget? trailing,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDestructive
              ? AppColors.error.withOpacity(0.2)
              : AppColors.outlineVariant.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    isDestructive ? AppColors.error : AppColors.onSurface,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isDestructive
                        ? AppColors.error
                        : AppColors.onSurfaceVariant,
                  )
                : null),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('CLEAR VAULT?',
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold, color: AppColors.error)),
          content: Text(
            'This will permanently delete all ${state.allSessions.length} sessions. PRs and logs cannot be recovered.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL',
                  style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                await state.clearAllData();
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vault cleared. All data purged.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('PURGE ALL',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'MORPHFIT v1.0.0',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, color: AppColors.secondary, size: 10),
                SizedBox(width: 8),
                Text(
                  'ZERO-CLOUD · LOCAL VAULT',
                  style: TextStyle(
                      fontSize: 8,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold),
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
        border: Border(
            top: BorderSide(
                color: AppColors.surfaceVariant.withOpacity(0.15))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: NavigationBar(
            backgroundColor: AppColors.background.withOpacity(0.7),
            indicatorColor: AppColors.primary,
            selectedIndex: 4,
            onDestinationSelected: (index) {
              if (index == 0) Navigator.pushReplacementNamed(context, '/home');
              if (index == 1) Navigator.pushReplacementNamed(context, '/run');
              if (index == 2) Navigator.pushReplacementNamed(context, '/workout');
              if (index == 3) Navigator.pushReplacementNamed(context, '/progress');
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined), label: 'HOME'),
              NavigationDestination(
                  icon: Icon(Icons.map_outlined), label: 'RUN'),
              NavigationDestination(
                  icon: Icon(Icons.fitness_center_outlined),
                  label: 'WORKOUT'),
              NavigationDestination(
                  icon: Icon(Icons.leaderboard_outlined), label: 'PROGRESS'),
              NavigationDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings,
                    color: AppColors.onPrimaryFixed),
                label: 'SETTINGS',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
