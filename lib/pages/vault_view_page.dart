import 'dart:io';

import 'package:calculator/domain/media_file.dart';
import 'package:calculator/pages/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user_command/user_command.dart';
import 'package:video_player/video_player.dart';

class VaultViewerPage extends StatefulWidget {
  const VaultViewerPage({Key? key}) : super(key: key);

  @override
  State<VaultViewerPage> createState() => _VaultViewerPageState();
}

class _VaultViewerPageState extends State<VaultViewerPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  int index = 0;
  final minDragDistance = 20;
  Offset _tapDownPosition = Offset.zero;
  List<String> mediaFiles = [];

  @override
  Widget build(BuildContext context) {
    hideAndroidStatusBar();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);

    if (mediaFiles.isEmpty) {
      MediaFileService().findMediaFilesInVault().then((value) {
        setState(() {
          mediaFiles = value;
          var lastSeenFilePath = LastSeenFilePathRepository().read();
          index = mediaFiles.indexOf(lastSeenFilePath);
          if (index == -1) index = 0;
        });
      });
    }
    return Scaffold(
        key: _key,
        drawer: const MainMenu(),
        endDrawer: const MainMenu(), //TODO edit meta such as rating and tags
        body: Listener(
          onPointerDown: (PointerDownEvent details) {
            _tapDownPosition = details.position;
          },
          onPointerUp: (PointerUpEvent details) {
            var tapUpPosition = details.position;
            var deltaX = _tapDownPosition.dx - tapUpPosition.dx;
            var deltaY = _tapDownPosition.dy - tapUpPosition.dy;
            bool horizontal = deltaX.abs() > deltaY.abs();
            if (dragLeft(horizontal, deltaX)) {
              openLeftDrawer(context);
            } else if (dragRight(horizontal, deltaX)) {
              openRightDrawer(context);
            } else if (dragUp(horizontal, deltaY)) {
              showPreviousItem(context);
            } else if (dragDown(horizontal, deltaY)) {
              showNextItem(context);
            }
          },

          child: GestureDetector(
            // onScaleStart: (ScaleStartDetails details) {
            //   _startScale = _scale;
            // },
            // onScaleUpdate: (ScaleUpdateDetails details) {
            //   setState(() {
            //     _scale = _startScale! * details.scale;
            //     if (_scale < 1.0) _scale = 1.0;
            //     print(_scale);
            //   });
            // },
            // },
            onLongPress: () {
              CommandPopupMenu(context, [
                Command(
                    name: 'Delete',
                    icon: Icons.delete,
                    action: () {
                      setState(() {
                        String mediaFilePathToRemove = mediaFiles[index];
                        mediaFiles.remove(mediaFilePathToRemove);
                        File(mediaFilePathToRemove).delete();
                      });
                    },
                    visible: mediaFiles.isNotEmpty)
              ]);
            },
            child: Container(
                constraints: const BoxConstraints.expand(),
                //needs to have a color to expand the GestureDetector to use the whole screen
                color: Colors.black,
                child: mediaFiles.isEmpty
                    ? const SizedBox.shrink()
                    : FittedBox(
                        fit: BoxFit.contain,
                        child: ItemViewer(mediaFiles[index]))),
          ),
          // FittedBox(fit: BoxFit.contain, child: Image.file(File(items[0]))),
        ));
  }

  bool dragLeft(bool horizontal, double deltaX) =>
      horizontal && deltaX < -minDragDistance;

  bool dragRight(bool horizontal, double deltaX) =>
      horizontal && deltaX > minDragDistance;

  bool dragUp(bool horizontal, double deltaY) =>
      !horizontal && deltaY < -minDragDistance;

  bool dragDown(bool horizontal, double deltaY) =>
      !horizontal && deltaY > minDragDistance;

  void showNextItem(BuildContext context) {
    if (index < (mediaFiles.length - 1)) {
      setState(() {
        index++;
        LastSeenFilePathRepository().write(mediaFiles[index]);
      });
    }
    //TODO show meta data with: showSnackBar(context, text);
  }

  void showPreviousItem(BuildContext context) {
    if (index > 0) {
      setState(() {
        index--;
        LastSeenFilePathRepository().write(mediaFiles[index]);
      });
    }
    //TODO show meta data with: showSnackBar(context, text);
  }

  /// hides time, messages and telephone status bar
  void hideAndroidStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    //You can bring it back with SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values)
  }

  void openLeftDrawer(BuildContext context) {
    _key.currentState!.openDrawer();
  }

  void openRightDrawer(BuildContext context) {
    _key.currentState!.openEndDrawer();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
          BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class ItemViewer extends StatelessWidget {
  final String url;

  const ItemViewer(this.url, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaFile mediaFile = MediaFile(url);
    switch (mediaFile.type) {
      case MediaFileType.image:
      case MediaFileType.animatedImage:
        return Image.file(File(url));
      case MediaFileType.movie:
        return VideoViewer(url);
      default:
        return FittedBox(
            fit: BoxFit.fill, child: Text('Not supported:\n $url'));
    }
  }
}

/// TODO see https://pub.dev/packages/video_player
class VideoViewer extends StatefulWidget {
  final String _url;

  const VideoViewer(this._url, {Key? key}) : super(key: key);

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late VideoPlayerController _controller;

  _VideoViewerState();

  @override
  void initState() {
    super.initState();
    initController();
  }

  void initController() {
    _controller = VideoPlayerController.file(File(widget._url));

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {
          _controller.play();
        }));
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    if (!_controller.dataSource.contains(widget._url)) {
      //load new video
      initController();
    }

    return SizedBox(
      width: 200,
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(_controller),
            _ControlsOverlay(controller: _controller),
            VideoProgressIndicator(_controller, allowScrubbing: true),
          ],
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white.withOpacity(0.7),
                      size: 30.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
