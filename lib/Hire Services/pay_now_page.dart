import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/androidenterprise/v1.dart';
import 'package:law_app/Hire%20Quickly/hire_quickly.dart';
import 'package:law_app/components/Email/send_email_emailjs.dart';
import 'package:law_app/components/common/uploadtask.dart';
import 'package:law_app/components/toaster.dart';
import 'package:law_app/receipt/model/customer.dart';
import 'package:law_app/receipt/model/invoice.dart';
import 'package:law_app/receipt/model/supplier.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../receipt/api/pdf_api.dart';
import '../receipt/api/pdf_invoice_api.dart';
import 'color_extension.dart';
import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class PayNowPage extends StatefulWidget {
  final String heading;
  final String title;
  final String subTitle;
  final String option;
  final double totalPrice;
  List<String> extraOption;
  final String name;
  final String email;
  final String subject;
  final String message;
  final String services;
  final DocumentReference<Object?> docRef;
  // ignore: use_super_parameters
  PayNowPage(
      {Key? key,
      required this.totalPrice,
      required this.heading,
      required this.title,
      required this.subTitle,
      required this.option,
      this.extraOption = const [],
      required this.name,
      required this.email,
      required this.subject,
      required this.message,
      required this.services,
      required this.docRef})
      : super(key: key);

  @override
  State<PayNowPage> createState() => _PayNowPageState();
}

class _PayNowPageState extends State<PayNowPage> {
  final user = FirebaseAuth.instance.currentUser;

  List paymentArr = [
    {"name": "Cash on delivery", "icon": "assets/images/cash.png"},
  ];
  int selectMethod = -1;
  late String deliveryAddress = "";
  String deliveryPhone = "";
  String deliveryName = "";
  String deliveryEmail = "";
  Map<String, dynamic>? paymentIntentData;

  bool isshowbutton = false;

  late File pdfFile;

  bool isPaid = false;

  @override
  void initState() {
    super.initState();

    Stripe.publishableKey =
        'pk_test_51PkMrnCSoqn7lOOtvp6danTk6p8Ti7ED9efwk1SgYz9HSPLwfs8gzuOrWDq8ymrH4XPkjJKUz93uxFVuQQDplSm400oRTIUGup';
    fetchOrderStatus();
  }
  ///////////////////////////Stripe payment gate way ////////////////////////

  Future<void> makePayment() async {
    try {
      paymentIntentData =
          await createPaymentIntent('${widget.totalPrice}', 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          merchantDisplayName: 'Example Merchant',
          style: ThemeMode.system,
        ),
      );
      displayPaymentSheet();
    } catch (e) {
      print('Error in makePayment: $e');
      Fluttertoast.showToast(
        msg: "Error in making payment",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> displayPaymentSheet() async {
    // try {
    await Stripe.instance.presentPaymentSheet();
    setState(() {
      paymentIntentData = null;
    });
    Fluttertoast.showToast(
      msg: "Payment successful",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    await pdfgent();
    final receipt =
        await storeToFirebase(pdfFile, "receipts/${widget.docRef.id}");
    updateOrderStatus(widget.docRef.id,"receipts/${widget.docRef.id}");
    // Use
    // try {
    //   final Email email = Email(
    //     body: 'Email body',
    //     subject: widget.subject,
    //     recipients: [widget.email],
    //     cc: ['cc@example.com'],
    //     bcc: ['bcc@example.com'],
    //     attachmentPaths: [pdfFile.path],
    //     isHTML: false,
    //   );

    //   await FlutterEmailSender.send(email);
    // } catch (e) {
    //   showToast(message: "$e this scenod eamil");
    // }

    sendEmailUsingEmailjs(
        isadmin: true,

        ///sending to admin
        name: widget.name,
        email: widget.email,
        subject: widget.subject,
        message: widget.message,
        pdf: receipt!);

    sendEmailUsingEmailjs(
        isadmin: false,

        ///sending to customer
        name: widget.name,
        email: widget.email,
        subject: widget.subject,
        message: widget.message,
        pdf: receipt);

    // sendEmailUsingEmailjs(
    //     name: _nameController.text,
    //     email: _emailController.text,
    //     subject: services,
    //     message: _messageController.text,
    //     services: widget.selectedCategorySubOptionName);
    // } on StripeException catch (e) {
    //   print('StripeException: $e');
    //   Fluttertoast.showToast(
    //     msg: "Payment failed",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0,
    //   );
    // } catch (e) {
    //   print('Exception: $e');
    //   Fluttertoast.showToast(
    //     msg: "Payment failed",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0,
    //   );
    // }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51PkMrnCSoqn7lOOtG9Gk5XjxHOXdAWgpmOfOPGUTLaws4hpWvED4S6plQ2uworUZGXyPVEKKxbXpCLcWO48YqQTO00gHeJUKnF',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      print('Error creating payment intent: $err');
      throw err;
    }
  }

  Future<void> updateOrderStatus(String reference,String url) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders') // The name of your collection
          .doc(
              reference) // The specific document ID (reference) you want to update
          .update({
        'status': 'completed',
        'receipturl':url // The field you want to update
      });

      print('Order status updated successfully.');
    } catch (e) {
      print('Failed to update order status: $e');
    }
  }

  String calculateAmount(String amount) {
    final calculatedAmount = (double.parse(amount) * 100).toInt().toString();
    return calculatedAmount;
  }

//   Future<void> sendPurchaseConfirmationEmail({
//     required String userName,
//     required String service,
//     required String userMessage,
//     required String userEmail,
//     required String userSubject,
//   }) async {
//     final Email email = Email(
//       body: '''
// Dear $userName,

// Thank you for your recent purchase! We are pleased to confirm that you have successfully purchased the following service:

// ---

// **Service Purchased:**
// $service

// **Message from You:**
// "$userMessage"

// ---

// We appreciate your trust in our services and look forward to assisting you.

// If you have any questions or need further assistance, please feel free to contact us.

// ---

// Best regards,

// The [Your Company Name] Team
// Email: $userEmail
// Subject: $userSubject

// ---

// Note: This email serves as confirmation of your recent service purchase. Please keep this information for your records.
// ''',
//       subject: 'Confirmation of Your Service Purchase',
//       recipients: [userEmail],
//       cc: [],
//       bcc: [],
//       attachmentPaths: [],
//       isHTML: false,
//     );

//     await FlutterEmailSender.send(email);
//   }

  // generatepdf() async {
  //   final date = DateTime.now();
  //   final dueDate = date.add(Duration(days: 7));
  //   final invoice = Invoice(
  //       supplier: Supplier(
  //         name: widget.name,
  //         address: 'Sarah Street 9, Beijing, China',
  //         paymentInfo: 'https://paypal.me/sarahfieldzz',
  //       ),
  //       customer: Customer(
  //         name: 'lawyer_name',
  //         address: 'Apple Street, Cupertino, CA 95014',
  //       ),
  //       info: InvoiceInfo(
  //         date: date,
  //         dueDate: dueDate,
  //         description: 'My description...',
  //         number: '${DateTime.now().year}-9999',
  //       ),
  //       items: List.generate(
  //         widget.extraOption.length,
  //         (index) {
  //           return InvoiceItem(
  //             description: widget.extraOption[index],
  //             date: DateTime.now(),
  //             quantity: 1,
  //             vat: 0.19,
  //             unitPrice: 100,
  //           );
  //         },
  //       ));

  //   final pdfFile = await PdfInvoiceApi.generate(invoice);
  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes(),
  //   );

  //   PdfApi.openFile(pdfFile);
  // }

  pdfgent() async {
    final date = DateTime.now();
    final dueDate = date.add(Duration(days: 7));

    final invoice = Invoice(
        supplier: Supplier(
          name: 'Sarah Field',
          address: 'Sarah Street 9, Beijing, China',
          paymentInfo: 'https://paypal.me/sarahfieldzz',
        ),
        customer: Customer(
          name: 'Apple Inc.',
          address: 'Apple Street, Cupertino, CA 95014',
        ),
        info: InvoiceInfo(
          date: date,
          dueDate: dueDate,
          description: 'My description...',
          number: '${DateTime.now().year}-9999',
        ),
        items: List.generate(
          widget.extraOption.length,
          (index) {
            return InvoiceItem(
              description: widget.extraOption[index],
              date: DateTime.now(),
              quantity: 1,
              vat: 0.19,
              unitPrice: 100,
            );
          },
        ));

    final pdFFile = await PdfInvoiceApi.generate(invoice);
    setState(() {
      pdfFile = pdFFile;
    });
    // await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes());
    // await OpenFile.open(pdfFile.path);
    setState(() {
      isshowbutton = true;
    });

    showToast(message: "Now you can save and share the Receipt");
    await OpenFile.open(pdfFile.path);
    fetchOrderStatus();
  }

  Future<void> fetchOrderStatus() async {
    try {
      DocumentSnapshot orderSnapshot = await widget.docRef.get();
      String status = orderSnapshot.get('status');

      setState(() {
        isPaid = status == 'completed';
      });
      print('Error fetching order status:');
    } catch (e) {
      print('Error fetching order status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double fee = 2; // Example delivery cost
    double discount = 4; // Example discount
    double subTotal = widget.totalPrice;
    double total = subTotal + fee - discount;

    return Scaffold(
      floatingActionButton: Visibility(
        visible: isshowbutton,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          FloatingActionButton(
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (format) async => pdfFile.readAsBytes(),
              );
            },
            heroTag: 'printBtn',
            child: const Icon(Icons.print),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              await Share.shareXFiles([XFile(pdfFile.path)],
                  text: 'Here is your document');
            },
            heroTag: 'shareBtn',
            child: const Icon(Icons.share),
          ),
        ]),
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset(
                        "assets/images/btn_back.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Pay Now",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Selected Services",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: TColor.secondaryText, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.heading,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subTitle,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.option,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        widget.extraOption.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widget.extraOption
                                    .map(
                                      (e) => Text(
                                        e,
                                        style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment method",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add, color: TColor.primary),
                          label: Text(
                            "Add Card",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // ListView.builder(
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   padding: EdgeInsets.zero,
                    //   shrinkWrap: true,
                    //   itemCount: paymentArr.length,
                    //   itemBuilder: (context, index) {
                    //     var pObj = paymentArr[index] as Map? ?? {};
                    //     return Container(
                    //       margin: const EdgeInsets.symmetric(vertical: 8.0),
                    //       padding: const EdgeInsets.symmetric(
                    //         vertical: 8.0,
                    //         horizontal: 15.0,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: TColor.textfield,
                    //         borderRadius: BorderRadius.circular(5),
                    //         border: Border.all(
                    //           color: TColor.secondaryText.withOpacity(0.2),
                    //         ),
                    //       ),
                    //       child: Row(
                    //         children: [
                    //           Image.asset(
                    //             pObj["icon"].toString(),
                    //             width: 50,
                    //             height: 20,
                    //             fit: BoxFit.contain,
                    //           ),
                    //           Expanded(
                    //             child: Text(
                    //               pObj["name"],
                    //               style: TextStyle(
                    //                 color: TColor.primaryText,
                    //                 fontSize: 12,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ),
                    //           InkWell(
                    //             onTap: () {
                    //               setState(() {
                    //                 selectMethod = index;
                    //               });
                    //             },
                    //             child: Icon(
                    //               selectMethod == index
                    //                   ? Icons.radio_button_on
                    //                   : Icons.radio_button_off,
                    //               color: TColor.primary,
                    //               size: 15,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sub Total",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${widget.totalPrice.toStringAsFixed(2)} \$",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Fee Tax (example)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "$fee \$",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discount",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "-$discount \$",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Divider(
                      color: TColor.secondaryText.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${total.toStringAsFixed(2)} \$",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => InvoicePage(
                    //             deliveryName: 'haroon',
                    //             deliveryEmail: 'example@mail.com',
                    //             deliveryAddress: 'xyz add',
                    //             deliveryCost: fee.toString(),
                    //             deliveryPhone: deliveryPhone),
                    //       ),
                    //     );
                    //   },
                    //   child: const Text("Generate Receipt"),
                    // ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        (isPaid)
                            ? showToast(message: "you have already pay")
                            : makePayment();
                        // generatepdf();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11CEC4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 110, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: Text(
                        isPaid ? "paid" : "Pay Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
