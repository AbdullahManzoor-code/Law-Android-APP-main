import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:law_app/Hire%20Services/form_page.dart';

class HireQuicklyPage extends StatefulWidget {
  const HireQuicklyPage({Key? key}) : super(key: key);

  @override
  _HireQuicklyPageState createState() => _HireQuicklyPageState();
}

class _HireQuicklyPageState extends State<HireQuicklyPage> {
  int _current = 0;
  dynamic _selectedIndex = {};

  final CarouselController _carouselController = CarouselController();

  final List _products = [
    {
      'heading': 'Consumer Contracts',
      'title': 'Travel',
      'subTitle': 'Air Plane',
      'option': 'Delay',
      'price': '100',
      'description':
          'Compensation for flight delays, including reimbursement for expenses incurred due to the delay.',
      'color': const Color.fromRGBO(0, 204, 204, 1.0),
    },
    {
      'heading': 'Consumer Contracts',
      'title': 'Hotel',
      'subTitle': 'Reservation',
      'option': 'Cancelled',
      'price': '200',
      'description':
          'Coverage for hotel reservation cancellations, including refunds and compensation for inconvenience.',
      'color': const Color.fromRGBO(159, 129, 247, 1.0),
    },
    {
      'heading': 'Administrative',
      'title': 'Immigration',
      'subTitle': 'Residence Foreigners',
      'option': 'Inadequate compensation',
      'price': '300',
      'description':
          'Legal assistance for inadequate compensation claims related to residence permits for foreigners.',
      'color': const Color.fromRGBO(249, 171, 0, 1.0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _selectedIndex.length > 0
          ? FloatingActionButton(
              backgroundColor: _selectedIndex['color'],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormPage(
                      selectedCategory: _selectedIndex['heading'],
                      selectedCategoryOption: _selectedIndex['title'],
                      selectedCategorySubOption: _selectedIndex['subTitle'],
                      selectedCategorySubOptionName: _selectedIndex['option'],
                      price: double.parse(_selectedIndex['price']),
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            )
          : null,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Hire Quickly',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
                height: 450.0,
                aspectRatio: 16 / 9,
                viewportFraction: 0.70,
                enlargeCenterPage: true,
                pageSnapping: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
            items: _products.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedIndex == item) {
                          _selectedIndex = {};
                        } else {
                          _selectedIndex = item;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          // color: item['color'],
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.orange[300]!,
                              Colors.red[400]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: _selectedIndex == item
                              ? Border.all(
                                  color: Colors.blue.shade500, width: 3)
                              : null,
                          boxShadow: _selectedIndex == item
                              ? [
                                  BoxShadow(
                                      color: Colors.blue.shade100,
                                      blurRadius: 30,
                                      offset: const Offset(0, 10))
                                ]
                              : [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 5))
                                ]),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 320,
                              margin: const EdgeInsets.only(top: 10),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    item['heading'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '${item['price']} \$',
                                    style: const TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(left: 12, right: 12),
                                    child: Divider(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        item['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        item['subTitle'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        item['option'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(left: 12, right: 12),
                                    child: Divider(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(
                            //   height: 20,
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: Text(
                                  item['description'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList()),
      ),
    );
  }
}
