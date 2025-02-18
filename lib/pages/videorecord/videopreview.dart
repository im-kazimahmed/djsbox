import 'dart:developer';
import 'dart:io';

import 'package:yourappname/main.dart';
import 'package:yourappname/pages/videorecord/postvideo.dart';
import 'package:yourappname/provider/videopreviewprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPreview extends StatefulWidget {
  final String filePath, vDuration, soundId, contestId, hashtagName, hashtagId;

  const VideoPreview(
      {Key? key,
      required this.filePath,
      required this.vDuration,
      required this.soundId,
      required this.contestId,
      required this.hashtagName,
      required this.hashtagId})
      : super(key: key);

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> with RouteAware {
  late VideoPreviewProvider videoPreviewProvider;
  VideoPlayerController? _controller;

  @override
  void initState() {
    printLog("soundId ====> ${widget.soundId}");
    videoPreviewProvider =
        Provider.of<VideoPreviewProvider>(context, listen: false);
    initController();
    log("Initilize Player");
    super.initState();
  }

  @override
  void didChangeDependencies() {
    printLog("========= didChangeDependencies =========");
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  /// Called when the current route has been popped off.
  @override
  void didPop() {
    printLog("========= didPop =========");
    super.didPop();
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {
    printLog("========= didPopNext =========");
    if (_controller == null) {
      initController();
    }
    super.didPopNext();
  }

  initController() async {
    try {
      _controller = VideoPlayerController.file(
        File(widget.filePath),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      )..initialize().then((value) {
          if (!mounted) return;
          setState(() {
            printLog(
                "visibleInfo visibleFraction =========> ${videoPreviewProvider.visibleInfo?.visibleFraction}");
            if (videoPreviewProvider.visibleInfo?.visibleFraction == 0.0) {
              if (_controller != null) _controller?.pause();
            } else {
              if (_controller != null) _controller?.play();
            }
          });
        });
      _controller?.seekTo(Duration.zero);
      _controller?.setLooping(true);
    } catch (e) {
      printLog("videoScreen initController Exception ==> $e");
    }
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {
    printLog(
        "visibleInfo =====didPush====> ${videoPreviewProvider.visibleInfo?.visibleFraction}");
    if (videoPreviewProvider.visibleInfo?.visibleFraction == 0.0) {
      _controller?.dispose();
      _controller = null;
    }
    printLog("========= didPush =========");
    super.didPush();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    printLog(
        "visibleInfo =====didPushNext====> ${videoPreviewProvider.visibleInfo?.visibleFraction}");
    if (videoPreviewProvider.visibleInfo?.visibleFraction == 0.0) {
      _controller?.dispose();
      _controller = null;
    }
    printLog("========= didPushNext =========");
    super.didPushNext();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    printLog("========= dispose =========");
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printLog("========= Enter Preview =========");
    return VisibilityDetector(
      key: const Key('Preview'),
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;
        videoPreviewProvider.setVisibilityInfo(visibilityInfo);
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        printLog(
            '=========== Widget ${visibilityInfo.key} is $visiblePercentage% visible ===========');
        if (videoPreviewProvider.visibleInfo?.visibleFraction == 0.0) {
          if (_controller != null) {
            _controller?.dispose();
            _controller = null;
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: MyText(
              color: white,
              text: "Preview",
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textBig,
              multilanguage: false,
              inter: false,
              maxline: 2,
              fontwaight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          elevation: 0,
          backgroundColor: transparent,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            _buildPlayer(),
            Positioned.fill(
              bottom: 25,
              right: 20,
              left: 20,
              child: Align(
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: () async {
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostVideo(
                          videoFile: File(widget.filePath),
                          contestId: widget.contestId,
                          vDuration: widget.vDuration,
                          soundId: widget.soundId,
                          hashtagId: widget.hashtagId,
                          hashtagName: widget.hashtagName,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: colorAccent),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                            color: white,
                            text: "Done",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            multilanguage: false,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 10),
                        MyImage(width: 15, height: 15, imagePath: "ic_send.png")
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (!(_controller?.value.isInitialized ?? false)) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return GestureDetector(
        onTap: () {
          if (_controller!.value.isPlaying) {
            if (_controller != null) _controller?.pause();
          } else {
            if (_controller != null) _controller?.play();
          }
        },
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: _controller?.value.size.width,
              height: _controller?.value.size.height,
              child: AspectRatio(
                aspectRatio: _controller?.value.aspectRatio ?? 16 / 9,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        ),
      );
    }
  }
}
