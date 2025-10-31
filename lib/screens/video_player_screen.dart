import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({
    super.key,
    required this.video,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _controller;
  bool _hasInternet = false;
  bool _isCheckingConnectivity = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    final videoId = widget.video.videoId;
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          loop: false,
          enableCaption: true,
        ),
      );
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = connectivityResult != ConnectivityResult.none;
      _isCheckingConnectivity = false;
    });
  }

  Future<void> _openInYouTubeApp() async {
    final youtubeUrl = Uri.parse(widget.video.youtubeUrl);
    final youtubeMobileUrl = Uri.parse(
      widget.video.youtubeUrl.replaceFirst('https://www.youtube.com', 'youtube'),
    );

    if (await canLaunchUrl(youtubeMobileUrl)) {
      await launchUrl(youtubeMobileUrl);
    } else if (await canLaunchUrl(youtubeUrl)) {
      await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingConnectivity) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Video'),
          backgroundColor: const Color(0xFF2196F3),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasInternet || widget.video.videoId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.video.titleVietnamese),
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'Cần kết nối internet để xem video',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Video YouTube cần internet để phát.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _checkConnectivity,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Kiểm tra lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _openInYouTubeApp,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Mở trong YouTube'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.video.titleVietnamese,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_controller != null)
              YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: const Color(0xFF2196F3),
                progressColors: const ProgressBarColors(
                  playedColor: Color(0xFF2196F3),
                  handleColor: Color(0xFF2196F3),
                ),
              ),
            if (widget.video.description != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mô tả:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.video.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
