import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';

class IFixButton extends StatefulWidget {
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
  State<IFixButton> createState() => _IFixButtonState();
}

class _IFixButtonState extends State<IFixButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedScale(
        scale: (_pressed && widget.onTap != null) ? 0.96 : 1.0,
        duration: AppConstants.animFast,
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: widget.onTap == null ? 0.5 : 1.0,
          duration: AppConstants.animFast,
          child: SizedBox(
            width: widget.width ?? double.infinity,
            height: widget.height,
            child: widget.isOutlined
                ? OutlinedButton(
                    onPressed: widget.isLoading ? null : widget.onTap,
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
                      gradient: widget.onTap == null
                          ? null
                          : LinearGradient(
                              colors: [
                                effectiveColor,
                                Color.lerp(effectiveColor, Colors.blue.shade300, 0.25)!,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                      color: widget.onTap == null ? AppColors.border : null,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                      boxShadow: widget.onTap == null
                          ? null
                          : [
                              BoxShadow(
                                color: effectiveColor.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: widget.isLoading ? null : widget.onTap,
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
        ),
      ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: textColor,
        ),
      );
    }
    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.icon!,
          const SizedBox(width: 8),
          Text(widget.label, style: AppTextStyles.labelLarge.copyWith(color: textColor, fontSize: 16)),
        ],
      );
    }
    return Text(widget.label, style: AppTextStyles.labelLarge.copyWith(color: textColor, fontSize: 16));
  }
}
