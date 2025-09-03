import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_sikap/screens/teachers_portal/student_report/student_report_screen.dart';
import '../../../utils/authentication/auth.dart';
import '../../../../controller/dashboard_controller.dart';
import '../../../../model/user.dart';
import '../../user/user_info_screen.dart';
import 'package:project_sikap/screens/teachers_portal/about_edi/aboutEDI_page.dart'; // ✅ Import ModulePage
import '../../../../model/module.dart'; // ✅ Assuming you use a Module model

class MainDashboardTeacher extends StatefulWidget {
  const MainDashboardTeacher({super.key});

  @override
  State<MainDashboardTeacher> createState() => _MainDashboardTeacherState();
}

class _MainDashboardTeacherState extends State<MainDashboardTeacher> {
  final Auth _auth = Auth();
  final DashboardController _dashboardController = DashboardController();
  String? fullName, gradeLevel, quarter, firstName;
  List<User>? students;
  bool isLoading = true;

  late User currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final data = userDoc.docs.first.data();
        final user = User.fromMap(data);
        setState(() {
          currentUser = user;
          firstName = user.firstName;
          gradeLevel = user.gradeLevel.toString();
          quarter = user.quarter;
          fullName = user.fullName ?? 'Loading...';
        });

        _fetchStudentsInfo();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _fetchStudentsInfo() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final studentDocs = await FirebaseFirestore.instance
          .collection('user')
          .where('teacher', isEqualTo: uid)
          .get();

      if (studentDocs.docs.isNotEmpty) {
        setState(() {
          students = studentDocs.docs
              .map((doc) => User.fromMap(doc.data()))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
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
      drawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardBody(),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(200, 230, 201, 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(fullName ?? 'Loading...',
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Grade: $gradeLevel • $quarter',
                    style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54)),
              ],
            ),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoScreen(
                      firstName: currentUser!.firstName,
                      middleName: currentUser!.middleName,
                      lastName: currentUser!.lastName,
                      fullName: currentUser!.fullName,
                      email: currentUser!.email,
                      gradeLevel: currentUser!.gradeLevel.toString(),
                      section: currentUser!.section,
                      quarter: currentUser!.quarter,
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

  Widget _buildDashboardBody() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                    text: 'Welcome, ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextSpan(
                    text: '$firstName 👋',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '"Isang Pangarap, Isang Tagumpay"',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _dashboardTile(
                    title: 'My Students',
                    icon: Icons.group,
                    color: Colors.green.shade100,
                    onTap: () {
                      if (students != null && students!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _StudentListScreen(
                              students: students!,
                              teacher: currentUser,
                            ),
                          ),
                        );
                      }
                    }),
                _dashboardTile(
                    title: 'About EDI',
                    icon: Icons.book_outlined,
                    color: Colors.red.shade100,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutEDIPage(assetPath: 'assets/pdf/about_edi/about_edi.pdf'),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 2))
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.black54),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentListScreen extends StatelessWidget {
  final List<User> students;
  final User teacher;

  const _StudentListScreen({required this.students, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Students")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentGraphScreen(
                  student: student,
                  teacher: teacher,
                ),
              ),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: Colors.green.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 50, color: Colors.green.shade500),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.fullName,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const SizedBox(height: 6),
                          Text('Grade: ${student.gradeLevel}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54)),
                          Text('Section: ${student.section}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 20, color: Colors.black45),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
