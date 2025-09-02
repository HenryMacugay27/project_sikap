import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:audioplayers/audioplayers.dart';

class StoryPage extends StatefulWidget {
  final String assetPath;
  final String audioPath;

  const StoryPage({super.key, required this.assetPath, required this.audioPath});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // Replace with your actual audio asset path (ensure it's in pubspec.yaml)
      await _audioPlayer.play(AssetSource(widget.audioPath));
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });

    // Optional feedback using SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPlaying ? 'Audio playing...' : 'Audio paused.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
      ),
      body: Stack(
        children: [
          SfPdfViewer.asset(widget.assetPath),
          Positioned(
            bottom: 20,
            right: 20, // Changed from left to right
            child: FloatingActionButton(
              onPressed: _toggleAudio,
              backgroundColor: _isPlaying ? Colors.redAccent : Colors.green,
              tooltip: _isPlaying ? 'Pause Audio' : 'Play Audio',
              child: Icon(
                _isPlaying ? Icons.pause : Icons.volume_up,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
