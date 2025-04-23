import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  // Search for locations
  static Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search?format=json&q=$query'),
      headers: {'User-Agent': 'BookSwap App'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => {
        'name': item['display_name'],
        'latitude': double.parse(item['lat']),
        'longitude': double.parse(item['lon']),
      }).toList();
    } else {
      throw Exception('Failed to load locations');
    }
  }

  // Get location details
  static Future<Map<String, dynamic>> getLocationDetails(LatLng location) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}'),
      headers: {'User-Agent': 'BookSwap App'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'name': data['display_name'],
        'address': data['address'],
      };
    } else {
      throw Exception('Failed to load location details');
    }
  }

  // Get nearby book locations (example implementation)
  static Future<List<LatLng>> getNearbyBookLocations(LatLng center, double radiusInKm) async {
    // This is a placeholder. You would typically get this data from your backend
    // For now, we'll return some dummy data
    return [
      LatLng(center.latitude + 0.01, center.longitude + 0.01),
      LatLng(center.latitude - 0.01, center.longitude - 0.01),
    ];
  }
} 