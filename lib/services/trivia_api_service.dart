import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class TriviaApiService {
  static const String baseUrl = 'https://opentdb.com/api.php';

  // Fetch trivia questions from the API
  // Default: 10 questions, General Knowledge category, Easy difficulty, Multiple choice
  Future<List<Question>> fetchQuestions({
    int amount = 10,
    int? category,
    String? difficulty,
    String? type,
  }) async {
    try {
      // Build the URL with query parameters
      final Map<String, String> queryParams = {
        'amount': amount.toString(),
      };

      if (category != null) {
        queryParams['category'] = category.toString();
      }
      if (difficulty != null) {
        queryParams['difficulty'] = difficulty;
      }
      if (type != null) {
        queryParams['type'] = type;
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      // Make the HTTP GET request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if the API returned a success response code
        final int responseCode = data['response_code'] ?? 1;

        if (responseCode == 0) {
          // Success - parse the questions
          final List<dynamic> results = data['results'] ?? [];
          return results.map((json) => Question.fromJson(json)).toList();
        } else {
          // API returned an error code
          throw Exception('API Error: Response code $responseCode');
        }
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  // Fetch questions with default settings for the class activity
  // Category 9 = General Knowledge, Easy difficulty, Multiple choice
  Future<List<Question>> fetchDefaultQuestions() async {
    return fetchQuestions(
      amount: 10,
      category: 9, // General Knowledge
      difficulty: 'easy',
      type: 'multiple',
    );
  }
}