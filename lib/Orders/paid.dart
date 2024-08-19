import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;



class PdfViewerScreen extends StatefulWidget {
   PdfViewerScreen({super.key,required this.receipturl});


 String receipturl;
  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Future<Uint8List>? _pdfData;
  @override
  void initState() {
    super.initState();
    _pdfData = _loadPdf();
  }

  Future<Uint8List> _loadPdf() async {
    final pdfUrl = 'https://www.example.com/sample.pdf';
    final response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdfData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return PDFView(
              filePath: snapshot.data.toString(),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
