import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/trivia_api_service.dart';
import '../widgets/question_card.dart';
import '../widgets/answer_button.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TriviaApiService _apiService = TriviaApiService();

  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedAnswer;
  bool _isAnswerChecked = false;
  List<String> _shuffledAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final questions = await _apiService.fetchDefaultQuestions();

      setState(() {
        _questions = questions;
        _isLoading = false;
        if (_questions.isNotEmpty) {
          _shuffledAnswers = _questions[0].getAllAnswers();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load questions. Please try again.';
      });
    }
  }

  void _selectAnswer(String answer) {
    if (_isAnswerChecked) return; // Prevent multiple selections

    setState(() {
      _selectedAnswer = answer;
      _isAnswerChecked = true;

      // Check if answer is correct
      if (answer == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });

    // Auto-advance to next question after showing feedback
    Future.delayed(const Duration(milliseconds: 1500), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswerChecked = false;
        _shuffledAnswers = _questions[_currentQuestionIndex].getAllAnswers();
      });
    } else {
      // Quiz complete - navigate to results
      _showResults();
    }
  }

  void _showResults() {
    final result = QuizResult(
      totalQuestions: _questions.length,
      correctAnswers: _score,
      incorrectAnswers: _questions.length - _score,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation (one-way flow)
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade100,
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_questions.isEmpty) {
      return _buildEmptyState();
    }

    return _buildQuizContent();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade700),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Questions...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.purple.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _loadQuestions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No questions available',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      children: [
        // Progress Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $_score/${_questions.length}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  Text(
                    '${(_currentQuestionIndex + 1)}/${_questions.length}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.purple.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.purple.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Question Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: QuestionCard(
            question: currentQuestion,
            questionNumber: _currentQuestionIndex + 1,
            totalQuestions: _questions.length,
          ),
        ),

        const SizedBox(height: 30),

        // Answer Buttons
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: _shuffledAnswers.map((answer) {
                final isSelected = answer == _selectedAnswer;
                final isCorrect = _isAnswerChecked
                    ? answer == currentQuestion.correctAnswer
                    : null;

                return AnswerButton(
                  answer: answer,
                  onPressed: () => _selectAnswer(answer),
                  isCorrect: isSelected ? isCorrect : null,
                  isSelected: isSelected,
                  isDisabled: _isAnswerChecked,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}