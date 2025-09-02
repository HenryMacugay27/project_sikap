import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String firstName;
  final String middleName;
  final String lastName;
  final String fullName;
  final String email;
  final int gradeLevel;
  final String section;
  final String quarter;
  final String role;
  final String teacher; // Add teacher as DocumentReference
  final String teacherName; // Add teacher as DocumentReference
  final Timestamp created_at; // Add created_at as DateTime
  final int allowedAttempts; // Add updated_at as DateTime 
  final int attempts; // Add updated_at as DateTime 
  final bool isPassed; // Add updated_at as DateTime 
  final String status; // Add updated_at as DateTime 



  // Constructor
  User({
    required this.uid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.gradeLevel,
    required this.section,
    required this.quarter,
    required this.role,
    required this.teacher, // Add teacher to constructor
    required this.teacherName, // Add teacher to constructor
    required this.created_at, // Add created_at to constructor
    required this.allowedAttempts, // Add allowedAttempts to constructor
    required this.attempts, // Add attempts to constructor
    required this.isPassed, // Add isPassed to constructor
    required this.status, // Add status to constructor
  });

  // Factory method to create a User from a map (usually fetched from Firestore)
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] ?? '',
      firstName: data['first_name'] ?? '',
      middleName: data['middle_name'] ?? '',
      lastName: data['last_name'] ?? '',
      fullName: data['full_name'] ?? '',
      email: data['email'] ?? '',
      gradeLevel: data['grade_level'] ?? 0, // Ensure gradeLevel is an int
      section: data['section'] ?? '',
      created_at: data['created_at'] ?? '',
      allowedAttempts: data['allowedAttempts'] ?? 0,
      attempts: data['attempts'] ?? 0,
      isPassed: data['isPassed'] ?? false,
      status: data['status'] ?? '',
      quarter: data['quarter'] ?? '',
      role: data['role'] ?? '',
      teacher: data['teacher'] ?? '',
      teacherName: data['teacher_name'] ?? '',
    );
  }

  // Method to convert the User object to a map (useful for saving in Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'first_name': firstName,
      'middle_name': middleName,
      'created_at': created_at,
      'allowed_attempts': allowedAttempts,
      'attempts': attempts,
      'is_passed': isPassed,
      'status': status,
      'email': email,
      'grade_level': gradeLevel,
      'section': section,
      'quarter': quarter,
      'role': role,
      'teacher': teacher, // Save the teacher reference as part of the map
      'teacherName': teacherName, // Save the teacher reference as part of the map
    };
  }
}
