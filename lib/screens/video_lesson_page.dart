import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoLessonPage extends StatefulWidget {
  const VideoLessonPage({super.key});

  @override
  State<VideoLessonPage> createState() => _VideoLessonPageState();
}

class _VideoLessonPageState extends State<VideoLessonPage> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  String _currentVideo = 'assets/video/week1Quarter1.mp4';
  String _currentTitle = 'Week 1 - Quarter 1';
  String _currentDescription = 'Introduction to Quarter 1 - Week 1 lessons.';

  final List<Map<String, String>> _videoList = [
    {
      'title': 'Week 1 - Quarter 1',
      'path': 'assets/video/week1Quarter1.mp4',
      'description': 'Introduction to Quarter 1 - Week 1 lessons.'
    },
    {
      'title': 'Week 2 - Quarter 2',
      'path': 'assets/video/week2Quarter2.mp4',
      'description': 'Learning materials for Week 2 of Quarter 2.'
    },
    {
      'title': 'Week 3 - Quarter 3',
      'path': 'assets/video/week3Quarter3.mp4',
      'description': 'Focus on Quarter 3 - Week 3 important topics.'
    },
    {
      'title': 'Week 4 - Quarter 4',
      'path': 'assets/video/week4Quarter4.mp4',
      'description': 'Detailed discussion for Week 4 of Quarter 4.'
    },
    {
      'title': 'Week 5 - Quarter 5',
      'path': 'assets/video/week5Quarter5.mp4',
      'description': 'Week 5 lessons covering Quarter 5 materials.'
    },
    {
      'title': 'Week 6 - Quarter 6',
      'path': 'assets/video/week6Quarter6.mp4',
      'description': 'Quarter 6 - Week 6 highlights and topics.'
    },
    {
      'title': 'Week 7 - Quarter 7',
      'path': 'assets/video/week7Quarter7.mp4',
      'description': 'Week 7 overview of Quarter 7 discussions.'
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo(_currentVideo, _currentTitle, _currentDescription);
  }

  Future<void> _initializeVideo(String path, String title, String description) async {
    if (_isInitialized) {
      await _controller.pause();
      await _controller.dispose();
    }

    _controller = VideoPlayerController.asset(path);
    await _controller.initialize();
    _controller.setLooping(true);

    _controller.addListener(() {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    });

    setState(() {
      _isInitialized = true;
      _currentVideo = path;
      _currentTitle = title;
      _currentDescription = description;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(position.inMinutes.remainder(60));
    final seconds = twoDigits(position.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _goFullScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(controller: _controller),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: Colors.black.withOpacity(0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                _formatDuration(_controller.value.position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const Spacer(),
              Text(
                _formatDuration(_controller.value.duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: _goFullScreen,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              padding: EdgeInsets.zero,
              colors: const VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.white54,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _videoList.map((video) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.play_circle_fill_rounded, color: Colors.red),
            title: Text(video['title']!),
            onTap: () => _initializeVideo(
              video['path']!,
              video['title']!,
              video['description']!,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Lessons'), centerTitle: true),
      body: _isInitialized
          ? SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showControls = !_showControls),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Stack(
                            children: [
                              VideoPlayer(_controller),
                              if (_showControls)
                                Positioned.fill(
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(
                                        _controller.value.isPlaying
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_filled,
                                        size: 80,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _controller.value.isPlaying
                                              ? _controller.pause()
                                              : _controller.play();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              if (_showControls)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: _buildBottomControls(),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currentDescription,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'More Lessons',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  _buildVideoList(),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  const FullScreenVideoPlayer({super.key, required this.controller});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  String _formatDuration(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(position.inMinutes.remainder(60));
    final seconds = twoDigits(position.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: Colors.black.withOpacity(0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                _formatDuration(widget.controller.value.position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const Spacer(),
              Text(
                _formatDuration(widget.controller.value.duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: VideoProgressIndicator(
              widget.controller,
              allowScrubbing: true,
              padding: EdgeInsets.zero,
              colors: const VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.white54,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Center(
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(widget.controller),
                if (_showControls)
                  Positioned.fill(
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          widget.controller.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 80,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.controller.value.isPlaying
                                ? widget.controller.pause()
                                : widget.controller.play();
                          });
                        },
                      ),
                    ),
                  ),
                if (_showControls)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomControls(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
