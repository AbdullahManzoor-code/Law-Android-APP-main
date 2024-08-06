// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PayNowPage extends StatefulWidget {
//   final String heading;
//   final String title;
//   final String subTitle;
//   final String option;
//   final double totalPrice;
//   final List<String> extraOption;

//   PayNowPage({
//     Key? key,
//     required this.totalPrice,
//     required this.heading,
//     required this.title,
//     required this.subTitle,
//     required this.option,
//     this.extraOption = const [],
//   }) : super(key: key);

//   @override
//   _PayNowPageState createState() => _PayNowPageState();
// }

// class _PayNowPageState extends State<PayNowPage> {
//   Map<String, dynamic>? paymentIntentData;

//   @override
//   void initState() {
//     super.initState();
//     Stripe.publishableKey =
//         'pk_test_51PkMrnCSoqn7lOOtvp6danTk6p8Ti7ED9efwk1SgYz9HSPLwfs8gzuOrWDq8ymrH4XPkjJKUz93uxFVuQQDplSm400oRTIUGup';
//   }

//   Future<void> makePayment() async {
//     try {
//       paymentIntentData =
//           await createPaymentIntent('${widget.totalPrice}', 'USD');
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntentData!['client_secret'],
//           merchantDisplayName: 'Example Merchant',
//           style: ThemeMode.system,
//         ),
//       );
//       displayPaymentSheet();
//     } catch (e) {
//       print('Error in makePayment: $e');
//     }
//   }

//   Future<void> displayPaymentSheet() async {
//     try {
//       await Stripe.instance.presentPaymentSheet();
//       setState(() {
//         paymentIntentData = null;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment successful')),
//       );
//     } on StripeException catch (e) {
//       print('StripeException: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment failed')),
//       );
//     } catch (e) {
//       print('Exception: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment failed')),
//       );
//     }
//   }

//   Future<Map<String, dynamic>> createPaymentIntent(
//       String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': calculateAmount(amount),
//         'currency': currency,
//         'payment_method_types[]': 'card',
//       };
//       var response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization':
//               'Bearer sk_test_51PkMrnCSoqn7lOOtG9Gk5XjxHOXdAWgpmOfOPGUTLaws4hpWvED4S6plQ2uworUZGXyPVEKKxbXpCLcWO48YqQTO00gHeJUKnF',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: body,
//       );
//       return json.decode(response.body);
//     } catch (err) {
//       print('Error creating payment intent: $err');
//       throw err;
//     }
//   }

//   String calculateAmount(String amount) {
//     final calculatedAmount = (double.parse(amount) * 100).toInt().toString();
//     return calculatedAmount;
//   }

//   @override
//   Widget build(BuildContext context) {
//     double fee = 2; // Example delivery cost
//     double discount = 4; // Example discount
//     double subTotal = widget.totalPrice;
//     double total = subTotal + fee - discount;

//     return Scaffold(
//       appBar: AppBar(title: Text('Pay Now')),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.heading,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text(widget.title, style: TextStyle(fontSize: 16)),
//             Text(widget.subTitle, style: TextStyle(fontSize: 14)),
//             Text(widget.option, style: TextStyle(fontSize: 12)),
//             ...widget.extraOption
//                 .map((e) => Text(e, style: TextStyle(fontSize: 12)))
//                 .toList(),
//             SizedBox(height: 20),
//             Text('Payment method', style: TextStyle(fontSize: 16)),
//             ElevatedButton(
//               onPressed: () async {
//                 await makePayment();
//               },
//               child: Text('Pay Now (\$${total.toStringAsFixed(2)})'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
