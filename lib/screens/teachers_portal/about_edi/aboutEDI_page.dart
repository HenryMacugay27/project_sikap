import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AboutEDIPage extends StatelessWidget {
  final String assetPath;

  const AboutEDIPage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About EDI'),
        backgroundColor: Colors.green.shade100,
      ),
      body: SfPdfViewer.asset('assets/pdf/about_edi1.pdf'),  
    );
  }
}
