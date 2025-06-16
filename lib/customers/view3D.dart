import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class View3DScreen extends StatefulWidget {
  // In a real implementation, you would pass the facility ID or video URL
  const View3DScreen({super.key});

  @override
  State<View3DScreen> createState() => _View3DScreenState();
}

class _View3DScreenState extends State<View3DScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;

  // This would come from your backend in a real implementation
  final String _sampleVideoUrl = 'https://example.com/sample_3d_tour.mp4';

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you would fetch the video URL from your backend
      final videoUrl = _sampleVideoUrl;

      _controller = VideoPlayerController.network(videoUrl);
      await _controller.initialize();
      _controller.addListener(() {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      });

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load video: ${e.toString()}";
      });
      print("Error loading video: $e");
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2C4F),
        elevation: 2,
        title: const Text(
          "3D View",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.only(left: 18),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B2C4F)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF2D3142), fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2C4F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoPlayer(),
          _buildTitle(),
          _buildDescription(),
          _buildUploadDateInfo(),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          _buildPlayPauseOverlay(),
          _buildVideoControls(),
        ],
      ),
    );
  }

  Widget _buildPlayPauseOverlay() {
    return _isPlaying
        ? const SizedBox.shrink()
        : Container(
            color: Colors.black26,
            child: Center(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _controller.play();
                  });
                },
                icon: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 70,
                ),
              ),
            ),
          );
  }

  Widget _buildVideoControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.black45,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isPlaying ? _controller.pause() : _controller.play();
                });
              },
            ),
            Expanded(
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF1B2C4F),
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.white54,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            Text(
              _formatDuration(_controller.value.position),
              style: const TextStyle(color: Colors.white),
            ),
            const Text(' / ', style: TextStyle(color: Colors.white)),
            Text(
              _formatDuration(_controller.value.duration),
              style: const TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              onPressed: () {
                // Implementation for full screen mode
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: const Text(
        "3D Tour of the Facility",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B2C4F),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About this 3D Tour",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Explore our state-of-the-art sports facility in immersive 3D. This video showcases all our amenities, courts, and services available to customers. Get a comprehensive view of what to expect when you visit us.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3142),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadDateInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Video Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFF1B2C4F),
              ),
              const SizedBox(width: 8),
              const Text(
                "Uploaded on: ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3142),
                ),
              ),
              Text(
                "June 15, 2023", // Would come from API in a real app
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF2D3142).withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Color(0xFF1B2C4F)),
              const SizedBox(width: 8),
              const Text(
                "Uploaded by: ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3142),
                ),
              ),
              Text(
                "Facility Manager", // Would come from API in a real app
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF2D3142).withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
