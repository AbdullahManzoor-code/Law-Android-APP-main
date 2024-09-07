import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model for the location details
class LocationDetails {
  final String ipAddress;
  final String country;
  final String language;
  final String currency;

  LocationDetails({
    required this.ipAddress,
    required this.country,
    required this.language,
    required this.currency,
  });
}

// Notifier class to handle the state
class LocationNotifier extends StateNotifier<LocationDetails?> {
  LocationNotifier() : super(null) {
    fetchIpAndLocation();
  }

  Future<void> fetchIpAndLocation() async {
    try {
      // Step 1: Get the IP address
      // String? ipAddress = await _getIpAddress();
      // if (ipAddress != null) {
        // Step 2: Get the location details
        Map<String, dynamic>? locationDetails = await _getLocationDetails();
        if (locationDetails != null) {
          String country = locationDetails['country_name'] ?? 'Unknown';
          String language = locationDetails['languages'] ?? 'Unknown';
          String currency = locationDetails['currency'] ?? 'Unknown';

          // Update the state with the fetched details
          state = LocationDetails(
            ipAddress: "154.192.132.37",
            country: country,
            language: language,
            currency: currency,
          );
        
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String?> _getIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print('Failed to get IP address: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getLocationDetails() async {
    String ipAddress="154.192.132.37";
    final url = 'https://ipapi.co/$ipAddress/json/';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching location details: $e');
    }
    return null;
  }
}

// Riverpod provider for the notifier
final locationProvider = StateNotifierProvider<LocationNotifier, LocationDetails?>((ref) {
  return LocationNotifier();
});
