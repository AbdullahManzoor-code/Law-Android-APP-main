import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:law_app/auth/login_page.dart'; // Import the Fluttertoast package or your custom `showToast` function

const String serviceId = 'service_xdpqrnk';
const String templateId = 'template_b0hrtsu';
const String publicApiKey = 'alu2bqZ6Bpf9uxXpF';
const String privateKey = 'DWUehV6BSHbJdpYqVbXve';

Future<bool> sendEmailUsingEmailjs({
  required String name,
  required String email,
  required String subject,
  required String message,
  String? services,
}) async {
  try {
    final templateParams = {
      'user_name': name,
      'user_email': email,
      'user_subject': subject,
      'user_message': message,
      'service': services ?? '',
    };

    print('Sending email with params: $templateParams');

    await emailjs.send(
      serviceId,
      templateId,
      templateParams,
      const emailjs.Options(publicKey: publicApiKey, privateKey: privateKey),
    );

    // Show success toast message
    showToast(message: "Email sent successfully!");
    return true;
  } catch (error) {
    // Improved error handling
    if (error is emailjs.EmailJSResponseStatus) {
      print('EmailJS Error: ${error.status} - ${error.text}');
      showToast(message: 'Failed to send email: ${error.text}');
    } else {
      print('Unexpected Error: ${error.toString()}');
      showToast(message: 'Unexpected error occurred: ${error.toString()}');
    }
    return false;
  }
}
