import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:law_app/Orders/user_orders_page.dart';
import 'package:law_app/components/common/round_button.dart';
import 'package:law_app/components/common/round_textfield.dart';
import 'package:law_app/components/common/uploadtask.dart';
import 'package:law_app/components/toaster.dart';
// import 'package:image_picker/image_picker.dart' as imgg;

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker picker = ImagePicker();
  File? image;
  final user = FirebaseAuth.instance.currentUser;

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      image = File(pickedFile.path);
      showToast(message: "Image Selected: ${pickedFile.name}");
    });
    if (image != null) {
      storeToFirebase(image, user!.uid);
    }
  }

  Future<void> storeToFirebase(File? imageFile, String userId) async {
    if (imageFile == null) return showToast(message: "image is aailablae");

    try {
      final ref = FirebaseStorage.instance.ref().child('$userId/image');
      final uploadTask = ref.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);

      setState(() {
        showToast(message: "Profile Image Updated Successfully");
      });
    } catch (e) {
      showToast(message: "Failed to Upload Image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                  icon: Icon(Icons.receipt),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: Icon(
                    Icons.logout,
                    size: 20,
                  ),
                  label: Text(
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
                color: Colors.grey[200], // Placeholder color
                borderRadius: BorderRadius.circular(50),
              ),
              alignment: Alignment.center,
              child: user?.photoURL != null
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
                      : Icon(
                          Icons.person,
                          size: 65,
                          color: Colors.grey, // Default icon color
                        ),
            ),
            TextButton.icon(
              onPressed: () async {
                pickImage();
              },
              icon: Icon(
                Icons.edit,
                size: 12,
              ),
              label: Text(
                "Edit Profile",
                style: TextStyle(fontSize: 12),
              ),
            ),
            Text(
              "Hi there!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: RoundTitleTextfield(
                title: "Name",
                hintText: user?.displayName ?? "Enter Name",
                controller: txtName,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: RoundTitleTextfield(
                title: "Email",
                hintText: user?.email ?? "Enter Email",
                keyboardType: TextInputType.emailAddress,
                controller: txtEmail,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: RoundTitleTextfield(
                title: "Mobile No",
                hintText: user?.phoneNumber ?? "Enter Mobile No",
                controller: txtMobile,
                keyboardType: TextInputType.phone,
              ),
            ),
            // Uncomment if password fields are needed
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            //   child: RoundTitleTextfield(
            //     title: "Password",
            //     hintText: "* * * * * *",
            //     obscureText: true,
            //     controller: txtPassword,
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            //   child: RoundTitleTextfield(
            //     title: "Confirm Password",
            //     hintText: "* * * * * *",
            //     obscureText: true,
            //     controller: txtConfirmPassword,
            //   ),
            // ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RoundButton(
                title: "Save",
                onPressed: () {
                  // Implement save functionality here
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
