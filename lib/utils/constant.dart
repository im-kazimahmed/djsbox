class Constant {
  final String baseurl = "https://djsbox.fun/public/api/";
//https://dttube.divinetechs.com/public/api/
  static String appName = "DJSBOX.fun";

  static String appPackageName = "com.techsolutions.djsboxfun";

  static String appleAppId = " ";

  /* OneSignal App ID keyId*/
  static String? oneSignalAppId;

  static const String oneSignalAppIdKey = "onesignal_apid";
  static const String vapIdKey = "vap_id_key";

  static bool isTV = false;

  static String userPanelUrl =
      "https://dttube.divinetechs.in/public/user/login";

  /* Share */
  static String androidAppShareUrlDesc =
      "Let me recommend you this application\n\n$androidAppUrl";

  static String iosAppShareUrlDesc =
      "Let me recommend you this application\n\n$iosAppUrl";

  static String androidAppUrl =
      "https://play.google.com/store/apps/details?id=$appPackageName";

  static String iosAppUrl = "https://apps.apple.com/us/app/id$appleAppId";

// Intro Screen Image
  List introImage = [
    "ic_intro1.png",
    "ic_intro2.png",
    "ic_intro3.png",
  ];

// Intro Screen Text
  List introText = [
    "Watch interesting videos from around the world",
    "Watch interesting videos easily from your smartphone",
    "Let's explore videos around the worldwith MyTube Now!",
  ];

// TabList Music Page
  static List tabList = [
    "home",
    "music",
    "radio",
    "podcast",
  ];

  static List tabIconList = [
    "ic_homeTab.png",
    "ic_musicTab.png",
    "ic_radioTab.png",
    "ic_podcastTab.png",
  ];

  static String musicType = "1";
  static String podcastType = "2";
  static String radioType = "3";

// Profile Tab List
  static List profileTabList = [
    "video",
    "podcast",
    "playlist",
    "short",
    "rent"
  ];

// SubscriberList Tab List
  static List subscriberTabList = [
    "video",
    "podcast",
    "playlist",
    "short",
  ];

  // History Tab List
  static List historyTabList = [
    "video",
    "music",
    "podcast",
  ];

  static List historyTabIconList = [
    "ic_homeTab.png",
    "ic_musicTab.png",
    "ic_podcastTab.png",
  ];

  // Profile Tab List
  static List selectContentTabList = [
    "video",
    "music",
    "podcast",
    "radio",
  ];

  static List watchlaterTabList = [
    "video",
    "Music",
    "Short",
    "Podcast",
    "Radio",
  ];

  static List watchlaterTabIconList = [
    "ic_homeTab.png",
    "ic_musicTab.png",
    "ic_shorts.png",
    "ic_radioTab.png",
    "ic_podcastTab.png",
  ];

  static List transectionHistoryList = [
    "Usage history",
    "Purchase history",
    "Withdrawal history",
  ];

  static String? selectedAudioPath = "";
  static int recordDuration = 30;
  static int maxRecordDuration = 30;
  static int minRecordDuration = 5;

  static int fixFourDigit = 1317;
  static int fixSixDigit = 161613;

  static String? userID;
  static String? channelID;
  static String? userPanelStatus;
  static String? channelName;
  static String? channelImage;
  static String? isDownload;
  static String? isAdsfree;
  static String? isBuy;
  static String? userImage;
  static String currencySymbol = "";
  static String currency = "";
  static String? webToken;
  static String? vapId;

  static String fullname = "FullName";
  static String channelname = "Channel Name";
  static String email = "Email";
  static String password = "Password";

// HomePage
  static String search = "Search";

// update Profile
  static String bio = "Bio";
  static String mobile = "Mobile";

  /* Show Ad By Type */
  static String bannerAdType = "bannerAd";
  static String rewardAdType = "rewardAd";
  static String interstialAdType = "interstialAd";

  /* Search ContentType */
  static String videoSearch = "1";
  static String musicSearch = "2";

  /*  ============================================== Custom Ads Helper Fields Start ============================================== */
  static String totalBalance = "";
  // static bool? isPremiumBuy;
  static String? diviceToken;
  static String? diviceType;
  /* Banner */
  static String? banneradStatus;
  static String? banneradCPV;
  static String? banneradCPC;
  /* Interstital */
  static String? interstitaladStatus;
  static String? interstitaladCPV;
  static String? interstitaladCPC;
  /* Reward */
  static String? rewardadStatus;
  static String? rewardadCPV;
  static String? rewardadCPC;
  /*  ============================================== Custom Ads Helper Fields End ============================================== */
}
