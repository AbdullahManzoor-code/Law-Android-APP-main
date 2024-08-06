import 'dart:convert';

import 'package:http/http.dart' as http;

Future sendEmail({
  required String name,
  required String email,
  required String subject,
  required String message,
  String? services,
}) async {
  final uri = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'service_id': 'service_y6ebq5q',
      'template_id': 'template_b0hrtsu',
      'user_id': 'alu2bqZ6Bpf9uxXpF',
      'template_params': {
        'user_name': name,
        'user_email': email,
        'user_subject': subject,
        'user_message': message,
        'service': services,
      },
    }),
  );

  print(response.body);
}
