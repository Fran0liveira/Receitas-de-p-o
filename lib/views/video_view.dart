import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoView extends StatefulWidget {
  String url;
  VideoView({this.url});

  @override
  State<VideoView> createState() => VideoViewState();
}

class VideoViewState extends State<VideoView> {
  YoutubePlayerController _controller;
  String videoId = '';

  @override
  Widget build(BuildContext context) {
    log('url received: ${widget.url}');
    videoId = YoutubePlayer.convertUrlToId(widget.url);

    _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          mute: false,
          autoPlay: false,
          disableDragSeek: true,
        ));

    _controller.load(videoId);
    _controller.pause();

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          onReady: () {
            log('Player is ready');
          },
          actionsPadding: EdgeInsets.all(5),
          bottomActions: [
            CurrentPosition(),
            ProgressBar(
              isExpanded: true,
            ),
            RemainingDuration(),
            PlaybackSpeedButton(),
          ]),
      builder: (context, player) {
        return Column(
          children: [
            player,
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
