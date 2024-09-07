import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:law_app/Hire%20Services/form_page.dart';
import 'package:law_app/components/Email/send_email_emailjs.dart';
import 'package:law_app/components/common/timer.dart';
import 'package:law_app/components/common/uploadtask.dart';
import 'package:law_app/components/toaster.dart';
import 'package:law_app/receipt/model/customer.dart';
import 'package:law_app/receipt/model/invoice.dart';
import 'package:law_app/receipt/model/supplier.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
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
  final bool isfromorder;
  final String whatsapp;
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
      required this.docRef,required this.isfromorder, required this.whatsapp})
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
    final GlobalKey _qrkey = GlobalKey();

  String? receipt;
  
  
  
  var qrdata ="www.mstips.org";
  
  String? link;

  @override
  void initState() {
    super.initState();

    Stripe.publishableKey =
        'pk_test_51PkMrnCSoqn7lOOtvp6danTk6p8Ti7ED9efwk1SgYz9HSPLwfs8gzuOrWDq8ymrH4XPkjJKUz93uxFVuQQDplSm400oRTIUGup';
    fetchOrderStatus();
  }
  ///////////////////////////Stripe payment gate way ////////////////////////

Future<void> handlePaymentCreation() async {
  paymentIntentData = await createPaymentIntent('${widget.totalPrice}', 'USD');
  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      paymentIntentClientSecret: paymentIntentData!['client_secret'],
      merchantDisplayName: 'Example Merchant',
      style: ThemeMode.system,
    ),
  );
  await displayPaymentSheet();
}

Future<void> generateAndSavePDFReceipt() async {
  final pdfFile = await pdfgent();
  receipt = await storeToFirebase(pdfFile, "receipts/${widget.docRef.id}");
  setState(() {
    qrdata = receipt!;
  });
}

Future<void> generateAndUploadQRCode() async {
        // final dir = await getApplicationDocumentsDirectory();
 
link=  await _captureAndSavePng();
  // link = await storeToFirebase(File('${dir.path}/qrcode.png'), "receiptQr/${widget.docRef.id}");
}

Future<void> sendEmails() async {
  await sendEmailUsingEmailjs(
    isadmin: true,
    name: widget.name,
    email: widget.email,
    subject: widget.subject,
    message: widget.message,
    pdf: receipt!,
    qrcode: link,
  );

  await sendEmailUsingEmailjs(
    isadmin: false,
    name: widget.name,
    email: widget.email,
    subject: widget.subject,
    message: widget.message,
    pdf: receipt!,
    qrcode: link,
  );
}

void handlePaymentError(Exception e) {
  Fluttertoast.showToast(
    msg: "Error in making payment",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Future<void> displayPaymentSheet() async {
  try {
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
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Payment failed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
  try {
    Map<String, dynamic> body = {
      'amount': calculateAmount(amount),
      'currency': currency,
      'payment_method_types[]': 'card',
    };
    var response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer sk_test_51PkMrnCSoqn7lOOtG9Gk5XjxHOXdAWgpmOfOPGUTLaws4hpWvED4S6plQ2uworUZGXyPVEKKxbXpCLcWO48YqQTO00gHeJUKnF',
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

Future<void> updateOrderStatus(String reference, String url) async {
  try {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(reference)
        .update({
      'status': 'completed',
      'receipturl': url,
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

Future<File> pdfgent() async {
  final date = DateTime.now();
  final dueDate = date.add(const Duration(days: 7));

  final invoice = Invoice(
    supplier: const Supplier(
      name: '',
      address: '',
      paymentInfo: '',
    ),
    customer:  Customer(
      name: widget.name,
      address:widget.whatsapp,
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
    ),
  );

  final pdf = await PdfInvoiceApi.generate(invoice);
  setState(() {
    pdfFile = pdf;
    isshowbutton = true;
  });

  showToast(message: "Now you can save and share the Receipt");
  await OpenFile.open(pdfFile.path);
  return pdfFile;
}

Future<String?> _captureAndSavePng() async {
  try {
    RenderRepaintBoundary boundary = _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 3.0);

    final whitePaint = Paint()..color = Colors.white;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
    canvas.drawRect(Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), whitePaint);
    canvas.drawImage(image, Offset.zero, Paint());
    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/qrcode.png');
    await file.writeAsBytes(pngBytes);

    return await storeToFirebase(file, "receiptQr/${widget.docRef.id}");
  } catch (e) {
    if (!mounted) {
      return null;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something went wrong!!!')));
  }
  return null;
}

Future<void> fetchOrderStatus() async {
  try {
    DocumentSnapshot orderSnapshot = await widget.docRef.get();
    String status = orderSnapshot.get('status');

    setState(() {
      isPaid = status == 'completed';
    });
  } catch (e) {
    print('Error fetching order status: $e');
  }
}

Future<void> makePayment() async {
  try {
    await handlePaymentCreation();
    await generateAndSavePDFReceipt();
    await updateOrderStatus(widget.docRef.id, receipt!);
    await generateAndUploadQRCode();
    ///////////  qrcode upload//////////
     await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.docRef.id)
        .update({
      
      'r_qrcode_link': link!});
    await sendEmails();
  } catch (e) {
    showToast(message: e.toString());
  }
}
  @override
  Widget build(BuildContext context) {
    double fee = 2; // Example delivery cost
    double discount = 4; // Example discount
    double subTotal = widget.totalPrice;
    double total = subTotal + fee - discount;

    return IdleTimeoutWrapper(
      child: Scaffold(
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
                      Row(
                        children: [
      
                          Text(
                            "Your Selected Services",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: TColor.secondaryText, fontSize: 12),
                          ),
      
                          Visibility(
                            visible: !isPaid,
                            child: IconButton(onPressed: (){ 
                               
                            
                           widget.  isfromorder? Navigator.push(
                                      context,
                                      MaterialPageRoute(builder:(context) => FormPage(selectedCategory: widget.heading, selectedCategoryOption: widget.title, selectedCategorySubOption: widget.subTitle, selectedCategorySubOptionName: widget.option, price: widget.totalPrice,isfromorder: widget.isfromorder,oderID:  widget.docRef.id),)) :Navigator.pop(context);
                            }, icon: const Icon(Icons.edit)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          
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
                          Column(
                            children: [
                              RepaintBoundary(
                                            key: _qrkey,
                                            child: QrImageView(
                                              data: qrdata,
                                              version: QrVersions.auto,
                                              size: 100,
                                              gapless: true,
                                              errorStateBuilder: (ctx, err) {
                                                return const Center(
                                                  child: Text(
                                                    'Something went wrong!!!',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                            ],
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
                      
                      const SizedBox(height: 20),
      
                      ElevatedButton(
                        onPressed: () {
                          // makePayment();
                          (isPaid||isshowbutton)
                              ? {showToast(message: "you have already pay")}
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
                          isPaid ||isshowbutton? "paid" : "Pay Now",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
