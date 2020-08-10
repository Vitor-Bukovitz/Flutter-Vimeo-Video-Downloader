import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_offline_saver/services/api.dart';
import 'package:video_player/video_player.dart';

final String id = "382169007";

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlatButton(
            color: Colors.red,
            textColor: Colors.white,
            child: Text("Downloaded Video Screen"),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OnlineVidedoScreen()));
            },
          ),
          FlatButton(
            color: Colors.red,
            textColor: Colors.white,
            child: Text("Online Video Screen"),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DownloadedVideoScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class OnlineVidedoScreen extends StatefulWidget {
  @override
  _OnlineVidedoScreenState createState() => _OnlineVidedoScreenState();
}

class _OnlineVidedoScreenState extends State<OnlineVidedoScreen> {
  String downloadValue = "";
  void showDownloadProgress(received, total) {
    if (total != -1) {
      setState(() {
        downloadValue = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(downloadValue)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text("Download Video"),
                onPressed: () =>
                    Api().downloadVideo(id, showDownloadProgress).then((value) {
                  setState(() {});
                }),
              ),
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text("Erase Video"),
                onPressed: () => Api().deleteVideo(id).then((value) {
                  print("Deleted");
                  setState(() {});
                }),
              ),
            ],
          ),
          VideoPlayerScreen(true),
        ],
      ),
    );
  }
}

class DownloadedVideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          VideoPlayerScreen(false),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final bool readLocal;
  VideoPlayerScreen(this.readLocal);
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;
  String text = "";

  @override
  void initState() {
    super.initState();
    if (widget.readLocal) {
      readLocal();
    } else {
      readOnline();
    }
  }

  void readLocal() async {
    File localFile = await Api().getVideoFile(id);
    if (await localFile.exists()) {
      _controller = VideoPlayerController.file(localFile)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
    } else {
      text = "Video not downloaded";
      setState(() {});
    }
  }

  void readOnline() async {
    String url = await Api().getVideoUrl(id);
    print(url);
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      }).catchError((error) {
        print(error);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
        _controller != null
            ? _controller.value.initialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container()
            : Container(),
        _controller != null
            ? FlatButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller != null
                      ? _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow
                      : Icons.wallpaper,
                ),
              )
            : Container(),
      ],
    );
  }
}
