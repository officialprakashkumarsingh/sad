import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BraveSearchService {
  static final BraveSearchService instance = BraveSearchService._internal();
  BraveSearchService._internal();

  List<String> _apiKeys = [];
  int _currentApiKeyIndex = 0;

  Future<void> _loadApiKeys() async {
    final keysString = dotenv.env['BRAVE_API_KEYS'];
    if (keysString != null && keysString.isNotEmpty) {
      _apiKeys = keysString.split(',');
    }
    final prefs = await SharedPreferences.getInstance();
    _currentApiKeyIndex = prefs.getInt('brave_api_key_index') ?? 0;
  }

  String _getApiKey() {
    if (_apiKeys.isEmpty) {
      throw Exception('Brave API keys not found in .env file.');
    }
    return _apiKeys[_currentApiKeyIndex];
  }

  Future<void> _rotateApiKey() async {
    _currentApiKeyIndex = (_currentApiKeyIndex + 1) % _apiKeys.length;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('brave_api_key_index', _currentApiKeyIndex);
  }

  Future<String> search(String query) async {
    await _loadApiKeys();
    if (_apiKeys.isEmpty) {
      return 'Error: No Brave API keys configured.';
    }

    for (int i = 0; i < _apiKeys.length; i++) {
      final apiKey = _getApiKey();
      final url = Uri.parse('https://api.search.brave.com/res/v1/web/search?q=$query&count=25');

      try {
        final response = await http.get(
          url,
          headers: {
            'Accept': 'application/json',
            'X-Subscription-Token': apiKey,
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return _formatResults(data);
        } else if (response.statusCode == 429 || response.statusCode == 401) {
          // Rate limit hit or unauthorized, rotate key and try again
          await _rotateApiKey();
          continue;
        } else {
          // Other error
          return 'Error: Brave Search API returned status code ${response.statusCode}';
        }
      } catch (e) {
        return 'Error: Failed to connect to Brave Search API.';
      }
    }

    return 'Error: All Brave API keys failed.';
  }

  String _formatResults(Map<String, dynamic> data) {
    if (data['web'] == null || data['web']['results'] == null) {
      return 'No results found.';
    }

    final results = data['web']['results'] as List;
    if (results.isEmpty) {
      return 'No results found.';
    }

    final buffer = StringBuffer();
    buffer.writeln('Here are the top web search results:');

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      buffer.writeln('${i + 1}. ${result['title']}');
      buffer.writeln('   ${result['url']}');
      buffer.writeln('   ${result['description']}');
      buffer.writeln();
    }

    return buffer.toString();
  }
}
