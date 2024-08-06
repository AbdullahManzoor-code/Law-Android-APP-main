import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

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
              return ListTile(
                leading: const Icon(Icons.receipt),
                title: Text(order['selectedCategorySubOptionName']),
                subtitle: Text(formattedDate),
                trailing: Text(order['status']),
              );
            },
          );
        },
      ),
    );
  }
}
