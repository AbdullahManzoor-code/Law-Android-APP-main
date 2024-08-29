import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:riverpod/riverpod.dart';
import 'package:law_app/Google%20meetup/google_meetup.dart';
import 'package:law_app/Hire%20Quickly/hire_quickly.dart';
import 'package:law_app/Hire%20Services/hire_services.dart';
import 'package:law_app/Orders/user_orders_page.dart';
import 'package:law_app/auth/auth_page.dart';
import 'package:law_app/text_editor/text%20_editor.dart';

import '../profille/profile.dart';
 // ignore: non_constant_identifier_names
 final CurrentUSrProvider = Provider((ref) {
  final 
  
 user = FirebaseAuth.instance.currentUser;
  return user ;
 });
class HomePage extends StatefulWidget {
  // ignore: use_super_parameters
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();
  late String title;

  static late Widget selectedWidget;
  // HomePageState() : selectedWidget = _AuthorList(); // Initialize with the widget

  late AnimationController _controller;

  String selectedMenuItem = '';

  // sign user out method
  void signUserOut()async  {
    await FirebaseAuth.instance.signOut();
    await Navigator.push(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AuthPage()));
     
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
                onPressed: () async {
 signUserOut();                },
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
    selectedWidget = const HireServices();
    selectedMenuItem = title;
    // title = "Text Editor";
    // selectedWidget = ScheduleMeeting();
    // selectedMenuItem = title;

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
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Scaffold(
          body: SliderDrawer(
            appBar: SliderAppBar(
              appBarHeight: 60,
              isTitleCenter: true,
              appBarColor: Colors.white,
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            key: _sliderDrawerKey,
            sliderOpenSize: 179,
            slider: _SliderView(
              title:title,
              selectedWidget: selectedWidget,
              selectedMenuItem: selectedMenuItem,
              onItemClick: (title) {
                _sliderDrawerKey.currentState!.closeSlider();
                setState(() {
                  this.title = title;
                  selectedMenuItem = title;
                });

                switch (title) {

                  
                  case 'Hire Services':
                    selectedWidget = const HireServices();
                    break;
                  case 'Hire Quickly':
                    selectedWidget = const HireQuicklyPage();
                    break;
                  case 'Orders':
                    selectedWidget = const OrderPage();
                    break;
                  case 'Google Meetup':
                    selectedWidget = const ScheduleMeeting();
                    break;
                  case 'Text Editor':
                    selectedWidget = const TextEditorScreen();
                    break;
                  case 'Profile':
                    selectedWidget = const ProfileView();
                    break;
                  case 'LogOut':
                    logoutDialog(context);
                    break;
                }
              },
            ),
            // child: _AuthorList(),
            child: selectedWidget,
          ),
        ),
      ),
    );
  }
}

class _SliderView extends StatefulWidget {
  final Function(String)? onItemClick;
  final String selectedMenuItem;
     Widget      selectedWidget ;
   String title;


  _SliderView( {Key? key, this.onItemClick, required this.selectedMenuItem,required this.selectedWidget,required this.title})
      : super(key: key);

  @override
  State<_SliderView> createState() => _SliderViewState();
}



class _SliderViewState extends State<_SliderView> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 30),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String? profilePhotoUrl = userData['profilepic'];
          String? displayName = userData['name'] ?? 'user';

          return ListView(
            children: [
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  if (widget.onItemClick != null) {
                    widget.onItemClick!('Profile');
                  }
                },
                child:  CircleAvatar(
  backgroundColor: Colors.grey,
  radius: 65,
  child: CircleAvatar(
    radius: 60,
    backgroundImage:profilePhotoUrl != null 
            ? NetworkImage(profilePhotoUrl) 
            :   user != null && user!.photoURL != null 
        ? NetworkImage(user!.photoURL!) 
        :  null,
    child: profilePhotoUrl == null && (user == null || user!.photoURL == null)
        ? const Icon(Icons.person, size: 60, color: Colors.white)
        : null,
  ),
)

              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  if (widget.onItemClick != null) {
                    widget.onItemClick!('Profile');
                  }
                },
                child: Text(
                  displayName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ...[
                Menu(Icons.work, 'Hire Services'),
                Menu(Icons.flash_on, 'Hire Quickly'),
                Menu(Icons.receipt, 'Orders'),
                Menu(Icons.meeting_room, 'Google Meetup'),
                Menu(Icons.edit, 'Text Editor'),
                Menu(Icons.person, 'Profile'),
                Menu(Icons.logout, 'LogOut')
              ]
                  .map(
                    (menu) => _SliderMenuItem(
                      title: menu.title,
                      iconData: menu.iconData,
                      onTap: widget.onItemClick,
                      selected: widget.selectedMenuItem == menu.title,
                    ),
                  )
                  .toList(),
            ],
          );
        },
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
