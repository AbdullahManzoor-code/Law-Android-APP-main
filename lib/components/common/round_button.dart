import 'package:flutter/material.dart';

enum RoundButtonType { bgPrimary, textPrimary }

class TColor {
  static Color get primary => const Color(0xFF11CEC4);
  static Color get primaryText => const Color(0xff4A4B4D);
  static Color get secondaryText => const Color(0xff7C7D7E);
  static Color get textfield => const Color(0xffF2F2F2);
  static Color get placeholder => const Color(0xffB6B7B7);
  static Color get white => const Color(0xffffffff);
}

class RoundButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final RoundButtonType type;
  final double fontSize;
  const RoundButton(
      {super.key,
      required this.title,
      required this.onPressed,
      this.fontSize = 16,
      this.type = RoundButtonType.bgPrimary});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: type == RoundButtonType.bgPrimary
              ? null
              : Border.all(color: TColor.primary, width: 1),
          color:
              type == RoundButtonType.bgPrimary ? TColor.primary : TColor.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          title,
          style: TextStyle(
              color: type == RoundButtonType.bgPrimary
                  ? TColor.white
                  : TColor.primary,
              fontSize: fontSize,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
