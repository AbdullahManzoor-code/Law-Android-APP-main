// Client ID
// Your app's unique identifier that's used to initiate OAuth.

// Voml9Z2NIRZ7Hl8fiNWMxs8HED71XbBGr2U9a7f556g

// Client secret
// 9sUfrEvMP34Qye8e3irOvY3j7m86NoePYW5U5Sl5HXo
// Webhook signing key

// eb7jKP75qEBT2xzDWn4oIEdXOlpHOe6I6w2BbNX6SHM

// Redirect URI

// https://localhost:300/auth

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ScheduleMeeting extends StatelessWidget {
  const ScheduleMeeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Background color for a clean look
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4), // Shadow position
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  // Background image
                  Image.asset(
                    'assets/images/Google_Meetup.png', // Replace with your image URL
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3), // Dark overlay
                    colorBlendMode: BlendMode.darken,
                  ),
                  // Content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Schedule Your Meeting',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              await launchUrlString(
                                  "https://zcal.co/i/7HMuXETO");
                            },
                            child: const Text(
                              "Schedule Meeting",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:googleapis/calendar/v3.dart' as calendar;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
// import 'package:uuid/uuid.dart';

// // Initialize Google Sign-In
// final GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: [calendar.CalendarApi.calendarScope],
// );

// // Sign-in function
// Future<GoogleSignInAccount?> signInWithGoogle() async {
//   try {
//     return await _googleSignIn.signIn();
//   } catch (error) {
//     print('Google Sign-In error: $error');
//     return null;
//   }
// }

// // Create a Google Meet event
// Future<void> createGoogleMeetEvent() async {
//   try {
//     final user = _googleSignIn.currentUser;
//     if (user == null) {
//       print('User is not signed in.');
//       return;
//     }

//     final authHeaders = await user.authHeaders;
//     final client = GoogleHttpClient(authHeaders);
//     final calendarApi = calendar.CalendarApi(client);

//     final uuid = Uuid();
//     String requestId = uuid.v4(); // Generate a unique request ID

//     final event = calendar.Event(
//       summary: 'Meeting with Expert',
//       description: 'Discussing project details.',
//       start: calendar.EventDateTime(
//         dateTime: DateTime.now().add(Duration(days: 1)),
//         timeZone: 'America/Los_Angeles',
//       ),
//       end: calendar.EventDateTime(
//         dateTime: DateTime.now().add(Duration(days: 1, hours: 1)),
//         timeZone: 'America/Los_Angeles',
//       ),
//       conferenceData: calendar.ConferenceData(
//         createRequest: calendar.CreateConferenceRequest(
//           requestId: requestId, // Use the generated unique request ID
//         ),
//       ),
//     );

//     final createdEvent = await calendarApi.events.insert(
//       event,
//       'primary',
//       conferenceDataVersion: 1,
//     );

//     print('Event created: ${createdEvent.htmlLink}');
//     print(
//         'Google Meet link: ${createdEvent.conferenceData?.entryPoints?.first.uri}');
//   } catch (error) {
//     print('Error creating event: $error');
//   }
// }

// // Custom HTTP client to handle Google API requests
// class GoogleHttpClient extends http.BaseClient {
//   final Map<String, String> headers;
//   final http.Client _inner = http.Client();

//   GoogleHttpClient(this.headers);

//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     return _inner.send(request..headers.addAll(headers));
//   }
// }

// // UI for scheduling a meeting
// class ScheduleMeeting extends StatelessWidget {
//   const ScheduleMeeting({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: () async {
//           final user = await signInWithGoogle();
//           if (user != null) {
//             await createGoogleMeetEvent();
//           }
//         },
//         child: Text("Schedule Meeting"),
//       ),
//     );
//   }
// }
