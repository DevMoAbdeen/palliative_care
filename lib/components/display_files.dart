import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../constants.dart';
import '../models/file.dart';

class ShowImageScreen extends StatelessWidget {
  final String uri;
  final bool isWantDownload;

  const ShowImageScreen({super.key, required this.uri, required this.isWantDownload});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: !isWantDownload
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {},
                  ),
                ),
              ),
        body: GestureDetector(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: kBackgroundColor,
            child: Center(
              child: Hero(
                tag: uri,
                child: Image.network(
                  uri,
                  fit: BoxFit.fill,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return Image.asset(
                      "images/no_network.jpg",
                    );
                  },
                ),
              ),
            ),
          ),
          // onPanDown: (s){
          //   Navigator.pop(context);
          // },
          onPanEnd: (end) {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

///////////////////////////////

class ShowImage extends StatelessWidget {
  final SelectedFile selectedImage;
  final Function funOnClickShow;
  final Function funOnClickDelete;

  const ShowImage({
    Key? key,
    required this.selectedImage,
    required this.funOnClickShow,
    required this.funOnClickDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.cancel_outlined,
            color: Colors.red,
            size: 32,
          ),
          onPressed: () {
            funOnClickDelete();
          },
        ),
        kSizeBoxW8,
        GestureDetector(
          onTap: () {
            funOnClickShow();
          },
          child: Row(
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: Hero(
                  tag: selectedImage.file.path,
                  child: Image.file(
                    File(selectedImage.file.path),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              kSizeBoxW16,
              Text(
                selectedImage.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

//////////////////

class ShowVideoScreen extends StatefulWidget {
  final String? videoUrl;
  final String? videoPath;

  const ShowVideoScreen({Key? key, required this.videoUrl, required this.videoPath}) : super(key: key);

  @override
  State<ShowVideoScreen> createState() => _ShowVideoScreenState();
}

class _ShowVideoScreenState extends State<ShowVideoScreen> {
  late VideoPlayerController _controller;

  bool isGettingVideo = false;

  @override
  void initState() {
    super.initState();
    isGettingVideo = true;
    _controller = widget.videoPath != null
        ? VideoPlayerController.file(File(widget.videoPath!))
        : VideoPlayerController.network(widget.videoUrl!)
      ..initialize().then((_) {
        _controller.play();
        isGettingVideo = false;
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video"),
      ),
      body: isGettingVideo
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

//////////////////////

class ShowSelectedVideos extends StatefulWidget {
  final SelectedFile selectedVideo;
  final Function funOnClickShow;
  final Function funOnClickDelete;

  const ShowSelectedVideos({
    Key? key,
    required this.selectedVideo,
    required this.funOnClickShow,
    required this.funOnClickDelete,
  }) : super(key: key);

  @override
  State<ShowSelectedVideos> createState() => _ShowSelectedVideosState();
}

class _ShowSelectedVideosState extends State<ShowSelectedVideos> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.selectedVideo.file.path))
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.cancel_outlined,
            color: Colors.red,
            size: 32,
          ),
          onPressed: () {
            widget.funOnClickDelete();
          },
        ),
        kSizeBoxW8,
        GestureDetector(
          onTap: () {
            widget.funOnClickShow();
          },
          child: Row(
            children: [
              SizedBox(
                  width: 42,
                  height: 42,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
              ),
              kSizeBoxW16,
              Text(
                widget.selectedVideo.file.name,
                maxLines: 1,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  color: Colors.black,
                  // fontSize: 17,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

///////////////////////////////////

class DetailScreen extends StatelessWidget {
  final String imagePath;

  const DetailScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: kBackgroundColor,
          child: Center(
            child: Hero(
              tag: imagePath,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        // onPanDown: (s){
        //   Navigator.pop(context);
        // },
        onPanEnd: (end) {
          Navigator.pop(context);
        },
      ),
    );
  }
}
