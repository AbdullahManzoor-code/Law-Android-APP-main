import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
       import 'package:http/http.dart' as http;

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(FirebaseAuth.instance.currentUser);

Future<String?> getIpAddress() async {
  try {
    final response = await http.get(Uri.parse('https://api.ipify.org'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  } catch (e) {
    print('Failed to get IP address: $e');
    return null;
  }
}

  void updateUser(User? user) {
    state = user;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

 class Notifier extends ChangeNotifier {

  late final String ipadress;

 
Future<String?> getIpAddress() async {
  try {
    final response = await http.get(Uri.parse('https://api.ipify.org'));
    if (response.statusCode == 200) {
      print(response.body);
      return response.body;
    } else {
      return null;
    }
  } catch (e) {
    print('Failed to get IP address: $e');
    return null;
  }
}
  
}



