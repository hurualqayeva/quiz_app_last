import 'package:flutter/material.dart';

class QuizResultCard extends StatelessWidget {
  final int correctCount;
  final int totalQuestions;
  final Future<int> userPoints;

  QuizResultCard({
    required this.correctCount,
    required this.totalQuestions,
    required this.userPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Quiz Result',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Correct Answers: $correctCount',
              style: TextStyle(color: Colors.green),
            ),
            Text(
              'Incorrect Answers: ${totalQuestions - correctCount}',
              style: TextStyle(color: Colors.red),
            ),
            FutureBuilder<int>(
              future: userPoints,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                    'Error fetching points',
                    style: TextStyle(color: Colors.red),
                  );
                } else {
                  int points = snapshot.data ?? 0;
                  return Text(
                    'Your Total point: $points',
                    style: TextStyle(color: Colors.blue),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}