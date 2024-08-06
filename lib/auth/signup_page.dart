import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:law_app/auth/authProviders/googleAuth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool loading = false;
  bool _isPasswordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form?.validate() ?? false) {
      form?.save();
      return true;
    }
    return false;
  }

  Future<void> signUpWithEmailPassword() async {
    setState(() {
      loading = true;
    });
    if (validateAndSave()) {
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // After successful signup, save the user's name and phone to Firestore
        final user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': _nameController.text,
            'phone': _phoneController.text,
          });

          // Send email verification
          await user.sendEmailVerification();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Signup Successful! A verification email has been sent to ${user.email}. Please verify your email to continue.')),
          );

          // Navigate back to login screen
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred. Please try again.';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An unexpected error occurred. Please try again.'),
              backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11CEC4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // text + image
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //text
                  const Flexible(
                    child: Text(
                      "Here's your first step with us!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  // image

                  Image.asset('assets/images/signup.png',
                      height: 200, width: 200),
                ],
              ),
            ),

            // input fileds container

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF11CEC4))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF11CEC4))),
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
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
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF11CEC4))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF11CEC4))),
                          labelText: 'Phone',
                          labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF11CEC4),
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF11CEC4),
                            ),
                          ),
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
                      height: 5,
                    ),
                    loading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF11CEC4))
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                signUpWithEmailPassword();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF11CEC4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 110, vertical: 15),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),

            // other options

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
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'use other method',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 100,
                    width: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100)),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF11CEC4),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          signInWithGoogle(context);
                        },
                        child: Image.asset('assets/images/google.png',
                            height: 50, width: 50),
                      ),
                      // const SizedBox(
                      //   width: 20,
                      // ),
                      // Image.asset(
                      //   'assets/images/linkedin.png',
                      //   height: 50,
                      //   width: 50,
                      // ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
