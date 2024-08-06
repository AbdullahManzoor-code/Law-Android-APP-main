import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law_app/Home/home_page.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF11CEC4)),
        );
      });
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // await FirebaseAuth.instance.signInWithCredential(credential);

      // Sign in the user with the credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Access the user information
      final User? user = userCredential.user;

      if (user != null) {
        // Dismiss the loading dialog if user cancelled the login
        Navigator.pop(context);

        // Store user information in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'phone': user.phoneNumber.toString(),
        });

        // Success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in successful')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) =>
              false, // This condition ensures all previous routes are removed
        );
      }
    } else {
      // Dismiss the loading dialog if user cancelled the login
      Navigator.pop(context);
      // User cancelled the login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in cancelled by user')),
      );
    }
  } catch (e) {
    Navigator.pop(context);
    // Error handling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error signing in: $e')),
    );
  }
}
