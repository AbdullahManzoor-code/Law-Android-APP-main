// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';

//   Future selectFiles() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: true);

//     if (result == null) return;

//     setState(() {
//       for (var file in result.files) {
//         if (!pickedFiles
//             .any((existingFile) => existingFile.name == file.name)) {
//           pickedFiles.add(file);
//         }
//         showToast(
//           message: "File Picked ${file.name}",
//         );
//       }
//     });
//   }

//   Future uploadFiles() async {
//     if (pickedFiles.isEmpty) return;

//     List<String> urls = [];

//     for (var file in pickedFiles) {
//       final path = 'files/${file.name}';
//       final fileToUpload = File(file.path!);
//       final ref = FirebaseStorage.instance.ref().child(path);

//       final uploadTask = ref.putFile(fileToUpload);

//       setState(() {
//         uploadTasks.add(uploadTask);
//         showToast(message: "File Uploaded");
//       });

//       final snapshot = await uploadTask.whenComplete(() {});
//       final urlDownload = await snapshot.ref.getDownloadURL();

//       print('Download Link: $urlDownload');
//       urls.add(urlDownload);
//     }

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:law_app/components/toaster.dart';

Future<String?> storeToFirebase(File imageFile, String path) async {
  if (imageFile == null) showToast(message: "file is not selected");

  try {
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(imageFile);

    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;

    // await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);

    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userId)
    //     .update({'photoURL': downloadUrl}); // Update photo URL in Firestore
  } catch (e) {
    showToast(message: "Failed to Upload  $e");
  }
}
