import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:law_app/Home/home_page.dart';
import 'package:law_app/auth/email_verification_page.dart';
import 'package:law_app/auth/login_page.dart';
import 'package:law_app/components/common/timer.dart';
import 'package:law_app/components/toaster.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return IdleTimeoutWrapper(
      child: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for the stream
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF11CEC4)));
            } else if (snapshot.hasData) {
              // User is logged in
              User? user = snapshot.data;
              if (user != null) {
                // Reload the user to get the latest data
                return FutureBuilder<void>(
                  future: user.reload(),
                  builder: (context, reloadSnapshot) {
                    if (reloadSnapshot.connectionState == ConnectionState.waiting) {
                      // Show a loading indicator while reloading
                      return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF11CEC4)));
                    } else if (reloadSnapshot.hasError) {
                      // Handle reload error
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showToast(message: "Error reloading user data.");
                      });
                      
                      return const Center(child: Text('Error reloading data.'));
                    } else {
                      // User data reloaded
                      user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        if (user!.providerData.any((provider) => provider.providerId == 'twitter.com')) {
                          // Skip email verification check for Twitter users
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showToast(message: "Login successful!");
                          });
                          return const HomePage();
                        } else {
                          if (!user!.emailVerified) {
                            // Email is not verified, redirect to verification screen
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showToast(message: "Please verify your email.");
                            });
                            return EmailVerificationPage();
                          } else {
                            // Email is verified, go to home page
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showToast(message: "Login successful!");
                            });
                            return const HomePage();
                          }
                        }
                      } else {
                        // User is null, show an error message
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showToast(message: "User data is null. Please try again.");
                        });
                        return const Center(child: Text('User data is null.'));
                      }
                    }
                  },
                );
              } else {
                // User is not logged in, show login page
                return const LoginPage(); // Make sure to create this widget
              }
            } else if (snapshot.hasError) {
              // Handle error state
              FirebaseAuthException? authException =
                  snapshot.error as FirebaseAuthException?;
              String errorMessage = "An error occurred. Please try again.";

              if (authException != null) {
                switch (authException.code) {
                  case 'network-request-failed':
                    errorMessage = "Network issue. Please check your connection.";
                    break;
                  case 'wrong-password':
                    errorMessage = "Incorrect credentials. Please try again.";
                    break;
                  case 'user-not-found':
                    errorMessage = "User not found. Please sign up.";
                    break;
                  default:
                    errorMessage = authException.message ?? errorMessage;
                }
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                showToast(message: errorMessage);
              });

              return const Center(child: Text('An error occurred.'));
            } else {
              // Fallback widget in case none of the conditions match
              return const LoginPage() ;
            }
          },
        ),
      ),
    );
  }
}
