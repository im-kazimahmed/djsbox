import 'dart:developer';
import 'dart:io';

import 'package:yourappname/pages/login.dart';
import 'package:yourappname/provider/getmusicbylanguageprovider.dart';
import 'package:yourappname/provider/musicdetailprovider.dart';
import 'package:yourappname/utils/adhelper.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/musicmanager.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/musictitle.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class GetMusicByLanguage extends StatefulWidget {
  final String languageId, title;
  const GetMusicByLanguage({
    super.key,
    required this.languageId,
    required this.title,
  });

  @override
  State<GetMusicByLanguage> createState() => GetMusicByLanguageState();
}

class GetMusicByLanguageState extends State<GetMusicByLanguage> {
  final MusicManager musicManager = MusicManager();
  late GetMusicByLanguageProvider getMusicByLanguageProvider;
  late ScrollController _scrollController;
  late ScrollController playlistController;
  final playlistTitleController = TextEditingController();

  @override
  void initState() {
    getMusicByLanguageProvider =
        Provider.of<GetMusicByLanguageProvider>(context, listen: false);
    _fetchData(0);
    _scrollController = ScrollController();
    playlistController = ScrollController();
    _scrollController.addListener(_scrollListener);
    playlistController.addListener(_scrollListenerPlaylist);
    super.initState();
  }

/* Scroll Pagination Language Music */
  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (getMusicByLanguageProvider.currentPage ?? 0) <
            (getMusicByLanguageProvider.totalPage ?? 0)) {
      printLog("load more====>");
      getMusicByLanguageProvider.setLoadMore(true);
      _fetchData(getMusicByLanguageProvider.currentPage ?? 0);
    }
  }

  /* Playlist Pagination */
  _scrollListenerPlaylist() async {
    if (!playlistController.hasClients) return;
    if (playlistController.offset >=
            playlistController.position.maxScrollExtent &&
        !playlistController.position.outOfRange &&
        (getMusicByLanguageProvider.playlistcurrentPage ?? 0) <
            (getMusicByLanguageProvider.playlisttotalPage ?? 0)) {
      await getMusicByLanguageProvider.setPlaylistLoadMore(true);
      _fetchPlaylist(getMusicByLanguageProvider.playlistcurrentPage ?? 0);
    }
  }

/* Language All Music Fetch Api */
  Future<void> _fetchData(int? nextPage) async {
    printLog("isMorePage  ======> ${getMusicByLanguageProvider.isMorePage}");
    printLog("currentPage ======> ${getMusicByLanguageProvider.currentPage}");
    printLog("totalPage   ======> ${getMusicByLanguageProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await getMusicByLanguageProvider.getMusicbyLanguage(
        widget.languageId, (nextPage ?? 0) + 1);
  }

  /* Playlist Api */
  Future _fetchPlaylist(int? nextPage) async {
    printLog(
        "playlistmorePage  =======> ${getMusicByLanguageProvider.playlistmorePage}");
    printLog(
        "playlistcurrentPage =======> ${getMusicByLanguageProvider.playlistcurrentPage}");
    printLog(
        "playlisttotalPage   =======> ${getMusicByLanguageProvider.playlisttotalPage}");
    printLog("nextPage   ========> $nextPage");
    await getMusicByLanguageProvider.getcontentbyChannel(
        Constant.userID, Constant.channelID, "5", (nextPage ?? 0) + 1);
    printLog(
        "fetchPlaylist length ==> ${getMusicByLanguageProvider.playlistData?.length}");
  }

  @override
  void dispose() {
    super.dispose();
    getMusicByLanguageProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, widget.title, false),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 190),
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            child: buildPage(),
          ),
          Utils.musicAndAdsPanel(context),
        ],
      ),
    );
  }

  Widget buildPage() {
    return Consumer<GetMusicByLanguageProvider>(
        builder: (context, getmusicbylanguageprovider, child) {
      if (getmusicbylanguageprovider.loading &&
          !getmusicbylanguageprovider.loadMore) {
        return musicListShimmer();
      } else {
        return Column(
          children: [
            musicList(),
            if (getMusicByLanguageProvider.loadMore)
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
    });
  }

  Widget musicList() {
    return Consumer<GetMusicByLanguageProvider>(
        builder: (context, getmusicbylanguageprovider, child) {
      if (getmusicbylanguageprovider.getMusicByLanguageModel.status == 200 &&
          getmusicbylanguageprovider.musicList != null) {
        if ((getmusicbylanguageprovider.musicList?.length ?? 0) > 0) {
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: ResponsiveGridList(
                minItemWidth: 120,
                minItemsPerRow: 1,
                maxItemsPerRow: 1,
                horizontalGridSpacing: 10,
                verticalGridSpacing: 25,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                ),
                children: List.generate(
                    getmusicbylanguageprovider.musicList?.length ?? 0, (index) {
                  return InkWell(
                    onTap: () {
                      AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                          () {
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
                          playAudio(
                            getmusicbylanguageprovider
                                    .musicList?[index].contentType
                                    .toString() ??
                                "",
                            getmusicbylanguageprovider.musicList?[index].id
                                    .toString() ??
                                "",
                            getmusicbylanguageprovider.musicList?[index].id
                                    .toString() ??
                                "",
                            index,
                            getmusicbylanguageprovider.musicList,
                            getmusicbylanguageprovider.musicList?[index].title
                                    .toString() ??
                                "",
                            getmusicbylanguageprovider.musicList?[index].isBuy
                                    .toString() ??
                                "",
                          );
                        }
                      });
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.70,
                      height: 55,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: MyNetworkImage(
                                fit: BoxFit.cover,
                                width: 55,
                                height: 55,
                                imagePath: getmusicbylanguageprovider
                                        .musicList?[index].portraitImg
                                        .toString() ??
                                    ""),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MusicTitle(
                                    color: white,
                                    multilanguage: false,
                                    text: getmusicbylanguageprovider
                                            .musicList?[index].title
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textDesc,
                                    maxline: 1,
                                    fontwaight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                const SizedBox(height: 8),
                                MusicTitle(
                                    color: white,
                                    multilanguage: false,
                                    text: getmusicbylanguageprovider
                                            .musicList?[index].description
                                            .toString() ??
                                        "",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textSmall,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
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
                                  getmusicbylanguageprovider
                                          .musicList?[index].userId
                                          .toString() ??
                                      "",
                                  getmusicbylanguageprovider
                                          .musicList?[index].id
                                          .toString() ??
                                      "",
                                  index,
                                  getmusicbylanguageprovider
                                          .musicList?[index].title
                                          .toString() ??
                                      "",
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: MyImage(
                                  width: 13,
                                  height: 13,
                                  imagePath: "ic_more.png"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        } else {
          return const NoData(title: "", subTitle: "");
        }
      } else {
        return const NoData(title: "", subTitle: "");
      }
    });
  }

  Widget musicListShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 1,
          maxItemsPerRow: 1,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(10, (index) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              height: 55,
              child: const Row(
                children: [
                  CustomWidget.roundrectborder(
                    width: 55,
                    height: 55,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomWidget.roundrectborder(
                          width: 250,
                          height: 8,
                        ),
                        SizedBox(height: 8),
                        CustomWidget.roundrectborder(
                          width: 250,
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  moreBottomSheet(reportUserid, contentid, position, contentName) {
    return showModalBottomSheet(
      elevation: 0,
      barrierColor: black.withAlpha(1),
      backgroundColor: colorPrimaryDark,
      context: context,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 700),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  moreFunctionItem("ic_watchlater.png", "savetowatchlater",
                      () async {
                    await getMusicByLanguageProvider.addremoveWatchLater(
                        "2", contentid, "0", "1");
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    Utils.showSnackbar(context, "savetowatchlater", true);
                  }),
                  moreFunctionItem("ic_playlisttitle.png", "savetoplaylist",
                      () async {
                    Navigator.pop(context);
                    selectPlaylistBottomSheet(position, contentid);
                    await getMusicByLanguageProvider.getcontentbyChannel(
                        Constant.userID, Constant.channelID, "5", "1");
                  }),
                  moreFunctionItem("ic_share.png", "share", () {
                    Navigator.pop(context);
                    Utils.shareApp(Platform.isIOS
                        ? "Hey! I'm Listening $contentName. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                        : "Hey! I'm Listening $contentName. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                  }),
                ],
              ),
            ],
          ),
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

  /* Playlist Bottom Sheet */
  selectPlaylistBottomSheet(position, contentid) {
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                          color: white,
                          text: "selectplaylist",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          multilanguage: true,
                          inter: false,
                          maxline: 2,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          createPlaylistDilog(
                              playlistId:
                                  getMusicByLanguageProvider.playlistId);
                        },
                        child: Container(
                          width: 160,
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: colorAccent),
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add,
                                color: white,
                                size: 22,
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                  color: white,
                                  text: "createplaylist",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textDesc,
                                  multilanguage: true,
                                  inter: false,
                                  maxline: 2,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: buildPlayList(),
                ),
                Consumer<GetMusicByLanguageProvider>(
                    builder: (context, playlistprovider, child) {
                  if (playlistprovider.playlistLoading &&
                      !playlistprovider.playlistLoadmore) {
                    return const SizedBox.shrink();
                  } else {
                    if (getMusicByLanguageProvider
                                .getContentbyChannelModel.status ==
                            200 &&
                        getMusicByLanguageProvider.playlistData != null) {
                      if ((getMusicByLanguageProvider.playlistData?.length ??
                              0) >
                          0) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                playlistprovider.clearPlaylistData();
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
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
                                Navigator.pop(context);
                                if (getMusicByLanguageProvider
                                        .playlistId.isEmpty ||
                                    getMusicByLanguageProvider.playlistId ==
                                        "") {
                                  Utils.showSnackbar(
                                      context, "pleaseelectyourplaylist", true);
                                } else {
                                  await getMusicByLanguageProvider
                                      .addremoveContentToPlaylist(
                                          Constant.channelID,
                                          getMusicByLanguageProvider.playlistId,
                                          "3",
                                          contentid,
                                          "0",
                                          "1");

                                  if (!getMusicByLanguageProvider.loading) {
                                    if (getMusicByLanguageProvider
                                            .addremoveContentToPlaylistModel
                                            .status ==
                                        200) {
                                      printLog("Added Succsessfully");
                                      Utils().showToast("Save to Playlist");
                                    } else {
                                      Utils().showToast(
                                          "${getMusicByLanguageProvider.addremoveContentToPlaylistModel.message}");
                                    }
                                  }
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                decoration: BoxDecoration(
                                    color: colorAccent,
                                    borderRadius: BorderRadius.circular(5)),
                                child: MyText(
                                    color: white,
                                    text: "addcontent",
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
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                }),
              ],
            ),
          );
        });
      },
    );
  }

  Widget buildPlayList() {
    return Consumer<GetMusicByLanguageProvider>(
        builder: (context, playlistprovider, child) {
      if (playlistprovider.playlistLoading &&
          !playlistprovider.playlistLoadmore) {
        return Utils.pageLoader(context);
      } else {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: playlistController,
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              buildPlaylistItem(),
              if (playlistprovider.playlistLoadmore)
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

  Widget buildPlaylistItem() {
    log("Playlist Lenght==>${getMusicByLanguageProvider.playlistData?.length ?? 0}");
    log("Playlist Position==>${getMusicByLanguageProvider.playlistPosition}");
    log("Playlist Id==>${getMusicByLanguageProvider.playlistId}");
    if (getMusicByLanguageProvider.getContentbyChannelModel.status == 200 &&
        getMusicByLanguageProvider.playlistData != null) {
      if ((getMusicByLanguageProvider.playlistData?.length ?? 0) > 0) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: getMusicByLanguageProvider.playlistData?.length ?? 0,
          itemBuilder: (BuildContext ctx, index) {
            return InkWell(
              onTap: () {
                getMusicByLanguageProvider.selectPlaylist(
                    index,
                    getMusicByLanguageProvider.playlistData?[index].id
                            .toString() ??
                        "",
                    true);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                color: getMusicByLanguageProvider.playlistPosition == index &&
                        getMusicByLanguageProvider.isSelectPlaylist == true
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
                          text: getMusicByLanguageProvider
                                  .playlistData?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textTitle,
                          multilanguage: false,
                          inter: false,
                          maxline: 2,
                          fontwaight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                    const SizedBox(width: 20),
                    getMusicByLanguageProvider.playlistPosition == index &&
                            getMusicByLanguageProvider.isSelectPlaylist == true
                        ? MyImage(width: 18, height: 18, imagePath: "true.png")
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return const NoData(
            title: "noplaylistfound", subTitle: "createnewplaylist");
      }
    } else {
      return const NoData(
          title: "noplaylistfound", subTitle: "createnewplaylist");
    }
  }

/* Create Playlist Bottom Sheet */
  createPlaylistDilog({playlistId}) {
    printLog("playlistId==> $playlistId");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          insetAnimationCurve: Curves.bounceInOut,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            width: MediaQuery.of(context).size.width * 0.90,
            height: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorAccent.withOpacity(0.10),
              // borderRadius: BorderRadius.circular(20),
            ),
            child: Consumer<GetMusicByLanguageProvider>(
                builder: (context, createplaylistprovider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                      color: white,
                      multilanguage: true,
                      text: "newplaylist",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textExtraBig,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 25),
                  TextField(
                    cursorColor: white,
                    controller: playlistTitleController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: Utils.googleFontStyle(1, Dimens.textBig,
                        FontStyle.normal, white, FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "Give your playlist a title",
                      hintStyle: Utils.googleFontStyle(1, Dimens.textBig,
                          FontStyle.normal, gray, FontWeight.w500),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "privacy",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 8),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: ":",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          createplaylistprovider.selectPrivacy(type: 1);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: createplaylistprovider.isType == 1
                                ? colorAccent
                                : transparent,
                            border: Border.all(
                                width: 2,
                                color: createplaylistprovider.isType == 1
                                    ? colorAccent
                                    : white),
                          ),
                          child: createplaylistprovider.isType == 1
                              ? const Icon(
                                  Icons.check,
                                  color: white,
                                  size: 15,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "public",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textDesc,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          createplaylistprovider.selectPrivacy(type: 2);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: createplaylistprovider.isType == 2
                                ? colorAccent
                                : transparent,
                            border: Border.all(
                                width: 2,
                                color: createplaylistprovider.isType == 2
                                    ? colorAccent
                                    : white),
                          ),
                          child: createplaylistprovider.isType == 2
                              ? const Icon(
                                  Icons.check,
                                  color: white,
                                  size: 15,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "private",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textDesc,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          playlistTitleController.clear();
                          getMusicByLanguageProvider.isType = 0;
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorAccent.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5,
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 25),
                      InkWell(
                        onTap: () async {
                          if (playlistTitleController.text.isEmpty) {
                            Utils.showSnackbar(
                                context, "pleaseenterplaylistname", true);
                          } else if (createplaylistprovider.isType == 0) {
                            Utils.showSnackbar(
                                context, "pleaseselectplaylisttype", true);
                          } else {
                            await createplaylistprovider.getcreatePlayList(
                              Constant.channelID,
                              playlistTitleController.text,
                              getMusicByLanguageProvider.isType.toString(),
                            );
                            if (!createplaylistprovider.loading) {
                              if (createplaylistprovider
                                      .createPlaylistModel.status ==
                                  200) {
                                if (!context.mounted) return;
                                Utils.showSnackbar(
                                    context,
                                    "${createplaylistprovider.createPlaylistModel.message}",
                                    false);
                              } else {
                                if (!context.mounted) return;
                                Utils.showSnackbar(
                                    context,
                                    "${createplaylistprovider.createPlaylistModel.message}",
                                    false);
                              }
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            playlistTitleController.clear();
                            getMusicByLanguageProvider.isType = 0;
                            // _fetchPlaylist(0);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorAccent.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "create",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Future<void> playAudio(
    String playingType,
    String episodeid,
    String contentid,
    int position,
    dynamic contentList,
    String contentName,
    String? isBuy,
  ) async {
    /* Play Music */
    musicManager.setInitialMusic(position, playingType, contentList, contentid,
        addView(playingType, contentid), false, 0, isBuy ?? "");
    /* Play Podcast */
  }

  addView(contentType, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.addView(contentType, contentId);
  }
}
