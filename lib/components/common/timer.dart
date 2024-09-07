import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:law_app/auth/login_page.dart';

class IdleTimeoutWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const IdleTimeoutWrapper({
    Key? key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 10),
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

  Future<void> _signOutUser() async {
    await FirebaseAuth.instance.signOut();

    // Navigate to the login screen
    // if (context.mounted) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (context) => LoginPage()),
    //   );
    // }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
