class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
  });

  // Calculate percentage score
  double get percentage => (correctAnswers / totalQuestions) * 100;

  // Get a message based on score
  String get message {
    if (percentage >= 80) {
      return 'Excellent! You are a Trivia Master!';
    } else if (percentage >= 60) {
      return 'Great Job! Keep it up!';
    } else if (percentage >= 40) {
      return 'Good Effort! Practice more!';
    } else {
      return 'Keep Learning! Try again!';
    }
  }

  @override
  String toString() {
    return 'QuizResult{total: $totalQuestions, correct: $correctAnswers, percentage: ${percentage.toStringAsFixed(1)}%}';
  }
}