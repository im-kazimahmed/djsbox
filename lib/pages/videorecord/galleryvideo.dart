import 'dart:io';
import 'package:yourappname/main.dart';
import 'package:yourappname/pages/videorecord/videopreview.dart';
import 'package:yourappname/provider/galleryvideoprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/log.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GalleryVideo extends StatefulWidget {
  final String vFilePath, vDuration, contestId, hashtagName, hashtagId;

  const GalleryVideo(
      {Key? key,
      required this.vFilePath,
      required this.vDuration,
      required this.contestId,
      required this.hashtagName,
      required this.hashtagId})
      : super(key: key);

  @override
  State<GalleryVideo> createState() => _GalleryVideoState();
}

class _GalleryVideoState extends State<GalleryVideo> with RouteAware {
  late ProgressDialog prDialog;
  VideoPlayerController? _controller;
  late GalleryVideoProvider galleryVideoProvider;
  List<String>? selectedAudioDetails;

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    galleryVideoProvider =
        Provider.of<GalleryVideoProvider>(context, listen: false);
    initController();
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
        File(widget.vFilePath),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      )..initialize().then((value) {
          if (!mounted) return;
          setState(() {
            printLog(
                "visibleInfo visibleFraction =========> ${galleryVideoProvider.visibleInfo?.visibleFraction}");
            if (galleryVideoProvider.visibleInfo?.visibleFraction == 0.0) {
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
        "visibleInfo =====didPush====> ${galleryVideoProvider.visibleInfo?.visibleFraction}");
    if (galleryVideoProvider.visibleInfo?.visibleFraction == 0.0) {
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
        "visibleInfo =====didPushNext====> ${galleryVideoProvider.visibleInfo?.visibleFraction}");
    if (galleryVideoProvider.visibleInfo?.visibleFraction == 0.0) {
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
    return VisibilityDetector(
      key: const Key('GalleryVideo'),
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;
        galleryVideoProvider.setVisibilityInfo(visibilityInfo);
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        printLog(
            '=========== Widget ${visibilityInfo.key} is $visiblePercentage% visible ===========');
        if (galleryVideoProvider.visibleInfo?.visibleFraction == 0.0) {
          if (_controller != null) {
            _controller?.dispose();
            _controller = null;
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: transparent,
          title: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            ),
            onTap: () async {
              // // printLog("Clicked on Sound Title!");
              // // selectedAudioDetails = await Navigator.push(
              // //   context,
              // //   MaterialPageRoute(
              // //     builder: (context) {
              // //       return const SoundList();
              // //     },
              // //   ),
              // // );
              // printLog("selectedAudioDetails ======> $selectedAudioDetails");
              // if (selectedAudioDetails != null) {
              //   await galleryVideoProvider.setSelectedAudio(
              //       audioPath: selectedAudioDetails?[0] ?? "",
              //       audioId: selectedAudioDetails?[1] ?? "");
              // }
            },
            child: Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyImage(
                    width: 18,
                    height: 18,
                    imagePath: "ic_song.png",
                    color: white,
                  ),
                  const SizedBox(width: 10),
                  Consumer<GalleryVideoProvider>(
                    builder: (context, galleryVideoProvider, child) {
                      if ((galleryVideoProvider.selectedAudioPath ?? "") ==
                          "") {
                        return MyText(
                          multilanguage: false,
                          color: white,
                          text: "add_sound",
                          fontsizeNormal: 13,
                          fontwaight: FontWeight.w600,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        );
                      } else {
                        return Expanded(
                          child: MyText(
                            color: white,
                            text: p.basename(
                                galleryVideoProvider.selectedAudioPath ?? ""),
                            fontsizeNormal: 13,
                            fontwaight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.start,
                            fontstyle: FontStyle.normal,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                mergeAudioVideo();
              },
            )
          ],
        ),
        extendBodyBehindAppBar: true,
        body: _buildPlayer(),
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

  void mergeAudioVideo() async {
    File? finalVideo = File(widget.vFilePath);
    printLog("finalVideo ========> $finalVideo");
    if (galleryVideoProvider.selectedAudioPath.toString().isNotEmpty &&
        (p.extension(galleryVideoProvider.selectedAudioPath ?? "") == ".mp3" ||
            p.extension(galleryVideoProvider.selectedAudioPath ?? "") ==
                ".aac")) {
      Utils.showProgress(context);
      await mixAudioVideo(
          videoPath: finalVideo.path,
          audioPath: selectedAudioDetails?[0] ?? "");
    } else {
      goToPreview(finalVideo);
    }
  }

  Future mixAudioVideo({
    required String videoPath,
    required String audioPath,
  }) async {
    String? output = "";
    Directory? documentDirectory;
    if (Platform.isAndroid) {
      documentDirectory = await getExternalStorageDirectory();
    } else {
      documentDirectory = await getApplicationDocumentsDirectory();
    }
    File mergeFile = File(p.join(documentDirectory?.path ?? "",
        '${DateTime.now().millisecondsSinceEpoch.toString()}.mp4'));
    output = mergeFile.path;
    printLog("mixAudioVideo output ===> $output");
    printLog("mixAudioVideo videoPath ===> $videoPath");
    printLog("mixAudioVideo audioPath ===> $audioPath");

    if (_controller != null) {
      _controller?.pause();
    }

    await FFmpegKit.executeAsync(
        "-y -i $videoPath -i $audioPath -map 0:v -map 1:a -c:v copy -shortest $output",
        (session) async {
      printLog(
          "=============================== EXECUTED ===============================");
      final returnCode = await session.getReturnCode();
      printLog("mergingExecuted returnCode ===> $returnCode");
      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        try {
          printLog("mergeFile =========> ${mergeFile.path}");
        } catch (e) {
          printLog("mergingExecuted Exception ===> $e");
        } finally {
          await prDialog.hide();
          session.cancel;
          goToPreview(mergeFile);
        }
      } else if (ReturnCode.isCancel(returnCode)) {
        // CANCEL
        await prDialog.hide();
        printLog("mergingExecuted CANCEL ===> ${session.getLogsAsString()}");
      } else {
        // ERROR
        await prDialog.hide();
        printLog("Error");
        final failStackTrace = await session.getFailStackTrace();
        printLog("failStackTrace ===> $failStackTrace");
        List<Log> logs = await session.getLogs();
        for (var element in logs) {
          printLog("Message ===> ${element.getMessage()}");
        }
        printLog(
            "Command failed with state ${await session.getState()} and rc ${await session.getReturnCode()}.${await session.getFailStackTrace()}  ${await session.getAllLogsAsString()}");
      }
    }, (logs) {
      printLog("logs ====> ${logs.getMessage()}");
    });
  }

  void goToPreview(File? videoFile) {
    printLog("videoFile ===> ${videoFile?.path ?? ""}");
    String soundId = galleryVideoProvider.selectedAudioId ?? "0";
    printLog("soundId =====> $soundId");
    final route = MaterialPageRoute(
      maintainState: false,
      fullscreenDialog: true,
      builder: (_) => VideoPreview(
        filePath: videoFile?.path ?? "",
        vDuration: "30",
        soundId: soundId,
        contestId:
            !galleryVideoProvider.isContestRemoved ? (widget.contestId) : "",
        hashtagId: widget.hashtagId,
        hashtagName: widget.hashtagName,
      ),
    );
    galleryVideoProvider.clearProvider();
    Navigator.push(context, route);
  }
}
