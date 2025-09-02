import 'dart:math';  // Import the Random class
import 'dart:convert'; // Import for JSON parsing
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_leap/firestore_services/firestore_exam_service.dart';
import 'package:project_leap/model/user.dart';
import 'package:project_leap/utils/internet_connectivity/connectivity.dart' as internet;
import 'package:project_leap/utils/widget/error_handler/error_dialog.dart' as error_dialog;
import 'package:project_leap/utils/widget/error_handler/exam_result/exam_result_screen.dart';  // Import for loading assets


class ExamScreen extends StatefulWidget {
  final String? gradeLevel;
  final String? quarter;
  final User? user;

  const ExamScreen({
    super.key,
    required this.gradeLevel,
    required this.quarter, 
    required this.user,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late List<Question> questions = [];
  final Map<int, String> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // Load questions from the JSON file
  Future<void> _loadQuestions() async {
  final String response = await rootBundle.loadString('assets/questions/question_post_test.json');
  final List<dynamic> data = json.decode(response);

  final allQuestions = data.map((json) => Question.fromJson(json)).toList();

  // Filter by Grade 9 and 1st Quarter
  final filteredQuestions = allQuestions.where((q) =>
    q.gradeLevel == widget.gradeLevel && q.quarter == widget.quarter).toList();

  setState(() {
    questions = filteredQuestions;
    _loadRandomQuestions();
  });
}

  void _loadRandomQuestions() {
    final random = Random();
    final shuffled = List<Question>.from(questions)..shuffle(random);
    setState(() {
      questions = shuffled.take(10).toList();  // Take the first 10 questions
    });
  }

  void _submitAnswers() async {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i].correctAnswer) {
        score++;
      }
    }

    try {
      bool hasInternet = await internet.Connectivity().hasInternetAccess();
      if (hasInternet) {
        
        final firestoreService = FirestoreExamService();
        firestoreService.saveExamResult(
          user: widget.user!,
          examType: 'Post_Exam',
          score: score,
          numberOfItems: questions.length,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => ExamResultScreen(
                  score: score,
                  totalItems: questions.length,
                ),
          ),
        );
      } else {
        if (!mounted) return;
        error_dialog.showErrorDialog(
          context,
          'No internet connection. Please try again later.',
        );
      }
    } catch (e) {
      error_dialog.showErrorDialog(
          context,
          '$e',
        );
    }
  }

  void _updateSelectedAnswer(int index, String answer) {
    setState(() {
      selectedAnswers[index] = answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Final Exam',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: questions.length + 1,
                itemBuilder: (context, index) {
                  if (index < questions.length) {
                  final question = questions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${question.question}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (var option in question.options)
                            RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: selectedAnswers[index],
                              onChanged: (value) {
                                _updateSelectedAnswer(index, value!);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                  }else{
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: ElevatedButton.icon(
                                onPressed:
                                    selectedAnswers.length == questions.length
                                        ? _submitAnswers
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  disabledBackgroundColor:
                                      Colors.green.shade100,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text(
                                  'Submit Answers',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String gradeLevel;
  final String quarter;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.gradeLevel,
    required this.quarter,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      gradeLevel: json['gradeLevel'],
      quarter: json['quarter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'gradeLevel': gradeLevel,
      'quarter': quarter,
    };
  }
}

