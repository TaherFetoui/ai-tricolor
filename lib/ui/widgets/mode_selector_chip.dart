import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/protocol/tricolor_protocol.dart';

class ModeSelectorGrid extends StatelessWidget {
  final LightingMode currentMode;
  final ValueChanged<LightingMode> onModeChanged;

  const ModeSelectorGrid({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  IconData _getModeIcon(LightingMode mode) {
    switch (mode) {
      case LightingMode.tricolor:
        return Icons.auto_awesome;
      case LightingMode.drl:
        return Icons.wb_sunny_rounded;
      case LightingMode.angelEye:
        return Icons.adjust_rounded;
      case LightingMode.roadWeather:
        return Icons.cloud_rounded;
      case LightingMode.strobe:
        return Icons.flash_on_rounded;
      case LightingMode.breathing:
        return Icons.waves_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LIGHTING SCENES & MODES',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: LightingMode.values.length,
          itemBuilder: (context, index) {
            final mode = LightingMode.values[index];
            final isSelected = mode == currentMode;

            return GestureDetector(
              onTap: () => onModeChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentCyan.withValues(alpha: 0.15)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.accentCyan : AppColors.cardBorder,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentCyan.withValues(alpha: 0.2)
                            : AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getModeIcon(mode),
                        size: 18,
                        color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          Text(
                            mode.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

