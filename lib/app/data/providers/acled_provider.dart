import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class AcledProvider extends GetConnect {
  final String _baseUrl = 'https://api.acleddata.com/acled/read';
  
  // Read credentials securely from environment variables
  final String _apiKey = dotenv.env['ACLED_API_KEY'] ?? 'NO_KEY';
  final String _apiUser = dotenv.env['ACLED_API_USER'] ?? 'NO_USER';

  Future<Map<String, dynamic>> getEvents({
    required String country,
    required String keyword,
  }) async {
    const String fields =
        'data_id|event_id_cnty|event_date|event_type|country|admin1|location|fatalities|latitude|longitude';
    
    final query = {
      'key': _apiKey,
      'email': _apiUser,
      'country': country,
      'terms': keyword,
      'fields': fields,
      'limit': '100',
    };

    final response = await get(_baseUrl, query: query);

    if (response.status.hasError) {
      return Future.error('API Error: ${response.statusText}');
    } else {
      return response.body;
    }
  }
}
