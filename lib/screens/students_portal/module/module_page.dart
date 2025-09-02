import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ModulePage extends StatelessWidget {
  final String assetPath;

  const ModulePage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module'),
      ),
      body: SfPdfViewer.asset(assetPath),
    );
  }
}
