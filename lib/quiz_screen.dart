import 'package:flutter/material.dart';
import 'api_service.dart';
import 'question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  bool _isLoading = true;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkAnswer(String selectedAnswer) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;

      if (selectedAnswer ==
          _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete'),
        content: Text('Your score: $_score / ${_questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _answered = false;
                _selectedAnswer = null;
              });
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No questions loaded')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              currentQuestion.questionText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...currentQuestion.options.map((option) {
              Color? buttonColor;

              if (_answered) {
                if (option == currentQuestion.correctAnswer) {
                  buttonColor = Colors.green;
                } else if (option == _selectedAnswer) {
                  buttonColor = Colors.red;
                }
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _answered ? null : () => _checkAnswer(option),
                  child: Text(option),
                ),
              );
            }),
            const SizedBox(height: 20),
            Text(
              'Score: $_score',
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _answered ? _nextQuestion : null,
              child: const Text('Next Question'),
            ),
          ],
        ),
      ),
    );
  }
}