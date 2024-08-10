import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:law_app/components/toaster.dart'; // Import the Fluttertoast package or your custom `showToast` function

const String serviceId = 'service_x8maq5z';
const String templateId = 'template_b0hrtsu';
const String publicApiKey = 'ehGeqJsWXVaiLJPjS';
const String privateKey = 'zAkBrMt8flDzxOa-eH-U1';

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
      showToast(message: 'Failed to send email: ${error.text}');
    } else {
      showToast(message: 'Unexpected error occurred: ${error.toString()}');
    }
    return false;
  }
}
