import 'dart:convert';
import 'package:http/http.dart' as http;

class AISearchService {
  static const String _geminiApiKey = 'AIzaSyCsfzNXk_nP9V5my0gqNc5wV0-kPcPZ9YU';
  static final Uri _geminiUrl = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiApiKey',
  );

  static Future<List<String>> getProcessedSearchTerms(String rawQuery) async {
    if (rawQuery.trim().isEmpty) {
      return [];
    }

    final prompt = """
    Analyze the following user query for finding food trucks: "$rawQuery".
    Extract key food items, cuisine types, or dietary preferences (like vegan, spicy, gluten-free).
    Return a concise list of these terms, comma-separated.
    For example:
    - If query is "I want a spicy vegan burger", return "spicy, vegan, burger".
    - If query is "pizza places", return "pizza".
    - If query is "coffee and donuts", return "coffee, donuts".
    - If query is "healthy salads", return "healthy, salad".
    Keep it short and focused on searchable keywords.
    """;

    try {
      final response = await http.post(
        _geminiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates']?[0]?['content']?['parts']?[0]['text'] as String?;
        final termsString = content?.trim() ?? rawQuery.toLowerCase();

        final termsList = termsString
            .split(',')
            .map((t) => t.trim().toLowerCase())
            .where((t) => t.isNotEmpty)
            .toList();

        if (termsList.isEmpty && rawQuery.trim().isNotEmpty) {
          return [rawQuery.trim().toLowerCase()];
        }
        return termsList;
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
        return [rawQuery.trim().toLowerCase()];
      }
    } catch (e) {
      print('Error connecting to Gemini API: $e');
      return [rawQuery.trim().toLowerCase()];
    }
  }
}
