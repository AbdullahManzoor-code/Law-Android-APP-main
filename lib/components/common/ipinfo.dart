import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Map<String, dynamic>? ipData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchIpAndLocation();
  }

  Future<void> fetchIpAndLocation() async {
    try {
      // Fetch IP address
      final ipAddress = await _getIpAddress();
      if (ipAddress != null) {
        // Fetch location details using IP
        final locationDetails = await _getLocationDetails(ipAddress);
        setState(() {
          ipData = locationDetails;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch IP address';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<String?> _getIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'];
      }
    } catch (e) {
      print('Failed to get IP address: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getLocationDetails(String ipAddress) async {

    try {
      final response = await http.get(Uri.parse('https://ipapi.co/$ipAddress/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
    } catch (e) {
      print('Error fetching location details: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ipData != null
              ? ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text('IP: ${ipData!['ip']}'),
                    Text('City: ${ipData!['city']}'),
                    Text('Region: ${ipData!['region']}'),
                    Text('Country: ${ipData!['country_name']}'),
                    Text('Latitude: ${ipData!['latitude']}'),
                    Text('Longitude: ${ipData!['longitude']}'),
                    Text('Timezone: ${ipData!['timezone']}'),
                    Text('Country Code: ${ipData!['country_code']}'),
                    Text('Country Population: ${ipData!['country_population']}'),
                    Text('Currency: ${ipData!['currency']}'),
                    Text('Languages: ${ipData!['languages']}'),
                    // Add more fields as needed
                  ],
                )
              : Center(child: Text(errorMessage)),
    );
  }
}
