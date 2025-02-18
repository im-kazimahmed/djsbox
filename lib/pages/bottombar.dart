import 'package:yourappname/pages/login.dart';
import 'package:yourappname/pages/videorecord/videorecord.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/adhelper.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customads.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourappname/pages/home.dart';
import 'package:yourappname/pages/setting.dart';
import 'package:yourappname/pages/shorts.dart';
import 'package:yourappname/pages/music.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

ValueNotifier<AudioPlayer?> currentlyPlaying = ValueNotifier(null);
double playerMinHeight = (!kIsWeb) ? 70 : 90;
const miniplayerPercentageDeclaration = 0.7;

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => BottombarState();
}

class BottombarState extends State<Bottombar> {
  int selectedIndex = 0;
  SharedPre sharedPre = SharedPre();
  late GeneralProvider generalsetting;
  late ProfileProvider profileProvider;

  @override
  void initState() {
    generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    super.initState();
    AdHelper().initGoogleMobileAds();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  getData() async {
    pushNotification();
    if (Constant.userID != null) {
      await profileProvider.getprofile(context, Constant.userID);
      if (profileProvider.profileModel.status == 200 &&
          profileProvider.profileModel.result != null) {
        await sharedPre.save(
            "userpanelstatus",
            profileProvider.profileModel.result?[0].userPenalStatus
                    .toString() ??
                "");
        Constant.userPanelStatus = await sharedPre.read("userpanelstatus");
        Constant.isAdsfree =
            profileProvider.profileModel.result?[0].adsFree.toString() ?? "";
        Constant.isDownload =
            profileProvider.profileModel.result?[0].isDownload.toString() ?? "";
        Constant.userImage =
            profileProvider.profileModel.result?[0].image.toString() ?? "";
      }
    } else {
      Utils.loadAds(context);
    }
    await generalsetting.getGeneralsetting();
    setState(() {});
  }

  pushNotification() async {
    Constant.oneSignalAppId = await sharedPre.read(Constant.oneSignalAppIdKey);
    printLog("OneSignal===>${Constant.oneSignalAppId}");
    /*  Push Notification Method OneSignal Start */
    if (!kIsWeb) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      // Initialize OneSignal
      printLog("OneSignal PushNotification===> ${Constant.oneSignalAppId}");
      OneSignal.initialize(Constant.oneSignalAppId ?? "");
      OneSignal.Notifications.requestPermission(false);
      OneSignal.Notifications.addPermissionObserver((state) {
        printLog("Has permission ==> $state");
      });
      OneSignal.User.pushSubscription.addObserver((state) {
        printLog(
            "pushSubscription state ==> ${state.current.jsonRepresentation()}");
      });
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        /// preventDefault to not display the notification
        event.preventDefault();
        // Do async work
        /// notification.display() to display after preventing default
        event.notification.display();
      });
    }
/*  Push Notification Method OneSignal End */
  }

  static List<Widget> widgetOptions = <Widget>[
    const Home(),
    const Shorts(),
    const VideoRecord(
      contestId: '',
      contestImg: '',
      hashtagId: '',
      hashtagName: '',
    ),
    const Music(),
    const Setting(),
  ];

  void _onItemTapped(int index) {
    AdHelper.showFullscreenAd(context, Constant.interstialAdType, () async {
      switch (index) {
        case 0:
          setState(() {
            selectedIndex = index;
          });
          break;

        case 1:
          setState(() {
            selectedIndex = index;
          });
          break;

        case 2:
          if (Constant.userID != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const VideoRecord(
                    contestId: '',
                    contestImg: '',
                    hashtagId: '',
                    hashtagName: '',
                  );
                },
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const Login();
                },
              ),
            );
          }
          break;

        case 3:
          setState(() {
            selectedIndex = index;
          });
          break;

        case 4:
          setState(() {
            selectedIndex = index;
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimaryDark,
      body: Stack(
        children: [
          Center(
            child: widgetOptions.elementAt(selectedIndex),
          ),
          selectedIndex == 1 || selectedIndex == 2
              ? const SizedBox.shrink()
              : Utils.buildMusicPanel(context),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          selectedIndex == 1 || selectedIndex == 2
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    CustomAds(adType: Constant.bannerAdType),
                    Utils.showBannerAd(context),
                  ],
                ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: BottomNavigationBar(
              backgroundColor: colorPrimaryDark,
              selectedFontSize: Dimens.textbottomNav,
              unselectedFontSize: Dimens.textbottomNav,
              selectedIconTheme: const IconThemeData(color: colorAccent),
              unselectedIconTheme: const IconThemeData(color: white),
              elevation: 5,
              unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: Dimens.textbottomNav,
                  color: gray,
                  fontWeight: FontWeight.w400),
              selectedLabelStyle: GoogleFonts.inter(
                  fontSize: Dimens.textbottomNav,
                  color: gray,
                  fontWeight: FontWeight.w500),
              currentIndex: selectedIndex,
              unselectedItemColor: white,
              selectedItemColor: colorAccent,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  backgroundColor: colorPrimary,
                  label: Locales.string(context, "home"),
                  activeIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: MyImage(
                      imagePath: "ic_homeTab.png",
                      width: Dimens.iconbottomNav,
                      height: Dimens.iconbottomNav,
                      color: colorAccent,
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: MyImage(
                      imagePath: "ic_homeTab.png",
                      width: Dimens.iconbottomNav,
                      height: Dimens.iconbottomNav,
                      color: white,
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  label: Locales.string(context, "shorts"),
                  backgroundColor: colorPrimary,
                  activeIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: MyImage(
                      imagePath: "ic_shorts.png",
                      width: Dimens.iconbottomNav,
                      height: Dimens.iconbottomNav,
                      color: colorAccent,
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: MyImage(
                      imagePath: "ic_shorts.png",
                      width: Dimens.iconbottomNav,
                      height: Dimens.iconbottomNav,
                      color: white,
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  label: "",
                  backgroundColor: colorPrimary,
                  activeIcon: Container(
                    padding: const EdgeInsets.all(0),
                    child: MyImage(
                      imagePath: "ic_post.png",
                      width: Dimens.centerIconbottomNav,
                      height: Dimens.centerIconbottomNav,
                    ),
                  ),
                  icon: Container(
                    padding: const EdgeInsets.all(0),
                    child: MyImage(
                      width: Dimens.centerIconbottomNav,
                      height: Dimens.centerIconbottomNav,
                      imagePath: "ic_post.png",
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  backgroundColor: colorPrimary,
                  label: Locales.string(context, "music"),
                  activeIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: MyImage(
                      imagePath: "ic_musicTab.png",
                      width: Dimens.iconbottomNav,
                      height: Dimens.iconbottomNav,
                      color: colorAccent,
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: MyImage(
                      width: Dimens.iconbottomNav,
                      height: Dimens.iconbottomNav,
                      color: white,
                      imagePath: "ic_musicTab.png",
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  backgroundColor: colorPrimary,
                  label: Locales.string(context, "setting"),
                  activeIcon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: MyImage(
                      imagePath: "ic_setting.png",
                      width: Dimens.iconbottomNav,
                      height: Dimens.iconbottomNav,
                      color: colorAccent,
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: MyImage(
                      width: Dimens.iconbottomNav,
                      height: Dimens.iconbottomNav,
                      color: white,
                      imagePath: "ic_setting.png",
                    ),
                  ),
                ),
              ],
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
