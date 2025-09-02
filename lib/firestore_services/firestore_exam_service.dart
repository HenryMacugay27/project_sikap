import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart';

class FirestoreExamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveExamResult({
    required User user,
    required String examType,
    required int score,
    required int numberOfItems,
  }) async {
    try {
      int allowedAttempts = 0;
      int attempts = 0;

      // Fetch user document
      final userQuery = await _firestore
          .collection('user')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      final bool userExists = userQuery.docs.isNotEmpty;

      if (userExists) {
        final userData = userQuery.docs.first.data();
        final fetchedUser = User.fromMap(userData);

        allowedAttempts = fetchedUser.allowedAttempts;
        attempts = fetchedUser.attempts;
      }

      // Post-exam: Check attempt limit
      if (examType == 'Post_Exam') {
        if (attempts >= allowedAttempts) {
          print('User has exceeded the allowed attempts.');
          throw Exception('User has exceeded the allowed number of attempts.');
        }
      }

      // Save exam result
      await _firestore.collection('test_exam_result').add({
        'user_uid': user.uid,
        'user_name': user.fullName,
        'grade_level': user.gradeLevel,
        'section': user.section,
        'teacher_uid': user.teacher,
        'teacher_name': user.teacherName,
        'exam_type': examType,
        'score': score,
        'number_of_items': numberOfItems,
        'date_created': FieldValue.serverTimestamp(),
      });

      // Update attempts if Post_Exam
      if (examType == 'Post_Exam' && userExists) {
        if(score > 4){
          await userQuery.docs.first.reference.update({
            'attempts': attempts + 1,
            'isPassed': true,
          });
        }else{
          await userQuery.docs.first.reference.update({
          'attempts': attempts + 1,
          });
        }
      } 
    } catch (e) {
      print('Error saving exam result: $e');
    }
  }

  Future<void> addExamResult({
    required User user,
    required String examType,
    required int score,
    required int numberOfItems,
  }) async {
    try {
      await _firestore.collection('test_exam_result').add({
        'user_uid': user.uid,
        'user_name': user.fullName,
        'grade_level': user.gradeLevel,
        'section': user.section,
        'teacher_uid': user.teacher,
        'teacher_name': user.teacherName,
        'exam_type': examType,
        'score': score,
        'number_of_items': numberOfItems,
        'date_created': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding exam result: $e');
    }
  }
}
