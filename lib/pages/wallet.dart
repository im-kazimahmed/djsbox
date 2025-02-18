import 'package:yourappname/provider/walletprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  late WalletProvider walletProvider;
  late ScrollController _scrollController;

  @override
  void initState() {
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    getApi();
    _fetchDataUsageHistory(0);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  getApi() async {
    /* Profile Api */
    await walletProvider.getprofile(context, Constant.userID);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (walletProvider.currentPage ?? 0) < (walletProvider.totalPage ?? 0)) {
      printLog("load more====>");
      // walletProvider.setLoadMore(true);
      // _fetchDataAdsPackageTransection(walletProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchDataUsageHistory(int? nextPage) async {
    /* get Ads Package Transection Api */
    await walletProvider.getUsageHistory((nextPage ?? 0) + 1);
    walletProvider.setUsageHistoryLoadMore(false);
  }

  Future<void> _fetchDataAdsPackageTransection(int? nextPage) async {
    /* get Ads Package Transection Api */
    // walletProvider.setLoadMore(false);
    await walletProvider.getAdsPackageTransection((nextPage ?? 0) + 1);
    walletProvider.setLoadMore(false);
  }

  Future<void> _fetchDataWithdrawalTransection(int? nextPage) async {
    /* get Ads Package Transection Api */
    await walletProvider.getWithdrawalTransection((nextPage ?? 0) + 1);
    walletProvider.setWithdrawalLoadMore(false);
  }

  @override
  void dispose() {
    walletProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: Utils().otherPageAppBar(context, "mywallet", true),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 190),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                myWallet(),
                const SizedBox(height: 30),
                buildTab(),
                buildTabItem(),
              ],
            ),
          ),
          Utils.musicAndAdsPanel(context),
        ],
      ),
    );
  }

  Widget myWallet() {
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyImage(width: 25, height: 25, imagePath: "ic_coin.png"),
                  const SizedBox(width: 8),
                  walletprovider.loading
                      ? MyText(
                          color: white,
                          multilanguage: false,
                          text: "0",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal)
                      : MyText(
                          color: white,
                          multilanguage: false,
                          text: walletprovider.profileModel.status != 200
                              ? "0"
                              : walletprovider
                                      .profileModel.result?[0].walletBalance
                                      .toString() ??
                                  "",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                  const SizedBox(width: 8),
                  MyText(
                      color: white,
                      multilanguage: true,
                      text: "coins",
                      textalign: TextAlign.center,
                      fontsizeNormal: Dimens.textBig,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ],
              ),
              const SizedBox(height: 12),
              MyText(
                  color: white,
                  multilanguage: false,
                  text: "Current Balance",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textMedium,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ],
          ),
          const SizedBox(width: 35),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyImage(width: 25, height: 25, imagePath: "ic_wallet.png"),
                  const SizedBox(width: 10),
                  walletprovider.loading
                      ? MyText(
                          color: white,
                          multilanguage: false,
                          text: "\$0",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal)
                      : MyText(
                          color: white,
                          multilanguage: false,
                          text: walletprovider.profileModel.status != 200
                              ? "0"
                              : "${Constant.currencySymbol}${walletprovider.profileModel.result?[0].walletEarning.toString() ?? ""}",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                ],
              ),
              const SizedBox(height: 12),
              MyText(
                  color: white,
                  multilanguage: false,
                  text: "Withdrawal",
                  textalign: TextAlign.center,
                  fontsizeNormal: Dimens.textMedium,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ],
          ),
        ],
      );
    });
  }

  Widget buildTab() {
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      return SizedBox(
        height: 65,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: Constant.transectionHistoryList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: InkWell(
                        autofocus: false,
                        focusColor: black,
                        highlightColor: black,
                        hoverColor: black,
                        splashColor: black,
                        onTap: () async {
                          walletprovider.changeTab(index);
                          /* Usage History */
                          if (walletprovider.position == 0) {
                            _fetchDataUsageHistory(0);
                            walletprovider.clearUsageHistory();
                            /* Parchas History */
                          } else if (walletprovider.position == 1) {
                            _fetchDataAdsPackageTransection(0);
                            walletprovider.clearAdsPackage();
                            /* Withdrawal History */
                          } else if (walletprovider.position == 2) {
                            _fetchDataWithdrawalTransection(0);
                            walletprovider.clearWithdrawal();
                          } else {
                            walletprovider.clearProvider();
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyText(
                                  color: walletprovider.position == index
                                      ? colorAccent
                                      : gray,
                                  text: Constant.transectionHistoryList[index],
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textTitle,
                                  inter: false,
                                  multilanguage: false,
                                  maxline: 1,
                                  fontwaight: walletprovider.position == index
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 15),
                              Container(
                                color: walletprovider.position == index
                                    ? colorAccent
                                    : black,
                                height: 3,
                                width: 60,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            Container(
              color: colorPrimaryDark,
              height: 2,
              width: MediaQuery.of(context).size.width,
            )
          ],
        ),
      );
    });
  }

  Widget buildTabItem() {
    return Consumer<WalletProvider>(builder: (context, profileprovider, child) {
      if (profileprovider.position == 0) {
        return buildUseHistory();
      } else if (profileprovider.position == 1) {
        return buildParchas();
      } else if (profileprovider.position == 2) {
        return buildWithdrawal();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

/* Use History */
  Widget buildUseHistory() {
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      if (walletprovider.usageHistoryloading &&
          !walletprovider.usageHistoryloadMore) {
        return commanShimmer();
      } else {
        return Column(
          children: [
            buildUseHistoryItem(),
            if (walletprovider.usageHistoryloadMore)
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

  Widget buildUseHistoryItem() {
    if (walletProvider.usageHistoryModel.status == 200 &&
        walletProvider.usageHistoryList != null) {
      if ((walletProvider.usageHistoryList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ResponsiveGridList(
                minItemWidth: 120,
                minItemsPerRow: 1,
                maxItemsPerRow: 1,
                horizontalGridSpacing: 10,
                verticalGridSpacing: 10,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                ),
                children: List.generate(
                    walletProvider.usageHistoryList?.length ?? 0, (index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                    decoration: const BoxDecoration(color: colorPrimaryDark),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: colorAccent,
                                  multilanguage: false,
                                  text: "Ads",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textExtraSmall,
                                  maxline: 1,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 8),
                              MyText(
                                  color: white,
                                  multilanguage: false,
                                  text: walletProvider
                                          .usageHistoryList?[index].title
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textMedium,
                                  maxline: 1,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            MyImage(
                                width: 15,
                                height: 15,
                                imagePath: "ic_coin.png"),
                            const SizedBox(width: 8),
                            MyText(
                                color: white,
                                multilanguage: false,
                                text: walletProvider
                                        .usageHistoryList?[index].totalCoin
                                        .toString() ??
                                    "",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textTitle,
                                maxline: 1,
                                fontwaight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              )),
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  /* Parchas */
  Widget buildParchas() {
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      if (walletprovider.adsPackageloading && !walletprovider.loadMore) {
        return commanShimmer();
      } else {
        return Column(
          children: [
            buildParchasItem(),
            if (walletprovider.loadMore)
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

  Widget buildParchasItem() {
    if (walletProvider.adspackageTransectionModel.status == 200 &&
        walletProvider.adsPackageTransectionList != null) {
      if ((walletProvider.adsPackageTransectionList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ResponsiveGridList(
                minItemWidth: 120,
                minItemsPerRow: 1,
                maxItemsPerRow: 1,
                horizontalGridSpacing: 10,
                verticalGridSpacing: 10,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                ),
                children: List.generate(
                    walletProvider.adsPackageTransectionList?.length ?? 0,
                    (index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                    decoration: const BoxDecoration(color: colorPrimaryDark),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: colorAccent,
                                  multilanguage: false,
                                  text: Utils.timeAgoCustom(DateTime.parse(
                                      walletProvider
                                              .adsPackageTransectionList?[index]
                                              .createdAt
                                              .toString() ??
                                          "")),
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textExtraSmall,
                                  maxline: 1,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  MyImage(
                                      width: 15,
                                      height: 15,
                                      imagePath: "ic_coin.png"),
                                  const SizedBox(width: 8),
                                  MyText(
                                      color: white,
                                      multilanguage: false,
                                      text: walletProvider
                                              .adsPackageTransectionList?[index]
                                              .coin
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 5),
                                  MyText(
                                      color: white,
                                      multilanguage: true,
                                      text: "coins",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyText(
                            color: white,
                            multilanguage: false,
                            text:
                                "${Constant.currencySymbol} ${walletProvider.adsPackageTransectionList?[index].price.toString() ?? ""}",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            maxline: 1,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  );
                }),
              )),
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  /* Withdrawal */
  Widget buildWithdrawal() {
    return Consumer<WalletProvider>(builder: (context, walletprovider, child) {
      if (walletprovider.withdrawalloading &&
          !walletprovider.withdrawalloadMore) {
        return commanShimmer();
      } else {
        return Column(
          children: [
            buildWithdrawalItem(),
            if (walletprovider.withdrawalloadMore)
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

  Widget buildWithdrawalItem() {
    if (walletProvider.withdrawalrequestModel.status == 200 &&
        walletProvider.withdrawalTransectionList != null) {
      if ((walletProvider.withdrawalTransectionList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ResponsiveGridList(
                minItemWidth: 120,
                minItemsPerRow: 1,
                maxItemsPerRow: 1,
                horizontalGridSpacing: 10,
                verticalGridSpacing: 10,
                listViewBuilderOptions: ListViewBuilderOptions(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                ),
                children: List.generate(
                    walletProvider.withdrawalTransectionList?.length ?? 0,
                    (index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                    decoration: const BoxDecoration(color: colorPrimaryDark),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  color: colorAccent,
                                  multilanguage: false,
                                  text: Utils.timeAgoCustom(DateTime.parse(
                                      walletProvider
                                              .withdrawalTransectionList?[index]
                                              .createdAt
                                              .toString() ??
                                          "")),
                                  textalign: TextAlign.center,
                                  fontsizeNormal: Dimens.textExtraSmall,
                                  maxline: 1,
                                  fontwaight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  MyImage(
                                      width: 15,
                                      height: 15,
                                      imagePath: "ic_coin.png"),
                                  const SizedBox(width: 8),
                                  MyText(
                                      color: white,
                                      multilanguage: false,
                                      text: walletProvider
                                              .withdrawalTransectionList?[index]
                                              .amount
                                              .toString() ??
                                          "",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                  const SizedBox(width: 5),
                                  MyText(
                                      color: white,
                                      multilanguage: true,
                                      text: "coins",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: Dimens.textMedium,
                                      maxline: 1,
                                      fontwaight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyText(
                            color: white,
                            multilanguage: false,
                            text:
                                "${Constant.currencySymbol} ${walletProvider.withdrawalTransectionList?[index].amount.toString() ?? ""}",
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textTitle,
                            maxline: 1,
                            fontwaight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  );
                }),
              )),
        );
      } else {
        return const NoData(title: "", subTitle: "");
      }
    } else {
      return const NoData(title: "", subTitle: "");
    }
  }

  Widget commanShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
            children: List.generate(8, (index) {
              return Container(
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                decoration: const BoxDecoration(color: colorPrimaryDark),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomWidget.roundrectborder(height: 5, width: 80),
                          SizedBox(height: 8),
                          CustomWidget.roundrectborder(
                            height: 5,
                            width: 120,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    CustomWidget.roundrectborder(height: 5, width: 50),
                  ],
                ),
              );
            }),
          )),
    );
  }
}
