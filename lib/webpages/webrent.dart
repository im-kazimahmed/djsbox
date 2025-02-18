import 'package:yourappname/music/musicdetails.dart';
import 'package:yourappname/provider/rentprovider.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customads.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/webpages/webseeall.dart';
import 'package:yourappname/webwidget/interactivecontainer.dart';
import 'package:yourappname/widget/musictitle.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:provider/provider.dart';
import '../model/rentsectionmodel.dart';

class WebRent extends StatefulWidget {
  const WebRent({super.key});

  @override
  State<WebRent> createState() => WebRentState();
}

class WebRentState extends State<WebRent> {
  late RentProvider rentProvider;
  late ScrollController _scrollController;
  int? sectionIndex;

  @override
  void initState() {
    rentProvider = Provider.of<RentProvider>(context, listen: false);
    _fetchData(0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (rentProvider.rentcurrentPage ?? 0) <
            (rentProvider.renttotalPage ?? 0)) {
      _fetchData(0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    printLog("isMorePage  ======> ${rentProvider.rentisMorePage}");
    printLog("currentPage ======> ${rentProvider.rentcurrentPage}");
    printLog("totalPage   ======> ${rentProvider.renttotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await rentProvider.getRentSeactionList((nextPage ?? 0) + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.videoSearch),
      body: Utils.sidePanelWithBody(
        myWidget: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(0, 20, 20, 190),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPage() {
    return Consumer<RentProvider>(builder: (context, rentprovider, child) {
      if (rentprovider.rentloading && !rentprovider.rentLoadMore) {
        return rentShimmer();
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MusicTitle(
                color: white,
                text: "rent",
                textalign: TextAlign.left,
                fontsizeNormal: Dimens.textExtraBig,
                fontsizeWeb: Dimens.textExtraBig,
                multilanguage: true,
                maxline: 1,
                fontwaight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
            const SizedBox(height: 30),
            CustomAds(adType: Constant.bannerAdType),
            const SizedBox(height: 30),
            setSection(),
            if (rentprovider.rentLoadMore)
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

  Widget setSection() {
    if (rentProvider.rentSectionModel.status == 200 &&
        rentProvider.rentsectionList != null) {
      if ((rentProvider.rentsectionList?.length ?? 0) > 0) {
        return ListView.builder(
          itemCount: rentProvider.rentsectionList?.length ?? 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            sectionIndex = index;
            if (rentProvider.rentsectionList?[index].data != null &&
                (rentProvider.rentsectionList?[index].data?.length ?? 0) > 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                            color: white,
                            multilanguage: false,
                            text: rentProvider.rentsectionList?[index].title
                                    .toString() ??
                                "",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textExtraBig,
                            fontsizeWeb: Dimens.textExtraBig,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        rentProvider.rentsectionList?[index].viewAll == 1
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (context, animation1, animation2) =>
                                              WebSeeAll(
                                        isRent: true,
                                        sectionId: rentProvider
                                                .rentsectionList?[index].id
                                                .toString() ??
                                            "",
                                        title: rentProvider
                                                .rentsectionList?[index].title
                                                .toString() ??
                                            "",
                                      ),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                                child: MyText(
                                    color: colorAccent,
                                    multilanguage: true,
                                    text: "seeall",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: Dimens.textMedium,
                                    fontsizeWeb: Dimens.textMedium,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Section Data List
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 280,
                      child: setSectionData(
                          sectionindex: index,
                          sectionList: rentProvider.rentsectionList),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  Widget setSectionData(
      {required int sectionindex, required List<Result>? sectionList}) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(width: 3),
      itemCount: sectionList?[sectionindex].data?.length ?? 0,
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            if (sectionList?[sectionindex].data?[index].isRentBuy == 0) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => AllPayment(
                    currency: Constant.currencySymbol,
                    itemId:
                        sectionList?[sectionindex].data?[index].id.toString() ??
                            "",
                    itemTitle: sectionList?[sectionindex]
                            .data?[index]
                            .title
                            .toString() ??
                        "",
                    payType: "Rent",
                    price: sectionList?[sectionindex]
                            .data?[index]
                            .rentPrice
                            .toString() ??
                        "",
                    productPackage: "",
                    typeId: "",
                    videoType: "",
                    coin: "",
                    rentSectionIndex: sectionindex,
                    rentVideoIndex: index,
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } else {
              audioPlayer.pause();
              Utils.openPlayer(
                isDownloadVideo: false,
                iscontinueWatching: false,
                stoptime: 0.0,
                context: context,
                videoId:
                    sectionList?[sectionindex].data?[index].id.toString() ?? "",
                videoUrl: sectionList?[sectionindex]
                        .data?[index]
                        .content
                        .toString() ??
                    "",
                vUploadType: sectionList?[sectionindex]
                        .data?[index]
                        .contentUploadType
                        .toString() ??
                    "",
                videoThumb: sectionList?[sectionindex]
                        .data?[index]
                        .landscapeImg
                        .toString() ??
                    "",
              );
            }
          },
          child: InteractiveContainer(child: (isHovered) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 235,
                        height: 135,
                        alignment: Alignment.center,
                        foregroundDecoration: isHovered
                            ? BoxDecoration(
                                gradient: LinearGradient(
                                colors: [
                                  colorPrimary.withOpacity(0.50),
                                  colorPrimary.withOpacity(0.50)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ))
                            : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: MyNetworkImage(
                            imagePath: sectionList?[sectionindex]
                                    .data?[index]
                                    .portraitImg
                                    .toString() ??
                                "",
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        top: 10,
                        left: 15,
                        right: 15,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: yellow,
                            ),
                            child: MyImage(
                              width: 18,
                              height: 18,
                              imagePath: "ic_king.png",
                              color: black,
                            ),
                          ),
                        ),
                      ),
                      MediaQuery.of(context).size.width < 400
                          ? Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                  decoration: BoxDecoration(
                                    color: yellow,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: MyText(
                                      color: black,
                                      text:
                                          "${Constant.currencySymbol} ${sectionList?[sectionindex].data?[index].rentPrice.toString() ?? ""}",
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
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 235,
                    height: 35,
                    child: MyText(
                        color: white,
                        text: sectionList?[sectionindex]
                                .data?[index]
                                .title
                                .toString() ??
                            "",
                        textalign: TextAlign.left,
                        fontsizeNormal: Dimens.textMedium,
                        fontsizeWeb: Dimens.textMedium,
                        multilanguage: false,
                        inter: false,
                        maxline: 2,
                        fontwaight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    width: 235,
                    height: isHovered == true ? 35 : 0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isHovered == true ? yellow : colorPrimary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: sectionList?[sectionindex].data?[index].isRentBuy ==
                            0
                        ? MusicTitle(
                            color: black,
                            text:
                                "Rent At Just ${Constant.currencySymbol} ${sectionList?[sectionindex].data?[index].rentPrice.toString() ?? ""}",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            fontsizeWeb: Dimens.textMedium,
                            multilanguage: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal)
                        : MusicTitle(
                            color: black,
                            text: "Watch Now",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            fontsizeWeb: Dimens.textMedium,
                            multilanguage: false,
                            maxline: 2,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget rentShimmer() {
    return ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomWidget.roundrectborder(height: 10, width: 200),
                    CustomWidget.roundrectborder(height: 10, width: 50),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Section Data List
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 230,
                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 3),
                  itemCount: 5,
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomWidget.roundrectborder(
                              width: 220,
                              height: 135,
                            ),
                            SizedBox(height: 10),
                            CustomWidget.roundrectborder(
                              width: 210,
                              height: 5,
                            ),
                            SizedBox(height: 7),
                            CustomWidget.roundrectborder(
                              width: 210,
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        });
  }
}
