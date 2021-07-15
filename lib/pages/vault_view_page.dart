import 'dart:io';

import 'package:calculator/pages/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

List<String> items = [
  //TODO get from DirectoryService
  '/storage/9016-4EF8/Android/data/nth.calculator.calculator/files/vault/1.png',
  '/storage/9016-4EF8/Android/data/nth.calculator.calculator/files/vault/2.png',
  '/storage/9016-4EF8/Android/data/nth.calculator.calculator/files/vault/3.png',
  '/storage/9016-4EF8/Android/data/nth.calculator.calculator/files/vault/4.mp4',
  '/storage/9016-4EF8/Android/data/nth.calculator.calculator/files/vault/5.gif',
  '/storage/9016-4EF8/Android/data/nth.calculator.calculator/files/vault/6.jpg',
];

class VaultViewerPage extends StatefulWidget {
  // Future<File> getFile(BuildContext context)  async {
  //   DirectoryService directoryService= context.read<DirectoryService>();
  //   Directory? vaultDirectory=await directoryService.vaultDirectory;
  //   File file=File('${vaultDirectory!.path}/1.png');
  //   return file;
  // }

  @override
  _VaultViewerPageState createState() => _VaultViewerPageState();
}

class _VaultViewerPageState extends State<VaultViewerPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  int index = 0;
  final minDragDistance = 20;
  Offset _tapDownPosition = Offset.zero;
  double _scale = 1.0;
  double? _startScale;

  @override
  Widget build(BuildContext context) {
    hideAndroidStatusBar();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);

    return Scaffold(
      key: _key,
      drawer: MainMenu(),
      endDrawer: MainMenu(), //TODO edit meta such as rating and tags
      body: Listener(
        onPointerDown: (PointerDownEvent details) {
          _tapDownPosition = details.position;
        },
        onPointerUp: (PointerUpEvent details) {
          var _tapUpPosition = details.position;
          var deltaX = _tapDownPosition.dx - _tapUpPosition.dx;
          var deltaY = _tapDownPosition.dy - _tapUpPosition.dy;
          bool horizontal = deltaX.abs() > deltaY.abs();
          if (dragLeft(horizontal, deltaX)) {
            openLeftDrawer(context);
          } else if (dragRight(horizontal, deltaX)) {
            openRightDrawer(context);
          } else if (dragUp(horizontal, deltaY)) {
            openPreviousItem(context);
          } else if (dragDown(horizontal, deltaY)) {
            openNextItem(context);
          }
        },

        // child: GestureDetector(
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
        child: Container(
            constraints: BoxConstraints.expand(),
            //needs to have a color to expand the GestureDetector to use the whole screen
            color: Colors.black,
            child: FittedBox(
                fit: BoxFit.contain, child: ItemViewer(items[index]))),
      ),
      // FittedBox(fit: BoxFit.contain, child: Image.file(File(items[0]))),
    );
  }

  bool dragLeft(bool horizontal, double deltaX) =>
      horizontal && deltaX < -minDragDistance;

  bool dragRight(bool horizontal, double deltaX) =>
      horizontal && deltaX > minDragDistance;

  bool dragUp(bool horizontal, double deltaY) =>
      !horizontal && deltaY < -minDragDistance;

  bool dragDown(bool horizontal, double deltaY) =>
      !horizontal && deltaY > minDragDistance;

  void openNextItem(BuildContext context) {
    if (index < (items.length - 1))
      setState(() {
        index++;
        print(index);
      });
    //TODO show meta data with: showSnackBar(context, text);
  }

  void openPreviousItem(BuildContext context) {
    if (index > 0)
      setState(() {
        index--;
        print(index);
      });
    //TODO show meta data with: showSnackBar(context, text);
  }

  /// hides time, messages and telephone status bar
  void hideAndroidStatusBar() {
    SystemChrome.setEnabledSystemUIOverlays([]);
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

  ItemViewer(this.url);

  @override
  Widget build(BuildContext context) {
    if (url.endsWith('.jpg') || url.endsWith('.png') || url.endsWith('.gif'))
      return Image.file(File(url)); //TODO return Image or Video
    else if (url.endsWith('.mp4'))
      return VideoViewer(url);
    else
      return FittedBox(fit: BoxFit.fill, child: Text('Not supported:\n $url'));
  }
}

/// TODO see https://pub.dev/packages/video_player
class VideoViewer extends StatefulWidget {
  final String _url;

  VideoViewer(this._url);

  @override
  _VideoViewerState createState() => _VideoViewerState(_url);
}

class _VideoViewerState extends State<VideoViewer> {
  late VideoPlayerController _controller;
  final String _url;

  _VideoViewerState(this._url);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(_url));

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {
          _controller.play();
        }));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        // SingleChildScrollView(
        Container(
      width: 200,
      //   padding: const EdgeInsets.all(20),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(_controller),
            _ControlsOverlay(controller: _controller),
            VideoProgressIndicator(_controller, colors: ,allowScrubbing: true),
          ],
        ),
      ),
      // ),
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
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50.0,
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
