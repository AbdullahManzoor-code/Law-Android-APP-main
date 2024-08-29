// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law_app/components/toaster.dart';

 signInWithGoogle(BuildContext context) async {
  // Optionally, show a loading indicator
  // showDialog(
  //   context: context,
  //   builder: (context) {
  //     return const Center(
  //       child: CircularProgressIndicator(color: Color(0xFF11CEC4)),
  //     );
  //   },
  // );

  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Ensure values are not null before saving
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'profilepic': user.photoURL ?? '',
        });

        // Optionally, show a success message
        showToast(message: "Login successful!");

        // Navigate to the home page
       
        return user;
      } else {
        showToast(message: "User is null after sign-in");
      }
    } else {
      showToast(message: "User Cancel the login");
    }
  } catch (e) {
    showToast(message: "An error occurred: $e");
  }
}
