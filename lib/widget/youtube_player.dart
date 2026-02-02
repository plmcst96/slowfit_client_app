import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeModalPlayer extends StatefulWidget {
  final String url;
  const YoutubeModalPlayer({super.key, required this.url});

  @override
  State<YoutubeModalPlayer> createState() => _YoutubeModalPlayerState();
}

class _YoutubeModalPlayerState extends State<YoutubeModalPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final id = YoutubePlayer.convertUrlToId(widget.url)!;

    _controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
