import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';

class IFixButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final Widget? icon;
  final double? width;
  final double height;

  const IFixButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.icon,
    this.width,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.accent;

    return AnimatedScale(
      scale: onTap == null ? 0.97 : 1.0,
      duration: AppConstants.animFast,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: isOutlined
            ? OutlinedButton(
                onPressed: isLoading ? null : onTap,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: effectiveColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                ),
                child: _buildChild(effectiveColor),
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  gradient: onTap == null
                      ? null
                      : LinearGradient(
                          colors: [effectiveColor, effectiveColor.withBlue(255)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: onTap == null ? AppColors.border : null,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  boxShadow: onTap == null
                      ? null
                      : [
                          BoxShadow(
                            color: effectiveColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    ),
                  ),
                  child: _buildChild(Colors.white),
                ),
              ),
      ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: textColor,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.labelLarge.copyWith(color: textColor)),
        ],
      );
    }
    return Text(label, style: AppTextStyles.labelLarge.copyWith(color: textColor));
  }
}
