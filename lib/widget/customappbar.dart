import 'package:yourappname/pages/login.dart';
import 'package:yourappname/pages/profile.dart';
import 'package:yourappname/pages/search.dart';
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/adhelper.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/widget/musictitle.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String contentType;
  const CustomAppBar({super.key, required this.contentType});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late HomeProvider homeProvider;
  late ProfileProvider profileProvider;
  SharedPre sharedPre = SharedPre();
  String image = "";
  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    getApi();
    super.initState();
  }

  getApi() async {
    if (Constant.userID != null) {
      await homeProvider.getprofile(Constant.userID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: colorPrimary,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: transparent,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: colorPrimary,
        ),
        title: Consumer<HomeProvider>(builder: (context, homeprovider, child) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    MyImage(width: 55, height: 55, imagePath: "appicon.png"),
                    Consumer<HomeProvider>(
                        builder: (context, profileprovider, child) {
                      return MusicTitle(
                          color: white,
                          text: Constant.isBuy == "1" ? "premium" : "appname",
                          textalign: TextAlign.center,
                          fontsizeNormal: Dimens.textBig,
                          fontsizeWeb: Dimens.textBig,
                          multilanguage: true,
                          maxline: 1,
                          fontwaight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal);
                    }),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                        onTap: () {
                          AdHelper.showFullscreenAd(
                              context, Constant.rewardAdType, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Search(
                                    contentType: widget.contentType,
                                  );
                                },
                              ),
                            );
                          });
                        },
                        child: MyImage(
                            width: 20, height: 20, imagePath: "ic_search.png")),
                    const SizedBox(width: 15),
                    InkWell(
                      onTap: () {
                        AdHelper.showFullscreenAd(
                            context, Constant.interstialAdType, () {
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Profile(
                                    isProfile: true,
                                    channelUserid: "",
                                    channelid: "",
                                  );
                                },
                              ),
                            );
                          }
                        });
                      },
                      child: Constant.userID == null || Constant.userImage == ""
                          ? MyImage(
                              width: 30, height: 30, imagePath: "ic_user.png")
                          : Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  border: Border.all(color: white, width: 1),
                                  shape: BoxShape.circle),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                    fit: BoxFit.cover,
                                    width: 30,
                                    height: 30,
                                    imagePath: Constant.userImage ?? ""),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
