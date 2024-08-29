// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:law_app/components/toaster.dart';
// import 'package:pdf/widgets.dart';
// import 'package:twitter_login/twitter_login.dart';

//     signInWithTwitter(Context) async {
//     final twitterLogin = TwitterLogin(
//       apiKey: 'MpmkZ1RUknIHBwnTeH5sDrxCC',
//       apiSecretKey: 'IKNA3v7yKOoJyi4ryWYSfmQ6jKWsMcDFrmvwzf2KCLzBhqa4FY',
//       redirectURI: 'flutter-twitter-practice://',
//     );

//     // try {
//       final authResult = await twitterLogin.login();

//       if (authResult.status == TwitterLoginStatus.loggedIn) {
//         final twitterAuthCredential = TwitterAuthProvider.credential(
//           accessToken: authResult.authToken!,
//           secret: authResult.authTokenSecret!,
//         );

//         final userCredential = await FirebaseAuth.instance
//             .signInWithCredential(twitterAuthCredential);
//     final user =userCredential.user;
//  if (user != null) {
//         // Ensure values are not null before saving
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'name': user.displayName ?? '',
//           'email': user.email ?? '',
//           'phone': user.phoneNumber ?? '',
//           'profilepic': user.photoURL ?? '',
//         });}
//         // if (userCredential.user != null) {
        
//         //   Navigator.of(context).pushReplacement(
//         //       MaterialPageRoute(builder: (context) => const HomePage()));
//         // }
//       } else if (authResult.status == TwitterLoginStatus.cancelledByUser) {
//         showToast(message: "Twitter login cancelled by user.");
//       } else if (authResult.status == TwitterLoginStatus.error) {
//         showToast(message: "Twitter login error: ${authResult.errorMessage}");
//       }
//     // } catch (e) {
//     //   showToast(message: "Error during Twitter login: $e");
//     // }
//   }