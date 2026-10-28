import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/protocol/tricolor_protocol.dart';
import '../../providers/ble_provider.dart';
import '../widgets/arc_slider.dart';
import '../widgets/kelvin_color_bar.dart';
import '../widgets/mode_selector_chip.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();
    final activeDevice = ble.activeDevice;
    final isOn = activeDevice?.isOn ?? true;
    final brightness = activeDevice?.brightness ?? 100;
    final whiteRatio = activeDevice?.whiteRatio ?? 50;
    final currentMode = activeDevice?.mode ?? LightingMode.tricolor;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar / Top Cockpit
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cardBorder),
                            image: const DecorationImage(
                              image: AssetImage('assets/icon.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI TRICOLOR',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: ble.devices.any((d) => d.isConnected)
                                        ? AppColors.powerOn
                                        : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  ble.devices.any((d) => d.isConnected)
                                      ? '${ble.devices.where((d) => d.isConnected).length} Active Device(s)'
                                      : 'Offline / Sim Mode',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Master Power Button
                    GestureDetector(
                      onTap: () => ble.togglePower(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isOn
                              ? AppColors.powerOn.withValues(alpha: 0.2)
                              : AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isOn ? AppColors.powerOn : AppColors.cardBorder,
                            width: 2,
                          ),
                          boxShadow: isOn
                              ? [
                                  BoxShadow(
                                    color: AppColors.powerOn.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          Icons.power_settings_new_rounded,
                          color: isOn ? AppColors.powerOn : AppColors.textMuted,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Device / Multi-Sync Selector Pills
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // Sync All Pods Pill
                      _buildSelectorPill(
                        label: 'All Connected (${ble.devices.length})',
                        icon: Icons.hub_rounded,
                        isSelected: ble.syncAll,
                        onTap: () => ble.setSyncAll(true),
                      ),
                      const SizedBox(width: 8),

                      // Individual Device Pills
                      ...ble.devices.map((device) {
                        final isSel = !ble.syncAll && ble.selectedDeviceId == device.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildSelectorPill(
                            label: device.displayName,
                            icon: Icons.lightbulb_outline_rounded,
                            isSelected: isSel,
                            onTap: () => ble.selectDevice(device.id),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Main Arc Dial: Master Brightness
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: ArcSlider(
                    value: brightness / 100.0,
                    onChanged: (val) {
                      ble.setBrightness((val * 100).round());
                    },
                    label: 'Master Brightness',
                    displayValue: '$brightness%',
                    gradientColors: const [
                      AppColors.amberYellow,
                      AppColors.warmWhite,
                      AppColors.xenonWhite,
                    ],
                  ),
                ),
              ),
            ),

            // Color Temperature Slider (3000K to 6500K)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: KelvinColorBar(
                  whiteRatio: whiteRatio,
                  onChanged: (ratio) => ble.setWhiteRatio(ratio),
                ),
              ),
            ),

            // Lighting Modes & Scene Presets Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ModeSelectorGrid(
                  currentMode: currentMode,
                  onModeChanged: (mode) => ble.setLightingMode(mode),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentCyan.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accentCyan : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

