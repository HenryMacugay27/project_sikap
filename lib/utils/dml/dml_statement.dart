import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_sikap/model/exam_result.dart';
import 'package:project_sikap/model/user.dart'; // Assuming this is your custom ExamResult model

class DmlStatement {
    Future<List<ExamResult>> fetchExamResults(User student) async {
    try {
      final examDocs = await FirebaseFirestore.instance
          .collection('test_exam_result')
          .where('user_uid', isEqualTo: student.uid)
          .orderBy('date_created') 
          .get();

      if (examDocs.docs.isNotEmpty) {
        List<ExamResult> results = examDocs.docs
            .map((doc) => ExamResult.fromMap(doc.data()))
            .toList();

        //print('Exam Results: ${results.first.toMap()}');
        return results;
      }
    } catch (e) {
      //print('Error fetching exam results: $e');
    }
    return []; // Return an empty list if no results are found or an error occurs
  }
}
