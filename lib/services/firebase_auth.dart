import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> registerWithEmailAndPassword({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

 


  Future<void> updateQuizResults({
    required int correctCount,
    required int totalQuestions,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        String userEmail = user.email!;

        DocumentReference userDocRef = _firestore.collection('users').doc(userId);

        await userDocRef.set({
          'correct': FieldValue.increment(correctCount),
          'incorrect': FieldValue.increment(totalQuestions - correctCount),
          'mail': userEmail,
          'point': FieldValue.increment(correctCount),
        }, SetOptions(merge: true));

        print('Quiz results updated successfully in Firestore!');
      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error updating quiz results: $e');
    }
  }

  Future<int> getUserPoints() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

        return userDoc['point'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error fetching user points: $e');
      return 0;
    }
  }
}
