import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../certificate/CertificateScreen.dart';
import '../../../utils/authentication/auth.dart';
import '../../../controller/dashboard_controller.dart';
import '../../video_lesson_page.dart';
import '../../../constants/module_paths.dart';
import '../../../model/module.dart';
import '../../../model/user.dart';
import '../../user/user_info_screen.dart';
import '../exam/exam_screen.dart';

class MainDashboardStudent extends StatefulWidget {
  const MainDashboardStudent({super.key});

  @override
  State<MainDashboardStudent> createState() => _MainDashboardStudentState();
}

class _MainDashboardStudentState extends State<MainDashboardStudent> {
  final Auth _auth = Auth();
  final DashboardController _dashboardController = DashboardController();

  User? user;
  List<Module> modules = [];
  String? storyPath;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final query = await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final fetchedUser = User.fromMap(data);

        final jsonModules = await _loadModulesJson(fetchedUser.gradeLevel, fetchedUser.quarter);
        final moduleList = jsonModules.map((item) => Module.fromJson(item)).toList();

        final storyModule = moduleList.firstWhere((m) => m.name == 'Story', orElse: () => Module(name: '', story: '', audio: '', description: '', link: []));

        setState(() {
          user = fetchedUser;
          modules = moduleList;
          storyPath = storyModule.story;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing dashboard: $e');
    }
  }

  Future<List<dynamic>> _loadModulesJson(int? gradeLevel, String? quarter) async {
    final gradeMap = modulePaths[gradeLevel.toString()];
    if (gradeMap == null) throw Exception('Unsupported grade level: $gradeLevel');

    final path = gradeMap[quarter];
    if (path == null) throw Exception('Invalid quarter selected: $quarter');

    final jsonString = await DefaultAssetBundle.of(context).loadString(path);
    print('Button clicked!' + jsonString);
    return jsonDecode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    final fullName = user?.fullName ?? 'Loading...';
    final gradeLevel = user?.gradeLevel ?? '';
    final quarter = user?.quarter ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(fullName.toString(), gradeLevel.toString(), quarter.toString()),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardBody(fullName),
    );
  }

  Drawer _buildDrawer(String fullName, String gradeLevel, String quarter) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color.fromRGBO(200, 230, 201, 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                Text('Grade: $gradeLevel • $quarter', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54)),
              ],
            ),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoScreen(
                      firstName: user!.firstName,
                      middleName: user!.middleName,
                      lastName: user!.lastName,
                      fullName: user!.fullName,
                      email: user!.email,
                      gradeLevel: user!.gradeLevel.toString(),
                      section: user!.section,
                      quarter: user!.quarter,
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Sign Out'),
            onTap: () => _dashboardController.signOut(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardBody(String fullName) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Welcome, ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextSpan(text: '$fullName 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '"Isang Pangarap, Isang Tagumpay"',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _dashboardTile('Modules', Icons.menu_book, Colors.blue.shade100),
                _dashboardTile('Articles', Icons.play_circle_fill, Colors.red.shade100),
                _dashboardTile('Mock Exam', Icons.edit_note, Colors.green.shade100),
                _dashboardTile('Final Exam', Icons.assignment_turned_in, Colors.orange.shade100),
                _dashboardTile('Certificate', Icons.verified, Colors.purple.shade100),
                _dashboardTile('Video Lessons', Icons.video_library, Colors.teal.shade100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardTile(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _handleTileTap(title),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 2))],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.black54),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTileTap(String title) {
    switch (title) {
      case 'Modules':
        _dashboardController.showModulesDialog(context, modules);
        break;
      case 'Articles':
        _dashboardController.showArticlesDialog(context, modules);
        break;
      case 'Mock Exam':
        _dashboardController.showDifficultyDialog(context, user);
        break;
      case 'Certificate':
        Navigator.push(context, MaterialPageRoute(builder: (context) => CertificateScreen()));
        break;
      case 'Video Lessons':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoLessonPage()));
        break;
      case 'Final Exam':
        if (user != null && (user!.allowedAttempts ?? 0) > (user!.attempts ?? 0)) {
          _showCodeInputDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have reached the maximum number of exam attempts.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        break;
      default:
        _dashboardController.showSelected(context, title);
    }
  }

  void _showCodeInputDialog() {
  final TextEditingController codeController = TextEditingController();
  bool isObscured = true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Enter Final Exam Code',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please enter the access code to proceed with the final exam.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                obscureText: isObscured,
                decoration: InputDecoration(
                  hintText: 'Enter code here',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => isObscured = !isObscured),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Submit'),
              onPressed: () {
                final inputCode = codeController.text.trim();
                if (inputCode == 'CODE123') {
                  Navigator.pop(context); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamScreen(
                        gradeLevel: user!.gradeLevel.toString(),
                        quarter: user?.quarter,
                        user: user,
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Invalid code. Please try again.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

}
