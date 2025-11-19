import 'dart:convert';

class Question {
  final String category;
  final String type;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  Question({
    required this.category,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  // Factory constructor to create Question from JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      category: _decodeHtml(json['category'] ?? ''),
      type: json['type'] ?? '',
      difficulty: json['difficulty'] ?? '',
      question: _decodeHtml(json['question'] ?? ''),
      correctAnswer: _decodeHtml(json['correct_answer'] ?? ''),
      incorrectAnswers: (json['incorrect_answers'] as List<dynamic>?)
              ?.map((answer) => _decodeHtml(answer.toString()))
              .toList() ??
          [],
    );
  }

  // Get all answers shuffled
  List<String> getAllAnswers() {
    List<String> allAnswers = [...incorrectAnswers, correctAnswer];
    allAnswers.shuffle();
    return allAnswers;
  }

  // Decode HTML entities (e.g., &quot; to ", &#039; to ')
  static String _decodeHtml(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&ntilde;', 'ñ');
  }

  @override
  String toString() {
    return 'Question{question: $question, difficulty: $difficulty}';
  }
}