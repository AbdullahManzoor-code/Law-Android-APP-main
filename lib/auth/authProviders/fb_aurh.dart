// sceret  86834313efb367724dfa3fcdfbfc78be 
// id 1187694882560501
//token 1187694882560501
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';

  String userEmail = "";
class LoginWithFacebook extends StatefulWidget {
  const LoginWithFacebook({Key? key}) : super(key: key);

  @override
  _LoginWithFacebookState createState() => _LoginWithFacebookState();
}

class _LoginWithFacebookState extends State<LoginWithFacebook> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login With Facebook"),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () async {
              await signInWithFb();

              setState(() {});
            }, child: const Text("Login with facebook")),

            ElevatedButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              userEmail = "";
              await FacebookAuth.instance.logOut();
              setState(() {

              });
            }, child: const Text("Logout"))
          ],
        ),
      ),
    );
  }


  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    log(loginResult.accessToken!.tokenString.toString());
    log(loginResult.message.toString());

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    // Once signed in, return the UserCredential
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);
    log(userCredential.additionalUserInfo!.username.toString());
    log(userCredential.user!.email.toString());
    log(userCredential.user!.photoURL.toString());
    return userCredential;
  }
  Future<UserCredential> signInWithFb() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile', 'user_birthday']
    );

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    final userData = await FacebookAuth.instance.getUserData();

    userEmail = userData['email'];

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }
  
}