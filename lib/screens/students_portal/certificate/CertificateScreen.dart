import 'package:flutter/material.dart';
import 'CertificateGenerator.dart';
import 'dart:io';
import '../../../utils/authentication/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/user.dart';

class CertificateScreen extends StatefulWidget {
  @override
  _CertificateScreenState createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final Auth _auth = Auth();
  User? user;
  String? _generatedPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCertificateScreen();
  }

  Future<void> _initializeCertificateScreen() async {
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
        setState(() {
          user = fetchedUser;
        });
      }
    } catch (e) {
      debugPrint('Error initializing certificate screen: $e');
    }
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    final file = await CertificateGenerator.generateCertificate(user?.fullName ?? 'Unknown');
    setState(() {
      _generatedPath = file.path;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fullName = user?.fullName ?? 'Guest';
    final isEligible = user?.isPassed == true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Certificate'),
        backgroundColor: Colors.green.shade100,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome, $fullName!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: (_isLoading || !isEligible) ? null : _generate,
                icon: Icon(Icons.picture_as_pdf),
                label: Text('Generate Certificate'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: const Color.fromARGB(255, 200, 230, 201),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              if (!isEligible)
                Text(
                  'Certificate is only available if you have passed.',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 30),
              if (_isLoading)
                CircularProgressIndicator()
              else if (_generatedPath != null)
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_generatedPath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              else
                Text(
                  'No certificate generated yet.',
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
