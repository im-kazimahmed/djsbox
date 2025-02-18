// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:yourappname/pages/otp.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late GeneralProvider generalProvider;
  SharedPre sharedPre = SharedPre();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final numberController = TextEditingController();
  String mobilenumber = "", countrycode = "", countryname = "";
  File? mProfileImg;
  bool isagreeCondition = false;
  String? strDeviceType, strDeviceToken;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _getDeviceToken();
  }

  _getDeviceToken() async {
    try {
      if (Platform.isAndroid) {
        strDeviceType = "1";
        strDeviceToken = await FirebaseMessaging.instance.getToken();
      } else {
        strDeviceType = "2";
        strDeviceToken = OneSignal.User.pushSubscription.id.toString();
      }
    } catch (e) {
      printLog("_getDeviceToken Exception ===> $e");
    }
    printLog("===>strDeviceToken $strDeviceToken");
    printLog("===>strDeviceType $strDeviceType");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: colorPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.35,
                      alignment: Alignment.bottomCenter,
                      child: MyImage(
                          width: MediaQuery.of(context).size.width * 0.60,
                          height: MediaQuery.of(context).size.height * 0.25,
                          imagePath: "appicon.png"),
                    ),
                    MyText(
                        color: white,
                        text: "hello",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textlargeBig,
                        multilanguage: true,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w800,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 5),
                    MyText(
                        color: white,
                        text: "loginyouraccount",
                        textalign: TextAlign.center,
                        fontsizeNormal: Dimens.textMedium,
                        multilanguage: true,
                        inter: false,
                        maxline: 1,
                        fontwaight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal),
                    const SizedBox(height: 20),
                    /* Send OTP Continue Button Text  */
                    IntlPhoneField(
                      disableLengthCheck: true,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: white,
                      autovalidateMode: AutovalidateMode.disabled,
                      controller: numberController,
                      style: Utils.googleFontStyle(4, Dimens.textTitle,
                          FontStyle.normal, white, FontWeight.w500),
                      showCountryFlag: true,
                      showDropdownIcon: false,
                      initialCountryCode: "UG",
                      dropdownTextStyle: Utils.googleFontStyle(
                          4,
                          Dimens.textTitle,
                          FontStyle.normal,
                          white,
                          FontWeight.w500),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: Utils.googleFontStyle(4, Dimens.textMedium,
                            FontStyle.normal, white, FontWeight.w500),
                        hintText: "Mobile Number",
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(color: white, width: 1),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(color: white, width: 1),
                        ),
                      ),
                      onChanged: (phone) {
                        mobilenumber = phone.completeNumber;
                        countryname = phone.countryISOCode;
                        countrycode = phone.countryCode;
                        log("numberController==> ${numberController.text}");
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
                    const SizedBox(height: 20),
                    /* Send OTP Continue Button Text  */
                    Consumer<GeneralProvider>(
                        builder: (context, generalprovider, child) {
                      if (generalprovider.isProgressLoading) {
                        return const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            color: colorAccent,
                          ),
                        );
                      } else {
                        return InkWell(
                          onTap: () {
                            if (numberController.text.toString().isEmpty) {
                              Utils.showSnackbar(
                                  context, "pleaseenteryourmobilenumber", true);
                            } else if (isagreeCondition != true) {
                              Utils.showSnackbar(context,
                                  "pleaseaccepttermsandcondition", true);
                            } else {
                              debugPrint("mobilenumber==> $mobilenumber");
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Otp(
                                    fullnumber: mobilenumber,
                                    countrycode: countrycode,
                                    countryName: countryname,
                                    number: numberController.text,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(15),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colorAccent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: MyText(
                                color: white,
                                text: "continue",
                                textalign: TextAlign.center,
                                fontsizeNormal: Dimens.textMedium,
                                inter: false,
                                maxline: 1,
                                multilanguage: true,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        );
                      }
                    }),
                    const SizedBox(height: 10),
                    /* Accept Terms & Consition */
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: white,
                          ),
                          child: Checkbox(
                            value: isagreeCondition,
                            activeColor: colorAccent,
                            checkColor: white,
                            onChanged: (bool? isagreeCondition) {
                              setState(() {
                                this.isagreeCondition = isagreeCondition!;
                              });
                              log("value== $isagreeCondition");
                            },
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                MyText(
                                    color: white,
                                    text: "termconditionfirst",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: 12,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                MyText(
                                    color: colorAccent,
                                    text: "terms",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: 12,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                MyText(
                                    color: colorAccent,
                                    text: "condition",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: 12,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 2,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                            MyText(
                                color: colorAccent,
                                text: "privacy_policy",
                                textalign: TextAlign.left,
                                fontsizeNormal: 12,
                                multilanguage: true,
                                inter: false,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    /* OR Text  */
                    Align(
                      alignment: Alignment.center,
                      child: MyText(
                          color: white,
                          text: "or",
                          textalign: TextAlign.center,
                          fontsizeNormal: 16,
                          inter: false,
                          multilanguage: true,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /* Google Signin Button */
                        InkWell(
                          onTap: () {
                            if (isagreeCondition == true) {
                              gmailLogin();
                              log("Gmail login ======>>>>>");
                            } else {
                              Utils.showSnackbar(context,
                                  "pleaseaccepttermsandcondition", true);
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              shape: BoxShape.rectangle,
                              color: white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyImage(
                                    width: 27,
                                    height: 27,
                                    imagePath: "ic_google.png"),
                                const SizedBox(width: 15),
                                MyText(
                                    color: black,
                                    text: "loginwithgoogle",
                                    textalign: TextAlign.left,
                                    fontsizeNormal: Dimens.textMedium,
                                    maxline: 1,
                                    multilanguage: true,
                                    fontwaight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        /* Apple Signin Button */
                        Platform.isIOS
                            ? InkWell(
                                onTap: () {
                                  if (isagreeCondition == true) {
                                    signInWithApple();
                                  } else {
                                    Utils.showSnackbar(context,
                                        "pleaseaccepttermsandcondition", true);
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    shape: BoxShape.rectangle,
                                    color: white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyImage(
                                          width: 27,
                                          height: 27,
                                          color: black,
                                          imagePath: "ic_apple.png"),
                                      const SizedBox(width: 15),
                                      MyText(
                                          color: black,
                                          text: "loginwithapple",
                                          textalign: TextAlign.left,
                                          fontsizeNormal: Dimens.textMedium,
                                          maxline: 1,
                                          multilanguage: true,
                                          fontwaight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                highlightColor: transparent,
                hoverColor: transparent,
                splashColor: transparent,
                focusColor: transparent,
                onTap: () {
                  Navigator.pop(context, false);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: MyImage(
                        width: 30, height: 30, imagePath: "ic_roundback.png"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Login With Google
  Future<void> gmailLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    GoogleSignInAccount user = googleUser;

    printLog('GoogleSignIn ===> id : ${user.id}');
    printLog('GoogleSignIn ===> email : ${user.email}');
    printLog('GoogleSignIn ===> displayName : ${user.displayName}');
    printLog('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

    generalProvider.setLoading(true);

    UserCredential userCredential;
    try {
      GoogleSignInAuthentication googleSignInAuthentication =
          await user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      userCredential = await auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      printLog("User Name: ${userCredential.user?.displayName}");
      printLog("User Email ${userCredential.user?.email}");
      printLog("User photoUrl ${userCredential.user?.photoURL}");
      printLog("uid ===> ${userCredential.user?.uid}");
      String firebasedid = userCredential.user?.uid ?? "";
      printLog('firebasedid :===> $firebasedid');
      // Call Login Api
      if (!mounted) return;
      generalProvider.setLoading(true);
      checkAndNavigate(user.email, user.displayName ?? "", "", "", "2", "", "");
    } on FirebaseAuthException catch (e) {
      printLog('===>Exp${e.code.toString()}');
      printLog('===>Exp${e.message.toString()}');
      generalProvider.setLoading(false);
    }
  }

  // Signin With Apple
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithApple() async {
    printLog("Click Apple");
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      printLog(appleCredential.authorizationCode);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult = await auth.signInWithCredential(oauthCredential);

      final displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';

      final firebaseUser = authResult.user;
      printLog("=================");

      final userEmail = '${firebaseUser?.email}';
      printLog("userEmail =====> $userEmail");
      printLog("${firebaseUser?.email.toString()}");
      printLog("${firebaseUser?.displayName.toString()}");
      printLog("${firebaseUser?.photoURL.toString()}");
      printLog("${firebaseUser?.uid}");
      printLog("=================");

      final firebasedId = firebaseUser?.uid;
      printLog("firebasedId ===> $firebasedId");

      checkAndNavigate(userEmail, displayName.toString(), "", "", "3", "", "");
    } catch (exception) {
      printLog("Apple Login exception =====> $exception");
    }
    return null;
  }

  checkAndNavigate(
      String email,
      String userName,
      String profileImg,
      String password,
      String type,
      String countrycode,
      String countryName) async {
    final loginItem = Provider.of<GeneralProvider>(context, listen: false);
    generalProvider.setLoading(true);
    File? userProfileImg = await Utils.saveImageInStorage(profileImg);
    printLog("userProfileImg ===========> $userProfileImg");

    await loginItem.login(type, email, "", strDeviceType ?? "",
        strDeviceToken ?? "", countrycode, countryName);

    printLog('checkAndNavigate loading ==>> ${loginItem.loading}');

    if (!loginItem.loading) {
      if (loginItem.loginModel.status == 200 &&
          loginItem.loginModel.result!.isNotEmpty) {
        Utils.saveUserCreds(
            userID: loginItem.loginModel.result?[0].id.toString(),
            channeId: loginItem.loginModel.result?[0].channelId.toString(),
            channelName: loginItem.loginModel.result?[0].channelName.toString(),
            fullName: loginItem.loginModel.result?[0].fullName.toString(),
            email: loginItem.loginModel.result?[0].email.toString(),
            mobileNumber:
                loginItem.loginModel.result?[0].mobileNumber.toString(),
            image: loginItem.loginModel.result?[0].image.toString(),
            coverImg: loginItem.loginModel.result?[0].coverImg.toString(),
            deviceType: loginItem.loginModel.result?[0].deviceType.toString(),
            deviceToken: loginItem.loginModel.result?[0].deviceToken.toString(),
            userIsBuy: loginItem.loginModel.result?[0].isBuy.toString(),
            isAdsFree: loginItem.loginModel.result?[0].adsFree.toString(),
            isDownload: loginItem.loginModel.result?[0].isDownload.toString());

        generalProvider.setLoading(false);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Bottombar()),
            (Route route) => false);
      } else {
        if (!mounted) return;
        generalProvider.setLoading(false);
      }
    }
  }
}
