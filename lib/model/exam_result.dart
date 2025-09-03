import 'package:cloud_firestore/cloud_firestore.dart';

class ExamResult {
  final DateTime dateCreated;
  final String examType;
  final int gradeLevel; 
  final int numberOfItems;
  final int score;
  final String section;
  final String teacherName;
  final String teacherUid;
  final String userName;
  final String userUid;

  const ExamResult({
    required this.dateCreated,
    required this.examType,
    required this.gradeLevel,
    required this.numberOfItems,
    required this.score,
    required this.section,
    required this.teacherName,
    required this.teacherUid,
    required this.userName,
    required this.userUid,
  });

  factory ExamResult.fromMap(Map<String, dynamic> data) {
    return ExamResult(
      dateCreated: (data['date_created'] as Timestamp).toDate(),
      examType: data['exam_type'] ?? '',
      gradeLevel: data['grade_level'] ?? 0,
      numberOfItems: data['number_of_items'] ?? 0,
      score: data['score'] ?? 0,
      section: data['section'] ?? '',
      teacherName: data['teacher_name'] ?? '',
      teacherUid: data['teacher_uid'] ?? '',
      userName: data['user_name'] ?? '',
      userUid: data['user_uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date_created': Timestamp.fromDate(dateCreated),
      'exam_type': examType,
      'grade_level': gradeLevel,
      'number_of_items': numberOfItems,
      'score': score,
      'section': section,
      'teacher_name': teacherName,
      'teacher_uid': teacherUid,
      'user_name': userName,
      'user_uid': userUid,
    };
  }
}
