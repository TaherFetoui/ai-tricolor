import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/protocol/tricolor_protocol.dart';
import '../../providers/ble_provider.dart';

class PresetItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final int whiteRatio;
  final int brightness;
  final LightingMode mode;

  const PresetItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.whiteRatio,
    required this.brightness,
    required this.mode,
  });
}

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  static const List<PresetItem> _quickPresets = [
    PresetItem(
      title: 'Fog & Storm Breaker',
      subtitle: '3000K Pure Amber • Max penetrating beam',
      icon: Icons.cloud_rounded,
      accentColor: AppColors.amberYellow,
      whiteRatio: 0,
      brightness: 100,
      mode: LightingMode.roadWeather,
    ),
    PresetItem(
      title: 'Daytime Highway Cruise',
      subtitle: '6500K Xenon DRL • High visibility running light',
      icon: Icons.wb_sunny_rounded,
      accentColor: AppColors.accentCyan,
      whiteRatio: 100,
      brightness: 75,
      mode: LightingMode.drl,
    ),
    PresetItem(
      title: 'Off-Road Max Flood',
      subtitle: '4500K Full Blend • Maximum lumen output',
      icon: Icons.terrain_rounded,
      accentColor: AppColors.warmWhite,
      whiteRatio: 50,
      brightness: 100,
      mode: LightingMode.tricolor,
    ),
    PresetItem(
      title: 'Stealth Angel Halo',
      subtitle: 'Accent halo ring for parking & twilight',
      icon: Icons.adjust_rounded,
      accentColor: Color(0xFF7C4DFF),
      whiteRatio: 70,
      brightness: 40,
      mode: LightingMode.angelEye,
    ),
    PresetItem(
      title: 'Emergency Warning Strobe',
      subtitle: 'High frequency alert beacon flash',
      icon: Icons.warning_amber_rounded,
      accentColor: Colors.redAccent,
      whiteRatio: 50,
      brightness: 100,
      mode: LightingMode.strobe,
    ),
    PresetItem(
      title: 'Camp / Tailgate Pulse',
      subtitle: 'Warm 3500K • Subtle breathing glow',
      icon: Icons.nightlight_round,
      accentColor: Color(0xFFFFB74D),
      whiteRatio: 25,
      brightness: 30,
      mode: LightingMode.breathing,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Quick Scene Presets',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: _quickPresets.length,
        itemBuilder: (context, index) {
          final preset = _quickPresets[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  ble.setWhiteRatio(preset.whiteRatio);
                  ble.setBrightness(preset.brightness);
                  ble.setLightingMode(preset.mode);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.surface,
                      content: Row(
                        children: [
                          Icon(preset.icon, color: preset.accentColor, size: 20),
                          const SizedBox(width: 10),
                          Text('Activated "${preset.title}"', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: preset.accentColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(preset.icon, color: preset.accentColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              preset.subtitle,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_circle_fill_rounded, color: AppColors.accentCyan, size: 28),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

