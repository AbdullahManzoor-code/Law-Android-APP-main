import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:law_app/Home/home_page.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:law_app/auth/authProviders/fb_aurh.dart';
import 'package:law_app/auth/authProviders/githubauth.dart';

import 'package:law_app/auth/authProviders/googleAuth.dart';
import 'package:law_app/auth/authProviders/x.dart';
import 'package:law_app/auth/signup_page.dart';
import 'package:law_app/components/toaster.dart';
import 'package:twitter_login/twitter_login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> 
 {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();  


  bool loading  
 = false;
  bool _isPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form?.validate()  
 ?? false) {
      form?.save();
      return true;
    }
    return false;
  }
Future<void> loginWithEmailPassword() async {
  // Check network connectivity
  final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
  if ( connectivityResult.first == ConnectivityResult.none) {
    showToast(message: "Network error. Please check your internet connection.");
    return;
  }

  if (validateAndSave()) {
    setState(() {
      loading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified ) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        showToast(message: "Login Successful! Welcome");
      } else {
        showToast(message: 'Please verify your email to log in.');
        // Send verification email
        final actionCodeSettings = ActionCodeSettings(
          // This must be a valid Dynamic Links URL
          url: 'https://yourapp.page.link/verify?email=${Uri.encodeComponent(user!.email!)}',
          handleCodeInApp: true,
              androidPackageName: 'com.example.law_app',
              androidInstallApp: true,
    // minimumVersion
    androidMinimumVersion: '12'
        );
        try {
          await user.sendEmailVerification(actionCodeSettings);
        } catch (e) {
          showToast(message: 'Failed to send verification email.');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      switch (e.code) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
        case "account-exists-with-different-credential":
        case "email-already-in-use":
          errorMessage = "Email already used. Go to login page.";
          break;
        case "ERROR_WRONG_PASSWORD":
        case "wrong-password":
          errorMessage = "Wrong email/password combination.";
          break;
        case "ERROR_USER_NOT_FOUND":
        case "user-not-found":
          errorMessage = "No user found with this email.";
          break;
        case "ERROR_USER_DISABLED":
        case "user-disabled":
          errorMessage = "User disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
        case "operation-not-allowed":
          errorMessage = "Too many requests to log into this account.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
        case "operation-not-allowed":
          errorMessage = "Server error, please try again later.";
          break;
        case "ERROR_INVALID_EMAIL":
        case "invalid-email":
          errorMessage = "Email address is invalid.";
          break;
        default:
          errorMessage = "Email address or Password  is invalid";
      }
      showToast(message: errorMessage);
    } on SocketException {
      showToast(message: "Network error. Please check your internet connection.");
    } catch (e) {
      showToast(message: 'An unexpected error occurred. Please check credentials and try again.');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }
}
 
    signInWithTwitter() async {
    final twitterLogin = TwitterLogin(
      apiKey: 'MpmkZ1RUknIHBwnTeH5sDrxCC',
      apiSecretKey: 'IKNA3v7yKOoJyi4ryWYSfmQ6jKWsMcDFrmvwzf2KCLzBhqa4FY',
      redirectURI: 'flutter-twitter-practice://',
    );

    try {
      final authResult = await twitterLogin.login();

      if (authResult.status == TwitterLoginStatus.loggedIn) {
        final twitterAuthCredential = TwitterAuthProvider.credential(
          accessToken: authResult.authToken!,
          secret: authResult.authTokenSecret!,
        );

        final userCredential = await FirebaseAuth.instance
            .signInWithCredential(twitterAuthCredential);
    final user =userCredential.user;

          // Retrieve email from Twitter API
 if (user != null) {
          final email = await (authResult.authToken!, authResult.authTokenSecret!);
        // Ensure values are not null before saving
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'profilepic': user.photoURL ?? '',
        });}
        // if (userCredential.user != null) {
        
        //   Navigator.of(context).pushReplacement(
        //       MaterialPageRoute(builder: (context) => const HomePage()));
        // }
      return  userCredential;
      } else if (authResult.status == TwitterLoginStatus.cancelledByUser) {
        showToast(message: "Twitter login cancelled by user.");
      } else if (authResult.status == TwitterLoginStatus.error) {
        showToast(message: "Twitter login error: ${authResult.errorMessage}");
      }
    } catch (e) {
      showToast(message: "Error during Twitter login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                    child: Text(
                      'Already have an Account?',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Image.asset('assets/images/login.png',
                      height: 200, width: 200),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email field cannot be empty';
                        }
                        final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Invalid Email';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFF11CEC4),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Color(0xFF11CEC4)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password field cannot be empty';
                        }
                        if (value.length < 8) {
                          return 'Password length should be greater than 8 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  loading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF11CEC4))
                      : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              loginWithEmailPassword();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF11CEC4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 110, vertical: 15),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(_createRoute());
                  },
                  child: const Text(
                    'New User? Register Now',
                    style: TextStyle(color: Color(0xFF11CEC4)),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'use other method',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: ()async {
                         await signInWithGoogle(context);
        //                 if(user!=null){
        //                           Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomePage()),
        //   (Route<dynamic> route) => false,
        // );

        //                 }
                        },
                        child: Image.asset('assets/images/google.png',
                            height: 50, width: 50),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => const LinkedInDemoPage()),
                      //     );
                      //   },
                      //   child: Image.asset('assets/images/linkedin.png',
                      //       height: 50, width: 50),
                      // ),
                       const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: ()async  {
                          // try {
                             await   signInWithTwitter();
                            // if (context.mounted) {
                            //   Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (context) => HomePage()));
                            // }
                            // // ignore: unnecessary_null_comparison
                            // if (userCredential != null) {showToast(message: "notlogin");}
                              //  Navigator.push(
                              //     // ignore: use_build_context_synchronously
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>  LoginWithTwitter()));
                            }
                          // } catch (e) {
                          //   showToast(message: e.toString());
                          // }
                        // },
                        ,
                        child: Image.asset('assets/images/x.jpg',
                            height: 50, width: 40),
                      ),
                    ],
                  ),
                ),
                // GestureDetector(
                //         onTap: () async {
                //           try {
                //             // UserCredential userCredential =
                //             //    await signInWithTwitter();
                //             // if (context.mounted) {
                //             //   Navigator.push(
                //             //       context,
                //             //       MaterialPageRoute(
                //             //           builder: (context) => HomePage()));
                //             // }
                //             // ignore: unnecessary_null_comparison
                //             // if (userCredential != null) {
                //             //   Navigator.push(
                //             //       // ignore: use_build_context_synchronously
                //             //       context,
                //             //       MaterialPageRoute(
                //             //           builder: (context) => const HomePage()));
                //             // }
                //              Navigator.push(
                //                   // ignore: use_build_context_synchronously
                //                   context,
                //                   MaterialPageRoute(
                //                       builder: (context) =>  LoginWithFacebook()));
                //           } catch (e) {
                //             showToast(message: e.toString());
                //           }
                //         },
                //         child: Image.asset('assets/images/x.jpg',
                //             height: 50, width: 40),
                //       ),
                    
                //   const SizedBox(width: 50,)
                // ,
                // GestureDetector(
                //   onTap: () {
                //     Navigator.of(context).push(_createRoute());
                //   },
                //   child: Container(
                //     height: 100,
                //     width: 50,
                //     decoration: const BoxDecoration(
                //       color: Color(0xFF11CEC4),
                //       borderRadius: BorderRadius.only(
                //           topLeft: Radius.circular(100),
                //           bottomLeft: Radius.circular(100)),
                //     ),
                //     child: const Icon(Icons.arrow_forward,
                //         size: 40, color: Colors.white),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SignupPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
