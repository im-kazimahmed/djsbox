import 'package:yourappname/pages/contentdetail.dart';
import 'package:yourappname/pages/detail.dart';
import 'package:yourappname/pages/profile.dart';
import 'package:yourappname/pages/shorts.dart';
import 'package:yourappname/provider/subscribedchannelprovider.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../model/getcontentbychannelmodel.dart';

class SubscribedChannel extends StatefulWidget {
  const SubscribedChannel({super.key});

  @override
  State<SubscribedChannel> createState() => SubscribedChannelState();
}

class SubscribedChannelState extends State<SubscribedChannel> {
  ImagePicker picker = ImagePicker();
  XFile? frontimage;
  late ScrollController _scrollController;
  late SubscribedChannelProvider subscribedChannelProvider;
  final ScrollController subscriberController = ScrollController();

  @override
  void initState() {
    subscribedChannelProvider =
        Provider.of<SubscribedChannelProvider>(context, listen: false);
    _scrollController = ScrollController();
    subscriberController.addListener(_scrollListenerCategory);
    _scrollController.addListener(_scrollListener);
    super.initState();
    _fetchSubscriberData(0);
  }

  /* Category Scroll Pagination */
  _scrollListenerCategory() async {
    if (!subscriberController.hasClients) return;
    if (subscriberController.offset >=
            subscriberController.position.maxScrollExtent &&
        !subscriberController.position.outOfRange &&
        (subscribedChannelProvider.currentPage ?? 0) <
            (subscribedChannelProvider.totalPage ?? 0)) {
      printLog("load more====>");
      await subscribedChannelProvider.setSubscriberLoadMore(true);
      _fetchSubscriberData(subscribedChannelProvider.currentPage ?? 0);
    }
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (subscribedChannelProvider.currentPage ?? 0) <
            (subscribedChannelProvider.totalPage ?? 0)) {
      printLog("load more====>");
      subscribedChannelProvider.setLoadMore(true);
      if (subscribedChannelProvider.position == 0) {
        getTabData(subscribedChannelProvider.currentPage ?? 0, "1");
      } else if (subscribedChannelProvider.position == 1) {
        getTabData(subscribedChannelProvider.currentPage ?? 0, "4");
      } else if (subscribedChannelProvider.position == 2) {
        getTabData(subscribedChannelProvider.currentPage ?? 0, "5");
      } else if (subscribedChannelProvider.position == 3) {
        getTabData(subscribedChannelProvider.currentPage ?? 0, "3");
      } else {
        printLog("Something Went Wronge!!!");
      }
    }
  }

  getTabData(pageNo, contenttype) {
    _fetchData(
      pageNo,
      contenttype,
      subscribedChannelProvider.channelUserId,
      subscribedChannelProvider.channelId,
    );
  }

  Future<void> _fetchSubscriberData(int? nextPage) async {
    printLog("isMorePage  ======> ${subscribedChannelProvider.isMorePage}");
    printLog("currentPage ======> ${subscribedChannelProvider.currentPage}");
    printLog("totalPage   ======> ${subscribedChannelProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await subscribedChannelProvider.getSubscriberList((nextPage ?? 0) + 1);
    await subscribedChannelProvider.selectChannel(
        subscribedChannelProvider.subscriberList?[0].id.toString() ?? "",
        subscribedChannelProvider.subscriberList?[0].channelId.toString() ?? "",
        0);

    subscribedChannelProvider.clearListData();

    if (subscribedChannelProvider.position == 0) {
      getTabData(0, "1");
      subscribedChannelProvider.clearListData();
      /* Podcast */
    } else if (subscribedChannelProvider.position == 1) {
      getTabData(0, "4");
      subscribedChannelProvider.clearListData();
      /* Playlist */
    } else if (subscribedChannelProvider.position == 2) {
      getTabData(0, "5");
      subscribedChannelProvider.clearListData();
      /* Short */
    } else if (subscribedChannelProvider.position == 3) {
      getTabData(0, "3");
      subscribedChannelProvider.clearListData();
      /* Other Page  */
    } else {
      subscribedChannelProvider.clearListData();
    }
  }

  Future<void> _fetchData(int? nextPage, contenttype, userid, channelid) async {
    printLog("isMorePage  ======> ${subscribedChannelProvider.isMorePage}");
    printLog("currentPage ======> ${subscribedChannelProvider.currentPage}");
    printLog("totalPage   ======> ${subscribedChannelProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await subscribedChannelProvider.getcontentbyChannel(
        userid, channelid, contenttype, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    super.dispose();
    subscribedChannelProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, "subscriptions", true),
      body: Consumer<SubscribedChannelProvider>(
          builder: (context, channelprovider, child) {
        if (channelprovider.subscriberLoading &&
            !channelprovider.subscriberloadMore) {
          return Utils.pageLoader(context);
        } else {
          if ((subscribedChannelProvider.subscriberlistModel.status == 200) &&
              (subscribedChannelProvider.subscriberList != null) &&
              ((subscribedChannelProvider.subscriberList?.length ?? 0) > 0)) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  buildSubscription(),
                  viewChannelButton(),
                  buildTab(),
                  buildTabItem(),
                ],
              ),
            );
          } else {
            return const NoData();
          }
        }
      }),
    );
  }

  Widget buildSubscription() {
    return Consumer<SubscribedChannelProvider>(
        builder: (context, subscriberprovider, child) {
      if (subscriberprovider.subscriberLoading &&
          !subscriberprovider.subscriberloadMore) {
        return Utils.pageLoader(context);
      } else {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 120,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: subscriberController,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                videocategoryList(),
                if (subscriberprovider.subscriberloadMore)
                  const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: colorAccent,
                        strokeWidth: 1,
                      ))
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        );
      }
    });
  }

  Widget videocategoryList() {
    if (subscribedChannelProvider.subscriberlistModel.status == 200 &&
        subscribedChannelProvider.subscriberList != null) {
      if ((subscribedChannelProvider.subscriberList?.length ?? 0) > 0) {
        return ListView.builder(
          itemCount: subscribedChannelProvider.subscriberList?.length ?? 0,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return InkWell(
              autofocus: false,
              highlightColor: transparent,
              focusColor: transparent,
              hoverColor: transparent,
              onTap: () async {
                await subscribedChannelProvider.selectChannel(
                    subscribedChannelProvider.subscriberList?[index].id
                            .toString() ??
                        "",
                    subscribedChannelProvider.subscriberList?[index].channelId
                            .toString() ??
                        "",
                    index);

                subscribedChannelProvider.clearListData();

                if (subscribedChannelProvider.position == 0) {
                  getTabData(0, "1");
                  subscribedChannelProvider.clearListData();
                  /* Podcast */
                } else if (subscribedChannelProvider.position == 1) {
                  getTabData(0, "4");
                  subscribedChannelProvider.clearListData();
                  /* Playlist */
                } else if (subscribedChannelProvider.position == 2) {
                  getTabData(0, "5");
                  subscribedChannelProvider.clearListData();
                  /* Short */
                } else if (subscribedChannelProvider.position == 3) {
                  getTabData(0, "3");
                  subscribedChannelProvider.clearListData();
                  /* Other Page  */
                } else {
                  subscribedChannelProvider.clearListData();
                }
              },
              child: Container(
                color: subscribedChannelProvider.channelPosition == index
                    ? colorPrimaryDark
                    : transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(width: 1, color: colorAccent)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: MyNetworkImage(
                            width: 45,
                            height: 45,
                            imagePath: subscribedChannelProvider
                                    .subscriberList?[index].image ??
                                "",
                            fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 10),
                    MyText(
                      color: white,
                      text: subscribedChannelProvider
                              .subscriberList?[index].fullName ??
                          "",
                      fontwaight: FontWeight.w500,
                      fontsizeNormal: Dimens.textSmall,
                      maxline: 1,
                      multilanguage: false,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget viewChannelButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 15, 5),
      child: InkWell(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Profile(
                  isProfile: false,
                  channelUserid: subscribedChannelProvider.channelUserId,
                  channelid: subscribedChannelProvider.channelId,
                );
              },
            ),
          );
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: colorAccent,
            ),
            child: MyText(
                color: white,
                text: "viewprofile",
                textalign: TextAlign.center,
                fontsizeNormal: Dimens.textSmall,
                inter: false,
                multilanguage: true,
                maxline: 1,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ),
        ),
      ),
    );
  }

  Widget buildTab() {
    return Consumer<SubscribedChannelProvider>(
        builder: (context, profileprovider, child) {
      return SizedBox(
        height: 65,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: Constant.subscriberTabList.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      autofocus: false,
                      focusColor: black,
                      highlightColor: black,
                      hoverColor: black,
                      splashColor: black,
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
                                text: Constant.subscriberTabList[index],
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
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
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget buildVideo() {
    return Consumer<SubscribedChannelProvider>(
        builder: (context, profileprovider, child) {
      if (profileprovider.loading && !profileprovider.loadMore) {
        return videoShimmer();
      } else {
        return Column(
          children: [
            video(),
            const SizedBox(height: 20),
            if (subscribedChannelProvider.loadMore)
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
    if (subscribedChannelProvider.getContentbyChannelModel.status == 200 &&
        subscribedChannelProvider.channelContentList != null) {
      if ((subscribedChannelProvider.channelContentList?.length ?? 0) > 0) {
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
                  subscribedChannelProvider.channelContentList?.length ?? 0,
                  (index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Detail(
                              stoptime: 0,
                              iscontinueWatching: false,
                              videoid: subscribedChannelProvider
                                      .channelContentList?[index].id
                                      .toString() ??
                                  "",
                            );
                          },
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          // width: 90,
                          height: 90,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MyNetworkImage(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                  imagePath: subscribedChannelProvider
                                          .channelContentList?[index]
                                          .portraitImg
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyText(
                            color: white,
                            text: subscribedChannelProvider
                                    .channelContentList?[index].title
                                    .toString() ??
                                "",
                            textalign: TextAlign.start,
                            fontsizeNormal: Dimens.textSmall,
                            inter: false,
                            multilanguage: false,
                            maxline: 2,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
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

  Widget videoShimmer() {
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
          children: List.generate(10, (index) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomWidget.roundrectborder(
                    width: 90,
                    height: 90,
                  ),
                  SizedBox(height: 8),
                  CustomWidget.roundrectborder(
                    width: 80,
                    height: 6,
                  ),
                  CustomWidget.roundrectborder(
                    width: 80,
                    height: 6,
                  ),
                ],
              ),
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
            if (subscribedChannelProvider.loadMore)
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
    if (subscribedChannelProvider.getContentbyChannelModel.status == 200 &&
        subscribedChannelProvider.channelContentList != null) {
      if ((subscribedChannelProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 2,
              maxItemsPerRow: 2,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  subscribedChannelProvider.channelContentList?.length ?? 0,
                  (index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ContentDetail(
                            contentType: subscribedChannelProvider
                                    .channelContentList?[index].contentType
                                    .toString() ??
                                "",
                            contentImage: subscribedChannelProvider
                                    .channelContentList?[index].portraitImg
                                    .toString() ??
                                "",
                            contentName: subscribedChannelProvider
                                    .channelContentList?[index].title
                                    .toString() ??
                                "",
                            /* Temporary Null ContentUserid */
                            contentUserid: "",
                            contentId: subscribedChannelProvider
                                    .channelContentList?[index].id
                                    .toString() ??
                                "",
                            playlistImage: subscribedChannelProvider
                                .channelContentList?[index].playlistImage,
                            isBuy: subscribedChannelProvider
                                    .channelContentList?[index].isBuy
                                    .toString() ??
                                "",
                          );
                        },
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                imagePath: subscribedChannelProvider
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: subscribedChannelProvider
                                  .channelContentList?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textMedium,
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
          minItemsPerRow: 2,
          maxItemsPerRow: 2,
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
                  height: 100,
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
            if (subscribedChannelProvider.loadMore)
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
    if (subscribedChannelProvider.getContentbyChannelModel.status == 200 &&
        subscribedChannelProvider.channelContentList != null) {
      if ((subscribedChannelProvider.channelContentList?.length ?? 0) > 0) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveGridList(
              minItemWidth: 120,
              minItemsPerRow: 2,
              maxItemsPerRow: 2,
              horizontalGridSpacing: 10,
              verticalGridSpacing: 25,
              listViewBuilderOptions: ListViewBuilderOptions(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: List.generate(
                  subscribedChannelProvider.channelContentList?.length ?? 0,
                  (index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ContentDetail(
                            contentType: subscribedChannelProvider
                                    .channelContentList?[index].contentType
                                    .toString() ??
                                "",
                            contentImage: subscribedChannelProvider
                                    .channelContentList?[index].portraitImg
                                    .toString() ??
                                "",
                            contentName: subscribedChannelProvider
                                    .channelContentList?[index].title
                                    .toString() ??
                                "",
                            /* Temporary Null ContentUserid */
                            contentUserid: "",
                            contentId: subscribedChannelProvider
                                    .channelContentList?[index].id
                                    .toString() ??
                                "",
                            playlistImage: subscribedChannelProvider
                                .channelContentList?[index].playlistImage,
                            isBuy: subscribedChannelProvider
                                    .channelContentList?[index].isBuy
                                    .toString() ??
                                "",
                          );
                        },
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
                          width: 160,
                          height: 150,
                          child: Stack(
                            children: [
                              playlistImages(
                                  index,
                                  subscribedChannelProvider
                                          .channelContentList ??
                                      []),
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
                          width: 150,
                          child: MyText(
                              color: white,
                              text: subscribedChannelProvider
                                      .channelContentList?[index].title
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
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
                                      subscribedChannelProvider
                                              .channelContentList?[index]
                                              .totalView
                                              .toString() ??
                                          "")),
                                  textalign: TextAlign.left,
                                  fontsizeNormal: Dimens.textMedium,
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
          minItemsPerRow: 2,
          maxItemsPerRow: 2,
          horizontalGridSpacing: 10,
          verticalGridSpacing: 25,
          listViewBuilderOptions: ListViewBuilderOptions(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(6, (index) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.rectangular(height: 150, width: 160),
                  SizedBox(height: 10),
                  CustomWidget.rectangular(height: 5, width: 160),
                  SizedBox(height: 5),
                  CustomWidget.rectangular(height: 5, width: 160),
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
            if (subscribedChannelProvider.loadMore)
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
    if (subscribedChannelProvider.getContentbyChannelModel.status == 200 &&
        subscribedChannelProvider.channelContentList != null) {
      if ((subscribedChannelProvider.channelContentList?.length ?? 0) > 0) {
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
                  subscribedChannelProvider.channelContentList?.length ?? 0,
                  (index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Shorts(
                            initialIndex: index,
                            shortType: "profile",
                          );
                        },
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MyNetworkImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                                imagePath: subscribedChannelProvider
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      MyText(
                          color: white,
                          text: subscribedChannelProvider
                                  .channelContentList?[index].title
                                  .toString() ??
                              "",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textMedium,
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
          minItemsPerRow: 3,
          maxItemsPerRow: 3,
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
                  height: 150,
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

  Widget playlistImages(index, List<Result>? sectionList) {
    if ((sectionList?[index].playlistImage?.length ?? 0) == 4) {
      return SizedBox(
          width: 160,
          height: 150,
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
                        height: 150,
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
                        height: 150,
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
                        height: 150,
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
                        height: 150,
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
          width: 160,
          height: 150,
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
                        height: 150,
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
                        height: 150,
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
          width: 160,
          height: 150,
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
                        height: 150,
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
                        height: 150,
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
          width: 160,
          height: 150,
          child: MyNetworkImage(
            width: 160,
            height: 150,
            fit: BoxFit.cover,
            imagePath: sectionList?[index].playlistImage?[0].toString() ?? "",
          ));
    } else {
      return Container(
        width: 160,
        height: 150,
        color: colorPrimaryDark,
        alignment: Alignment.center,
        child: MyImage(width: 35, height: 35, imagePath: "ic_music.png"),
      );
    }
  }
}
