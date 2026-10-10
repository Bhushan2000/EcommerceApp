import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AddressLookupService {
  // Comprehensive mapping of lowercase city names to State / Province
  static final Map<String, String> _cityToState = {
    // US Major Cities
    'new york': 'NY',
    'nyc': 'NY',
    'brooklyn': 'NY',
    'queens': 'NY',
    'manhattan': 'NY',
    'los angeles': 'CA',
    'la': 'CA',
    'san francisco': 'CA',
    'sf': 'CA',
    'san diego': 'CA',
    'san jose': 'CA',
    'sacramento': 'CA',
    'fresno': 'CA',
    'oakland': 'CA',
    'chicago': 'IL',
    'springfield': 'IL',
    'houston': 'TX',
    'dallas': 'TX',
    'austin': 'TX',
    'san antonio': 'TX',
    'fort worth': 'TX',
    'el paso': 'TX',
    'phoenix': 'AZ',
    'tucson': 'AZ',
    'mesa': 'AZ',
    'philadelphia': 'PA',
    'pittsburgh': 'PA',
    'allentown': 'PA',
    'seattle': 'WA',
    'spokane': 'WA',
    'tacoma': 'WA',
    'denver': 'CO',
    'colorado springs': 'CO',
    'aurora': 'CO',
    'boston': 'MA',
    'worcester': 'MA',
    'cambridge': 'MA',
    'miami': 'FL',
    'orlando': 'FL',
    'tampa': 'FL',
    'jacksonville': 'FL',
    'tallahassee': 'FL',
    'atlanta': 'GA',
    'savannah': 'GA',
    'columbus ga': 'GA',
    'detroit': 'MI',
    'grand rapids': 'MI',
    'ann arbor': 'MI',
    'minneapolis': 'MN',
    'saint paul': 'MN',
    'st paul': 'MN',
    'las vegas': 'NV',
    'reno': 'NV',
    'portland': 'OR',
    'salem': 'OR',
    'eugene': 'OR',
    'nashville': 'TN',
    'memphis': 'TN',
    'knoxville': 'TN',
    'charlotte': 'NC',
    'raleigh': 'NC',
    'greensboro': 'NC',
    'columbus': 'OH',
    'cleveland': 'OH',
    'cincinnati': 'OH',
    'indianapolis': 'IN',
    'fort wayne': 'IN',
    'bloomington': 'IN',
    'baltimore': 'MD',
    'annapolis': 'MD',
    'bethesda': 'MD',
    'milwaukee': 'WI',
    'madison': 'WI',
    'green bay': 'WI',
    'kansas city': 'MO',
    'st louis': 'MO',
    'saint louis': 'MO',
    'salt lake city': 'UT',
    'provo': 'UT',
    'richmond': 'VA',
    'virginia beach': 'VA',
    'norfolk': 'VA',
    'washington': 'DC',
    'washington dc': 'DC',
    'honolulu': 'HI',
    'anchorage': 'AK',

    // Indian Major Cities
    'mumbai': 'Maharashtra',
    'pune': 'Maharashtra',
    'nagpur': 'Maharashtra',
    'thane': 'Maharashtra',
    'nashik': 'Maharashtra',
    'delhi': 'Delhi',
    'new delhi': 'Delhi',
    'noida': 'Uttar Pradesh',
    'greater noida': 'Uttar Pradesh',
    'ghaziabad': 'Uttar Pradesh',
    'lucknow': 'Uttar Pradesh',
    'kanpur': 'Uttar Pradesh',
    'varanasi': 'Uttar Pradesh',
    'agra': 'Uttar Pradesh',
    'gurugram': 'Haryana',
    'gurgaon': 'Haryana',
    'faridabad': 'Haryana',
    'panipat': 'Haryana',
    'bengaluru': 'Karnataka',
    'bangalore': 'Karnataka',
    'mysuru': 'Karnataka',
    'mysore': 'Karnataka',
    'mangalore': 'Karnataka',
    'hubli': 'Karnataka',
    'hyderabad': 'Telangana',
    'secunderabad': 'Telangana',
    'warangal': 'Telangana',
    'chennai': 'Tamil Nadu',
    'coimbatore': 'Tamil Nadu',
    'madurai': 'Tamil Nadu',
    'salem tn': 'Tamil Nadu',
    'tiruchirappalli': 'Tamil Nadu',
    'kolkata': 'West Bengal',
    'calcutta': 'West Bengal',
    'howrah': 'West Bengal',
    'durgapur': 'West Bengal',
    'siliguri': 'West Bengal',
    'ahmedabad': 'Gujarat',
    'surat': 'Gujarat',
    'vadodara': 'Gujarat',
    'rajkot': 'Gujarat',
    'gandhinagar': 'Gujarat',
    'jaipur': 'Rajasthan',
    'jodhpur': 'Rajasthan',
    'udaipur': 'Rajasthan',
    'kota': 'Rajasthan',
    'bhopal': 'Madhya Pradesh',
    'indore': 'Madhya Pradesh',
    'gwalior': 'Madhya Pradesh',
    'jabalpur': 'Madhya Pradesh',
    'chandigarh': 'Chandigarh',
    'mohali': 'Punjab',
    'amritsar': 'Punjab',
    'ludhiana': 'Punjab',
    'jalandhar': 'Punjab',
    'patna': 'Bihar',
    'gaya': 'Bihar',
    'ranchi': 'Jharkhand',
    'jamshedpur': 'Jharkhand',
    'bhubaneswar': 'Odisha',
    'cuttack': 'Odisha',
    'puri': 'Odisha',
    'thiruvananthapuram': 'Kerala',
    'kochi': 'Kerala',
    'cochin': 'Kerala',
    'kozhikode': 'Kerala',
    'guwahati': 'Assam',
    'dehradun': 'Uttarakhand',
    'haridwar': 'Uttarakhand',
    'shimla': 'Himachal Pradesh',
    'srinagar': 'Jammu & Kashmir',
    'jammu': 'Jammu & Kashmir',
    'panaji': 'Goa',
    'margao': 'Goa',
    'vasco': 'Goa',
    'visakhapatnam': 'Andhra Pradesh',
    'vizag': 'Andhra Pradesh',
    'vijayawada': 'Andhra Pradesh',
    'guntur': 'Andhra Pradesh',

    // Global Hubs
    'london': 'Greater London',
    'manchester': 'Greater Manchester',
    'birmingham': 'West Midlands',
    'toronto': 'Ontario',
    'vancouver': 'British Columbia',
    'montreal': 'Quebec',
    'sydney': 'New South Wales',
    'melbourne': 'Victoria',
    'brisbane': 'Queensland',
    'dubai': 'Dubai',
    'abu dhabi': 'Abu Dhabi',
    'singapore': 'Singapore',
  };

  /// Looks up the state or province for a given city query
  static String? lookupState(String cityName) {
    final cleanCity = cityName.trim().toLowerCase();
    if (cleanCity.isEmpty) return null;

    // Exact match
    if (_cityToState.containsKey(cleanCity)) {
      return _cityToState[cleanCity];
    }

    // Prefix match
    for (final entry in _cityToState.entries) {
      if (entry.key.startsWith(cleanCity) || cleanCity.startsWith(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Preset location points with real GPS coordinates for Map Picker
  static List<Map<String, String>> getPresetLocations() {
    return [
      {
        'title': '742 Evergreen Terrace',
        'city': 'Springfield',
        'state': 'IL',
        'zip': '62701',
        'country': 'United States',
        'tag': 'Home',
        'lat': '39.7817',
        'lng': '-89.6501',
      },
      {
        'title': '123 Market Street, Suite 400',
        'city': 'San Francisco',
        'state': 'CA',
        'zip': '94105',
        'country': 'United States',
        'tag': 'Work',
        'lat': '37.7937',
        'lng': '-122.3965',
      },
      {
        'title': '450 Lexington Avenue',
        'city': 'New York',
        'state': 'NY',
        'zip': '10017',
        'country': 'United States',
        'tag': 'Office',
        'lat': '40.7527',
        'lng': '-73.9749',
      },
      {
        'title': 'Bandra Kurla Complex, G Block',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'zip': '400051',
        'country': 'India',
        'tag': 'Work',
        'lat': '19.0660',
        'lng': '72.8687',
      },
      {
        'title': 'Indiranagar 100ft Road',
        'city': 'Bengaluru',
        'state': 'Karnataka',
        'zip': '560038',
        'country': 'India',
        'tag': 'Home',
        'lat': '12.9719',
        'lng': '77.6412',
      },
      {
        'title': 'Connaught Place, Radial Road',
        'city': 'New Delhi',
        'state': 'Delhi',
        'zip': '110001',
        'country': 'India',
        'tag': 'Central',
        'lat': '28.6315',
        'lng': '77.2167',
      },
    ];
  }

  /// Real-world Reverse Geocoding from Latitude and Longitude to Street, City, State, ZIP
  static Future<Map<String, String>?> reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'AntigravityEcommerceApp/1.0 (Mobile Android; Flutter)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final road = address['road'] ??
              address['pedestrian'] ??
              address['suburb'] ??
              address['neighbourhood'] ??
              address['residential'] ??
              '';
          final houseNumber = address['house_number'] ?? '';
          final street = houseNumber.isNotEmpty && road.isNotEmpty
              ? '$houseNumber, $road'
              : (road.isNotEmpty
                  ? road
                  : (data['display_name']?.toString().split(',').first ?? 'Selected Location'));

          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['county'] ??
              '';
          final state = address['state'] ?? (lookupState(city) ?? '');
          final zip = address['postcode'] ?? '';
          final country = address['country'] ?? 'United States';

          return {
            'street': street.toString(),
            'city': city.isNotEmpty ? city.toString() : 'Selected Area',
            'state': state.toString(),
            'zip': zip.toString(),
            'country': country.toString(),
          };
        }
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    return null;
  }

  /// Search places worldwide for real-time camera jumping and pin dropping
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=5&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'AntigravityEcommerceApp/1.0 (Mobile Android; Flutter)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((item) {
          final lat = double.tryParse(item['lat'].toString()) ?? 0.0;
          final lon = double.tryParse(item['lon'].toString()) ?? 0.0;
          final address = item['address'] as Map<String, dynamic>?;

          final road = address?['road'] ?? address?['suburb'] ?? '';
          final city = address?['city'] ?? address?['town'] ?? address?['village'] ?? '';
          final state = address?['state'] ?? '';
          final zip = address?['postcode'] ?? '';
          final country = address?['country'] ?? '';

          return {
            'displayName': item['display_name']?.toString() ?? query,
            'lat': lat,
            'lng': lon,
            'street': road.isNotEmpty ? road : (item['display_name']?.toString().split(',').first ?? query),
            'city': city.isNotEmpty ? city : 'Selected Area',
            'state': state.isNotEmpty ? state : (lookupState(city) ?? ''),
            'zip': zip,
            'country': country,
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Search places error: $e');
    }
    return [];
  }
}
