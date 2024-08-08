import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({
  required String message,
  ToastGravity position = ToastGravity.BOTTOM,
  Toast length = Toast.LENGTH_SHORT,
  Color backgroundColor = const Color.fromARGB(255, 54, 160, 160),
  Color textColor = Colors.white,
  double fontSize = 16.0,
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: length,
    gravity: position,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: fontSize,
  );
}


// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// void showToast({
//   required String message,
//   ToastGravity position = ToastGravity.BOTTOM,
//   Toast length = Toast.LENGTH_SHORT,
//   Color backgroundColor = const Color.fromARGB(255, 54, 160, 160),
//   Color textColor = Colors.white,
//   double fontSize = 16.0,
//   TextAlign textAlign = TextAlign.center,
//   double borderRadius = 8.0,
//   EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//   double? elevation,
//   int? timeInSeconds,
// }) {
//   Fluttertoast.showToast(
//     msg: message,
//     toastLength: length,
//     gravity: position,
//     backgroundColor: backgroundColor,
//     textColor: textColor,
//     fontSize: fontSize,
//     webBgColor: backgroundColor.value.toRadixString(16), // For web support
//     webPosition: position == ToastGravity.BOTTOM ? 'bottom' : 'top', // For web support
//     timeInSeconds: timeInSeconds,
//     webShowClose: true,
//   );

//   // If you need more control over the appearance or want to use `elevation`, 
//   // you would need to implement a custom toast or use a different package.
// }

