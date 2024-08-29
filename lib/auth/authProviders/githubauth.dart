// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:twitter_login/twitter_login.dart';


//    signInWithTwitter() async {

//     // Create a TwitterLogin instance
//     final twitterLogin = TwitterLogin(
//         apiKey: 'CP1ck9xhkSPRI3fpZbssh20Ay',
//         apiSecretKey: 'ExovdLXEkaDktrjuUEnXl0tzBZNBe30oz4qJhpBVlMVwdpJ3KA',
//         redirectURI: 'flutter-twitter-practice://'
//     );

//     // Trigger the sign-in flow
//     await twitterLogin.login().then((value) async {

//       final twitterAuthCredential = TwitterAuthProvider.credential(
//         accessToken: value.authToken!,
//         secret: value.authTokenSecret!,
//       );

//      return await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);

//     });

//   }