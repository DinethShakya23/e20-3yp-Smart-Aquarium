import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class SeefishScreen extends StatefulWidget {
  const SeefishScreen({super.key});

  @override
  State<SeefishScreen> createState() => _SeefishScreenState();
}

class _SeefishScreenState extends State<SeefishScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  final String streamUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  @override
  void initState() {
    super.initState();

    // Allow all orientations while on this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = VideoPlayerController.network(streamUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller
            ..setLooping(true)
            ..play();
        }
      });
  }

  @override
  void dispose() {
    // Lock back to portrait when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 4.0,
        shadowColor: Colors.blueGrey.shade500,
        title: const Text(
          '🐟 Live Fish Activity',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0468BF), Color(0xFFA1D6F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Video player with orientation handling
          if (_isInitialized)
            OrientationBuilder(
              builder: (context, orientation) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                );
              },
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Bottom banner
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(199, 237, 24, 24),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.videocam, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Live Streaming...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
