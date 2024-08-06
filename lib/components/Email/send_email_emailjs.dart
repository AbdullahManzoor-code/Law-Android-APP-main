import 'package:emailjs/emailjs.dart' as emailjs;

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
    print('SUCCESS!');
    return true;
  } catch (error) {
    if (error is emailjs.EmailJSResponseStatus) {
      print('ERROR... ${error.status}: ${error.text}');
    } else {
      print(error.toString());
    }
    return false;
  }
}
