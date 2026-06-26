import 'package:flutter/material.dart';

extension NavigationExtensions on BuildContext {
  Future<dynamic>? push(Widget screen) =>
      Navigator.push(this, MaterialPageRoute(builder: (_) => screen));

  Future<dynamic> pushReplacement(Widget screen) => Navigator.of(
    this,
  ).pushReplacement(MaterialPageRoute(builder: (_) => screen));

  Future<dynamic> pushAndRemoveUntil(Widget screen, RoutePredicate predicate) =>
      Navigator.of(this).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => screen),
        predicate,
      );

  void pop({dynamic result}) => Navigator.of(this).pop(result);

  void popUntil({dynamic result}) =>
      Navigator.of(this).popUntil((route) => route.isFirst);
}

extension StringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

abstract class SnackbarType {
  IconData get icon;

  Color get backgroundColor;

  Color get textColor => Colors.white;
}

class Error extends SnackbarType {
  @override
  IconData get icon => Icons.error;

  @override
  Color get backgroundColor => Colors.red;
}

class Success extends SnackbarType {
  @override
  IconData get icon => Icons.verified;

  @override
  Color get backgroundColor => Colors.green;
}

class Warning extends SnackbarType {
  @override
  IconData get icon => Icons.warning;

  @override
  Color get backgroundColor => Colors.yellow;
}

enum SnackPosition { top, center, bottom }

extension SnackbarExtensions on BuildContext {
  void showOverlaySnackBar({
    required String message,
    required SnackbarType type,
    String? subTitle,
    Widget? action,
    SnackPosition position = SnackPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    double verticalPadding = 16,
    double horizontalPadding = 20,
    VoidCallback? afterClose,
  }) {
    final overlay = Overlay.of(this);

    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: Navigator.of(this),
    );

    final fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        double? top;
        double? bottom;

        switch (position) {
          case SnackPosition.top:
            top = MediaQuery.of(context).padding.top + 20;
            break;
          case SnackPosition.center:
            top = MediaQuery.of(context).size.height / 2 - 40;
            break;
          case SnackPosition.bottom:
            bottom = MediaQuery.of(context).padding.bottom + 20;
            break;
        }

        return PositionedDirectional(
          top: top,
          bottom: bottom,
          start: 20,
          end: 20,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: horizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: type.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type.icon, color: type.textColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: type.textColor),
                          ),
                          if (subTitle != null)
                            Text(
                              subTitle,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: type.textColor.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontSize: 12,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    ?action,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
    animationController.forward();

    Future.delayed(duration, () async {
      await animationController.reverse();
      overlayEntry.remove();
      animationController.dispose();
      if (afterClose != null) afterClose();
    });
  }
}

extension SmartNumberFormat on String {
  String toTwoDecimals({String decimalSeparator = '.'}) {
    String value = trim();

    if (value.isEmpty) return '0${decimalSeparator}00';

    if (value.contains(',') && value.contains('.')) {
      if (value.lastIndexOf(',') > value.lastIndexOf('.')) {
        value = value.replaceAll('.', '').replaceAll(',', '.');
      } else {
        value = value.replaceAll(',', '');
      }
    } else if (value.contains(',')) {
      value = value.replaceAll(',', '.');
    }

    final number = double.tryParse(value) ?? 0.0;

    return number.toStringAsFixed(2).replaceAll('.', decimalSeparator);
  }
}

extension StringError on String {
  bool isLoginError() {
    const targetSentences = [
      "You must login",
      "يجب تسجيل الدخول",
      "İstek göndermeden önce",
    ];
    return targetSentences.any((phrase) => contains(phrase));
  }
}

extension StringNumberFormatting on String {
  String removeTrailingZeros() {
    if (!contains('.')) {
      return this;
    }

    String result = replaceAll(RegExp(r'0*$'), '');

    if (result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }

    return result;
  }
}
