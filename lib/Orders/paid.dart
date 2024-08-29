import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerScreen extends StatefulWidget {
  PdfViewerScreen({super.key, required this.receipturl});

  String receipturl;

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Future<String>? _pdfPath;

  @override
  void initState() {
    super.initState();
    _pdfPath = _loadPdf();
  }
 late final pdffile;
  Future<String> _loadPdf() async {
    final response = await http.get(Uri.parse(widget.receipturl));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
     var  dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');
      
     await file.writeAsBytes(bytes);
     pdffile=file.path;
      return file.path;
    } else {
      throw Exception('Failed to load PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( floatingActionButton: FloatingActionButton(
              onPressed: ()async{
                    await Share.shareXFiles([XFile(pdffile)], text: 'Here is your document');

              },
              heroTag: 'uploadFileBtn',
              child: const Icon(Icons.upload_file),
            ),
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: FutureBuilder<String>(
        future: _pdfPath,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return PDFView(
              filePath: snapshot.data!,
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
