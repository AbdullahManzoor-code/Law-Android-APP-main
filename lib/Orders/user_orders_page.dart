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

  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  
  bool isPaid=false;
  
  String receipturl="";

  @override
  Widget build(BuildContext context) {
  Future<void> fetchOrderStatus(docRef) async {
    try {
      DocumentSnapshot orderSnapshot = await docRef.get();
      String status = orderSnapshot.get('status');
     receipturl= orderSnapshot.get('receipturl');


      setState(() {
        isPaid = status == 'completed';
      });
      print('Error fetching order status:');
    } catch (e) {
      print('Error fetching order status: $e');
    }
  }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton.filled(
            onPressed: () {
              print("object");
            },
            icon: const Icon(Icons.abc)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        // title: const Text(
        //   'Orders',
        //   style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        // ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: orders.where('userId', isEqualTo: uid).get(),
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
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No Orders found.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            );
          }
          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              var order = data.docs[index];
              var timestamp = order['timestamp'] as Timestamp;
              var formattedDate =
                  DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());
              return GestureDetector(
                onTap: () {
                  fetchOrderStatus(order.reference);
                  isPaid? Navigator.push(context, MaterialPageRoute(builder:(context) =>  PdfViewerScreen(receipturl: receipturl,),)):
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PayNowPage(
                          docRef: order.reference,
                          name: order["name"],
                          email: order["email"],
                          subject: order["name"],
                          message: order["message"],
                          services: order['selectedCategorySubOptionName'],
                          heading: order["selectedCategory"],
                          title: order["selectedCategoryOption"],
                          subTitle: order['selectedCategorySubOption'],
                          option: order['selectedCategorySubOptionName'],
                          totalPrice: order['totalPrice'],
                          extraOption: List<String>.from(order[
                              "extraOption"]), // Explicitly casting to List<String>
                        ),
                      ));

                },
                child: ListTile(
                  leading: const Icon(Icons.receipt),
                  title: Text(order['selectedCategorySubOptionName']),
                  subtitle: Text(formattedDate),
                  trailing: Text(order['status']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
