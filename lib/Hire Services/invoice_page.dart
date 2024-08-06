import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

final InvoiceInfo invoiceInfo = InvoiceInfo(
  description: 'Order Invoice',
  date: DateTime.now(),
  dueDate: DateTime.now().add(Duration(days: 7)),
);

Future<void> saveCartItems(List<InvoiceItem> items) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> itemsJson =
      items.map((item) => jsonEncode(item.toJson())).toList();
  await prefs.setStringList('cartItems', itemsJson);
}

Future<List<InvoiceItem>> getCartItems() async {
  return [
    InvoiceItem(
        description: 'Sample Item Description',
        quantity: 1,
        unitPrice: 100,
        vat: 0.15,
        date: DateTime.now(),
        imageUrl: ''),
  ];
}

class InvoicePage extends StatefulWidget {
  final String deliveryName;
  final String deliveryAddress;
  final String deliveryPhone;
  final String deliveryEmail;
  final String deliveryCost;

  InvoicePage({
    required this.deliveryName,
    required this.deliveryAddress,
    required this.deliveryPhone,
    required this.deliveryEmail,
    required this.deliveryCost,
  });

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  late Future<List<InvoiceItem>> futureItems;

  var invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    futureItems = getCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<InvoiceItem>>(
          future: futureItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No items found'));
            } else {
              final items = snapshot.data!;
              final customer = Customer(
                name: widget.deliveryName,
                email: widget.deliveryEmail,
                address: widget.deliveryAddress,
              );
              final invoiceInfo = InvoiceInfo(
                description: 'Order Invoice',
                date: DateTime.now(),
                dueDate: DateTime.now().add(Duration(days: 7)),
              );
              // final supplier = Supplier(
              //   name: 'Foodie-Food Order',
              //   address: '',
              //   paymentInfo: 'Cash On Delivery',
              // );

              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          'Law App',
                          style: TextStyle(
                            fontFamily: 'Lobster',
                            fontSize: 40,
                            fontWeight: FontWeight.w400,
                            height: 1,
                            color: Color(0xFF6A6A6A),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      buildInfoCard(invoiceInfo),
                      SizedBox(height: 10),
                      buildItemsTable(items),
                      SizedBox(height: 10),
                      buildTotal(items),
                      SizedBox(height: 10),
                      buildContactInfo(customer),
                      SizedBox(height: 10),
                      buildDownloadButton(context, customer, items),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildInfoCard(InvoiceInfo invoiceInfo) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.description, color: Colors.blue),
              ],
            ),
            SizedBox(height: 10),
            Text('Invoice Number: $invoiceNumber'),
            Text('Invoice Date: ${Utils.formatDate(invoiceInfo.date)}'),
            Text('Due Date: ${Utils.formatDate(invoiceInfo.dueDate)}'),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildItemsTable(List<InvoiceItem> items) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.health_and_safety, color: Colors.green),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Unit Price')),
                  DataColumn(label: Text('Total')),
                ],
                rows: items
                    .map((item) => DataRow(
                          cells: [
                            DataCell(Text(item.description)),
                            DataCell(Text(item.quantity.toString())),
                            DataCell(Text(Utils.formatPrice(item.unitPrice))),
                            DataCell(Text(Utils.formatPrice(item.unitPrice *
                                item.quantity *
                                (1 + item.vat)))),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTotal(List<InvoiceItem> items) {
    double netTotal = 0;
    double vatTotal = 0;

    items.forEach((item) {
      netTotal += item.unitPrice * item.quantity;
      vatTotal += item.unitPrice * item.quantity * item.vat;
    });

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.monetization_on, color: Colors.orange),
              ],
            ),
            SizedBox(height: 10),
            Text('Net Total: ${Utils.formatPrice(netTotal)}'),
            Divider(),
            Text(
              'Total Amount Due: ${Utils.formatPrice(netTotal + vatTotal)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContactInfo(Customer customer) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customer Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.contact_mail, color: Colors.red),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text('Customer Name: ${customer.name}'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text('Customer Email: ${customer.email}'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text('Customer Address: ${customer.address}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDownloadButton(
      BuildContext context, Customer customer, List<InvoiceItem> items) {
    return ElevatedButton.icon(
      onPressed: () async {
        final pdf = await generatePdf(customer, items);
        await Printing.sharePdf(
          bytes: pdf,
          filename: 'invoice-${customer.name}.pdf',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading receipt...')),
        );
      },
      icon: const Icon(Icons.download_rounded),
      label: const Text('Download Receipt'),
    );
  }

  Future<Uint8List> generatePdf(
      Customer customer, List<InvoiceItem> items) async {
    final pdf = pw.Document();

    final netTotal = items.fold(
        0.0, (double sum, item) => sum + item.unitPrice * item.quantity);
    final vatTotal = items.fold(0.0,
        (double sum, item) => sum + item.unitPrice * item.quantity * item.vat);

    // Load font
    final fontData =
        await rootBundle.load('assets/fonts/roboto/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              margin: const pw.EdgeInsets.all(16),
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Law App',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 40,
                      color: const PdfColor.fromInt(0xFF6A6A6A),
                      fontStyle: pw.FontStyle.italic, // Italic style
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Invoice Information',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text('Invoice Number: $invoiceNumber,'),
                        pw.Text(
                            'Invoice Date: ${Utils.formatDate(invoiceInfo.date)}'),
                        pw.Text(
                            'Due Date: ${Utils.formatDate(invoiceInfo.dueDate)}'),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Description: ${invoiceInfo.description}',
                          style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Items',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Table.fromTextArray(
                          headers: [
                            'Description',
                            'Quantity',
                            'Unit Price',
                            'Total'
                          ],
                          data: items.map((item) {
                            final total =
                                item.unitPrice * item.quantity * (1 + item.vat);
                            return [
                              item.description,
                              item.quantity.toString(),
                              Utils.formatPrice(item.unitPrice),
                              Utils.formatPrice(total),
                            ];
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Amount',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text('Net Total: ${Utils.formatPrice(netTotal)}'),
                        pw.Divider(),
                        pw.Text(
                          'Total Amount Due: ${Utils.formatPrice(netTotal + vatTotal)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Customer Information',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text('Customer Name: ${customer.name}'),
                        pw.Text('Customer Email: ${customer.email}'),
                        pw.Text('Customer Address: ${customer.address}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}

class Utils {
  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  static String formatPrice(double price) {
    final NumberFormat formatter = NumberFormat.currency(symbol: '\$');
    return formatter.format(price);
  }
}

class Customer {
  final String name;
  final String email;
  final String address;

  Customer({
    required this.name,
    required this.email,
    required this.address,
  });
}

class InvoiceInfo {
  final String description;
  final DateTime date;
  final DateTime dueDate;

  InvoiceInfo({
    required this.description,
    required this.date,
    required this.dueDate,
  });

  String getInvoiceNumber() {
    return 'INV-${DateTime.now().millisecondsSinceEpoch}';
  }
}

class InvoiceItem {
  final String description;
  final DateTime date;
  final int quantity;
  final double vat;
  final double unitPrice;
  final String imageUrl;

  InvoiceItem({
    required this.description,
    required this.date,
    required this.quantity,
    required this.vat,
    required this.unitPrice,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'vat': vat,
      'unitPrice': unitPrice,
      'imageUrl': imageUrl,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'],
      date: DateTime.parse(json['date']),
      quantity: json['quantity'],
      vat: json['vat'],
      unitPrice: json['unitPrice'],
      imageUrl: json['imageUrl'],
    );
  }

  factory InvoiceItem.fromString(String data) {
    final parts = data.split('#');
    return InvoiceItem(
      description: parts[0],
      date: DateTime.now(), // Update as needed to parse date correctly
      quantity: int.parse(parts[3]),
      vat: 0.15, // Default VAT rate, update as needed
      unitPrice: double.parse(parts[1]),
      imageUrl: parts[2],
    );
  }
}

class Supplier {
  final String name;
  final String address;
  final String paymentInfo;

  Supplier({
    required this.name,
    required this.address,
    required this.paymentInfo,
  });
}
