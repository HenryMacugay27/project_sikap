import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CertificateGenerator {
  static Future<File> generateCertificate(String name) async {
    // Load background image from assets
    final ByteData data = await rootBundle.load('assets/certificate/bses_template.jpg'); 
    final Uint8List bytes = data.buffer.asUint8List();
    img.Image image = img.decodeImage(bytes)!;

    // Draw name on the image
    img.drawString(image, x: 300, y: 700, name, font: img.arial48,
        color:  img.ColorUint8.rgb(0, 0, 0));
      //img.drawString(image, name, font: img.arial48,  color: img.ColorUint8.rgb(0, 0, 0));


    // Save to file/storage/emulated/0/DCIM/
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('/storage/emulated/0/DCIM/Camera/certificate.jpg');
    await file.writeAsBytes(img.encodePng(image));
    return file;
  }
}
