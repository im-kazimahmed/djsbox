import 'dart:developer';
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/utils/adhelper.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/pages/intro.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  SharedPre sharedpre = SharedPre();

  @override
  void initState() {
    final splashdata = Provider.of<GeneralProvider>(context, listen: false);
    splashdata.getGeneralsetting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ischeckFirstTime();
    return Scaffold(
      backgroundColor: colorPrimary,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: MyImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
            imagePath: "splash.png"),
      ),
    );
  }

  Future ischeckFirstTime() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final splashdata = Provider.of<GeneralProvider>(context);
    Utils.getCurrencySymbol();

    Constant.userID = await sharedpre.read('userid');
    Constant.isAdsfree = await sharedpre.read('isAdsFree');
    Constant.isDownload = await sharedpre.read('isDownload');
    Constant.channelID = await sharedpre.read('channelid');
    Constant.channelName = await sharedpre.read('channelname');
    Constant.userImage = await sharedpre.read('image');
    Constant.isBuy = await sharedpre.read('userIsBuy');

    printLog("Userid===>${Constant.userID}");
    printLog("Channalid===>${Constant.channelID}");
    printLog("isAdsfree===>${Constant.isAdsfree}");
    printLog("isDownload===>${Constant.isDownload}");
    if (!splashdata.loading) {
      for (var i = 0; i < splashdata.generalsettingModel.result!.length; i++) {
        sharedpre.save(
          splashdata.generalsettingModel.result?[i].key.toString() ?? "",
          splashdata.generalsettingModel.result?[i].value.toString() ?? "",
        );
      }
      String? seen = await sharedpre.read("seen") ?? "";
      log("seen:---$seen");
      /* Get Ads Init */
      if (context.mounted && !kIsWeb) {
        AdHelper.getAds(context);
        Utils.getCustomAdsStatus();

        printLog("isAdsfree.com===>${Constant.isAdsfree}");
      }

      await splashdata.getIntroPages();

      if (seen == "1") {
        printLog("Boolian statement if Condition : $seen");
        await homeProvider.setLoading(true);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Bottombar();
            },
          ),
        );
      } else {
        if (!splashdata.loading) {
          if ((splashdata.introScreenModel.status == 200) &&
              splashdata.introScreenModel.result != null &&
              (splashdata.introScreenModel.result?.length ?? 0) > 0) {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Intro(
                    introList: splashdata.introScreenModel.result ?? [],
                  );
                },
              ),
            );
          } else {
            printLog("Boolian statement if Condition : $seen");
            await homeProvider.setLoading(true);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const Bottombar();
                },
              ),
            );
          }
        }
      }
    }
  }
}
