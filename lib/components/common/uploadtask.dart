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
