import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const TriviaQuizApp());
}

class TriviaQuizApp extends StatelessWidget {
  const TriviaQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const WelcomeScreen(),
    );
  }
}
