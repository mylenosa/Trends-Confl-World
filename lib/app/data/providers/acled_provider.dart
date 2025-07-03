import 'package:get/get.dart';

class AcledProvider extends GetConnect {
  final String _baseUrl = 'https://api.acleddata.com/acled/read';
  final String _apiKey = '***REMOVED***';
  final String _apiUser = 'mylena.nunes@estudante.ifro.edu.br';

  Future<Map<String, dynamic>> getEvents({
    required String country,
    required String keyword,
  }) async {
    // 1. OPTIMIZATION: Define exactly which fields the app needs
    const String fields =
        'data_id|event_id_cnty|event_date|event_type|country|admin1|location|fatalities|latitude|longitude';
    
    // Construct the query with optimizations
    final query = {
      'key': _apiKey,
      'email': _apiUser,
      'country': country,
      'terms': keyword,
      'fields': fields,
      // 2. OPTIMIZATION: Limit results to a reasonable number
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
