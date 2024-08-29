import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IdleTimeoutWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const IdleTimeoutWrapper({
    Key? key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 30),
  }) : super(key: key);

  @override
  _IdleTimeoutWrapperState createState() => _IdleTimeoutWrapperState();
}

class _IdleTimeoutWrapperState extends State<IdleTimeoutWrapper> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(),
      onScaleStart: (_) => _resetTimer(),
      child: widget.child,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeoutDuration, _signOutUser);
  }

  void _resetTimer() {
    _startTimer();
  }

  void _signOutUser() async {
    // Perform sign-out operation (e.g., using Firebase Auth)
    await FirebaseAuth.instance.signOut();

    // Optionally navigate the user to the login screen
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (context) => LoginScreen()),
    // );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
