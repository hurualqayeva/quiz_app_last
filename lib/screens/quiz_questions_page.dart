import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app/models/model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:quiz_app/services/firebase_auth.dart';
import 'package:quiz_app/widgets/quiz_result_dialog.dart';



class QuizQuestionsPage extends StatefulWidget {
  final String selectedCategory;
  final String selectedDifficulty;
  final String selectedType;
  final int numberOfQuestions;

  QuizQuestionsPage({
    required this.selectedCategory,
    required this.selectedDifficulty,
    required this.selectedType,
    required this.numberOfQuestions,
  });

  @override
  _QuizQuestionsPageState createState() => _QuizQuestionsPageState();
}

class _QuizQuestionsPageState extends State<QuizQuestionsPage> {
  late List<QuizQuestion> quizQuestions;
  late int currentQuestionIndex;
  late Map<int, String?> selectedAnswers;
  late Timer timer;
  late int timerSeconds;
  late double timerProgress;

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    quizQuestions = [];
    currentQuestionIndex = 0;
    selectedAnswers = {};
    timerSeconds = 60;
    timerProgress = 1.0;
    fetchQuizQuestions();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (timerSeconds > 0) {
          timerSeconds--;
          timerProgress = timerSeconds / 60.0;
        } else {
          goToNextQuestion();
        }
      });
    });
  }

  Future<void> fetchQuizQuestions() async {
    final categoryParam = widget.selectedCategory.isNotEmpty ? '&category=${widget.selectedCategory}' : '';
    final difficultyParam = widget.selectedDifficulty == 'any' ? '' : '&difficulty=${widget.selectedDifficulty}';
    final typeParam = widget.selectedType == 'any' ? '' : '&type=${widget.selectedType}';

    final response = await http.get(Uri.parse(
        'https://opentdb.com/api.php?amount=${widget.numberOfQuestions}$categoryParam$difficultyParam$typeParam'));
    final data = json.decode(response.body);

    setState(() {
      quizQuestions = (data['results'] as List)
          .map((questionData) => QuizQuestion(
                question: questionData['question'],
                options: List<String>.from(questionData['incorrect_answers']) +
                    [questionData['correct_answer']],
                correctAnswer: questionData['correct_answer'],
              ))
          .toList();
    });
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < widget.numberOfQuestions - 1) {
      setState(() {
        currentQuestionIndex++;
        timerSeconds = 60;
        timerProgress = 1.0;
      });
    } else {
      timer.cancel();
      showQuizResult();
    }
  }

  void showQuizResult() async {
    int correctCount = calculateCorrectAnswers();

    await _authService.updateQuizResults(
      correctCount: correctCount,
      totalQuestions: widget.numberOfQuestions,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QuizResultDialog(
          correctCount: correctCount,
          totalQuestions: widget.numberOfQuestions,
          quizQuestions: quizQuestions,
          selectedAnswers: selectedAnswers,
          userPoints: _authService.getUserPoints(),
        );
      },
    );
  }

  int calculateCorrectAnswers() {
    int correctCount = 0;
    for (int i = 0; i < widget.numberOfQuestions; i++) {
      if (selectedAnswers.containsKey(i) && selectedAnswers[i] == quizQuestions[i].correctAnswer) {
        correctCount++;
      }
    }
    return correctCount;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz Questions'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 37, 55, 83),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${widget.numberOfQuestions}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: timerProgress,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Time Remaining: ${timerSeconds}s',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Html(
                    data: quizQuestions[currentQuestionIndex].question,
                    style: {
                      "html": Style(
                        color: Colors.white,
                        fontSize: FontSize(18),
                      ),
                    },
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: quizQuestions[currentQuestionIndex].options.map((option) {
                      bool isSelected = selectedAnswers[currentQuestionIndex] == option;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedAnswers[currentQuestionIndex] = option;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.0),
                          margin: EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8.0),
                            color: isSelected ? (Colors.blue) : Colors.transparent,
                          ),
                          child: Html(
                            data: option,
                            style: {
                              "html": Style(
                                color: Colors.white,
                              ),
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text(
                      'Next Question',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      goToNextQuestion();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

