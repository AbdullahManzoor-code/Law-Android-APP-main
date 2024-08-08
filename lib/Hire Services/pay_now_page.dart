import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:law_app/components/Email/send_email_emailjs.dart';
import 'color_extension.dart';
import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

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
      required this.services})
      : super(key: key);

  @override
  State<PayNowPage> createState() => _PayNowPageState();
}

class _PayNowPageState extends State<PayNowPage> {
  List paymentArr = [
    {"name": "Cash on delivery", "icon": "assets/images/cash.png"},
  ];
  int selectMethod = -1;
  late String deliveryAddress = "";
  String deliveryPhone = "";
  String deliveryName = "";
  String deliveryEmail = "";
  Map<String, dynamic>? paymentIntentData;

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey =
        'pk_test_51PkMrnCSoqn7lOOtvp6danTk6p8Ti7ED9efwk1SgYz9HSPLwfs8gzuOrWDq8ymrH4XPkjJKUz93uxFVuQQDplSm400oRTIUGup';
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
    sendEmailUsingEmailjs(
        name: widget.name,
        email: widget.email,
        subject: widget.subject,
        message: widget.message);

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

  String calculateAmount(String amount) {
    final calculatedAmount = (double.parse(amount) * 100).toInt().toString();
    return calculatedAmount;
  }

  @override
  Widget build(BuildContext context) {
    double fee = 2; // Example delivery cost
    double discount = 4; // Example discount
    double subTotal = widget.totalPrice;
    double total = subTotal + fee - discount;

    return Scaffold(
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
                        makePayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11CEC4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 110, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text(
                        "Pay Now",
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
