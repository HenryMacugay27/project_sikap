import 'package:flutter/material.dart';
import 'package:project_leap/main.dart';
import 'package:project_leap/screens/students_portal/story/story_page.dart';
import '../utils/authentication/auth.dart';
import '../model/module.dart';
import '../model/user.dart'; 
import '../screens/students_portal/module/module_page.dart';
import '../screens/students_portal/practice_exam/practice_exam_easy.dart';
import '../screens/students_portal/practice_exam/practice_exam_medium.dart';
import '../screens/students_portal/practice_exam/practice_exam_hard.dart';


class DashboardController {
  final Auth _auth = Auth();

  // Function to show Difficulty Dialog
  void showDifficultyDialog(BuildContext context, User? user) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Select Difficulty',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              difficultyButton(
                context: context,
                dialogContext: dialogContext,
                label: 'Easy',
                color: Colors.green.shade100,
                destination: PracticeExamEasy(user: user),
              ),
              const SizedBox(height: 12),
              difficultyButton(
                context: context,
                dialogContext: dialogContext,
                label: 'Average',
                color: Colors.amber.shade100,
                destination: PracticeExamMedium(user: user),
              ),
              const SizedBox(height: 12),
              difficultyButton(
                context: context,
                dialogContext: dialogContext,
                label: 'Difficult',
                color: Colors.red.shade100,
                destination: PracticeExamHard(user: user),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to create difficulty button
  Widget difficultyButton({
    required BuildContext context,
    required BuildContext dialogContext,
    required String label,
    required Color color,
    required Widget destination,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(dialogContext).pop();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
  
  // Function to handle article selection
  void showArticlesDialog(BuildContext context, List<Module> modules) {

    final filteredArticles = modules.where((m) => m.name.contains('Article')).toList();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Select an Article',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                return articleButton(context, filteredArticles[index]);
              },
            ),
          ),
        );
      },
    );
  }

  // Function to handle module selection
  void showModulesDialog(BuildContext context, List<Module> modules) {

    final filteredModules = modules.where((m) => m.name.contains('Module')).toList();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Select a Module',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredModules.length,
              itemBuilder: (context, index) {
                return moduleButton(context, filteredModules[index]);
              },
            ),
          ),
        );
      },
    );
  }

  // Function to create module button
  Widget articleButton(BuildContext context, Module module) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoryPage(
                  assetPath: module.link.first, audioPath:  module.audio, // Navigate to the first link
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.green.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            module.name,
            style: const TextStyle(
              color: Color.fromARGB(221, 0, 0, 0),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16), // Add space between buttons
      ],
    );
  }

  // Function to create module button
  Widget moduleButton(BuildContext context, Module module) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModulePage(
                  assetPath: module.link.first, // Navigate to the first link
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.green.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            module.name,
            style: const TextStyle(
              color: Color.fromARGB(221, 0, 0, 0),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16), // Add space between buttons
      ],
    );
  }

  // Function to show selected option
  void showSelected(BuildContext context, String title) {
    final currentUser = _auth.currentUser;

    String userInfo =
        currentUser != null
            ? 'Logged in as: ${currentUser.email}'
            : 'Not logged in';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('You selected: $title\n$userInfo')));
  }

  // Function to handle sign out
  void signOut(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }


}
