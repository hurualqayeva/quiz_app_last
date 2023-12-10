import 'package:flutter/material.dart';
import 'package:quiz_app/models/model.dart';
import 'package:quiz_app/screens/quiz_result_page.dart';
import 'package:quiz_app/widgets/quiz_card.dart';

class QuizResultDialog extends StatelessWidget {
  final int correctCount;
  final int totalQuestions;
  final List<QuizQuestion> quizQuestions;
  final Map<int, String?> selectedAnswers;
  final Future<int> userPoints;

  QuizResultDialog({
    required this.correctCount,
    required this.totalQuestions,
    required this.quizQuestions,
    required this.selectedAnswers,
    required this.userPoints,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Here is your result'),
      content: Column(
        children: [
          SizedBox(height: 16),
          QuizResultCard(correctCount: correctCount, totalQuestions: totalQuestions, userPoints: userPoints),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizResultPage(
                    quizQuestions: quizQuestions,
                    selectedAnswers: selectedAnswers,
                  ),
                ),
              );
            },
            child: Text('See Correct/Incorrect Answers'),
          ),
        ],
      ),
    );
  }
}


