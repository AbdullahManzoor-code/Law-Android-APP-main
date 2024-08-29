import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:law_app/Orders/user_orders_page.dart';
import 'package:law_app/auth/auth_page.dart';
import 'package:law_app/components/common/round_button.dart';
import 'package:law_app/components/common/round_textfield.dart';
import 'package:law_app/components/common/timer.dart';
import 'package:law_app/components/toaster.dart';
import '../components/common/uploadtask.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker picker = ImagePicker();
  File? image;
  final user = FirebaseAuth.instance.currentUser;

  // Form Key
  final _formKey = GlobalKey<FormState>();

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  bool loading = false;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> saveProfile() async {
  if (_formKey.currentState?.validate() ?? false) {
    if (txtName.text.isEmpty) {
      showToast(message: "Name cannot be empty.");
      return;
    }

    if (txtMobile.text.isEmpty) {
      showToast(message: "Mobile number cannot be empty.");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      if (user != null) {
        final userId = user!.uid;

        // Update display name
        if (txtName.text.isNotEmpty) {
          await user!.updateDisplayName(txtName.text.trim());
        }

        // Update Firestore database
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'name': txtName.text.trim(),
          'phone': txtMobile.text.trim(),
          'email': txtEmail.text.trim(),
        });

        if (image != null) {
          final downloadUrl = await storeToFirebase(image!, "image/profilepic/$userId");
          await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'profilepic': downloadUrl,
          });
        }

        showToast(message: "Profile Updated Successfully");
      }
    } catch (e) {
      showToast(message: "Failed to Update Profile: $e");
    } finally {
      setState(() {
        loading = false;
        
      });
    }
  } else {
    showToast(message: "Please correct the errors in the form.");
  }
}


  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  Future<void> getProfileData() async {
    if (user != null) {
      final userId = user!.uid;
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if (doc.exists) {
          setState(() {
            txtName.text = doc['name'] ?? '';
            txtEmail.text = doc['email'] ?? '';
            txtMobile.text = doc['phone'] ?? '';
          });
        } else {
          showToast(message: "No Profile Data Found");
        }
      } catch (e) {
        showToast(message: "Failed to Fetch Profile Data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IdleTimeoutWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AuthPage()));
                      },
                      icon: const Icon(
                        Icons.logout,
                        size: 20,
                      ),
                      label: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: image == null && user?.photoURL != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            user!.photoURL!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(
                                File(image!.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 65,
                              color: Colors.grey,
                            ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    pickImage();
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 12,
                  ),
                  label: const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const Text(
                  "Hi there!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: RoundTitleTextfield(
                    title: "Name",
                    hintText: user?.displayName ?? "Enter Name",
                    controller: txtName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: RoundTitleTextfield(
                    title: "Email",
                    hintText: user?.email ?? "Enter Email",
                    keyboardType: TextInputType.emailAddress,
                    controller: txtEmail,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: RoundTitleTextfield(
                    title: "Mobile No",
                    hintText: txtMobile.text.isNotEmpty
                        ? txtMobile.text
                        : "Enter Mobile No",
                    controller: txtMobile,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.startsWith('0')) {
                        return 'Phone number cannot start with zero';
                      }
      
                      final validCountries = {
                        'GB': {'name': 'England', 'minLength': 10, 'maxLength': 10},
                        'US': {'name': 'USA', 'minLength': 10, 'maxLength': 10},
                        'DE': {'name': 'Germany', 'minLength': 10, 'maxLength': 11},
                        'FR': {'name': 'France', 'minLength': 9, 'maxLength': 9},
                        'SE': {'name': 'Sweden', 'minLength': 9, 'maxLength': 9},
                        'PK': {'name': 'Pakistan', 'minLength': 10, 'maxLength': 10},
                      };
      
                      final selectedCountry = 'US'; // Replace this with your actual selected country code logic
      
                      if (!validCountries.containsKey(selectedCountry)) {
                        return 'Please select a valid country';
                      }
      
                      final countrySettings = validCountries[selectedCountry]!;
                      final phoneNumberLength = value.length;
      
                      if (phoneNumberLength <
                              int.parse(countrySettings['minLength'].toString()) ||
                          phoneNumberLength >
                              int.parse(countrySettings['maxLength'].toString())) {
                        return 'Phone number must be ${countrySettings['minLength']} digits for ${countrySettings['name']}';
                      }
      
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                loading
                    ? const CircularProgressIndicator(color: Color(0xFF11CEC4))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RoundButton(
                          title: "Save",
                          onPressed: () async {
                            saveProfile();
                          },
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
