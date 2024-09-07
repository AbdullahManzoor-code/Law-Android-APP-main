import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:law_app/Orders/paid.dart';
import '../Hire Services/pay_now_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orders.where('userId', isEqualTo: uid).            orderBy('timestamp', descending: true)
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
                'No Orders found.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            );
          }
          
          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              var order = data.docs[index];
              var timestamp = order['timestamp'] as Timestamp;
              var formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());
              var orderData = order.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  final isPaid = orderData['status'] == 'completed';
                  if (isPaid) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          receipturl: orderData['receipturl'], // Use fetched receipt URL
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PayNowPage(
                          whatsapp: orderData['whatsapp'],
                          isfromorder: true,
                          docRef: order.reference,
                          name: orderData["name"],
                          email: orderData["email"],
                          subject: orderData["name"],
                          message: orderData["message"],
                          services: orderData['selectedCategorySubOptionName'],
                          heading: orderData["selectedCategory"],
                          title: orderData["selectedCategoryOption"],
                          subTitle: orderData['selectedCategorySubOption'],
                          option: orderData['selectedCategorySubOptionName'],
                          totalPrice: orderData['totalPrice'],
                          extraOption: List<String>.from(orderData["extraOption"]), // Explicitly cast to List<String>
                        ),
                      ),
                    );
                  }
                },
                child: ListTile(
                  leading: const Icon(Icons.receipt),
                  title: Text(orderData['selectedCategorySubOptionName']),
                  subtitle: Text(formattedDate),
                  trailing: Text(orderData['status']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
