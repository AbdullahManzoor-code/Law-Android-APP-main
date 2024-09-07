import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/androidpublisher/v3.dart';
import 'package:law_app/Orders/paid.dart';

class DocumentNamesPage extends StatefulWidget {
  const DocumentNamesPage({super.key});

  @override
  State<DocumentNamesPage> createState() => _DocumentNamesPageState();
}

class _DocumentNamesPageState extends State<DocumentNamesPage> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Documents',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Documents')
            .doc(uid)
            .collection('documents')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF11CEC4),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No Documents found.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            );
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var document = documents[index];
              var docData = document.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          receipturl: docData['doc'], // Use fetched receipt URL
                        ),
                      ),
                    );
                },
                child: ListTile(
                  leading: const Icon(Icons.document_scanner),
                  title: Text(docData['name'] ?? 'No Name'),
                  subtitle: Text(docData['createdAt'] != null
                      ? (docData['createdAt']).toDate().toString()
                      : 'Unknown Date'),
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          receipturl: docData['doc'], // Use fetched receipt URL
                        ),
                      ),
                    );
                    // Handle document opening or downloading
                    // You can navigate to another page or download the document
                    final docUrl = docData['doc'];
                    if (docUrl != null) {
                      // Use this URL to download or open the document
                      // You can use Firebase Storage or other methods to open the file
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
