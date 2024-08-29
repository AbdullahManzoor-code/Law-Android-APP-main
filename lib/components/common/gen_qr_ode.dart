// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:law_app/components/common/uploadtask.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class MainPage extends StatefulWidget {
//    MainPage(  {required this.receipt});
// String receipt;
//   @override
//   State<MainPage> createState() => _MainPageState();
// a
// class _MainPageState extends State<MainPage> {
//   final TextEditingController _textController = TextEditingController(text: '');
  
//   final GlobalKey _qrkey = GlobalKey();

//   Future<void> _captureAndSavePng() async {
//     try{
//       RenderRepaintBoundary boundary = _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//       var image = await boundary.toImage(pixelRatio: 3.0);

//       //Drawing White Background because Qr Code is Black
//       final whitePaint = Paint()..color = Colors.white;
//       final recorder = PictureRecorder();
//       final canvas = Canvas(recorder,Rect.fromLTWH(0,0,image.width.toDouble(),image.height.toDouble()));
//       canvas.drawRect(Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), whitePaint);
//       canvas.drawImage(image, Offset.zero, Paint());
//       final picture = recorder.endRecording();
//       final img = await picture.toImage(image.width, image.height);
//       ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
//       Uint8List pngBytes = byteData!.buffer.asUint8List();

//       final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/qrcode.png');

//     await file.writeAsBytes(pngBytes);

      
//  final link = storeToFirebase(file, "receiptQr/");
//  print(link);
//       if(!mounted)return;
//       const snackBar = SnackBar(content: Text('QR code saved to gallery'));
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);

//     }catch(e){
//       if(!mounted)return;
//       const snackBar = SnackBar(content: Text('Something went wrong!!!'));
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('QR Code Generator'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//           child: Column(
//         children: [
          
          
//           const SizedBox(
//             height: 15,
//           ),
//           Center(
//             child: RepaintBoundary(
//               key: _qrkey,
//               child: QrImageView(
//                 data: widget.receipt,
//                 version: QrVersions.auto,
//                 size: 250.0,
//                 gapless: true,
//                 errorStateBuilder: (ctx, err) {
//                   return const Center(
//                     child: Text(
//                       'Something went wrong!!!',
//                       textAlign: TextAlign.center,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           RawMaterialButton(
//             onPressed: _captureAndSavePng,
          
//             shape: const StadiumBorder(),
//             padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
//             child: const Text(
//               'Export',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 18,
//               ),
//             ),
//           ),
//         ],
//       )),
//     );
//   }
// }