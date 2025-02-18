import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/pages/updateprofile.dart';
import 'package:yourappname/provider/updateprofileprovider.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webcontentdetail.dart';
import 'package:yourappname/webpages/webdetail.dart';
import 'package:yourappname/webpages/webshorts.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../model/getcontentbychannelmodel.dart';
import 'package:yourappname/model/profilemodel.dart' as profile;

class WebProfile extends StatefulWidget {
  final bool isProfile;
  final String channelUserid;
  final String channelid;
  const WebProfile(
      {super.key,
      required this.isProfile,
      required this.channelUserid,
      required this.channelid});

  @override
  State<WebProfile> createState() => WebProfileState();
}

class WebProfileState extends State<WebProfile> {
  ImagePicker picker = ImagePicker();
  XFile? frontimage;
  late ScrollController _scrollController;
  late ProfileProvider profileProvider;

  /* Update Profile Web */
  String mobilenumber = "", countrycode = "", countryname = "";
  // ignore: deprecated_member_use
  final nameController = TextEditingController();
  final channelNameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();

  @override
  void initState() {
    log("channelUserid===>${widget.channelUserid}");
    log("loginUserid===>${Constant.userID}");
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    getApi();
    if (widget.isProfile == true) {
      _fetchData(0, "1", Constant.userID, Constant.channelID);
    } else {
      _fetchData(0, "1", widget.channelUserid, widget.channelid);
    }
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  getApi() async {
    await profileProvider.getprofile(context,
        widget.isProfile == true ? Constant.userID : widget.channelUserid);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (profileProvider.currentPage ?? 0) < (profileProvider.totalPage ?? 0)) {
      printLog("load more====>");
      profileProvider.setLoadMore(true);
      if (profileProvider.position == 0) {
        getTabData(profileProvider.currentPage ?? 0, "1");
      } else if (profileProvider.position == 1) {
        getTabData(profileProvider.currentPage ?? 0, "4");
      } else if (profileProvider.position == 2) {
        getTabData(profileProvider.currentPage ?? 0, "5");
      } else if (profileProvider.position == 3) {
        getTabData(profileProvider.currentPage ?? 0, "3");
      } else {
        printLog("Something Went Wronge!!!");
      }
    }
  }

  getTabData(pageNo, contenttype) {
    if (widget.isProfile == true) {
      _fetchData(pageNo, contenttype, Constant.userID, Constant.channelID);
    } else {
      _fetchData(pageNo, contenttype, widget.channelUserid, widget.channelid);
    }
  }

  Future<void> _fetchData(int? nextPage, contenttype, userid, channelid) async {
    printLog("isMorePage  ======> ${profileProvider.isMorePage}");
    printLog("currentPage ======> ${profileProvider.currentPage}");
    printLog("totalPage   ======> ${profileProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await profileProvider.getcontentbyChannel(
        userid, channelid, contenttype, (nextPage ?? 0) + 1);
  }

  Future<void> _fetchRentData(int? nextPage) async {
    printLog("isMorePage  ======> ${profileProvider.rentisMorePage}");
    printLog("currentPage ======> ${profileProvider.rentcurrentPage}");
    printLog("totalPage   ======> ${profileProvider.renttotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await profileProvider.getUserbyRentContent(
        widget.isProfile == true ? Constant.userID : widget.channelUserid,
        (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    profileProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.videoSearch),
      body: Utils.sidePanelWithBody(
        isProfile: true,
        myWidget: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfo(),
              buildTab(),
              buildTabItem(),
            ],
          ),
        ),
      ),
    );
  }

  buildInfo() {
    return Consumer<ProfileProvider>(
        builder: (context, settingProvider, child) {
      if (settingProvider.profileloading) {
        return buildImageShimmer();
      } else {
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: MyNetworkImage(
                    width: 160,
                    height: 160,
                    imagePath:
                        settingProvider.profileModel.result?[0].image ?? "",
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                        color: white,
                        text: (settingProvider.profileModel.status == 200 &&
                                settingProvider.profileModel.result != null)
                            ? (settingProvider.profileModel.result?[0].fullName
                                    .toString() ??
                                "")
                            : "",
                        textalign: TextAlign.center,
                        fontsizeNormal: 34,
                        fontsizeWeb: 34,
                        inter: false,
                        multilanguage: false,
                        maxline: 1,
                        fontwaight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 15),
                    MyText(
                        color: gray,
                        text: (settingProvider.profileModel.status == 200 &&
                                settingProvider.profileModel.result != null)
                            ? (settingProvider.profileModel.result?[0].email
                                    .toString() ??
                                "")
                            : "",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textDesc,
                        fontsizeWeb: Dimens.textDesc,
                        inter: false,
                        multilanguage: false,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 10),
                    MyText(
                        color: gray,
                        text: (settingProvider.profileModel.status == 200 &&
                                settingProvider.profileModel.result != null)
                            ? (settingProvider
                                    .profileModel.result?[0].channelName
                                    .toString() ??
                                "")
                            : "",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textDesc,
                        fontsizeWeb: Dimens.textDesc,
                        inter: false,
                        multilanguage: false,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyText(
                            color: gray,
                            text: Utils.kmbGenerator((settingProvider
                                        .profileModel
                                        .result?[0]
                                        .totalSubscriber ??
                                    0)
                                .round()),
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: gray,
                            text: "subscriber",
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            multilanguage: true,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: gray,
                            text: settingProvider
                                    .profileModel.result?[0].totalContent
                                    .toString() ??
                                "",
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            multilanguage: false,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: gray,
                            text: "content",
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            inter: false,
                            maxline: 1,
                            multilanguage: true,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        widget.isProfile == true
                            ? buildButtons(
                                title: "customizechannel",
                                onTap: () {
                                  Utils().showInterstitalAds(
                                      context, Constant.interstialAdType,
                                      () async {
                                    if (Constant.userPanelStatus == "0" ||
                                        Constant.userPanelStatus == "" ||
                                        Constant.userPanelStatus == null) {
                                      Utils.userPanelActiveDilog(context);
                                    } else {
                                      Utils.lanchAdsUrl(Constant.userPanelUrl);
                                    }
                                  });
                                })
                            : const SizedBox.shrink(),
                        const SizedBox(width: 10),
                        widget.isProfile == true
                            ? buildButtons(
                                title: "editprofile",
                                onTap: () {
                                  nameController.text = settingProvider
                                          .profileModel.result?[0].fullName
                                          .toString() ??
                                      "";
                                  emailController.text = settingProvider
                                          .profileModel.result?[0].email
                                          .toString() ??
                                      "";
                                  numberController.text = settingProvider
                                          .profileModel.result?[0].mobileNumber
                                          .toString() ??
                                      "";
                                  channelNameController.text = settingProvider
                                          .profileModel.result?[0].channelName
                                          .toString() ??
                                      "";
                                  buildUpdateProfileDilog(
                                      settingProvider.profileModel.result ??
                                          []);
                                })
                            : const SizedBox.shrink(),
                        const SizedBox(width: 10),
                        widget.isProfile == false &&
                                widget.channelUserid != Constant.userID
                            ? buildButtons(
                                title: "blockuser",
                                onTap: () {
                                  if (widget.isProfile == false &&
                                      widget.channelUserid != Constant.userID) {
                                    showMenu(
                                      context: context,
                                      position: const RelativeRect.fromLTRB(
                                          100, 100, 0, 0),
                                      items: <PopupMenuEntry>[
                                        PopupMenuItem(
                                          onTap: () async {
                                            await profileProvider
                                                .addremoveBlockChannel(
                                                    "1",
                                                    settingProvider
                                                            .profileModel
                                                            .result?[0]
                                                            .channelId
                                                            .toString() ??
                                                        "");
                                          },
                                          value: 'item1',
                                          child: settingProvider.profileModel
                                                      .result?[0].isBlock ==
                                                  0
                                              ? MyText(
                                                  color: colorPrimaryDark,
                                                  text: "blockuser",
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textTitle,
                                                  fontsizeWeb: Dimens.textTitle,
                                                  multilanguage: true,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w500,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal)
                                              : MyText(
                                                  color: colorPrimaryDark,
                                                  text: "removeblockuser",
                                                  textalign: TextAlign.center,
                                                  fontsizeNormal:
                                                      Dimens.textTitle,
                                                  fontsizeWeb: Dimens.textTitle,
                                                  multilanguage: true,
                                                  inter: false,
                                                  maxline: 1,
                                                  fontwaight: FontWeight.w500,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal),
                                        ),
                                      ],
                                    );
                                  }
                                })
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget buildButtons({onTap, title}) {
    return InkWell(
      hoverColor: transparent,
      highlightColor: transparent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        decoration: BoxDecoration(
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(50),
        ),
        child: MyText(
            color: white,
            text: title,
            textalign: TextAlign.center,
            fontsizeNormal: Dimens.textSmall,
            fontsizeWeb: Dimens.textSmall,
            inter: false,
            multilanguage: true,
            maxline: 1,
            fontwaight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal),
      ),
    );
  }

  Widget buildImageShimmer() {
    return const Padding(
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        children: [
          CustomWidget.circular(
            width: 160,
            height: 160,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomWidget.roundrectborder(
                  width: 200,
                  height: 12,
                ),
                SizedBox(height: 15),
                CustomWidget.roundrectborder(
                  width: 200,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTab() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      return SizedBox(
        height: 65,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: Constant.profileTabList.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  // physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      hoverColor: transparent,
                      highlightColor: transparent,
                      onTap: () async {
                        profileprovider.changeTab(index);
                        /* Video */
                        if (profileprovider.position == 0) {
                          getTabData(0, "1");
                          profileprovider.clearListData();
                          /* Podcast */
                        } else if (profileprovider.position == 1) {
                          getTabData(0, "4");
                          profileprovider.clearListData();
                          /* Playlist */
                        } else if (profileprovider.position == 2) {
                          getTabData(0, "5");
                          profileprovider.clearListData();
                          /* Short */
                        } else if (profileprovider.position == 3) {
                          getTabData(0, "3");
                          profileprovider.clearListData();
                          /* Other Page  */
                        } else if (profileprovider.position == 4) {
                          _fetchRentData(0);
                          profileprovider.clearListData();
                          /* Other Page  */
                        } else {
                          profileprovider.clearListData();
                        }
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                                color: profileprovider.position == index
                                    ? colorAccent
                                    : white,
                                text: Constant.profileTabList[index],
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
                                fontsizeWeb: Dimens.textTitle,
                                inter: false,
                                multilanguage: true,
                                maxline: 1,
                                fontwaight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                            const SizedBox(height: 20),
                            Container(
                              color: profileprovider.position == index
                                  ? colorAccent
                                  : black,
                              height: 2,
                              width: 100,
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            Container(
              color: colorPrimaryDark,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              height: 2,
              width: MediaQuery.of(context).size.width,
            )
          ],
        ),
      );
    });
  }

  Widget buildTabItem() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.position == 0) {
        return buildVideo();
      } else if (profileprovider.position == 1) {
        return buildPadcast();
      } else if (profileprovider.position == 2) {
        return buildPlaylist();
      } else if (profileprovider.position == 3) {
        return buildReels();
      } else if (profileprovider.position == 4) {
        return buildRentVideo();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget buildVideo() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return videoShimmer();
      } else {
        return Column(
          children: [
            video(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget video() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: Utils.crossAxisCount(context),
              maxItemsPerRow: Utils.crossAxisCount(context),
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  profileProvider.channelContentList?.length ?? 0, (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebDetail(
                          stoptime: 0,
                          iscontinueWatching: false,
                          videoid: profileProvider.channelContentList?[index].id
                                  .toString() ??
                              "",
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                                height: 180,
                                imagePath: profileProvider
                                        .channelContentList?[index].landscapeImg
                                        .toString() ??
                                    ""),
                          ),
                          Positioned.fill(
                            right: 15,
                            bottom: 15,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(5, 4, 5, 4),
                                decoration: BoxDecoration(
                                  color: transparent.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: MyText(
                                    color: white,
                                    text: Utils.formatTime(double.parse(
                                        profileProvider
                                                .channelContentList?[index]
                                                .contentDuration
                                                .toString() ??
                                            "")),
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textSmall,
                                    fontsizeWeb: Dimens.textSmall,
                                    inter: false,
                                    multilanguage: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(3, 20, 3, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: MyNetworkImage(
                                width: 35,
                                height: 35,
                                imagePath: profileProvider
                                        .channelContentList?[index].channelImage
                                        .toString() ??
                                    "",
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                      color: white,
                                      text: profileProvider
                                              .channelContentList?[index].title
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textTitle,
                                      fontsizeWeb: Dimens.textTitle,
                                      inter: false,
                                      maxline: 2,
                                      multilanguage: false,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  profileProvider.channelContentList?[index]
                                              .channelName
                                              .toString() ==
                                          ""
                                      ? const SizedBox.shrink()
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            MyText(
                                                color: gray,
                                                text: profileProvider
                                                        .channelContentList?[
                                                            index]
                                                        .channelName
                                                        .toString() ??
                                                    "",
                                                textalign: TextAlign.left,
                                                fontsizeNormal:
                                                    Dimens.textMedium,
                                                fontsizeWeb: Dimens.textMedium,
                                                inter: false,
                                                maxline: 2,
                                                multilanguage: false,
                                                fontwaight: FontWeight.w400,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal),
                                          ],
                                        ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                          color: gray,
                                          text: Utils.kmbGenerator(
                                              profileProvider
                                                      .channelContentList?[0]
                                                      .totalView ??
                                                  0),
                                          textalign: TextAlign.left,
                                          fontsizeNormal: Dimens.textMedium,
                                          fontsizeWeb: Dimens.textMedium,
                                          inter: false,
                                          maxline: 2,
                                          multilanguage: false,
                                          fontwaight: FontWeight.w400,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                      const SizedBox(width: 5),
                                      MyText(
                                          color: gray,
                                          text: "views",
                                          textalign: TextAlign.left,
                                          fontsizeNormal: Dimens.textMedium,
                                          fontsizeWeb: Dimens.textMedium,
                                          inter: false,
                                          maxline: 2,
                                          multilanguage: true,
                                          fontwaight: FontWeight.w400,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: MyText(
                                            color: gray,
                                            text: Utils.timeAgoCustom(
                                              DateTime.parse(
                                                profileProvider
                                                        .channelContentList?[
                                                            index]
                                                        .createdAt ??
                                                    "",
                                              ),
                                            ),
                                            textalign: TextAlign.left,
                                            fontsizeNormal: Dimens.textMedium,
                                            fontsizeWeb: Dimens.textMedium,
                                            inter: false,
                                            maxline: 1,
                                            multilanguage: false,
                                            fontwaight: FontWeight.w400,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
      } else {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget videoShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.crossAxisCount(context),
          maxItemsPerRow: Utils.crossAxisCount(context),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(10, (index) {
            return Column(
              children: [
                CustomWidget.webImageRound(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(3, 20, 3, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomWidget.circular(
                        width: 35,
                        height: 35,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomWidget.roundrectborder(
                              width: 250,
                              height: 5,
                            ),
                            CustomWidget.roundrectborder(
                              width: 250,
                              height: 5,
                            ),
                            CustomWidget.roundrectborder(
                              width: 250,
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      CustomWidget.roundrectborder(
                        width: 5,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildPadcast() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return padcastShimmer();
      } else {
        return Column(
          children: [
            padcast(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget padcast() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: Utils.crossAxisCount(context),
              maxItemsPerRow: Utils.crossAxisCount(context),
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  profileProvider.channelContentList?.length ?? 0, (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebContentDetail(
                          contentDiscription: profileProvider
                                  .channelContentList?[index].description
                                  .toString() ??
                              "",
                          contentType: profileProvider
                                  .channelContentList?[index].contentType
                                  .toString() ??
                              "",
                          contentImage: profileProvider
                                  .channelContentList?[index].portraitImg
                                  .toString() ??
                              "",
                          contentName: profileProvider
                                  .channelContentList?[index].title
                                  .toString() ??
                              "",
                          /* Temporary Null ContentUserid */
                          contentUserid: "",
                          contentId: profileProvider
                                  .channelContentList?[index].id
                                  .toString() ??
                              "",
                          playlistImage: profileProvider
                              .channelContentList?[index].playlistImage,
                          isBuy: profileProvider
                                  .channelContentList?[index].isBuy
                                  .toString() ??
                              "",
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 180,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                imagePath: profileProvider
                                        .channelContentList?[index].portraitImg
                                        .toString() ??
                                    "",
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "pause.png"),
                            ),
                            if (profileProvider.deleteItemIndex == index &&
                                profileProvider.deletecontentLoading)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorAccent,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  hoverColor: transparent,
                                  highlightColor: transparent,
                                  onTap: () async {
                                    if (widget.channelUserid ==
                                        Constant.userID) {
                                      await profileProvider.getDeleteContent(
                                          index,
                                          profileProvider
                                                  .channelContentList?[index]
                                                  .contentType
                                                  .toString() ??
                                              "",
                                          profileProvider
                                                  .channelContentList?[index].id
                                                  .toString() ??
                                              "",
                                          "0");
                                    }
                                  },
                                  child: widget.channelUserid == Constant.userID
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 8, 5, 8),
                                          child: MyImage(
                                              width: 20,
                                              height: 20,
                                              color: white,
                                              imagePath: "ic_delete.png"),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: profileProvider.channelContentList?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textMedium,
                          fontsizeWeb: Dimens.textMedium,
                          inter: false,
                          multilanguage: false,
                          maxline: 2,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      } else {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget padcastShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.crossAxisCount(context),
          maxItemsPerRow: Utils.crossAxisCount(context),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(8, (index) {
            return const Column(
              children: [
                CustomWidget.roundrectborder(
                  height: 180,
                ),
                SizedBox(height: 10),
                CustomWidget.roundrectborder(
                  height: 6,
                ),
                CustomWidget.roundrectborder(
                  height: 6,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildPlaylist() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return playlistShimmer();
      } else {
        return Column(
          children: [
            playlist(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget playlist() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: Utils.customCrossAxisCount(
                  context: context,
                  height1600: 6,
                  height1200: 5,
                  height800: 3,
                  height600: 2),
              maxItemsPerRow: Utils.customCrossAxisCount(
                  context: context,
                  height1600: 6,
                  height1200: 5,
                  height800: 3,
                  height600: 2),
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  profileProvider.channelContentList?.length ?? 0, (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebContentDetail(
                          contentDiscription: profileProvider
                                  .channelContentList?[index].description
                                  .toString() ??
                              "",
                          contentType: profileProvider
                                  .channelContentList?[index].contentType
                                  .toString() ??
                              "",
                          contentImage: profileProvider
                                  .channelContentList?[index].portraitImg
                                  .toString() ??
                              "",
                          contentName: profileProvider
                                  .channelContentList?[index].title
                                  .toString() ??
                              "",
                          /* Temporary Null ContentUserid */
                          contentUserid: "",
                          contentId: profileProvider
                                  .channelContentList?[index].id
                                  .toString() ??
                              "",
                          playlistImage: profileProvider
                              .channelContentList?[index].playlistImage,
                          isBuy: profileProvider
                                  .channelContentList?[index].isBuy
                                  .toString() ??
                              "",
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 180,
                          child: Stack(
                            children: [
                              playlistImages(index,
                                  profileProvider.channelContentList ?? []),
                              Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "pause.png"),
                              ),
                              if (profileProvider.deleteItemIndex == index &&
                                  profileProvider.deletecontentLoading)
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: colorAccent,
                                        strokeWidth: 1,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    hoverColor: transparent,
                                    highlightColor: transparent,
                                    onTap: () async {
                                      if (widget.channelUserid ==
                                          Constant.userID) {
                                        await profileProvider.getDeleteContent(
                                            index,
                                            profileProvider
                                                    .channelContentList?[index]
                                                    .contentType
                                                    .toString() ??
                                                "",
                                            profileProvider
                                                    .channelContentList?[index]
                                                    .id
                                                    .toString() ??
                                                "",
                                            "0");
                                      }
                                    },
                                    child: widget.channelUserid ==
                                            Constant.userID
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 8, 5, 8),
                                            child: MyImage(
                                                width: 20,
                                                height: 20,
                                                color: white,
                                                imagePath: "ic_delete.png"),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 150,
                          child: MyText(
                              color: white,
                              text: profileProvider
                                      .channelContentList?[index].title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
                              fontsizeWeb: Dimens.textMedium,
                              inter: false,
                              multilanguage: false,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: gray,
                                  text: Utils.kmbGenerator(int.parse(
                                      profileProvider.channelContentList?[index]
                                              .totalView
                                              .toString() ??
                                          "")),
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textMedium,
                                  fontsizeWeb: Dimens.textMedium,
                                  inter: false,
                                  multilanguage: false,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(width: 5),
                              MyText(
                                  color: gray,
                                  text: "views",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textMedium,
                                  fontsizeWeb: Dimens.textMedium,
                                  inter: false,
                                  multilanguage: true,
                                  maxline: 1,
                                  fontwaight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
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
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget playlistShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 6,
              height1200: 5,
              height800: 3,
              height600: 1),
          maxItemsPerRow: Utils.customCrossAxisCount(
              context: context,
              height1600: 6,
              height1200: 5,
              height800: 3,
              height600: 1),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.rectangular(
                      height: 180, width: MediaQuery.of(context).size.width),
                  const SizedBox(height: 10),
                  CustomWidget.rectangular(
                      height: 5, width: MediaQuery.of(context).size.width),
                  const SizedBox(height: 5),
                  CustomWidget.rectangular(
                      height: 5, width: MediaQuery.of(context).size.width),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildReels() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return reelsShimmer();
      } else {
        return Column(
          children: [
            reels(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget reels() {
    if (profileProvider.getContentbyChannelModel.status == 200 &&
        profileProvider.channelContentList != null) {
      if ((profileProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: Utils.customCrossAxisCount(
                  context: context,
                  height1600: 8,
                  height1200: 6,
                  height800: 4,
                  height600: 2),
              maxItemsPerRow: Utils.customCrossAxisCount(
                  context: context,
                  height1600: 8,
                  height1200: 6,
                  height800: 4,
                  height600: 2),
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  profileProvider.channelContentList?.length ?? 0, (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            WebShorts(
                          initialIndex: index,
                          shortType: "profile",
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 350,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                imagePath: profileProvider
                                        .channelContentList?[index].portraitImg
                                        .toString() ??
                                    "",
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "pause.png"),
                            ),
                            if (profileProvider.deleteItemIndex == index &&
                                profileProvider.deletecontentLoading)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: colorAccent,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  hoverColor: transparent,
                                  highlightColor: transparent,
                                  onTap: () async {
                                    if (widget.channelUserid ==
                                        Constant.userID) {
                                      await profileProvider.getDeleteContent(
                                          index,
                                          profileProvider
                                                  .channelContentList?[index]
                                                  .contentType
                                                  .toString() ??
                                              "",
                                          profileProvider
                                                  .channelContentList?[index].id
                                                  .toString() ??
                                              "",
                                          "0");
                                    }
                                  },
                                  child: widget.channelUserid == Constant.userID
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 8, 5, 8),
                                          child: MyImage(
                                              width: 20,
                                              height: 20,
                                              color: white,
                                              imagePath: "ic_delete.png"),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: profileProvider.channelContentList?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textMedium,
                          fontsizeWeb: Dimens.textMedium,
                          inter: false,
                          multilanguage: false,
                          maxline: 2,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      } else {
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget reelsShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: Utils.crossAxisCountShorts(context),
          maxItemsPerRow: Utils.crossAxisCountShorts(context),
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(8, (index) {
            return const Column(
              children: [
                CustomWidget.roundrectborder(
                  height: 350,
                ),
                SizedBox(height: 10),
                CustomWidget.roundrectborder(
                  height: 6,
                ),
                CustomWidget.roundrectborder(
                  height: 6,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildRentVideo() {
    return Consumer<ProfileProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return rentVideoShimmer();
      } else {
        return Column(
          children: [
            rentVideo(),
            const SizedBox(height: 20),
            if (profileProvider.loadMore)
              Container(
                alignment: Alignment.center,
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

  Widget rentVideo() {
    if (profileProvider.getUserRentContentModel.status == 200 &&
        profileProvider.rentContentList != null) {
      if ((profileProvider.rentContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 3,
              maxItemsPerRow: 3,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  profileProvider.rentContentList?.length ?? 0, (index) {
                return InkWell(
                  hoverColor: transparent,
                  highlightColor: transparent,
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    audioPlayer.pause();
                    Utils.openPlayer(
                      isDownloadVideo: false,
                      iscontinueWatching: false,
                      stoptime: 0.0,
                      context: context,
                      videoId: profileProvider.rentContentList?[index].id
                              .toString() ??
                          "",
                      videoUrl: profileProvider.rentContentList?[index].content
                              .toString() ??
                          "",
                      vUploadType: profileProvider
                              .rentContentList?[index].contentUploadType
                              .toString() ??
                          "",
                      videoThumb: profileProvider
                              .rentContentList?[index].landscapeImg
                              .toString() ??
                          "",
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 135,
                          height: 155,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: MyNetworkImage(
                                  imagePath: profileProvider
                                          .rentContentList?[index].portraitImg
                                          .toString() ??
                                      "",
                                  fit: BoxFit.cover,
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      color: colorAccent,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: MyText(
                                      color: white,
                                      text:
                                          "${Constant.currencySymbol} ${profileProvider.rentContentList?[index].rentPrice.toString() ?? ""}",
                                      textalign: TextAlign.left,
                                      fontsizeNormal: Dimens.textMedium,
                                      fontsizeWeb: Dimens.textMedium,
                                      multilanguage: false,
                                      inter: false,
                                      maxline: 2,
                                      fontwaight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "pause.png"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 130,
                          child: MyText(
                              color: white,
                              text: profileProvider
                                      .rentContentList?[index].title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
                              fontsizeWeb: Dimens.textMedium,
                              multilanguage: false,
                              inter: false,
                              maxline: 2,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
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
        return const NoData(
            title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
      }
    } else {
      return const NoData(
          title: "nodatavideotitle", subTitle: "nodatavideosubtitle");
    }
  }

  Widget rentVideoShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: ResponsiveGridList(
          minItemWidth: 120,
          minItemsPerRow: 3,
          maxItemsPerRow: 3,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
          ),
          children: List.generate(
            10,
            (index) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(
                      width: 135,
                      height: 150,
                    ),
                    SizedBox(height: 10),
                    CustomWidget.roundrectborder(
                      width: 130,
                      height: 5,
                    ),
                    SizedBox(height: 7),
                    CustomWidget.roundrectborder(
                      width: 130,
                      height: 5,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget playlistImages(index, List<Result>? sectionList) {
    if ((sectionList?[index].playlistImage?.length ?? 0) == 4) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath:
                            sectionList?[index].playlistImage?[0].toString() ??
                                "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath:
                            sectionList?[index].playlistImage?[1].toString() ??
                                "",
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath:
                            sectionList?[index].playlistImage?[2].toString() ??
                                "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath:
                            sectionList?[index].playlistImage?[3].toString() ??
                                "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((sectionList?[index].playlistImage?.length ?? 0) == 3) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath:
                            sectionList?[index].playlistImage?[0].toString() ??
                                "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath:
                            sectionList?[index].playlistImage?[1].toString() ??
                                "",
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: MyNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  imagePath:
                      sectionList?[index].playlistImage?[2].toString() ?? "",
                ),
              ),
            ],
          ));
    } else if ((sectionList?[index].playlistImage?.length ?? 0) == 2) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath:
                            sectionList?[index].playlistImage?[0].toString() ??
                                "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath:
                            sectionList?[index].playlistImage?[1].toString() ??
                                "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((sectionList?[index].playlistImage?.length ?? 0) == 1) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: MyNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            imagePath: sectionList?[index].playlistImage?[0].toString() ?? "",
          ));
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: colorPrimaryDark,
        alignment: Alignment.center,
        child: MyImage(width: 35, height: 35, imagePath: "ic_music.png"),
      );
    }
  }

  Widget profileNoData() {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: colorPrimaryDark,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            hoverColor: transparent,
                            highlightColor: transparent,
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: MyImage(
                                width: 25,
                                height: 25,
                                imagePath: "ic_roundback.png"),
                          ),
                          const SizedBox(width: 15),
                          MyText(
                              color: white,
                              text: "myprofile",
                              textalign: TextAlign.center,
                              fontsizeNormal: Dimens.textBig,
                              fontsizeWeb: Dimens.textBig,
                              multilanguage: true,
                              inter: false,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ],
                      ),
                    ),
                    widget.isProfile == false
                        ? InkWell(
                            hoverColor: transparent,
                            highlightColor: transparent,
                            onTap: () {
                              // showMenu(
                              //   context: context,
                              //   position:
                              //       const RelativeRect.fromLTRB(100, 100, 0, 0),
                              //   items: <PopupMenuEntry>[
                              //     PopupMenuItem(
                              //       onTap: () async {},
                              //       value: 'item1',
                              //       child: settingProvider.profileModel
                              //                   .result?[0].isBlock ==
                              //               0
                              //           ? MyText(
                              //               color: colorPrimaryDark,
                              //               text: "blockuser",
                              //               textalign: TextAlign.center,
                              //               fontsize: Dimens.textTitle,
                              //               multilanguage: true,
                              //               inter: false,
                              //               maxline: 1,
                              //               fontwaight: FontWeight.w500,
                              //               overflow: TextOverflow.ellipsis,
                              //               fontstyle: FontStyle.normal)
                              //           : MyText(
                              //               color: colorPrimaryDark,
                              //               text: "removeblockuser",
                              //               textalign: TextAlign.center,
                              //               fontsize: Dimens.textTitle,
                              //               multilanguage: true,
                              //               inter: false,
                              //               maxline: 1,
                              //               fontwaight: FontWeight.w500,
                              //               overflow: TextOverflow.ellipsis,
                              //               fontstyle: FontStyle.normal),
                              //     ),
                              //   ],
                              // );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyImage(
                                  width: 15,
                                  height: 15,
                                  imagePath: "ic_more.png"),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: colorAccent),
                              borderRadius: BorderRadius.circular(60)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: MyImage(
                              width: 90,
                              height: 90,
                              fit: BoxFit.fill,
                              imagePath: "ic_user.png",
                            ),
                          ),
                        ),
                        widget.isProfile == true
                            ? Positioned.fill(
                                bottom: 3,
                                right: 3,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: InkWell(
                                    hoverColor: transparent,
                                    highlightColor: transparent,
                                    onTap: () {
                                      if (Utils.checkLoginUser(context)) {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                  builder: (_) => UpdateProfile(
                                                      channelid:
                                                          Constant.channelID ??
                                                              "")),
                                            )
                                            .then(
                                                (val) => val ? getApi() : null);
                                      }
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorAccent),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MyText(
                        color: colorAccent,
                        text: "Guest User",
                        multilanguage: false,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                            color: white,
                            text: "0",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: white,
                            text: "subscriber",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            multilanguage: true,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: white,
                            text: "0",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            inter: false,
                            maxline: 1,
                            multilanguage: false,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(width: 5),
                        MyText(
                            color: white,
                            text: "content",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            inter: false,
                            maxline: 1,
                            multilanguage: true,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  buildUpdateProfileDilog(List<profile.Result>? profileData) {
    return showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: colorPrimaryDark,
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20.0),
            constraints: const BoxConstraints(
              minWidth: 400,
              maxWidth: 500,
              minHeight: 500,
              maxHeight: 550,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MyText(
                        color: white,
                        text: "editprofile",
                        multilanguage: true,
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textTitle,
                        fontsizeWeb: Dimens.textTitle,
                        maxline: 6,
                        fontwaight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                  space(0.04),
                  Stack(
                    children: [
                      MyNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          imagePath: profileData?[0].coverImg.toString() ?? "",
                          fit: BoxFit.cover),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: MyNetworkImage(
                                width: 100,
                                height: 100,
                                imagePath:
                                    profileData?[0].image.toString() ?? "",
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ],
                  ),
                  space(0.05),
                  myTextField(nameController, TextInputAction.next,
                      TextInputType.text, Constant.fullname, false),
                  space(0.03),
                  myTextField(channelNameController, TextInputAction.next,
                      TextInputType.text, Constant.channelname, false),
                  space(0.03),
                  myTextField(emailController, TextInputAction.next,
                      TextInputType.text, Constant.email, false),
                  space(0.03),
                  myTextField(numberController, TextInputAction.next,
                      TextInputType.number, Constant.mobile, true),
                  space(0.03),
                  updateProfileButton(),
                  space(0.03),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget myTextField(
      controller, textInputAction, keyboardType, labletext, isMobile) {
    return SizedBox(
      height: 55,
      child: isMobile == false
          ? TextFormField(
              textAlign: TextAlign.left,
              obscureText: false,
              keyboardType: keyboardType,
              controller: controller,
              textInputAction: textInputAction,
              cursorColor: white,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontStyle: FontStyle.normal,
                  color: white,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: labletext,
                labelStyle: GoogleFonts.montserrat(
                    fontSize: Dimens.textMedium,
                    fontStyle: FontStyle.normal,
                    color: colorAccent,
                    fontWeight: FontWeight.w500),
                contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: white, width: 1.5),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: white, width: 1.5),
                ),
              ),
            )
          : IntlPhoneField(
              disableLengthCheck: true,
              textAlignVertical: TextAlignVertical.center,
              autovalidateMode: AutovalidateMode.disabled,
              controller: controller,
              style: Utils.googleFontStyle(4, Dimens.textMedium,
                  FontStyle.normal, white, FontWeight.w500),
              showCountryFlag: false,
              showDropdownIcon: false,
              initialValue: "In",
              initialCountryCode: "IN",
              dropdownTextStyle: Utils.googleFontStyle(4, Dimens.textMedium,
                  FontStyle.normal, white, FontWeight.w500),
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              decoration: InputDecoration(
                labelText: labletext,
                fillColor: transparent,
                border: InputBorder.none,
                labelStyle: Utils.googleFontStyle(4, Dimens.textMedium,
                    FontStyle.normal, colorAccent, FontWeight.w500),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: white, width: 1),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: white, width: 1),
                ),
              ),
              onChanged: (phone) {
                mobilenumber = phone.number;
                countryname = phone.countryISOCode;
                countrycode = phone.countryCode;
                log('mobile number==> $mobilenumber');
                log('countryCode number==> $countryname');
                log('countryISOCode==> $countrycode');
              },
              onCountryChanged: (country) {
                countryname = country.code.replaceAll('+', '');
                countrycode = "+${country.dialCode.toString()}";
                log('countryname===> $countryname');
                log('countrycode===> $countrycode');
              },
            ),
    );
  }

  Widget space(double space) {
    return SizedBox(height: MediaQuery.of(context).size.height * space);
  }

  Widget updateProfileButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          hoverColor: transparent,
          highlightColor: transparent,
          radius: 15,
          borderRadius: BorderRadius.circular(15),
          autofocus: false,
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
              color: colorPrimaryDark,
              borderRadius: BorderRadius.circular(15),
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
                fontsizeWeb: Dimens.textBig,
                maxline: 1,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ),
        ),
        const SizedBox(width: 25),
        InkWell(
          hoverColor: transparent,
          highlightColor: transparent,
          radius: 15,
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            final updateprofileProvider =
                Provider.of<UpdateprofileProvider>(context, listen: false);

            String fullname = nameController.text.toString();
            String channelName = channelNameController.text.toString();
            String email = emailController.text.toString();

            Utils.showProgress(context);

            await updateprofileProvider.getupdateprofile(
                Constant.userID.toString(),
                fullname,
                channelName,
                email,
                mobilenumber,
                countrycode,
                channelName,
                File(""),
                File(""));

            if (updateprofileProvider.loading) {
              if (!mounted) return;
              Utils.showProgress(context);
            } else {
              if (updateprofileProvider.updateprofileModel.status == 200) {
                if (!mounted) return;
                Utils.showSnackbar(
                    context,
                    "${updateprofileProvider.updateprofileModel.status}",
                    false);
                if (!mounted) return;
                Utils().hideProgress(context);
                getApi();
                Navigator.pop(context);
              } else {
                if (!mounted) return;
                Utils.showSnackbar(
                    context,
                    "${updateprofileProvider.updateprofileModel.status}",
                    false);
                Utils().hideProgress(context);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
              color: colorAccent,
              borderRadius: BorderRadius.circular(15),
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
                text: "update",
                textalign: TextAlign.left,
                fontsizeNormal: Dimens.textBig,
                fontsizeWeb: Dimens.textBig,
                maxline: 1,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ),
        ),
      ],
    );
  }
}
