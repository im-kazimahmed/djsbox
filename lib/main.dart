import 'dart:ui';
import 'package:yourappname/model/download_item.dart';
import 'package:yourappname/provider/allcontentprovider.dart';
import 'package:yourappname/provider/contentdetailprovider.dart';
import 'package:yourappname/provider/downloadprovider.dart';
import 'package:yourappname/provider/subscribedchannelprovider.dart';
import 'package:yourappname/provider/withdrawalrequestprovider.dart';
import 'package:yourappname/provider/galleryvideoprovider.dart';
import 'package:yourappname/provider/getmusicbycategoryprovider.dart';
import 'package:yourappname/provider/getmusicbylanguageprovider.dart';
import 'package:yourappname/provider/historyprovider.dart';
import 'package:yourappname/provider/likevideosprovider.dart';
import 'package:yourappname/provider/musicdetailprovider.dart';
import 'package:yourappname/provider/notificationprovider.dart';
import 'package:yourappname/provider/playerprovider.dart';
import 'package:yourappname/provider/playlistcontentprovider.dart';
import 'package:yourappname/provider/playlistprovider.dart';
import 'package:yourappname/provider/postvideoprovider.dart';
import 'package:yourappname/provider/rentprovider.dart';
import 'package:yourappname/provider/seeallprovider.dart';
import 'package:yourappname/provider/settingprovider.dart';
import 'package:yourappname/provider/subscriptionprovider.dart';
import 'package:yourappname/provider/videopreviewprovider.dart';
import 'package:yourappname/provider/videorecordprovider.dart';
import 'package:yourappname/provider/videoscreenprovider.dart';
import 'package:yourappname/provider/walletprovider.dart';
import 'package:yourappname/provider/watchlaterprovider.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webhome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:yourappname/firebase_options.dart';
import 'package:yourappname/pages/splash.dart';
import 'package:yourappname/provider/detailsprovider.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/provider/searchprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/musicprovider.dart';
import 'package:yourappname/provider/updateprofileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'provider/shortprovider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  printLog("Enter Main");
  // Just Audio Player Background Service Set
  /* Initialize Hive Start */
  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(DownloadItemAdapter());
    await Hive.openBox<DownloadItem>('downloads');
  }
  /* Initialize Hive End */

  await JustAudioBackground.init(
    androidNotificationChannelId: Constant.appPackageName,
    androidNotificationChannelName: Constant.appName,
    androidNotificationOngoing: true,
    notificationColor: colorPrimary,
  );

  await Locales.init([
    'en',
    'hi',
    'af',
    'ar',
    'de',
    'es',
    'fr',
    'gu',
    'id',
    'nl',
    'pt',
    'sq',
    'tr',
    'vi'
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GeneralProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DetailsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => UpdateprofileProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => ShortProvider()),
        ChangeNotifierProvider(create: (_) => VideoScreenProvider()),
        ChangeNotifierProvider(create: (_) => MusicDetailProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => WatchLaterProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => LikeVideosProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ContentDetailProvider()),
        ChangeNotifierProvider(create: (_) => SeeAllProvider()),
        ChangeNotifierProvider(create: (_) => GetMusicByCategoryProvider()),
        ChangeNotifierProvider(create: (_) => GetMusicByLanguageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
        ChangeNotifierProvider(create: (_) => RentProvider()),
        ChangeNotifierProvider(create: (_) => AllContentProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistContentProvider()),
        ChangeNotifierProvider(create: (_) => VideoRecordProvider()),
        ChangeNotifierProvider(create: (_) => VideoPreviewProvider()),
        ChangeNotifierProvider(create: (_) => PostVideoProvider()),
        ChangeNotifierProvider(create: (_) => GalleryVideoProvider()),
        ChangeNotifierProvider(create: (_) => WithdrawalRequestProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => SubscribedChannelProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
      ],
      child: const MyApp(),
    ));
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: black,
      statusBarColor: colorPrimary,
    ),
  );
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    getApi();
    super.initState();
  }

  getApi() async {
    final settingProvider =
        Provider.of<SettingProvider>(context, listen: false);
    await settingProvider.getSocialLink();
    await settingProvider.getPages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
        home: (kIsWeb) ? const WebHome() : const Splash(),
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown,
            PointerDeviceKind.trackpad
          },
        ),
      ),
    );
  }
}
