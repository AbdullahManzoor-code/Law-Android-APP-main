import 'package:flutter/material.dart';
import 'package:law_app/auth/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:law_app/components/common/timer.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(
      child: IdleTimeoutWrapper(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'BalsamiqSans'),
          home: const AuthPage(),
        ),
      ),
    ),
  );
}
