import 'dart:developer';
import 'dart:io';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/pages/profile.dart';
import 'package:yourappname/provider/shortprovider.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mymarqueetext.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:yourappname/widget/nopost.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/pages/videoscreen.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class Shorts extends StatefulWidget {
  final String? shortType;
  final int? initialIndex;
  const Shorts({Key? key, this.shortType, this.initialIndex}) : super(key: key);

  @override
  State<Shorts> createState() => ShortsState();
}

class ShortsState extends State<Shorts> {
  SharedPre sharePref = SharedPre();
  late ProgressDialog prDialog;
  late ShortProvider shortProvider;
  final commentController = TextEditingController();
  late ScrollController commentListController;
  late ScrollController reportReasonController;
  int checkboxIndex = 0;
  bool ischange = true;
  List<VideoPlayerController> controllers = [];
  late VideoPlayerController controller;
  late ScrollController replaycommentController;
  late Future<void> initializeVideoPlayerFuture;

  @override
  void initState() {
    shortProvider = Provider.of<ShortProvider>(context, listen: false);
    audioPlayer.pause();
    getApi();
    commentListController = ScrollController();
    reportReasonController = ScrollController();
    replaycommentController = ScrollController();
    commentListController.addListener(_scrollListener);
    reportReasonController.addListener(_scrollListenerReportReason);
    replaycommentController.addListener(_scrollListenerReplayComment);
    super.initState();
    printLog("Userid==> ${Constant.userID}");
  }

  getApi() async {
    if (widget.shortType == "profile") {
      await shortProvider.getcontentbyChannelShort(
          Constant.userID, Constant.channelID, "3", "1");
    } else if (widget.shortType == "watchlater") {
      await shortProvider.getContentByWatchLater("3", "1");
    } else {
      await shortProvider.getShortList(1);
    }
  }

  _scrollListener() async {
    if (!commentListController.hasClients) return;
    if (commentListController.offset >=
            commentListController.position.maxScrollExtent &&
        !commentListController.position.outOfRange &&
        (shortProvider.currentPageComment ?? 0) <
            (shortProvider.totalPageComment ?? 0)) {
      _fetchCommentNewData(
          shortProvider.commentId, shortProvider.currentPageComment ?? 0);
    }
  }

  _scrollListenerReportReason() async {
    if (!reportReasonController.hasClients) return;
    if (reportReasonController.offset >=
            reportReasonController.position.maxScrollExtent &&
        !reportReasonController.position.outOfRange &&
        (shortProvider.reportcurrentPage ?? 0) <
            (shortProvider.reporttotalPage ?? 0)) {
      await shortProvider.setReportReasonLoadMore(true);
      _fetchReportReason(shortProvider.reportcurrentPage ?? 0);
    }
  }

  _scrollListenerReplayComment() async {
    if (!replaycommentController.hasClients) return;
    if (replaycommentController.offset >=
            replaycommentController.position.maxScrollExtent &&
        !replaycommentController.position.outOfRange &&
        (shortProvider.currentPageReplayComment ?? 0) <
            (shortProvider.totalPageReplayComment ?? 0)) {
      await shortProvider.setReplayCommentLoadMore(true);
      _fetchReplayCommentData(shortProvider.replayCommentId,
          shortProvider.currentPageReplayComment ?? 0);
    }
  }

  Future _fetchReportReason(int? nextPage) async {
    printLog("reportmorePage  =======> ${shortProvider.reportmorePage}");
    printLog("reportcurrentPage =======> ${shortProvider.reportcurrentPage}");
    printLog("reporttotalPage   =======> ${shortProvider.reporttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await shortProvider.getReportReason("2", (nextPage ?? 0) + 1);
    printLog(
        "fetchReportReason length ==> ${shortProvider.reportReasonList?.length}");
  }

  Future _fetchAllShort() async {
    printLog("isMorePage  =======> ${shortProvider.morePage}");
    printLog("currentPage =======> ${shortProvider.currentPage}");
    printLog("totalPage   =======> ${shortProvider.totalPage}");
    int nextPage = (shortProvider.currentPage ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.currentPage ?? 0) <= (shortProvider.totalPage ?? 0) &&
        nextPage <= (shortProvider.totalPage ?? 0)) {
      await shortProvider.getShortList(nextPage);
    }
    printLog(
        "shortVideoList length ==> ${shortProvider.shortVideoList?.length}");
  }

  Future _fetchCommentNewData(contentid, int? nextPage) async {
    printLog("isMorePage  =======> ${shortProvider.morePageComment}");
    printLog("currentPage =======> ${shortProvider.currentPageComment}");
    printLog("totalPage   =======> ${shortProvider.totalPageComment}");
    int nextPage = (shortProvider.currentPageComment ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.currentPageComment ?? 0) <=
            (shortProvider.totalPageComment ?? 0) &&
        nextPage <= (shortProvider.totalPageComment ?? 0)) {
      await shortProvider.getComment("3", contentid, nextPage);
    }
    printLog("commentlist length ==> ${shortProvider.commentList?.length}");
  }

  Future _fetchUserShort() async {
    printLog("userShortmorePage  =======> ${shortProvider.userShortmorePage}");
    printLog(
        "userShortcurrentPage =======> ${shortProvider.profileShortcurrentPage}");
    printLog(
        "userShorttotalPage   =======> ${shortProvider.profileShorttotalPage}");
    int nextPage = (shortProvider.profileShortcurrentPage ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.profileShortcurrentPage ?? 0) <=
            (shortProvider.profileShorttotalPage ?? 0) &&
        nextPage <= (shortProvider.profileShorttotalPage ?? 0)) {
      await shortProvider.getcontentbyChannelShort(
          Constant.userID, Constant.channelID, "3", nextPage);
    }
    printLog(
        "UsershortList length ==> ${shortProvider.profileShortList?.length}");
  }

  Future _fetchWatchLaterShort() async {
    printLog("userShortmorePage  =======> ${shortProvider.userShortmorePage}");
    printLog(
        "userShortcurrentPage =======> ${shortProvider.profileShortcurrentPage}");
    printLog(
        "userShorttotalPage   =======> ${shortProvider.profileShorttotalPage}");
    int nextPage = (shortProvider.profileShortcurrentPage ?? 0) + 1;
    printLog("nextPage   ========> $nextPage");
    if ((shortProvider.profileShortcurrentPage ?? 0) <=
            (shortProvider.profileShorttotalPage ?? 0) &&
        nextPage <= (shortProvider.profileShorttotalPage ?? 0)) {
      await shortProvider.getcontentbyChannelShort(
          Constant.userID, Constant.channelID, "3", nextPage);
    }
    printLog(
        "UsershortList length ==> ${shortProvider.profileShortList?.length}");
  }

  Future<void> _fetchReplayCommentData(commentid, int? nextPage) async {
    printLog("isMorePage  ======> ${shortProvider.morePageReplayComment}");
    printLog("currentPage ======> ${shortProvider.currentPageReplayComment}");
    printLog("totalPage   ======> ${shortProvider.totalPageReplayComment}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await shortProvider.getReplayComment(commentid, (nextPage ?? 0) + 1);
    await shortProvider.setReplayCommentLoadMore(false);
  }

  @override
  void dispose() {
    // shortProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: colorPrimary,
        child: buildLayout(),
      ),
    );
  }

  Widget buildLayout() {
    if (widget.shortType == "profile") {
      return _buildProfileShort();
    } else if (widget.shortType == "watchlater") {
      return _buildWatchLaterShort();
    } else {
      return _buildShort();
    }
  }

/* Simple Short */
  Widget _buildShort() {
    return Consumer<ShortProvider>(
      builder: (context, shortprovider, child) {
        if (shortprovider.loading) {
          return shimmer();
        } else {
          if (shortprovider.shortModel.status == 200) {
            if (shortprovider.shortVideoList != null &&
                (shortprovider.shortVideoList?.length ?? 0) > 0) {
              return _buildShortPageView();
            } else {
              return const NoPost(title: "no_posts_available", subTitle: "");
            }
          } else {
            return const NoPost(title: "no_posts_available", subTitle: "");
          }
        }
      },
    );
  }

  Widget _buildShortPageView() {
    return Stack(
      children: [
        PageView.builder(
          controller: PageController(initialPage: 0, viewportFraction: 1),
          itemCount: shortProvider.shortVideoList?.length ?? 0,
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                /* Reels Video */
                VideoScreen(
                  pagePos: index,
                  thumbnailImg: shortProvider.shortVideoList?[index].portraitImg
                          .toString() ??
                      "",
                  videoId:
                      shortProvider.shortVideoList?[index].id.toString() ?? "",
                  videoUrl:
                      shortProvider.shortVideoList?[index].content.toString() ??
                          "",
                ),
                /* Like, Dislike, Comment, Share and More Buttons*/
                Positioned.fill(
                  bottom: 30,
                  right: 15,
                  left: 15,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Like Button With Like Count
                        InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider.shortVideoList?[index].isLike ==
                                  0) {
                                Utils.showSnackbar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                //  Call Like APi Call
                                if ((shortProvider.shortVideoList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    1) {
                                  printLog("Remove Api");
                                  await shortProvider.shortLike(
                                      index,
                                      "3",
                                      shortProvider.shortVideoList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await shortProvider.shortLike(
                                      index,
                                      "3",
                                      shortProvider.shortVideoList?[index].id
                                              .toString() ??
                                          "",
                                      "1",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: (shortProvider.shortVideoList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    1
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_likefill.png")
                                : MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_like.png"),
                          ),
                        ),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(shortProvider
                                    .shortVideoList?[index].totalLike
                                    .toString() ??
                                "")),
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        // Dislike Button With Deslike Count
                        InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider.shortVideoList?[index].isLike ==
                                  0) {
                                Utils.showSnackbar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                //  Call DisLike APi Call
                                if ((shortProvider.shortVideoList?[index]
                                            .isUserLikeDislike ??
                                        2) ==
                                    0) {
                                  printLog("Remove Api");
                                  await shortProvider.shortDislike(
                                      index,
                                      "3",
                                      shortProvider.shortVideoList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await shortProvider.shortDislike(
                                      index,
                                      "3",
                                      shortProvider.shortVideoList?[index].id
                                              .toString() ??
                                          "",
                                      "2",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: (shortProvider.shortVideoList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    2
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_dislikefill.png")
                                : MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_dislike.png"),
                          ),
                        ),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(shortProvider
                                    .shortVideoList?[index].totalDislike
                                    .toString() ??
                                "")),
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        // Commenet Button Bottom Sheet Open
                        InkWell(
                          onTap: () {
                            shortProvider.storeContentId(shortProvider
                                    .shortVideoList?[index].id
                                    .toString() ??
                                "");
                            // Call Comment bottom Sheet
                            shortProvider.getComment(
                                "3",
                                shortProvider.shortVideoList?[index].id
                                        .toString() ??
                                    "",
                                1);

                            commentBottomSheet(
                                videoid: shortProvider.shortVideoList?[index].id
                                        .toString() ??
                                    "",
                                index: index,
                                isShortType: "short");
                          },
                          child: MyImage(
                              width: 25,
                              height: 25,
                              imagePath: "ic_comment.png"),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(shortProvider
                                    .shortVideoList?[index].totalComment ??
                                0),
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        // Share Button
                        InkWell(
                          onTap: () {
                            Utils.shareApp(Platform.isIOS
                                ? "Hey! I'm Listening ${shortProvider.shortVideoList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                : "Hey! I'm Listening ${shortProvider.shortVideoList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                          },
                          child: MyImage(
                              width: 25, height: 25, imagePath: "ic_share.png"),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                            color: white,
                            text: "share",
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            multilanguage: true,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              moreBottomSheet(
                                shortProvider.shortVideoList?[index].userId
                                        .toString() ??
                                    "",
                                shortProvider.shortVideoList?[index].id
                                        .toString() ??
                                    "",
                              );
                            }
                          },
                          child: MyImage(
                              width: 20, height: 20, imagePath: "ic_more.png"),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: MyNetworkImage(
                                width: 50,
                                height: 50,
                                imagePath: shortProvider
                                        .shortVideoList?[index].portraitImg
                                        .toString() ??
                                    "",
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "music.gif"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                /* Channel Name, Reels Title */
                Positioned.fill(
                  bottom: 30,
                  left: 15,
                  right: 15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Uploded Reels User Image */

                      shortProvider.shortVideoList?[index].userId != 0
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Profile(
                                        isProfile: false,
                                        channelUserid: shortProvider
                                                .shortVideoList?[index].userId
                                                .toString() ??
                                            "",
                                        channelid: shortProvider
                                                .shortVideoList?[index]
                                                .channelId
                                                .toString() ??
                                            "",
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                width: 250,
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: MyNetworkImage(
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.cover,
                                          imagePath: shortProvider
                                                  .shortVideoList?[index]
                                                  .channelImage
                                                  .toString() ??
                                              ""),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: shortProvider
                                                  .shortVideoList?[index]
                                                  .channelName
                                                  .toString() ==
                                              ""
                                          ? MyText(
                                              color: white,
                                              text: "guestuser",
                                              multilanguage: true,
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal)
                                          : MyText(
                                              color: white,
                                              text: shortProvider
                                                      .shortVideoList?[index]
                                                      .channelName
                                                      .toString() ??
                                                  "",
                                              multilanguage: false,
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                    ),
                                    const SizedBox(width: 10),
                                    /* User Subscribe Button */
                                    Constant.userID !=
                                            shortProvider
                                                .shortVideoList?[index].userId
                                                .toString()
                                        ? InkWell(
                                            onTap: () async {
                                              if (Constant.userID == null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return const Login();
                                                    },
                                                  ),
                                                );
                                              } else {
                                                await shortProvider
                                                    .addremoveSubscribe(
                                                        index,
                                                        shortProvider
                                                                .shortVideoList?[
                                                                    index]
                                                                .userId
                                                                .toString() ??
                                                            "",
                                                        "1",
                                                        widget.shortType);
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 5, 5, 5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: shortProvider
                                                              .shortVideoList?[
                                                                  index]
                                                              .isSubscribe ==
                                                          0
                                                      ? colorAccent
                                                      : transparent,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: colorAccent)),
                                              child: MyText(
                                                  color: white,
                                                  text: shortProvider
                                                              .shortVideoList?[
                                                                  index]
                                                              .isSubscribe ==
                                                          0
                                                      ? "subscribe"
                                                      : "subscribed",
                                                  multilanguage: true,
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textSmall,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w600,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal),
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                MyImage(
                                    width: 25,
                                    height: 25,
                                    fit: BoxFit.cover,
                                    imagePath: "ic_user.png"),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: MyText(
                                      color: white,
                                      text: "Admin",
                                      multilanguage: false,
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textTitle,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                      /* User Title */
                      Container(
                        width: 250,
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                        child: SizedBox(
                          height: 20,
                          child: MyMarqueeText(
                              text: shortProvider.shortVideoList?[index].title
                                      .toString() ??
                                  "",
                              fontsize: Dimens.textMedium,
                              color: white),
                        ),
                      ),
                      /* Gif Image Music */
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Row(
                          children: [
                            MyImage(
                                width: 15,
                                height: 15,
                                imagePath: "music.png",
                                color: white),
                            const SizedBox(width: 15),
                            MyText(
                                color: white,
                                text: "originalsound",
                                textalign: TextAlign.center,
                                fontsizeNormal: 12,
                                multilanguage: true,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          /* Reels Pagination Content */
          onPageChanged: (index) async {
            if (index > 0 && (index % 2) == 0) {
              _fetchAllShort();
            }
            printLog("onPageChanged value ======> $index");
            log("totalComment==>${shortProvider.shortVideoList?[index].totalComment.toString() ?? ""}");
          },
        ),
      ],
    );
  }

/* Profile Short */
  Widget _buildProfileShort() {
    return Consumer<ShortProvider>(
      builder: (context, profileShortprovider, child) {
        if (profileShortprovider.loading) {
          return shimmer();
        } else {
          if (profileShortprovider.getContentbyChannelModel.status == 200) {
            if (profileShortprovider.profileShortList != null &&
                (profileShortprovider.profileShortList?.length ?? 0) > 0) {
              return _buildProfileShortPageView();
            } else {
              return const NoPost(title: "no_posts_available", subTitle: "");
            }
          } else {
            return const NoPost(title: "no_posts_available", subTitle: "");
          }
        }
      },
    );
  }

  Widget _buildProfileShortPageView() {
    return Stack(
      children: [
        PageView.builder(
          controller: PageController(initialPage: 0, viewportFraction: 1),
          itemCount: shortProvider.profileShortList?.length ?? 0,
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) {
            printLog("Index==>$index");
            printLog("initialindex==>${widget.initialIndex}");
            return Stack(
              children: [
                /* Reels Video */
                VideoScreen(
                  pagePos: index,
                  thumbnailImg: shortProvider
                          .profileShortList?[index].portraitImg
                          .toString() ??
                      "",
                  videoId:
                      shortProvider.profileShortList?[index].id.toString() ??
                          "",
                  videoUrl: shortProvider.profileShortList?[index].content
                          .toString() ??
                      "",
                ),
                /* Like, Dislike, Comment, Share and More Buttons*/
                Positioned.fill(
                  bottom: 30,
                  right: 15,
                  left: 15,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Like Button With Like Count
                        InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .profileShortList?[index].isLike ==
                                  0) {
                                Utils.showSnackbar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                //  Call Like APi Call
                                if ((shortProvider.profileShortList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    1) {
                                  printLog("Remove Api");
                                  await shortProvider.profileShortLike(
                                      index,
                                      "3",
                                      shortProvider.profileShortList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await shortProvider.profileShortLike(
                                      index,
                                      "3",
                                      shortProvider.profileShortList?[index].id
                                              .toString() ??
                                          "",
                                      "1",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: (shortProvider.profileShortList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    1
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_likefill.png")
                                : MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_like.png"),
                          ),
                        ),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(shortProvider
                                    .profileShortList?[index].totalLike
                                    .toString() ??
                                "")),
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        // Dislike Button With Deslike Count
                        InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .profileShortList?[index].isLike ==
                                  0) {
                                Utils.showSnackbar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                //  Call DisLike APi Call
                                if ((shortProvider.profileShortList?[index]
                                            .isUserLikeDislike ??
                                        2) ==
                                    0) {
                                  printLog("Remove Api");
                                  await shortProvider.profileShortDislike(
                                      index,
                                      "3",
                                      shortProvider.profileShortList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await shortProvider.profileShortDislike(
                                      index,
                                      "3",
                                      shortProvider.profileShortList?[index].id
                                              .toString() ??
                                          "",
                                      "2",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: (shortProvider.profileShortList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    2
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_dislikefill.png")
                                : MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_dislike.png"),
                          ),
                        ),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(shortProvider
                                    .profileShortList?[index].totalDislike
                                    .toString() ??
                                "")),
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        // Commenet Button Bottom Sheet Open
                        InkWell(
                          onTap: () {
                            shortProvider.storeContentId(shortProvider
                                    .profileShortList?[index].id
                                    .toString() ??
                                "");
                            // Call Comment bottom Sheet
                            shortProvider.getComment(
                                "3",
                                shortProvider.profileShortList?[index].id
                                        .toString() ??
                                    "",
                                1);

                            commentBottomSheet(
                                videoid: shortProvider
                                        .profileShortList?[index].id
                                        .toString() ??
                                    "",
                                index: index,
                                isShortType: "profile");
                          },
                          child: MyImage(
                              width: 25,
                              height: 25,
                              imagePath: "ic_comment.png"),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(shortProvider
                                    .profileShortList?[index].totalComment ??
                                0),
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        // Share Button
                        InkWell(
                          onTap: () {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              Utils.shareApp(Platform.isIOS
                                  ? "Hey! I'm Listening ${shortProvider.profileShortList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                  : "Hey! I'm Listening ${shortProvider.profileShortList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                            }
                          },
                          child: MyImage(
                              width: 25, height: 25, imagePath: "ic_share.png"),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                            color: white,
                            text: "share",
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            multilanguage: true,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              moreBottomSheet(
                                shortProvider.profileShortList?[index].userId
                                        .toString() ??
                                    "",
                                shortProvider.profileShortList?[index].id
                                        .toString() ??
                                    "",
                              );
                            }
                          },
                          child: MyImage(
                              width: 20, height: 20, imagePath: "ic_more.png"),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: MyNetworkImage(
                                width: 50,
                                height: 50,
                                imagePath: shortProvider
                                        .profileShortList?[index].portraitImg
                                        .toString() ??
                                    "",
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "music.gif"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                /* Channel Name, Reels Title */
                Positioned.fill(
                  bottom: 30,
                  left: 15,
                  right: 15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Uploded Reels User Image */

                      shortProvider.profileShortList?[index].userId != 0
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Profile(
                                        isProfile: false,
                                        channelUserid: shortProvider
                                                .profileShortList?[index].userId
                                                .toString() ??
                                            "",
                                        channelid: shortProvider
                                                .profileShortList?[index]
                                                .channelId
                                                .toString() ??
                                            "",
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                width: 250,
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: MyNetworkImage(
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.cover,
                                          imagePath: shortProvider
                                                  .profileShortList?[index]
                                                  .channelImage
                                                  .toString() ??
                                              ""),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: shortProvider
                                                  .profileShortList?[index]
                                                  .channelName
                                                  .toString() ==
                                              ""
                                          ? MyText(
                                              color: white,
                                              text: "guestuser",
                                              multilanguage: true,
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal)
                                          : MyText(
                                              color: white,
                                              text: shortProvider
                                                      .profileShortList?[index]
                                                      .channelName
                                                      .toString() ??
                                                  "",
                                              multilanguage: false,
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                    ),
                                    const SizedBox(width: 10),
                                    /* User Subscribe Button */
                                    Constant.userID !=
                                            shortProvider
                                                .profileShortList?[index].userId
                                                .toString()
                                        ? InkWell(
                                            onTap: () async {
                                              if (Constant.userID == null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return const Login();
                                                    },
                                                  ),
                                                );
                                              } else {
                                                await shortProvider
                                                    .addremoveSubscribe(
                                                        index,
                                                        shortProvider
                                                                .profileShortList?[
                                                                    index]
                                                                .userId
                                                                .toString() ??
                                                            "",
                                                        "1",
                                                        widget.shortType);
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 5, 5, 5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: shortProvider
                                                              .profileShortList?[
                                                                  index]
                                                              .isSubscribe ==
                                                          0
                                                      ? colorAccent
                                                      : transparent,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: colorAccent)),
                                              child: MyText(
                                                  color: white,
                                                  text: shortProvider
                                                              .profileShortList?[
                                                                  index]
                                                              .isSubscribe ==
                                                          0
                                                      ? "subscribe"
                                                      : "subscribed",
                                                  multilanguage: true,
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textSmall,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w600,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal),
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                MyImage(
                                    width: 25,
                                    height: 25,
                                    fit: BoxFit.cover,
                                    imagePath: "ic_user.png"),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: MyText(
                                      color: white,
                                      text: "Admin",
                                      multilanguage: false,
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textTitle,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                      /* User Title */
                      Container(
                        width: 250,
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                        child: SizedBox(
                          height: 20,
                          child: MyMarqueeText(
                              text: shortProvider.profileShortList?[index].title
                                      .toString() ??
                                  "",
                              fontsize: Dimens.textMedium,
                              color: white),
                        ),
                      ),
                      /* Gif Image Music */
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Row(
                          children: [
                            MyImage(
                                width: 15,
                                height: 15,
                                imagePath: "music.png",
                                color: white),
                            const SizedBox(width: 15),
                            MyText(
                                color: white,
                                text: "originalsound",
                                textalign: TextAlign.center,
                                fontsizeNormal: 12,
                                multilanguage: true,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          /* Reels Pagination Content */
          onPageChanged: (index) async {
            if (index > 0 && (index % 2) == 0) {
              _fetchUserShort();
            }
            printLog("onPageChanged value ======> $index");
          },
        ),
        /* Back Button */
        Positioned.fill(
          top: 60,
          left: 20,
          right: 20,
          child: Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: MyImage(
                  width: 35,
                  height: 35,
                  imagePath: "ic_roundback.png",
                  color: white,
                ),
              )),
        ),
      ],
    );
  }

/* WatchLater Short */
  Widget _buildWatchLaterShort() {
    return Consumer<ShortProvider>(
      builder: (context, watchlaterShortprovider, child) {
        if (watchlaterShortprovider.loading) {
          return shimmer();
        } else {
          if (watchlaterShortprovider.watchlaterModel.status == 200) {
            if (watchlaterShortprovider.watchlaterShortList != null &&
                (watchlaterShortprovider.watchlaterShortList?.length ?? 0) >
                    0) {
              return _buildWatchLaterShortPageView();
            } else {
              return const NoPost(title: "no_posts_available", subTitle: "");
            }
          } else {
            return const NoPost(title: "no_posts_available", subTitle: "");
          }
        }
      },
    );
  }

  Widget _buildWatchLaterShortPageView() {
    return Stack(
      children: [
        PageView.builder(
          controller: PageController(initialPage: 0, viewportFraction: 1),
          itemCount: shortProvider.watchlaterShortList?.length ?? 0,
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) {
            printLog("Index==>$index");
            printLog("initialindex==>${widget.initialIndex}");
            return Stack(
              children: [
                /* Reels Video */
                VideoScreen(
                  pagePos: index,
                  thumbnailImg: shortProvider
                          .watchlaterShortList?[index].portraitImg
                          .toString() ??
                      "",
                  videoId:
                      shortProvider.watchlaterShortList?[index].id.toString() ??
                          "",
                  videoUrl: shortProvider.watchlaterShortList?[index].content
                          .toString() ??
                      "",
                ),
                /* Like, Dislike, Comment, Share and More Buttons*/
                Positioned.fill(
                  bottom: 30,
                  right: 15,
                  left: 15,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Like Button With Like Count
                        InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .watchlaterShortList?[index].isLike ==
                                  0) {
                                Utils.showSnackbar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                //  Call Like APi Call
                                if ((shortProvider.watchlaterShortList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    1) {
                                  printLog("Remove Api");
                                  await shortProvider.watchLaterShortLike(
                                      index,
                                      "3",
                                      shortProvider
                                              .watchlaterShortList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await shortProvider.watchLaterShortLike(
                                      index,
                                      "3",
                                      shortProvider
                                              .watchlaterShortList?[index].id
                                              .toString() ??
                                          "",
                                      "1",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: (shortProvider.watchlaterShortList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    1
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_likefill.png")
                                : MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_like.png"),
                          ),
                        ),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(shortProvider
                                    .watchlaterShortList?[index].totalLike
                                    .toString() ??
                                "")),
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        // Dislike Button With Deslike Count
                        InkWell(
                          onTap: () async {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              if (shortProvider
                                      .watchlaterShortList?[index].isLike ==
                                  0) {
                                Utils.showSnackbar(
                                    context, "youcannotlikethiscontent", true);
                              } else {
                                //  Call DisLike APi Call
                                if ((shortProvider.watchlaterShortList?[index]
                                            .isUserLikeDislike ??
                                        2) ==
                                    0) {
                                  printLog("Remove Api");
                                  await shortProvider.watchLaterShortDislike(
                                      index,
                                      "3",
                                      shortProvider
                                              .watchlaterShortList?[index].id
                                              .toString() ??
                                          "",
                                      "0",
                                      "0");
                                } else {
                                  await shortProvider.watchLaterShortDislike(
                                      index,
                                      "3",
                                      shortProvider
                                              .watchlaterShortList?[index].id
                                              .toString() ??
                                          "",
                                      "2",
                                      "0");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: (shortProvider.watchlaterShortList?[index]
                                            .isUserLikeDislike ??
                                        0) ==
                                    2
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_dislikefill.png")
                                : MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "ic_dislike.png"),
                          ),
                        ),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(int.parse(shortProvider
                                    .watchlaterShortList?[index].totalDislike
                                    .toString() ??
                                "")),
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        // Commenet Button Bottom Sheet Open
                        InkWell(
                          onTap: () {
                            shortProvider.storeContentId(shortProvider
                                    .watchlaterShortList?[index].id
                                    .toString() ??
                                "");
                            // Call Comment bottom Sheet
                            shortProvider.getComment(
                                "3",
                                shortProvider.watchlaterShortList?[index].id
                                        .toString() ??
                                    "",
                                1);

                            commentBottomSheet(
                                videoid: shortProvider
                                        .watchlaterShortList?[index].id
                                        .toString() ??
                                    "",
                                index: index,
                                isShortType: "watchlater");
                          },
                          child: MyImage(
                              width: 25,
                              height: 25,
                              imagePath: "ic_comment.png"),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                            color: white,
                            text: Utils.kmbGenerator(shortProvider
                                    .watchlaterShortList?[index].totalComment ??
                                0),
                            multilanguage: false,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        // Share Button
                        InkWell(
                          onTap: () {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              Utils.shareApp(Platform.isIOS
                                  ? "Hey! I'm Listening ${shortProvider.watchlaterShortList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                                  : "Hey! I'm Listening ${shortProvider.watchlaterShortList?[index].title.toString() ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                            }
                          },
                          child: MyImage(
                              width: 25, height: 25, imagePath: "ic_share.png"),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                            color: white,
                            text: "share",
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            multilanguage: true,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            } else {
                              moreBottomSheet(
                                shortProvider.watchlaterShortList?[index].userId
                                        .toString() ??
                                    "",
                                shortProvider.watchlaterShortList?[index].id
                                        .toString() ??
                                    "",
                              );
                            }
                          },
                          child: MyImage(
                              width: 20, height: 20, imagePath: "ic_more.png"),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: MyNetworkImage(
                                width: 50,
                                height: 50,
                                imagePath: shortProvider
                                        .watchlaterShortList?[index].portraitImg
                                        .toString() ??
                                    "",
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "music.gif"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                /* Channel Name, Reels Title */
                Positioned.fill(
                  bottom: 30,
                  left: 15,
                  right: 15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Uploded Reels User Image */

                      shortProvider.watchlaterShortList?[index].userId != 0
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Profile(
                                        isProfile: false,
                                        channelUserid: shortProvider
                                                .watchlaterShortList?[index]
                                                .userId
                                                .toString() ??
                                            "",
                                        channelid: shortProvider
                                                .watchlaterShortList?[index]
                                                .channelId
                                                .toString() ??
                                            "",
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                width: 250,
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: MyNetworkImage(
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.cover,
                                          imagePath: shortProvider
                                                  .watchlaterShortList?[index]
                                                  .channelImage
                                                  .toString() ??
                                              ""),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: shortProvider
                                                  .watchlaterShortList?[index]
                                                  .channelName
                                                  .toString() ==
                                              ""
                                          ? MyText(
                                              color: white,
                                              text: "guestuser",
                                              multilanguage: true,
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal)
                                          : MyText(
                                              color: white,
                                              text: shortProvider
                                                      .watchlaterShortList?[
                                                          index]
                                                      .channelName
                                                      .toString() ??
                                                  "",
                                              multilanguage: false,
                                              textalign: TextAlign.left,
                                              fontsizeNormal: Dimens.textTitle,
                                              inter: false,
                                              maxline: 1,
                                              fontwaight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal),
                                    ),
                                    const SizedBox(width: 10),
                                    /* User Subscribe Button */
                                    Constant.userID ==
                                            shortProvider
                                                .watchlaterShortList?[index]
                                                .userId
                                                .toString()
                                        ? InkWell(
                                            onTap: () async {
                                              if (Constant.userID == null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return const Login();
                                                    },
                                                  ),
                                                );
                                              } else {
                                                await shortProvider
                                                    .addremoveSubscribe(
                                                        index,
                                                        shortProvider
                                                                .watchlaterShortList?[
                                                                    index]
                                                                .userId
                                                                .toString() ??
                                                            "",
                                                        "1",
                                                        widget.shortType);
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 5, 5, 5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: shortProvider
                                                              .watchlaterShortList?[
                                                                  index]
                                                              .isSubscribe ==
                                                          0
                                                      ? colorAccent
                                                      : transparent,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: colorAccent)),
                                              child: MyText(
                                                  color: white,
                                                  text: shortProvider
                                                              .watchlaterShortList?[
                                                                  index]
                                                              .isSubscribe ==
                                                          0
                                                      ? "subscribe"
                                                      : "subscribed",
                                                  multilanguage: true,
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textSmall,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w600,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal),
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                MyImage(
                                    width: 25,
                                    height: 25,
                                    fit: BoxFit.cover,
                                    imagePath: "ic_user.png"),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: MyText(
                                      color: white,
                                      text: "Admin",
                                      multilanguage: false,
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textTitle,
                                      inter: false,
                                      maxline: 1,
                                      fontwaight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                      /* User Title */
                      Container(
                        width: 250,
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                        child: SizedBox(
                          height: 20,
                          child: MyMarqueeText(
                              text: shortProvider
                                      .watchlaterShortList?[index].title
                                      .toString() ??
                                  "",
                              fontsize: Dimens.textMedium,
                              color: white),
                        ),
                      ),
                      /* Gif Image Music */
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Row(
                          children: [
                            MyImage(
                                width: 15,
                                height: 15,
                                imagePath: "music.png",
                                color: white),
                            const SizedBox(width: 15),
                            MyText(
                                color: white,
                                text: "originalsound",
                                textalign: TextAlign.center,
                                fontsizeNormal: 12,
                                multilanguage: true,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          /* Reels Pagination Content */
          onPageChanged: (index) async {
            if (index > 0 && (index % 2) == 0) {
              _fetchWatchLaterShort();
            }
            printLog("onPageChanged value ======> $index");
          },
        ),
        /* Back Button */
        Positioned.fill(
          top: 60,
          left: 20,
          right: 20,
          child: Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: MyImage(
                  width: 35,
                  height: 35,
                  imagePath: "ic_roundback.png",
                  color: white,
                ),
              )),
        ),
      ],
    );
  }

  Widget shimmer() {
    return Stack(
      children: [
        PageView.builder(
          itemCount: 1,
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: colorPrimary,
                ),
                const Positioned.fill(
                  bottom: 30,
                  right: 20,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomWidget.circular(
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(
                          width: 30,
                          height: 15,
                        ),
                        SizedBox(height: 20),
                        CustomWidget.circular(
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(
                          width: 30,
                          height: 15,
                        ),
                        SizedBox(height: 20),
                        CustomWidget.circular(
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(
                          width: 30,
                          height: 15,
                        ),
                        SizedBox(height: 20),
                        CustomWidget.circular(
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(height: 10),
                        CustomWidget.roundrectborder(
                          width: 30,
                          height: 15,
                        ),
                        SizedBox(height: 20),
                        CustomWidget.circular(
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(height: 20),
                        CustomWidget.roundrectborder(
                          width: 45,
                          height: 45,
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned.fill(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomWidget.roundcorner(
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(width: 10),
                          CustomWidget.roundrectborder(
                            width: 150,
                            height: 15,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      CustomWidget.roundrectborder(
                        width: 200,
                        height: 15,
                      ),
                      CustomWidget.roundrectborder(
                        width: 200,
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          onPageChanged: (index) async {},
        ),
      ],
    );
  }

/* Comment Bottom Sheet */
  commentBottomSheet(
      {required int index, required videoid, required isShortType}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            buildComment(index, videoid, isShortType),
          ],
        );
      },
    ).whenComplete(() {
      log("comment Back");
      commentController.clear();
      shortProvider.clearComment();
    });
  }

/* Build Comment List */
  Widget buildComment(index, dynamic videoid, isShortType) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: MyText(
                        color: white,
                        multilanguage: true,
                        text: "comments",
                        fontsizeNormal: 15,
                        fontstyle: FontStyle.normal,
                        fontwaight: FontWeight.w600,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.start,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        Navigator.pop(context);
                        commentController.clear();
                        shortProvider.clearComment();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: MyImage(
                          width: 15,
                          height: 15,
                          imagePath: "ic_close.png",
                          fit: BoxFit.contain,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Utils.buildGradLine(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: commentListController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  children: [
                    Consumer<ShortProvider>(
                        builder: (context, commentprovider, child) {
                      if (shortProvider.commentloading &&
                          !shortProvider.commentLoadmore) {
                        return Utils.pageLoader(context);
                      } else {
                        if (shortProvider.getcommentModel.status == 200 &&
                            shortProvider.commentList != null) {
                          if ((shortProvider.commentList?.length ?? 0) > 0) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          commentprovider.commentList?.length ??
                                              0,
                                      itemBuilder: (BuildContext ctx, index) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(1),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: white)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: MyNetworkImage(
                                                      imagePath: commentprovider
                                                              .commentList?[
                                                                  index]
                                                              .image
                                                              .toString() ??
                                                          "",
                                                      fit: BoxFit.fill,
                                                      width: 25,
                                                      height: 25),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  commentprovider.commentList?[index].channelName
                                                              .toString() ==
                                                          ""
                                                      ? MyText(
                                                          color: white,
                                                          text: "guestuser",
                                                          fontsizeNormal:
                                                              Dimens.textTitle,
                                                          fontwaight:
                                                              FontWeight.w500,
                                                          multilanguage: true,
                                                          maxline: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          inter: false,
                                                          textalign:
                                                              TextAlign.center,
                                                          fontstyle:
                                                              FontStyle.normal)
                                                      : MyText(
                                                          color: white,
                                                          text: commentprovider
                                                                  .commentList?[
                                                                      index]
                                                                  .channelName
                                                                  .toString() ??
                                                              "",
                                                          fontsizeNormal:
                                                              Dimens.textTitle,
                                                          fontwaight:
                                                              FontWeight.w500,
                                                          multilanguage: false,
                                                          maxline: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          inter: false,
                                                          textalign:
                                                              TextAlign.center,
                                                          fontstyle:
                                                              FontStyle.normal),
                                                  const SizedBox(height: 8),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.70,
                                                    child: MyText(
                                                        color: white,
                                                        text: commentprovider
                                                                .commentList?[
                                                                    index]
                                                                .comment
                                                                .toString() ??
                                                            "",
                                                        fontsizeNormal:
                                                            Dimens.textMedium,
                                                        fontwaight:
                                                            FontWeight.w400,
                                                        multilanguage: false,
                                                        maxline: 10,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        inter: false,
                                                        textalign:
                                                            TextAlign.left,
                                                        fontstyle:
                                                            FontStyle.normal),
                                                  ),
                                                  const SizedBox(height: 7),
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          shortProvider.storeReplayCommentId(
                                                              shortProvider
                                                                      .commentList?[
                                                                          index]
                                                                      .id
                                                                      .toString() ??
                                                                  "");
                                                          // Set Replay Comment Channal name
                                                          commentController
                                                              .clear();

                                                          Navigator.pop(
                                                              context);

                                                          replayCommentBottomSheet(
                                                              index,
                                                              videoid,
                                                              commentprovider
                                                                      .commentList?[
                                                                          index]
                                                                      .id
                                                                      .toString() ??
                                                                  "",
                                                              commentprovider
                                                                      .commentList?[
                                                                          index]
                                                                      .image
                                                                      .toString() ??
                                                                  "",
                                                              commentprovider
                                                                      .commentList?[
                                                                          index]
                                                                      .fullName
                                                                      .toString() ??
                                                                  "",
                                                              commentprovider
                                                                      .commentList?[
                                                                          index]
                                                                      .comment
                                                                      .toString() ??
                                                                  "",
                                                              isShortType);

                                                          await shortProvider
                                                              .getReplayComment(
                                                                  commentprovider
                                                                          .commentList?[
                                                                              index]
                                                                          .id
                                                                          .toString() ??
                                                                      "",
                                                                  1);
                                                        },
                                                        child: commentprovider
                                                                    .commentList?[
                                                                        index]
                                                                    .totalReply !=
                                                                0
                                                            ? Row(
                                                                children: [
                                                                  MyText(
                                                                      color:
                                                                          gray,
                                                                      text:
                                                                          "seeall",
                                                                      fontsizeNormal: Dimens
                                                                          .textSmall,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w400,
                                                                      multilanguage:
                                                                          true,
                                                                      maxline:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      inter:
                                                                          false,
                                                                      textalign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal),
                                                                  const SizedBox(
                                                                      width: 5),
                                                                  MyText(
                                                                      color:
                                                                          gray,
                                                                      text: Utils.kmbGenerator(int
                                                                          .parse(
                                                                        commentprovider.commentList?[index].totalReply.toString() ??
                                                                            "",
                                                                      )),
                                                                      fontsizeNormal:
                                                                          Dimens
                                                                              .textSmall,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w400,
                                                                      multilanguage:
                                                                          false,
                                                                      maxline:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      inter:
                                                                          false,
                                                                      textalign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal),
                                                                  const SizedBox(
                                                                      width: 5),
                                                                  MyText(
                                                                      color:
                                                                          gray,
                                                                      text:
                                                                          "comments",
                                                                      fontsizeNormal: Dimens
                                                                          .textSmall,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w400,
                                                                      multilanguage:
                                                                          true,
                                                                      maxline:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      inter:
                                                                          false,
                                                                      textalign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal),
                                                                ],
                                                              )
                                                            : MyText(
                                                                color: gray,
                                                                text: "seeall",
                                                                fontsizeNormal:
                                                                    Dimens
                                                                        .textSmall,
                                                                fontwaight:
                                                                    FontWeight
                                                                        .w400,
                                                                multilanguage:
                                                                    true,
                                                                maxline: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                inter: false,
                                                                textalign:
                                                                    TextAlign
                                                                        .center,
                                                                fontstyle:
                                                                    FontStyle
                                                                        .normal),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      if (commentprovider
                                                              .commentList?[
                                                                  index]
                                                              .userId
                                                              .toString() ==
                                                          Constant.userID)
                                                        if (commentprovider
                                                                .deletecommentLoading &&
                                                            commentprovider
                                                                    .deleteItemIndex ==
                                                                index)
                                                          const SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  colorAccent,
                                                              strokeWidth: 1,
                                                            ),
                                                          )
                                                        else
                                                          InkWell(
                                                            onTap: () async {
                                                              await shortProvider.getDeleteComment(
                                                                  commentprovider
                                                                          .commentList?[
                                                                              index]
                                                                          .id
                                                                          .toString() ??
                                                                      "",
                                                                  true,
                                                                  index,
                                                                  isShortType);
                                                            },
                                                            child: MyImage(
                                                                width: 15,
                                                                height: 15,
                                                                imagePath:
                                                                    "ic_delete.png"),
                                                          )
                                                      else
                                                        const SizedBox.shrink(),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                                if (shortProvider.commentloading)
                                  const CircularProgressIndicator(
                                    color: colorAccent,
                                  )
                                else
                                  const SizedBox.shrink(),
                              ],
                            );
                          } else {
                            return Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                width: 130,
                                height:
                                    MediaQuery.of(context).size.height * 0.40,
                                fit: BoxFit.contain,
                                imagePath: "nodata.png",
                              ),
                            );
                          }
                        } else {
                          return Align(
                            alignment: Alignment.center,
                            child: MyImage(
                              width: 130,
                              height: MediaQuery.of(context).size.height * 0.35,
                              fit: BoxFit.contain,
                              imagePath: "nodata.png",
                            ),
                          );
                        }
                      }
                    }),
                  ],
                ),
              ),
            ),
            Utils.buildGradLine(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              alignment: Alignment.center,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: commentController,
                        maxLines: 1,
                        scrollPhysics: const AlwaysScrollableScrollPhysics(),
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: transparent,
                          border: InputBorder.none,
                          hintText: "Add Comments",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: white,
                          ),
                          contentPadding:
                              const EdgeInsets.only(left: 10, right: 10),
                        ),
                        obscureText: false,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
                            ),
                          );
                        } else if (commentController.text.isEmpty) {
                          Utils().showToast("Please Enter Your Comment");
                        } else {
                          if (shortProvider.shortVideoList?[index].isComment ==
                                  0 &&
                              isShortType == "short") {
                            Utils.showSnackbar(
                                context, "youcannotcommentthiscontent", true);
                            Navigator.pop(context);
                          } else {
                            await shortProvider.getaddcomment(
                                index,
                                "3",
                                videoid,
                                "0",
                                commentController.text,
                                "0",
                                widget.shortType);

                            commentController.clear();
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Consumer<ShortProvider>(
                            builder: (context, commentprovider, child) {
                              if (commentprovider.addcommentloading) {
                                return const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: colorAccent,
                                    strokeWidth: 1,
                                  ),
                                );
                              } else {
                                return MyImage(
                                  height: 15,
                                  width: 15,
                                  fit: BoxFit.contain,
                                  imagePath: "ic_send.png",
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

/* More Button Bottom Sheet */
  moreBottomSheet(reportUserid, contentid) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: colorPrimaryDark,
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.shortType == "watchlater"
                    ? const SizedBox.shrink()
                    : moreFunctionItem("ic_watchlater.png", "savetowatchlater",
                        () async {
                        await shortProvider.addremoveWatchLater(
                            "3", contentid, "0", "1");
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        Utils.showSnackbar(context, "savetowatchlater", true);
                      }),
                moreFunctionItem("report.png", "report", () async {
                  Navigator.pop(context);
                  _fetchReportReason(0);
                  reportBottomSheet(reportUserid, contentid);
                }),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget moreFunctionItem(icon, title, onTap) {
    return ListTile(
      iconColor: white,
      textColor: white,
      title: MyText(
        color: white,
        text: title,
        fontwaight: FontWeight.w500,
        fontsizeNormal: Dimens.textTitle,
        maxline: 1,
        multilanguage: true,
        overflow: TextOverflow.ellipsis,
        textalign: TextAlign.left,
        fontstyle: FontStyle.normal,
      ),
      leading: MyImage(
        width: 20,
        height: 20,
        imagePath: icon,
        color: white,
      ),
      onTap: onTap,
    );
  }

/* Report Reason Bottom Sheet */
  reportBottomSheet(reportUserid, contentid) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(15),
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: BoxDecoration(
              color: colorPrimaryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  alignment: Alignment.centerLeft,
                  child: MyText(
                      color: white,
                      text: "selectreportreason",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 2,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: buildReportReasonList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        shortProvider.reportReasonList?.clear();
                        shortProvider.position = 0;
                        shortProvider.clearSelectReportReason();
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 1, color: white),
                        ),
                        child: MyText(
                            color: white,
                            text: "cancel",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            multilanguage: true,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      onTap: () async {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  const Login(),
                            ),
                          );
                        } else {
                          if (shortProvider.reasonId == "" ||
                              shortProvider.reasonId.isEmpty) {
                            Utils.showSnackbar(
                                context, "pleaseselectyourreportreason", true);
                          } else {
                            await shortProvider.addContentReport(
                                reportUserid,
                                contentid,
                                shortProvider
                                        .reportReasonList?[
                                            shortProvider.reportposition ?? 0]
                                        .reason
                                        .toString() ??
                                    "",
                                "1");

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            Utils.showSnackbar(
                                context,
                                "${shortProvider.addContentReportModel.message}",
                                false);
                            shortProvider.clearSelectReportReason();
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(5)),
                        child: MyText(
                            color: white,
                            text: "report",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textBig,
                            multilanguage: true,
                            inter: false,
                            maxline: 2,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget buildReportReasonList() {
    return Consumer<ShortProvider>(
        builder: (context, reportreasonprovider, child) {
      if (reportreasonprovider.getcontentreportloading &&
          !reportreasonprovider.getcontentreportloadmore) {
        return Utils.pageLoader(context);
      } else {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: reportReasonController,
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              buildReportReasonListItem(),
              if (reportreasonprovider.getcontentreportloadmore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      }
    });
  }

  Widget buildReportReasonListItem() {
    if (shortProvider.getRepostReasonModel.status == 200 &&
        shortProvider.reportReasonList != null) {
      if ((shortProvider.reportReasonList?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: shortProvider.reportReasonList?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                shortProvider.selectReportReason(index, true,
                    shortProvider.reportReasonList?[index].id.toString() ?? "");
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                color: shortProvider.reportposition == index &&
                        shortProvider.isSelectReason == true
                    ? colorAccent
                    : colorPrimaryDark,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyText(
                        color: white,
                        text: "${(index + 1).toString()}.",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        multilanguage: false,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(width: 20),
                    Expanded(
                      child: MyText(
                          color: white,
                          text: shortProvider.reportReasonList?[index].reason
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          fontsizeWeb: Dimens.textTitle,
                          multilanguage: false,
                          inter: false,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                    const SizedBox(width: 20),
                    shortProvider.reportposition == index &&
                            shortProvider.isSelectReason == true
                        ? MyImage(width: 18, height: 18, imagePath: "true.png")
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        printLog("null Array");
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      printLog("null Array Last");
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

/* ReplayComment Bottom Sheet */
  // Replay Comment
  replayCommentBottomSheet(int index, videoid, commentid, commentUserImage,
      commentUsername, comment, isShortPage) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            buildReplayComment(index, videoid, commentid, commentUserImage,
                commentUsername, comment, isShortPage),
          ],
        );
      },
    ).whenComplete(() {
      log("clear Replaycomment====>");
      commentController.clear();
      shortProvider.clearReplayComment();
    });
  }

  Widget buildReplayComment(index, videoid, commentId, commentUserImage,
      commentUsername, comment, isShortPage) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 20),
                      child: MyText(
                          color: white,
                          text: "replay",
                          fontsizeNormal: Dimens.textTitle,
                          fontwaight: FontWeight.w500,
                          multilanguage: true,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        Navigator.pop(context);
                        commentController.clear();
                        shortProvider.clearComment();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: MyImage(
                          width: 15,
                          height: 15,
                          imagePath: "ic_close.png",
                          fit: BoxFit.contain,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(width: 1, color: white)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: MyNetworkImage(
                          imagePath: commentUserImage,
                          fit: BoxFit.fill,
                          width: 26,
                          height: 26),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                          color: white,
                          text: commentUsername,
                          fontsizeNormal: Dimens.textMedium,
                          fontwaight: FontWeight.w500,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                      const SizedBox(height: 5),
                      MyText(
                          color: white,
                          text: comment,
                          fontsizeNormal: Dimens.textSmall,
                          fontwaight: FontWeight.w400,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          inter: false,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(child: buildreplayCommentList(isShortPage)),
            Utils.buildGradLine(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              alignment: Alignment.center,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: commentController,
                        maxLines: 1,
                        scrollPhysics: const AlwaysScrollableScrollPhysics(),
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: transparent,
                          border: InputBorder.none,
                          hintText: "Replay Comments",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: white,
                          ),
                          contentPadding:
                              const EdgeInsets.only(left: 10, right: 10),
                        ),
                        obscureText: false,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () async {
                        if (Constant.userID == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Login();
                              },
                            ),
                          );
                        } else if (commentController.text.isEmpty) {
                          Utils().showToast("Please Enter Your Comment");
                        } else {
                          printLog("videoid==> $videoid");
                          printLog("comment==> ${commentController.text}");
                          printLog("comment==> $commentId");
                          await shortProvider.getaddReplayComment(
                            "3",
                            videoid,
                            "0",
                            commentController.text,
                            commentId,
                          );
                          commentController.clear();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Consumer<ShortProvider>(
                              builder: (context, detailprovider, child) {
                            if (detailprovider.addreplaycommentloading) {
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: colorAccent,
                                  strokeWidth: 1,
                                ),
                              );
                            } else {
                              return MyImage(
                                  width: 20,
                                  height: 20,
                                  imagePath: "ic_send.png");
                            }
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildreplayCommentList(isShortPage) {
    return SingleChildScrollView(
      controller: replaycommentController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
      child: Consumer<ShortProvider>(builder: (context, detailprovider, child) {
        if (detailprovider.replaycommentloding &&
            !detailprovider.replayCommentloadmore) {
          return Utils.pageLoader(context);
        } else {
          return Column(
            children: [
              replayCommentList(isShortPage),
              if (detailprovider.replayCommentloadmore)
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                  child: Utils.pageLoader(context),
                )
              else
                const SizedBox.shrink(),
            ],
          );
        }
      }),
    );
  }

  Widget replayCommentList(isShortPage) {
    if (shortProvider.replayCommentModel.status == 200 &&
        shortProvider.replaycommentList != null) {
      if ((shortProvider.replaycommentList?.length ?? 0) > 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: shortProvider.replaycommentList?.length ?? 0,
                  itemBuilder: (BuildContext ctx, index) {
                    return Container(
                      // color: gray,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(width: 1, color: white)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                  imagePath: shortProvider
                                          .replaycommentList?[index].image
                                          .toString() ??
                                      "",
                                  fit: BoxFit.fill,
                                  width: 20,
                                  height: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                shortProvider.replaycommentList?[index].fullName ==
                                        ""
                                    ? MyText(
                                        color: white,
                                        text: shortProvider
                                                .replaycommentList?[index]
                                                .fullName
                                                .toString() ??
                                            "",
                                        fontsizeNormal: Dimens.textDesc,
                                        fontwaight: FontWeight.w600,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        inter: false,
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal)
                                    : MyText(
                                        color: white,
                                        text: shortProvider
                                                .replaycommentList?[index]
                                                .channelName
                                                .toString() ??
                                            "",
                                        fontsizeNormal: Dimens.textMedium,
                                        fontwaight: FontWeight.w500,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        inter: false,
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  child: MyText(
                                      color: gray,
                                      text: shortProvider
                                              .replaycommentList?[index].comment
                                              .toString() ??
                                          "",
                                      fontsizeNormal: Dimens.textSmall,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: false,
                                      maxline: 3,
                                      overflow: TextOverflow.ellipsis,
                                      inter: false,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (shortProvider.replaycommentList?[index].userId
                                  .toString() ==
                              Constant.userID)
                            if (shortProvider.deletecommentLoading &&
                                shortProvider.deleteItemIndex == index)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: colorAccent,
                                  strokeWidth: 1,
                                ),
                              )
                            else
                              InkWell(
                                onTap: () async {
                                  if (Constant.userID == null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const Login();
                                        },
                                      ),
                                    );
                                  } else {
                                    await shortProvider.getDeleteComment(
                                        shortProvider
                                                .replaycommentList?[index].id
                                                .toString() ??
                                            "",
                                        false,
                                        index,
                                        isShortPage);
                                  }
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: colorAccent),
                                  child: MyText(
                                      color: white,
                                      text: "delete",
                                      fontsizeNormal: Dimens.textSmall,
                                      fontwaight: FontWeight.w400,
                                      multilanguage: true,
                                      maxline: 3,
                                      overflow: TextOverflow.ellipsis,
                                      inter: false,
                                      textalign: TextAlign.left,
                                      fontstyle: FontStyle.normal),
                                ),
                              )
                        ],
                      ),
                    );
                  }),
            ),
            if (shortProvider.commentloading)
              const CircularProgressIndicator(
                color: colorAccent,
              )
            else
              const SizedBox.shrink(),
          ],
        );
      } else {
        return const Expanded(child: NoData(title: "", subTitle: ""));
      }
    } else {
      return const Expanded(child: NoData(title: "", subTitle: ""));
    }
  }
}
