import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  String? _errorMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    String url = widget.videoUrl;
    // neu thieu extension, them .mp4
    if (!url.contains('.') && !url.contains('?')) {
      url = '$url.mp4';
    }

    debugPrint("VideoPlayer: Initializing for URL: $url");
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize()
          .then((_) {
            debugPrint("VideoPlayer: Initialized successfully");
            if (mounted) {
              setState(() {
                _isError = false;
                _errorMessage = null;
              });
            }
          })
          .catchError((error) {
            debugPrint("VideoPlayer: Error initializing video ($url): $error");
            if (mounted) {
              setState(() {
                _isError = true;
                _errorMessage = error.toString();
              });
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Lỗi tải video",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? "Không rõ nguyên nhân",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isError = false;
                      _errorMessage = null;
                    });
                    _initializeVideo();
                  },
                  child: const Text(
                    "Thử lại",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 250,
        width: double.infinity,
        color: Colors.black,
        child: _controller.value.isInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  _buildPlayPauseOverlay(),
                  _buildControlsOverlay(),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildPlayPauseOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: !_controller.value.isPlaying
            ? Container(
                color: Colors.black26,
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white70,
                    size: 64,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: VideoProgressIndicator(
        _controller,
        allowScrubbing: true,
        colors: const VideoProgressColors(
          playedColor: Colors.blueAccent,
          bufferedColor: Colors.white24,
          backgroundColor: Colors.white12,
        ),
        padding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }
}
