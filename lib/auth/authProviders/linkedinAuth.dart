import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:linkedin_login/linkedin_login.dart';

class LinkedInDemoPage extends StatefulWidget {
  const LinkedInDemoPage({super.key});

  @override
  _LinkedInDemoPageState createState() => _LinkedInDemoPageState();
}

class _LinkedInDemoPageState extends State<LinkedInDemoPage> {
  UserObject? user;
  bool logoutUser = false;

  final String clientId = '77xwf0huvckgl2';
  final String clientSecret = 'xitXnlQ6v0jOmOXE';
  final String redirectUri =
      'https://www.linkedin.com/developers/tools/oauth/redirect';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkedIn Authorization'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LinkedInButtonStandardWidget(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => LinkedInUserWidget(
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        title: const Text('OAuth User'),
                        centerTitle: true,
                      ),
                      destroySession: logoutUser,
                      redirectUrl: redirectUri,
                      clientId: clientId,
                      clientSecret: clientSecret,
                      onError: (UserFailedAction e) {
                        print('Error: ${e.toString()}');
                        print('Error: ${e.stackTrace.toString()}');
                        DelightToastBar(
                          builder: (context) => ToastCard(
                            leading: const Icon(
                              Icons.error,
                              size: 28,
                            ),
                            title: Text(
                              "Failed to login: ${e.toString()}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ).show(context);
                      },
                      onGetUserProfile: (UserSucceededAction linkedInUser) {
                        print('Access token: ${linkedInUser.user.token}');
                        print('First name: ${linkedInUser.user.name}');
                        print('Last name: ${linkedInUser.user.familyName}');

                        setState(() {
                          user = UserObject(
                            firstName: linkedInUser.user.name.toString(),
                            lastName: linkedInUser.user.name.toString(),
                            email: linkedInUser.user.email.toString(),
                            profileImageUrl:
                                linkedInUser.user.picture.toString(),
                          );
                          logoutUser = false;
                        });

                        DelightToastBar(
                          builder: (context) => const ToastCard(
                            leading: Icon(
                              Icons.check_circle,
                              size: 28,
                            ),
                            title: Text(
                              "Login Successful!",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ).show(context);

                        Navigator.pop(context);
                      },
                    ),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            LinkedInButtonStandardWidget(
              onTap: () {
                setState(() {
                  user = null;
                  logoutUser = true;
                });
                DelightToastBar(
                  builder: (context) => const ToastCard(
                    leading: Icon(
                      Icons.logout,
                      size: 28,
                    ),
                    title: Text(
                      "Successfully Logged Out",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ).show(context);
              },
              buttonText: 'Logout',
            ),
            const SizedBox(height: 20),
            if (user != null)
              Column(
                children: <Widget>[
                  Text('First Name: ${user?.firstName}'),
                  Text('Last Name: ${user?.lastName}'),
                  Text('Email: ${user?.email}'),
                  Text('Profile Image: ${user?.profileImageUrl}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class UserObject {
  UserObject({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileImageUrl,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImageUrl;
}
