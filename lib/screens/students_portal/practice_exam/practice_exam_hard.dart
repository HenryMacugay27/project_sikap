import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_leap/firestore_services/firestore_exam_service.dart';
import 'package:project_leap/utils/widget/error_handler/exam_result/exam_result_screen.dart';
import 'package:project_leap/utils/widget/error_handler/error_dialog.dart' as error_dialog;
import 'package:project_leap/utils/internet_connectivity/connectivity.dart' as internet;
import '../../../model/user.dart';

class PracticeExamHard extends StatefulWidget {
  final User? user;

  const PracticeExamHard({super.key, required this.user});

  @override
  State<PracticeExamHard> createState() => _PracticeExamHardState();
}

class _PracticeExamHardState extends State<PracticeExamHard> {
  late List<Question> questions = [];
  final Map<int, String> selectedAnswers = {};
  List<String> dropdownOptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String response = await rootBundle.loadString(
      'assets/questions/questions_hard.json',
    );
    final List<dynamic> data = json.decode(response);
    final allQuestions = data.map((json) => Question.fromJson(json)).toList();

    final filteredQuestions = allQuestions
        .where((q) =>
            q.gradeLevel == widget.user?.gradeLevel.toString() &&
            q.quarter == widget.user?.quarter)
        .toList();

    filteredQuestions.shuffle(Random());

    setState(() {
      questions = filteredQuestions.take(5).toList();
      dropdownOptions =
          questions.map((q) => q.correctAnswer).toSet().toList()..shuffle();
      isLoading = false;
    });
  }

  void _submitAnswers() async {
    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      final userAnswer = selectedAnswers[i]?.trim().toLowerCase() ?? '';
      final correctAnswer = questions[i].correctAnswer.trim().toLowerCase();
      if (userAnswer == correctAnswer) {
        score++;
      }
    }

    try {
      bool hasInternet = await internet.Connectivity().hasInternetAccess();
      if (hasInternet) {
        final firestoreService = FirestoreExamService();
        firestoreService.saveExamResult(
          user: widget.user!,
          examType: 'Hard',
          score: score,
          numberOfItems: questions.length,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExamResultScreen(
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
          'Practice Exam',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: questions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Select your answer',
                                    ),
                                    isExpanded: true,
                                    value: selectedAnswers[index],
                                    items: dropdownOptions.map((answer) {
                                      return DropdownMenuItem<String>(
                                        value: answer,
                                        child: Text(
                                          answer,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        _updateSelectedAnswer(index, value);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: ElevatedButton.icon(
                              onPressed: selectedAnswers.length ==
                                      questions.length
                                  ? _submitAnswers
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                disabledBackgroundColor: Colors.green.shade100,
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
  final String correctAnswer;
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
}
