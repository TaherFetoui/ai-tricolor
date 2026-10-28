import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class KelvinColorBar extends StatelessWidget {
  final int whiteRatio; // 0 to 100
  final ValueChanged<int> onChanged;

  const KelvinColorBar({
    super.key,
    required this.whiteRatio,
    required this.onChanged,
  });

  int get kelvinValue => (3000 + (whiteRatio * 35)).round(); // 3000K to 6500K

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'COLOR TEMPERATURE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  '$kelvinValue K',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Gradient slider bar
          Container(
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  AppColors.amberYellow, // 3000K Pure Amber
                  AppColors.warmWhite,   // 4500K Blend
                  AppColors.xenonWhite,  // 6500K Xenon White
                ],
              ),
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 24,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 14,
                  elevation: 4,
                ),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: whiteRatio.toDouble(),
                min: 0,
                max: 100,
                onChanged: (val) => onChanged(val.round()),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Quick Preset Buttons
          Row(
            children: [
              _buildPresetPill(
                label: '3000K Amber',
                subtitle: 'Fog / Rain',
                color: AppColors.amberYellow,
                isSelected: whiteRatio <= 10,
                onTap: () => onChanged(0),
              ),
              const SizedBox(width: 8),
              _buildPresetPill(
                label: '4500K Blend',
                subtitle: 'Tricolor Mix',
                color: AppColors.warmWhite,
                isSelected: whiteRatio > 35 && whiteRatio < 65,
                onTap: () => onChanged(50),
              ),
              const SizedBox(width: 8),
              _buildPresetPill(
                label: '6500K White',
                subtitle: 'Clear Road',
                color: AppColors.xenonWhite,
                isSelected: whiteRatio >= 90,
                onTap: () => onChanged(100),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetPill({
    required String label,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

