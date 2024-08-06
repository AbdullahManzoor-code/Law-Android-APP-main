import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:law_app/Hire%20Quickly/hire_quickly.dart';
import 'package:law_app/Hire%20Services/hire_services.dart';
import 'package:law_app/Orders/user_orders_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();
  late String title;

  late Widget _selectedWidget;
  // HomePageState() : _selectedWidget = _AuthorList(); // Initialize with the widget

  late AnimationController _controller;

  String selectedMenuItem = '';

  // sign user out method
  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void logoutDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  signUserOut();
                  Navigator.of(context).pop();
                },
                child: const Text("Logout"),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    title = "Hire Services";
    _selectedWidget = const HireServices();
    selectedMenuItem = title;

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // Dispose of the AnimationController to avoid the error
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SliderDrawer(
        appBar: const SliderAppBar(
          appBarColor: Colors.white,
          title: Text(
            '',
            style: TextStyle(
              // fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        key: _sliderDrawerKey,
        sliderOpenSize: 179,
        slider: _SliderView(
          selectedMenuItem: selectedMenuItem,
          onItemClick: (title) {
            _sliderDrawerKey.currentState!.closeSlider();
            setState(() {
              this.title = title;
              selectedMenuItem = title;
            });

            switch (title) {
              case 'Hire Services':
                _selectedWidget = const HireServices();
                break;
              case 'Hire Quickly':
                _selectedWidget = const HireQuicklyPage();
                break;
              case 'Orders':
                _selectedWidget = const OrderPage();
                break;
              case 'ChatBot':
                _selectedWidget = Center(
                  child: Text(title),
                );
                break;
              case 'Text Editor':
                _selectedWidget = Center(
                  child: Text(title),
                );
                break;
              case 'Profile':
                _selectedWidget = Center(
                  child: Text(title),
                );
                break;
              case 'LogOut':
                logoutDialog(context);
                break;
            }
          },
        ),
        // child: _AuthorList(),
        child: _selectedWidget,
      ),
    );
  }
}

class _SliderView extends StatelessWidget {
  final Function(String)? onItemClick;
  final String selectedMenuItem;

  final User? user = FirebaseAuth.instance.currentUser!;

  _SliderView({Key? key, this.onItemClick, required this.selectedMenuItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 30),
      child: ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
          CircleAvatar(
            radius: 65,
            backgroundColor: Colors.grey,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: Image.network(
                      user?.photoURL ?? 'https://github.com/codexharoon.png')
                  .image,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            user?.displayName ?? 'user',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ...[
            Menu(Icons.work, 'Hire Services'),
            Menu(Icons.flash_on, 'Hire Quickly'),
            Menu(Icons.receipt, 'Orders'),
            // Menu(Icons.chat_bubble, 'Chatbot'),
            Menu(Icons.forum, 'ChatBot'),
            Menu(Icons.edit, 'Text Editor'),
            // Menu(Icons.add_circle, 'Add Post'),
            // Menu(Icons.notifications_active, 'Notification'),
            // Menu(Icons.favorite, 'Likes'),
            Menu(Icons.person, 'Profile'),
            // Menu(Icons.settings, 'Settings'),
            Menu(Icons.logout, 'LogOut')
          ]
              .map(
                (menu) => _SliderMenuItem(
                  title: menu.title,
                  iconData: menu.iconData,
                  onTap: onItemClick,
                  selected: selectedMenuItem == menu.title,
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _SliderMenuItem extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Function(String)? onTap;
  final bool selected;

  const _SliderMenuItem({
    Key? key,
    required this.title,
    required this.iconData,
    required this.onTap,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected ? Colors.grey[300] : Colors.transparent,
      child: ListTile(
          title: Text(title,
              style: const TextStyle(
                  color: Colors.black, fontFamily: 'BalsamiqSans_Regular')),
          leading: Icon(iconData, color: Colors.black),
          onTap: () => onTap?.call(title)),
    );
  }
}

class _AuthorList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Quotes> quotesList = [];
    quotesList.add(Quotes(Colors.amber, 'Amelia Brown',
        'Life would be a great deal easier if dead things had the decency to remain dead.'));
    quotesList.add(Quotes(Colors.orange, 'Olivia Smith',
        'That proves you are unusual," returned the Scarecrow'));
    quotesList.add(Quotes(Colors.deepOrange, 'Sophia Jones',
        'Her name badge read: Hello! My name is DIE, DEMIGOD SCUM!'));
    quotesList.add(Quotes(Colors.red, 'Isabella Johnson',
        'I am about as intimidating as a butterfly.'));
    quotesList.add(Quotes(Colors.purple, 'Emily Taylor',
        'Never ask an elf for help; they might decide your better off dead, eh?'));
    quotesList
        .add(Quotes(Colors.green, 'Maya Thomas', 'Act first, explain later'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemBuilder: (builder, index) {
            return LimitedBox(
              maxHeight: 150,
              child: Container(
                decoration: BoxDecoration(
                    color: quotesList[index].color,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    )),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        quotesList[index].author,
                        style: const TextStyle(
                            fontFamily: 'BalsamiqSans_Blod',
                            fontSize: 30,
                            color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        quotesList[index].quote,
                        style: const TextStyle(
                            fontFamily: 'BalsamiqSans_Regular',
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (builder, index) {
            return const Divider(
              height: 10,
              thickness: 0,
            );
          },
          itemCount: quotesList.length),
    );
  }
}

class Quotes {
  final MaterialColor color;
  final String author;
  final String quote;

  Quotes(this.color, this.author, this.quote);
}

class Menu {
  final IconData iconData;
  final String title;

  Menu(this.iconData, this.title);
}
