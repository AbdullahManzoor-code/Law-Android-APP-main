import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:law_app/auth/login_page.dart'; // Ensure this is imported or your custom `showToast` function

Future<void> sendEmail({
  required String name,
  required String email,
  required String subject,
  required String message,
  String? services,
}) async {
  final uri = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  try {
    final response = await http.post(
      uri,
      headers: {
        'origin': 'http:localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': 'service_x8maq5z',
        'template_id': 'template_b0hrtsu',
        'user_id': 'ehGeqJsWXVaiLJPjS',
        'template_params': {
          'user_name': name,
          'user_email': email,
          'user_subject': subject,
          'user_message': message,
          'service': services,
        },
      }),
    );

    if (response.statusCode == 200) {
      // Email sent successfully
      print(response.body);
      showToast(message: "Email sent successfully!");
    } else {
      // Email sending failed, handle specific status codes
      String errorMessage = 'Failed to send email. Please try again.';
      if (response.statusCode == 400) {
        errorMessage = 'Bad request. Please check your input.';
      } else if (response.statusCode == 401) {
        errorMessage = 'Unauthorized. Please check your credentials.';
      } else if (response.statusCode == 403) {
        errorMessage =
            'Forbidden. You do not have permission to send this email.';
      } else if (response.statusCode == 500) {
        errorMessage = 'Server error. Please try again later.';
      }
      showToast(message: errorMessage);
    }
  } catch (error) {
    // Handle network and other unexpected errors
    String errorMessage = 'An unexpected error occurred.';
    if (error is http.ClientException) {
      errorMessage = 'Network error. Please check your connection.';
    } else if (error is FormatException) {
      errorMessage = 'Formatting error. Please check the data.';
    } else {
      errorMessage = error.toString();
    }
    showToast(message: errorMessage);
  }
}
