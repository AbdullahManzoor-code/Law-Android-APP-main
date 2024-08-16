import 'dart:convert';
import 'dart:io';
import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:law_app/components/toaster.dart'; // Import the Fluttertoast package or your custom `showToast` function

const String serviceId = 'service_x8maq5z';
const String templateId = 'template_b0hrtsu';
const String publicApiKey = 'ehGeqJsWXVaiLJPjS';
const String privateKey = 'zAkBrMt8flDzxOa-eH-U1';
const String customertemplateId = 'template_fonpd1m';

Future<bool> sendEmailUsingEmailjs({
  required String name,
  required String email,
  required String subject,
  required String message,
  String? services,
  required bool isadmin,
  File? pdfAttachment, // New parameter for the PDF attachment
}) async {
  try {
    // Convert the PDF file to a base64 string if an attachment is provided
    String? base64Pdf;
    String? fileName;
    if (pdfAttachment != null) {
      List<int> fileBytes = pdfAttachment.readAsBytesSync();
      base64Pdf = base64Encode(fileBytes);
      fileName = pdfAttachment.path.split('/').last;
    }

    final templateParams = {
      'user_name': name,
      'user_email': email,
      'user_subject': subject,
      'user_message': message,
      'service': services ?? '',
      'attachment': base64Pdf != null
          ? 'data:application/pdf;base64,$base64Pdf'
          : '', // Include the PDF attachment if available
      'file_name': fileName ?? '', // Include the file name if available
    };

    await emailjs.send(
      serviceId,
      isadmin ? templateId : customertemplateId,
      templateParams,
      const emailjs.Options(publicKey: publicApiKey, privateKey: privateKey),
    );

    // Show success toast message
    showToast(
      message: isadmin
          ? "Email sent successfully to the lawyer!"
          : "Email sent successfully to your Email ${email}",
    );
    return true;
  } catch (error) {
    // Improved error handling
    if (error is emailjs.EmailJSResponseStatus) {
      showToast(
        message: isadmin
            ? 'Failed to send email to lawyer: ${error.text}'
            : 'Failed to send email to your Email Address: ${email}',
      );
    } else {
      showToast(message: 'Unexpected error occurred: ${error.toString()}');
    }
    return false;
  }
}
