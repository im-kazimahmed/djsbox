import 'dart:developer';

import 'package:yourappname/main.dart';
import 'package:yourappname/pages/videoplaypause.dart';
import 'package:yourappname/provider/videoscreenprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoScreen extends StatefulWidget {
  final int pagePos;
  final String videoUrl, videoId, thumbnailImg;
  const VideoScreen({
    Key? key,
    required this.pagePos,
    required this.videoUrl,
    required this.videoId,
    required this.thumbnailImg,
  }) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with RouteAware {
  VideoPlayerController? videoController;
  late VideoScreenProvider videoScreenProvider;
  late Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    videoScreenProvider =
        Provider.of<VideoScreenProvider>(context, listen: false);
    videoScreenProvider.addShortView("2", widget.videoId);
    super.initState();
  }

  checkAdAndInitialize() {
    initController(startPlaying: true);
  }

  Future<void> initController({required bool startPlaying}) async {
    printLog("current videoUrl =======> ${widget.videoUrl}");
    printLog("current pagePos ===> ${widget.pagePos}");
    try {
      if (videoController == null) {
        videoController =
            VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
        _initializeVideoPlayerFuture =
            videoController?.initialize().then((value) {
          if (!mounted) return;
          setState(() {});
          if (startPlaying) {
            playVideo();
          }
        });
      }
    } catch (e) {
      printLog("setVideoController Exception =========> $e");
    }
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void didPop() {
    printLog("========= didPop =========");
    super.didPop();
  }

  @override
  void didPopNext() {
    printLog("========= didPopNext =========");
    super.didPopNext();
  }

  @override
  void didPush() {
    printLog(
        "visibleInfo =====didPush====> ${videoScreenProvider.visibleInfo?.visibleFraction}");
    if (videoScreenProvider.visibleInfo?.visibleFraction == 0.0) {
      clearController();
    }
    printLog("========= didPush =========");
    super.didPush();
  }

  @override
  void didPushNext() {
    printLog(
        "visibleInfo =====didPushNext====> ${videoScreenProvider.visibleInfo?.visibleFraction}");
    if (videoScreenProvider.visibleInfo?.visibleFraction == 0.0) {
      clearController();
    }
    printLog("========= didPushNext =========");
    super.didPushNext();
  }

  @override
  void dispose() {
    videoScreenProvider.clearProvider();
    routeObserver.unsubscribe(this);
    clearController();
    printLog("========= dispose =========");
    super.dispose();
  }

  playVideo() async {
    if (videoController != null) {
      await videoController?.play();
      await videoController?.setLooping(true);
      if (!mounted) return;
      setState(() {});
    }
  }

  pauseVideo() async {
    if (videoController != null) {
      await videoController?.pause();
      if (!mounted) return;
      setState(() {});
    }
  }

  clearController() async {
    videoController?.dispose();
    videoController = null;
  }

  @override
  Widget build(BuildContext context) {
    printLog("Enter Video Build");
    return VisibilityDetector(
      key: Key('reel_${widget.pagePos}'),
      onVisibilityChanged: (visibilityInfo) async {
        if (!mounted) return;
        final videoScreenProvider =
            Provider.of<VideoScreenProvider>(context, listen: false);
        videoScreenProvider.setVisibilityInfo(visibilityInfo);
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        printLog(
            '=========== Widget ${visibilityInfo.key} is $visiblePercentage% visible===========');
        if (visiblePercentage > 80.0) {
          checkAdAndInitialize();
        } else {
          pauseVideo();
          clearController();
        }
      },
      child: _buildFuture(),
    );
  }

  Widget _buildFuture() {
    return _buildPlayer();
  }

  Widget _buildPlayer() {
    if (videoController == null) {
      return _buildImage();
    } else {
      return GestureDetector(
        onTap: () {
          log("click");
          if (!(videoController?.value.isPlaying ?? false)) {
            playVideo();
          } else {
            pauseVideo();
          }
        },
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SizedBox(
                        width: videoController?.value.size.width,
                        height: videoController?.value.size.height,
                        child: AspectRatio(
                          aspectRatio:
                              videoController?.value.aspectRatio ?? 16 / 9,
                          child: VideoPlayer(videoController!),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (videoController != null &&
                          !(videoController!.value.isPlaying)) {
                        playVideo();
                      } else {
                        pauseVideo();
                      }
                    },
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: VideoPlayPause(controller: videoController!)),
                  ),
                ],
              );
            } else {
              return _buildLoadingWithImage();
            }
          },
        ),
      );
    }
  }

  Widget _buildImage() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          MyNetworkImage(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            imagePath: widget.thumbnailImg,
            fit: BoxFit.cover,
          ),

          /* Play Button */
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 60,
              width: 60,
              decoration: Utils.setGradTTBBGWithBorder(
                  colorPrimaryDark.withOpacity(0.45),
                  colorPrimary.withOpacity(0.45),
                  transparent,
                  40,
                  0),
              child: InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child:
                      MyImage(imagePath: "ic_play.png", height: 20, width: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWithImage() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          MyNetworkImage(
            imagePath: widget.thumbnailImg,
            fit: BoxFit.contain,
          ),

          /* Play Button */
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 60,
              width: 60,
              child: Utils.pageLoader(context),
            ),
          ),
        ],
      ),
    );
  }
}
