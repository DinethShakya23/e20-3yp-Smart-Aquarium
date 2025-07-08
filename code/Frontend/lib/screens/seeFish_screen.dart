import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';          // Import package
import 'package:media_kit_video/media_kit_video.dart'; // Import package

class SeefishScreen extends StatefulWidget {
  const SeefishScreen({super.key});

  @override
  State<SeefishScreen> createState() => _SeefishScreenState();
}

class _SeefishScreenState extends State<SeefishScreen> {
  late final Player player; // Declared as late final, will be initialized in initState
  late final VideoController controller;

  final String streamUrl = 'rtsp://18.140.68.45:8555/mystream';

  @override
  void initState() {
    super.initState();
    print("Flutter app attempting to connect to streamUrl: $streamUrl with media_kit");

    // --- IMPORTANT: Initialize the player with the configuration to enable logging ---
    player = Player(
      configuration: const PlayerConfiguration(
        // Set the log level to debug
        //logLevel: MpvLogLevel.debug, // This should now be recognized after fixing pubspec.yaml
      ),
    );
    // --- END IMPORTANT ---

    controller = VideoController(player); // Initialize controller after player

    // Open the stream
    player.open(Media(streamUrl), play: true);
  }

  @override
  void dispose() {
    player.dispose(); // Dispose the player when the widget is unmounted
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Fish Activity'),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * (9 / 16), // Example aspect ratio
          child: Video(controller: controller), // Use the Video widget
        ),
      ),
    );
  }
}