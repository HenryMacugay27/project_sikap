import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_sikap/utils/internet_connectivity/connectivity.dart' as internet;
import 'package:project_sikap/utils/widget/error_handler/error_dialog.dart' as error_dialog;
import 'model/user.dart';
import 'screens/students_portal/registration/register_page.dart'; 
import 'screens/students_portal/dashbard/main_dashboard_student.dart'; 
import 'utils/authentication/auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/teachers_portal/dashboard/main_dashboard_teacher.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'Student Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomePage(), // Show the Welcome Page first with buttons
    );
  }
}

class WelcomePage extends StatefulWidget {
  
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Auth _auth = Auth();
  User? user;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchUserInfo() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      QuerySnapshot query =
          await FirebaseFirestore.instance
              .collection('user')
              .where('uid', isEqualTo: uid)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data() as Map<String, dynamic>;
        setState(() {
          user = User.fromMap(data);
        });


        if (!mounted) return;

        if(user?.role == 'student'){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainDashboardStudent()),
          );

        }
        if(user?.role == 'teacher'){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainDashboardTeacher()),
          );
        }
      }
    } catch (e) {
      throw ('Error fetching student info: $e');
    }
  }
 

  Future<void> _login() async { 
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    
    try { 

      bool hasInternet = await internet.Connectivity().hasInternetAccess();
      if (hasInternet) {
        
        await _auth.signInWithEmailAndPassword(email, password);

        /*
        if(_usernameController.text.trim() == '1'){
          await _auth.signInWithEmailAndPassword('abby.macugay@gmail.com', '1234567');
        }
        if(_usernameController.text.trim() == '2'){
          await _auth.signInWithEmailAndPassword('macugayhenry@gmail.com', '1234567');
        }
        if(_usernameController.text.trim() == '3'){
          await _auth.signInWithEmailAndPassword('evangeline.benosa@gmail.com', '1234567');
        }*/

      } else {
        if (!mounted) return;
        error_dialog.showErrorDialog(
          context,
          'No internet connection. Please try again later.',
        );
      }

      if (!mounted) return;
      
      fetchUserInfo(); // Fetch student info after login

    } catch (e) {
      if (!mounted) return;
      error_dialog.showErrorDialog(
          context,
          'Login failed: Incorrect email or password.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/main_logo.png',
                height: 300,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 30),
              
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: Text(
                  "Don't have an account? Click here to register.",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}
