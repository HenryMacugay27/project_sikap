import 'package:flutter/material.dart';
import 'package:project_sikap/main.dart';
import 'package:project_sikap/model/user.dart';
import '../../../utils/authentication/auth.dart';

// Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();

  int? _selectedGradeLevel;
  String? _selectedQuarter;
  String? _selectedRole;
  User? _selectedTeacher;

  final Auth _auth = Auth();
  List<User>? teachers;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeachersInfo();
  }

  Future<void> _fetchTeachersInfo() async {
    try {
      final teacherDocs = await FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'teacher')
          .get();

      if (teacherDocs.docs.isNotEmpty) {
        setState(() {
          teachers = teacherDocs.docs
              .map((doc) => User.fromMap(doc.data()))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error silently or log it
    }
  }

  void _registerStudent() {
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection('user');

    userCollection.add({
      'first_name': _firstNameController.text.trim(),
      'middle_name': _middleNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'full_name':
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      'email': _emailController.text.trim(),
      'uid': _auth.currentUser!.uid,
      'grade_level': _selectedGradeLevel,
      'section': _sectionController.text.trim(),
      'quarter': _selectedQuarter,
      'role': _selectedRole ?? 'student',
      'teacher': _selectedTeacher?.uid ?? '',
      'teacher_name': _selectedTeacher?.fullName ?? '',
      //asdasd
      'created_at': FieldValue.serverTimestamp(),
      'allowedAttempts' : 3,
      'attempts' : 0,
      'isPassed' : false,
      'status' : 'Enrolled',

    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        await _auth.createUserWithEmailAndPassword(email, password);
        _registerStudent();

        if (!mounted) return;

        if(_selectedRole == 'student'){
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
        } else {
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_firstNameController, 'First Name'),
              const SizedBox(height: 12),
              _buildTextField(_middleNameController, 'Middle Name'),
              const SizedBox(height: 12),
              _buildTextField(_lastNameController, 'Last Name'),
              const SizedBox(height: 12),
              _buildTextField(_emailController, 'Email',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(_passwordController, 'Password',
                  obscureText: true),
              const SizedBox(height: 12),
              _buildRoleDropdown(),
              const SizedBox(height: 12),

              // Student-specific fields
              if (_selectedRole == 'student') ...[
                if (!isLoading) _buildTeacherDropdown(),
                const SizedBox(height: 12),
                _buildGradeDropdown(),
                const SizedBox(height: 12),
                _buildQuarterDropdown(),
                const SizedBox(height: 12),
                _buildTextField(_sectionController, 'Section'),
                const SizedBox(height: 12),
              ],

              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Enter $labelText' : null,
    );
  }

  Widget _buildGradeDropdown() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Grade Level',
        border: OutlineInputBorder(),
      ),
      value: _selectedGradeLevel,
      items: [7, 8, 9, 10]
          .map((grade) => DropdownMenuItem(
                value: grade,
                child: Text('Grade $grade'),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedGradeLevel = value;
        });
      },
      validator: (value) =>
          _selectedRole == 'student' && value == null ? 'Select a grade level' : null,
    );
  }

  Widget _buildQuarterDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Quarter',
        border: OutlineInputBorder(),
      ),
      value: _selectedQuarter,
      items: ['1st Quarter', '2nd Quarter', '3rd Quarter', '4th Quarter']
          .map((quarter) => DropdownMenuItem(
                value: quarter,
                child: Text(quarter),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedQuarter = value;
        });
      },
      validator: (value) =>
          _selectedRole == 'student' && value == null ? 'Select a quarter' : null,
    );
  }

  Widget _buildTeacherDropdown() {
    return DropdownButtonFormField<User>(
      decoration: const InputDecoration(
        labelText: 'Select Teacher',
        border: OutlineInputBorder(),
      ),
      value: _selectedTeacher,
      items: teachers!.map((teacher) {
        final name = teacher.fullName;
        return DropdownMenuItem<User>(
          value: teacher,
          child: Text(name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedTeacher = value;
        });
      },
      validator: (value) =>
          _selectedRole == 'student' && value == null ? 'Select a teacher' : null,
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
      ),
      value: _selectedRole,
      items: ['student', 'teacher'].map((role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role[0].toUpperCase() + role.substring(1)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRole = value;
        });
      },
      validator: (value) => value == null ? 'Select a role' : null,
    );
  }
}
