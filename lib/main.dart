import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:law_app/auth/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  Stripe.publishableKey =
      'pk_test_51PkMrnCSoqn7lOOtvp6danTk6p8Ti7ED9efwk1SgYz9HSPLwfs8gzuOrWDq8ymrH4XPkjJKUz93uxFVuQQDplSm400oRTIUGup';

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'BalsamiqSans'),
      home: const AuthPage(),
    ),
  );
}
