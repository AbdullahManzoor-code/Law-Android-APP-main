import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:law_app/Hire%20Services/form_page.dart';

class HireQuicklyPage extends StatefulWidget {
  // ignore: use_super_parameters
  const HireQuicklyPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HireQuicklyPageState createState() => _HireQuicklyPageState();
}

class _HireQuicklyPageState extends State<HireQuicklyPage> {
  // ignore: unused_field
  int _current = 0;
  dynamic _selectedIndex = {};

  final CarouselController _carouselController = CarouselController();

  final List _products = [
    {
      'Type': 'BASIC',
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
      'Type': 'STANDARD',
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
      'Type': 'PERMIUM',
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
        // title: const Text(
        //   'Hire Quickly',
        //   style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        // ),
      ),
      body: SizedBox(
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
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color.fromARGB(255, 153, 206, 215),
                              Color.fromARGB(255, 46, 188, 213),
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
                                    item['Type'],
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Center(
                                      child: Text(
                                        item['description'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(
                            //   height: 20,
                            // ),
                            Center(
                              child: Container(
                                height: 50,
                                width: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    shape: BoxShape.rectangle,
                                    color:
                                        const Color.fromARGB(255, 4, 103, 122)),
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FormPage(
                                            selectedCategory: item['Type'],
                                            selectedCategoryOption:
                                                item['title'],
                                            selectedCategorySubOption:
                                                item['subTitle'],
                                            selectedCategorySubOptionName:
                                                item['option'],
                                            price: double.parse(item['price']),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Purchase Now",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                            )
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
