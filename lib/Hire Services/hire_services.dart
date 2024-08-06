import 'package:flutter/material.dart';
import 'package:law_app/Hire%20Services/form_page.dart';
import 'package:law_app/Hire%20Services/sub_options_details.dart';
import 'package:collection/collection.dart';
import 'package:accordion/accordion.dart';
import 'package:custom_accordion/custom_accordion.dart';

class HireServices extends StatefulWidget {
  static const headerStyle = TextStyle(
      color: Color(0xffffffff), fontSize: 18, fontWeight: FontWeight.bold);
  static const contentStyleHeader = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.w700);
  static const contentStyle = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.normal);
  static const loremIpsum =
      '''Lorem ipsum is typically a corrupted version of 'De finibus bonorum et malorum', a 1st century BC text by the Roman statesman and philosopher Cicero, with words altered, added, and removed to make it nonsensical and improper Latin.''';
  static const slogan =
      'Do not forget to play around with all sorts of colors, backgrounds, borders, etc.';

  const HireServices({super.key});

  @override
  State<HireServices> createState() => _HireServicesState();
}

class _HireServicesState extends State<HireServices> {
  String selectedCategory = "Consumer Contracts";
  String? selectedSubOption;

  final List<Category> categories = [
    Category(
      backgroundColor: const Color.fromRGBO(159, 129, 247, 0.15),
      labelColor: const Color.fromRGBO(159, 129, 247, 1.0),
      icon: Icons.category,
      title: 'Consumer Contracts',
      subOptions: [
        Option(
          title: 'Travel',
          subOptions: [
            AnotherOption(title: 'Air Plane', subOptions: [
              'Delay',
              'Cancelled',
              'Baggage Handling',
              'OverBooking',
            ]),
            AnotherOption(
              title: 'Train',
              subOptions: [
                'Delay',
                'Cancelled',
                'Baggage Handling',
              ],
            ),
          ],
        ),
        Option(
          title: 'Hotel',
          subOptions: [
            AnotherOption(title: 'Reservation', subOptions: [
              'Delay',
              'Cancelled',
              'Baggage Handling',
              'OverBooking',
            ]),
            AnotherOption(
              title: 'Complaint',
              subOptions: [
                'Delay',
                'Cancelled',
                'Baggage Handling',
              ],
            ),
          ],
        ),
        Option(
          title: 'Insurance',
          subOptions: [
            AnotherOption(title: 'Car Insurance', subOptions: [
              'Delay',
              'Cancelled',
              'Baggage Handling',
              'OverBooking',
            ]),
            AnotherOption(
              title: 'Home Insurance',
              subOptions: [
                'Delay',
                'Cancelled',
                'Baggage Handling',
              ],
            ),
          ],
        ),
        Option(
          title: 'Telecommunication',
          subOptions: [
            AnotherOption(title: 'Contract', subOptions: [
              'Restraction',
              'Matter 2',
              'Matter 3',
              'Matter 4',
            ]),
            AnotherOption(
              title: 'Complaints',
              subOptions: [
                'Delay',
                'Cancelled',
                'Baggage Handling',
              ],
            ),
          ],
        ),
        // 'Purchase Contracts',
        // 'Appointment Cancellation',
      ],
    ),
    Category(
      backgroundColor: const Color.fromRGBO(25, 103, 210, 0.15),
      labelColor: const Color.fromRGBO(25, 103, 210, 1.0),
      icon: Icons.computer,
      title: 'Administrative',
      subOptions: [
        Option(
          title: 'Immigration',
          subOptions: [
            AnotherOption(title: 'Residence Foreigners', subOptions: [
              'Inadequate compensation',
              'Hidden fees and charges',
              'Booking and reservation issues',
              // 'Matter 4',
            ]),
            AnotherOption(
              title: 'Nationality',
              subOptions: [
                // 'Implementation',
                'Customer service',
                'Cancelled',
                'Baggage Handling',
              ],
            ),
            AnotherOption(
              title: 'Marriage issues',
              subOptions: [
                'Cancelled',
                'Booking and reservation issues',
                // 'Cancelled',
                // 'Baggage Handling',
              ],
            ),
          ],
        ),
        Option(
          title: 'Traffic issues',
          subOptions: [
            AnotherOption(title: 'Parking tickets', subOptions: [
              'Inadequate compensation',
              'Hidden fees and charges',
              'Booking and reservation issues',
              // 'Matter 4',
            ]),
            AnotherOption(
              title: 'Traffic violations penalties',
              subOptions: [
                // 'Implementation',
                'Billing errors',
                'Security concerns',
                'Disturbances',
              ],
            ),
          ],
        ),
      ],
    ),
    // Category(
    //   backgroundColor: const Color.fromRGBO(255, 0, 0, 0.15),
    //   labelColor: const Color.fromRGBO(255, 0, 0, 1.0),
    //   // backgroundColor: const Color.fromRGBO(159, 129, 247, 0.15),
    //   // labelColor: const Color.fromRGBO(159, 129, 247, 1.0),
    //   icon: Icons.record_voice_over,
    //   title: 'Testimony',
    //   subOptions: [
    //     Option(
    //       title: 'Entry',
    //       subOptions: [
    //         AnotherOption(title: 'Storage', subOptions: [
    //           'Data input',
    //         ]),
    //       ],
    //     ),
    //   ],
    // ),
    Category(
      backgroundColor: const Color.fromRGBO(255, 0, 0, 0.15),
      labelColor: const Color.fromRGBO(255, 0, 0, 1.0),
      icon: Icons.business,
      title: 'Contract archiving',
      subOptions: [
        Option(
          title: 'Data Archiving',
          subOptions: [
            AnotherOption(title: 'Deadlines', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
            AnotherOption(title: 'Copy export', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
            AnotherOption(title: 'Alerts', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
          ],
        ),
      ],
    ),
    Category(
      backgroundColor: const Color.fromRGBO(249, 171, 0, 0.15),
      labelColor: const Color.fromRGBO(249, 171, 0, 1.0),
      icon: Icons.credit_card,
      title: 'Credit Card',
      subOptions: [
        Option(
          title: 'Debits',
          subOptions: [
            AnotherOption(title: 'Contract copy', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Overcharging', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Abusive debits', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Irregular flow rates', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
          ],
        ),
        Option(
          title: 'Contract revocation',
          subOptions: [
            AnotherOption(title: 'Contract copy', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Overcharging', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Abusive debits', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Irregular flow rates', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
          ],
        ),
        Option(
          title: 'Contract cancellation',
          subOptions: [
            AnotherOption(title: 'Contract copy', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Overcharging', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Abusive debits', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Irregular flow rates', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
          ],
        ),
        Option(
          title: 'Contract resolution',
          subOptions: [
            AnotherOption(title: 'Contract copy', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Overcharging', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Abusive debits', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
            AnotherOption(title: 'Irregular flow rates', subOptions: [
              'Cancellation',
              'Billing errors',
              'Security concerns',
              'Hidden fees and charges',
            ]),
          ],
        ),
      ],
    ),
    Category(
      backgroundColor: const Color.fromRGBO(25, 103, 210, 0.15),
      labelColor: const Color.fromRGBO(25, 103, 210, 1.0),
      icon: Icons.verified_user,
      title: 'Waranties Claims',
      subOptions: [
        Option(
          title: 'Data Archiving',
          subOptions: [
            AnotherOption(title: 'Contract copy', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
            AnotherOption(title: 'Deadlines', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
            AnotherOption(title: 'Copy export', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
            AnotherOption(title: 'Alerts', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
          ],
        ),
      ],
    ),
    Category(
      backgroundColor: const Color.fromRGBO(159, 129, 247, 0.15),
      labelColor: const Color.fromRGBO(159, 129, 247, 1.0),
      icon: Icons.record_voice_over,
      title: 'Partner lawyers',
      subOptions: [
        Option(
          title: 'Specialties',
          subOptions: [
            AnotherOption(title: 'Contract copy', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
            AnotherOption(title: 'Deadlines', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
            AnotherOption(title: 'Copy export', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
            AnotherOption(title: 'Alerts', subOptions: [
              'Cancelled',
              'Delay',
              'Baggage Handling',
              'OverBooking Complaints',
              'Hidden fees and charges',
              'Booking and reservation issues',
              'Inadequate compensation',
            ]),
          ],
        ),
      ],
    ),
    // Category(
    //   backgroundColor: const Color.fromRGBO(52, 168, 83, 0.15),
    //   labelColor: const Color.fromRGBO(52, 168, 83, 1.0),
    //   icon: Icons.build,
    //   title: 'Engineering',
    //   subOptions: ['Construction Claims', 'Patent Disputes'],
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    final Category? category = categories.firstWhereOrNull(
      (cat) => cat.title == selectedCategory,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Select Category',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 159, 129, 247).withOpacity(1),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 5),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'swipe to see more ',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
              ),
              Icon(
                Icons.arrow_forward,
                size: 17,
                color: Colors.grey,
              )
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 150, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              bool isSelected = selectedCategory == cat.title;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = cat.title;
                    selectedSubOption =
                        null; // Reset selected sub-option when changing category
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: selectedCategory == cat.title ? 150 : 152,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: cat.backgroundColor,
                    border: Border.all(
                      width: 2,
                      color: selectedCategory == cat.title
                          ? cat.labelColor
                          : Colors.transparent,
                    ),
                  ),
                  child: Transform.scale(
                    scale: isSelected ? 1.1 : 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat.icon,
                          color: cat.labelColor,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: cat.labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (category != null && category.subOptions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: 25,
              left: 16,
              right: 16,
              bottom: 2,
            ),
            child: Text(
              'Select Sub-Option',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 159, 129, 247).withOpacity(1),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: category.subOptions.length,
              itemBuilder: (context, index) {
                final subOption = category.subOptions[index];
                return Container(
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 5, bottom: 5),
                  child: CustomAccordion(
                    title: subOption.title,
                    headerBackgroundColor: Colors.blue,
                    titleStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    toggleIconOpen: Icons.keyboard_arrow_down_sharp,
                    toggleIconClose: Icons.keyboard_arrow_up_sharp,
                    headerIconColor: Colors.white,
                    accordionElevation: 0,
                    widgetItems: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyNestedAccordion(
                          selectedCategory: selectedCategory,
                          selectedCategoryOption: subOption.title,
                          subOptions: subOption.subOptions,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class Category {
  final Color backgroundColor;
  final Color labelColor;
  final IconData icon;
  final String title;
  final List<Option> subOptions;

  Category({
    required this.backgroundColor,
    required this.labelColor,
    required this.icon,
    required this.title,
    required this.subOptions,
  });
}

class Option {
  final String title;
  final List<AnotherOption> subOptions;

  Option({
    required this.title,
    required this.subOptions,
  });
}

class AnotherOption {
  final String title;
  final List<String> subOptions;

  AnotherOption({
    required this.title,
    required this.subOptions,
  });
}

class MyNestedAccordion extends StatelessWidget //__
{
  final String selectedCategory;
  final String selectedCategoryOption;
  final List<AnotherOption> subOptions;
  const MyNestedAccordion(
      {super.key,
      required this.selectedCategory,
      required this.selectedCategoryOption,
      required this.subOptions});

  @override
  Widget build(context) //__
  {
    return Column(
      children: List.generate(subOptions.length, (index) {
        final sbOption = subOptions[index];
        return Accordion(
          paddingListTop: 0,
          paddingListBottom: 0,
          maxOpenSections: 1,
          headerBackgroundColorOpened: Colors.black54,
          headerPadding:
              const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
          children: [
            AccordionSection(
              isOpen: false,
              leftIcon: const Icon(Icons.insights_rounded, color: Colors.white),
              headerBackgroundColor: Colors.black38,
              headerBackgroundColorOpened: Colors.black54,
              header: Text(sbOption.title, style: HireServices.headerStyle),
              contentHorizontalPadding: 20,
              contentBorderColor: Colors.black54,
              content: Column(
                children: List.generate(
                  sbOption.subOptions.length,
                  (index) {
                    final opt = sbOption.subOptions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(opt),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormPage(
                                selectedCategory: selectedCategory,
                                selectedCategoryOption: selectedCategoryOption,
                                selectedCategorySubOption: sbOption.title,
                                selectedCategorySubOptionName: opt,
                                price: 50,
                                selectedCategorySubOptionAllName:
                                    sbOption.subOptions,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
