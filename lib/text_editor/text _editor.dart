  import 'package:flutter/services.dart';
import 'package:law_app/components/common/timer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:law_app/components/toaster.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:docx_to_text/docx_to_text.dart';

class TextEditorScreen extends StatefulWidget {
  const TextEditorScreen({super.key});

  @override
  _TextEditorScreenState createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final QuillController _controller = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  
  bool loading=false;

  Future<void> selectFiles() async {
    setState(() {
      loading=true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'json', 'docx','doc','pdf'], // Allow text files and other document types
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final extension = result.files.single.extension;

      // try {
        String fileContent = '';

        if (['txt', 'md', 'json'].contains(extension)) {
          // Read text-based files
          fileContent = await file.readAsString();
        } else if (extension == 'docx') {
          // Handle DOCX files
          fileContent = await _readDocxFile(file);
        } else if (['pdf'].contains(extension)) {
          // Handle Excel files
          fileContent = await extractTextFromPDF(file.path);
        }

        setState(() {
          _controller.document = Document()..insert(0, fileContent);
          showToast(
            message: "File Picked: ${result.files.single.name}",
          );
        });
      // } catch (e) {
      //   showToast(
      //     message: "Error reading file content: $e",
      //     backgroundColor: Colors.red,
      //   );
      // }
      setState(() {
        
      loading=false;
      });
    } else {
      setState(() {
        
      loading=false;
      });
      showToast(
        message: "File selection canceled.",
      );
    }
  }

Future<String> extractTextFromPDF(String assetPath) async {
  // Load the PDF document from assets
  PdfDocument document = PdfDocument(inputBytes: await _readDocumentData(assetPath));

  // Create a PdfTextExtractor instance
  PdfTextExtractor extractor = PdfTextExtractor(document);

  // Extract all the text from the document
  String extractedText = extractor.extractText();

  // Dispose of the document
  document.dispose();

  // Return the extracted text
  return extractedText;
}

// Helper function to load PDF data from assets
Future<List<int>> _readDocumentData(String filePath) async {
  final File file = File(filePath);
  if (await file.exists()) {
    return await file.readAsBytes();
  } else {
    throw Exception("File not found: $filePath");
  }
}

  //  Future<String> _readPdfFile(File file) async {
  //   try {
  //     final pdfDoc = await .fromFile(file);
  //     final numPages = pdfDoc.length;
  //     String textContent = '';

  //     for (int i = 0; i < numPages; i++) {
  //       final page = pdfDoc.pageAt(i);
  //       final pageText = await page.text;
  //       textContent += pageText + '\n\n'; // Add page breaks for clarity
  //     }

  //     return textContent;
  //   } catch (e) {
  //     showToast(
  //       message: 'Error reading PDF file: $e',
  //       backgroundColor: Colors.red,
  //     );
  //     return '';
  //   }
  // }


  Future<String> _readDocxFile(File file) async {
  final bytes = await file.readAsBytes();
final doc = docxToText(bytes);
    return doc;
  }

  Future<String> _readExcelFile(File file) async {
    // Implement reading Excel files
    return 'Excel file content (not implemented)';
  }

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
        message: 'Error exporting PDF: $e',
        backgroundColor: Colors.red,
      );
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
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IdleTimeoutWrapper(
        child: Scaffold(
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: selectFiles,
                heroTag: 'uploadFileBtn',
                child: const Icon(Icons.upload_file),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: saveAndPrintPDF,
                heroTag: 'printBtn',
                child: const Icon(Icons.print),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _saveAndExportPDF,
                heroTag: 'shareBtn',
                child: const Icon(Icons.share),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: Stack(
                children: [
                   
              
                  SingleChildScrollView(
                            child: Column(
                  children: [
                    QuillToolbar.simple(
                      controller: _controller,
                      configurations: const QuillSimpleToolbarConfigurations(
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
                            configurations:
                                const QuillEditorConfigurations(minHeight: 500),
                          ),
                        ),
                      ),
                    ),
                  ],
                            ),
                          ),
        
                          if (loading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF11CEC4),
                    ),
                  ),
                ),),
                ],
              ),
        ),
      ),
    );
  }
}
