import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_leap/firestore_services/firestore_exam_service.dart';
import 'package:project_leap/utils/widget/error_handler/error_dialog.dart' as error_dialog;
import '../../../model/user.dart';
import '../../../utils/widget/error_handler/exam_result/exam_result_screen.dart'; // 
import 'package:project_leap/utils/internet_connectivity/connectivity.dart' as internet;

class PracticeExamEasy extends StatefulWidget {
  final User? user;

  const PracticeExamEasy({super.key, required this.user});

  @override
  State<PracticeExamEasy> createState() => _PracticeExamEasyState();
}

class _PracticeExamEasyState extends State<PracticeExamEasy> {
  List<Question> questions = [];
  final Map<int, bool> selectedAnswers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String jsonString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/questions/questions_easy.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);
    final allQuestions = jsonData.map((q) => Question.fromJson(q)).toList();

    final filteredQuestions =
        allQuestions
            .where(
              (q) =>
                  q.gradeLevel == widget.user?.gradeLevel.toString() &&
                  q.quarter == widget.user?.quarter,
            )
            .toList();

    filteredQuestions.shuffle(Random());

    setState(() {
      questions = filteredQuestions.take(5).toList();
      isLoading = false;
    });
  }

  void _updateSelectedAnswer(int index, bool answer) {
    setState(() {
      selectedAnswers[index] = answer;
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
          examType: 'Easy',
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
      throw ("Error saving record to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Practice Exam',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          () => _updateSelectedAnswer(
                                            index,
                                            true,
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            selectedAnswers[index] == true
                                                ? Colors.green
                                                : Colors.grey.shade200,
                                        foregroundColor:
                                            selectedAnswers[index] == true
                                                ? Colors.white
                                                : Colors.black87,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Tama'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          () => _updateSelectedAnswer(
                                            index,
                                            false,
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            selectedAnswers[index] == false
                                                ? Colors.red
                                                : Colors.grey.shade200,
                                        foregroundColor:
                                            selectedAnswers[index] == false
                                                ? Colors.white
                                                : Colors.black87,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Mali'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: ElevatedButton.icon(
                          onPressed:
                              selectedAnswers.length == questions.length
                                  ? _submitAnswers
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            disabledBackgroundColor: Colors.green.shade100,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}

class Question {
  final String question;
  final bool correctAnswer;
  final String gradeLevel;
  final String quarter;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.gradeLevel,
    required this.quarter,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      correctAnswer: json['correctAnswer'],
      gradeLevel: json['gradeLevel'],
      quarter: json['quarter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'correctAnswer': correctAnswer,
      'gradeLevel': gradeLevel,
      'quarter': quarter,
    };
  }
}
