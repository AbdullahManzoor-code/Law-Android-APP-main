import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:law_app/components/toaster.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

class TextEditorScreen extends StatefulWidget {
  const TextEditorScreen({super.key});

  @override
  _TextEditorScreenState createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();

  Future<void> _saveAndExportPDF() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/document.pdf';

      final pdfConverter = PDFConverter(
        document: _controller.document.toDelta(),
        params: PDFPageFormat.a4,
        frontMatterDelta: null,
        backMatterDelta: null,
        fallbacks: [],
      );
      final pdfDocument = await pdfConverter.createDocument();

      final file = File(path);
      await file.writeAsBytes(await pdfDocument!.save());

      await Share.shareXFiles([XFile(path)], text: 'Here is your document');

      showToast(message: 'PDF exported and saved to $path');
    } catch (e) {
      showToast(
          message: 'Error exporting PDF: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> saveAndPrintPDF() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/document.pdf';

      final pdfConverter = PDFConverter(
        document: _controller.document.toDelta(),
        params: PDFPageFormat.a4,
        frontMatterDelta: null,
        backMatterDelta: null,
        fallbacks: [],
      );
      final pdfDocument = await pdfConverter.createDocument();

      final file = File(path);
      await file.writeAsBytes(await pdfDocument!.save());
      await Printing.layoutPdf(
        onLayout: (format) async => pdfDocument.save(),
      );

      showToast(message: 'PDF generated and print dialog opened.');
    } catch (e) {
      showToast(
          message: 'Error generating or printing PDF: $e',
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: saveAndPrintPDF,
              heroTag: 'printBtn',
              child: Icon(Icons.print),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: _saveAndExportPDF,
              heroTag: 'shareBtn',
              child: Icon(Icons.share),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              QuillToolbar.simple(
                controller: _controller,
                configurations: QuillSimpleToolbarConfigurations(
                  toolbarSectionSpacing: 5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.lightBlueAccent,
                        offset: Offset(
                          5.0,
                          5.0,
                        ),
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: QuillEditor.basic(
                      controller: _controller,
                      scrollController: ScrollController(),
                      focusNode: _focusNode,
                      configurations: QuillEditorConfigurations(minHeight: 500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
