// ignore_for_file: deprecated_member_use
import 'dart:developer';
import 'dart:io';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:yourappname/provider/updateprofileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  final String channelid;
  const UpdateProfile({super.key, required this.channelid});

  @override
  State<UpdateProfile> createState() => UpdateProfileState();
}

class UpdateProfileState extends State<UpdateProfile> {
  final ImagePicker picker = ImagePicker();
  SharedPre sharedPre = SharedPre();
  late UpdateprofileProvider updateprofileProvider;
  late ProfileProvider profileProvider;
  String userid = "", name = "", countrycode = "", countryname = "";
  String gendarvalue = 'Male';
  XFile? _image;
  XFile? _coverImage;
  bool iseditimg = false;
  bool iseditcoverImg = false;
  final nameController = TextEditingController();
  final channelNameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  String mobilenumber = "";
  @override
  void initState() {
    updateprofileProvider =
        Provider.of<UpdateprofileProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    super.initState();
    getApi();
  }

  getApi() async {
    await profileProvider.getprofile(context, Constant.userID);

    nameController.text =
        profileProvider.profileModel.result?[0].fullName.toString() ?? "";
    emailController.text =
        profileProvider.profileModel.result?[0].email.toString() ?? "";
    numberController.text =
        profileProvider.profileModel.result?[0].mobileNumber.toString() ?? "";
    channelNameController.text =
        profileProvider.profileModel.result?[0].channelName.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimaryDark,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        child: Consumer<UpdateprofileProvider>(
            builder: (context, updateprofileProvider, child) {
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.40,
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorPrimary.withOpacity(0.9),
                          colorPrimary.withOpacity(0.1),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.1, 0.9],
                      ),
                      color: white,
                    ),
                    child: _coverImage == null
                        ? MyNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            imagePath: updateprofileProvider
                                    .profileModel.result?[0].coverImg
                                    .toString() ??
                                "",
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            File(_coverImage?.path ?? ""),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorPrimary.withOpacity(0.6),
                          colorPrimary.withOpacity(1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.5],
                      ),
                      color: colorAccent,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        space(0.07),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      child: MyImage(
                                          width: 25,
                                          height: 25,
                                          imagePath: "ic_roundback.png"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  MyText(
                                      color: white,
                                      text: "editprofile",
                                      multilanguage: true,
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 16,
                                      maxline: 6,
                                      fontwaight: FontWeight.w500,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                try {
                                  var coverImage = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 100);
                                  setState(() {
                                    _coverImage = coverImage;
                                    iseditcoverImg = true;
                                  });
                                } catch (e) {
                                  printLog("Error ==>${e.toString()}");
                                }
                              },
                              child: MyImage(
                                  width: 30,
                                  height: 30,
                                  imagePath: "ic_camera.png"),
                            ),
                          ],
                        ),
                        space(0.04),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: white, width: 1),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: _image == null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: MyNetworkImage(
                                          imagePath: updateprofileProvider
                                                  .profileModel.result?[0].image
                                                  .toString() ??
                                              "",
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.file(
                                          height: 151,
                                          width: 151,
                                          File(_image?.path ?? ""),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () async {
                                      try {
                                        var image = await picker.pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 100);
                                        setState(() {
                                          _image = image;
                                          iseditimg = true;
                                        });
                                      } catch (e) {
                                        printLog("Error ==>${e.toString()}");
                                      }
                                    },
                                    child: MyImage(
                                        width: 30,
                                        height: 30,
                                        imagePath: "ic_camera.png"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        space(0.04),
                        myTextField(nameController, TextInputAction.next,
                            TextInputType.text, Constant.fullname, false),
                        space(0.03),
                        myTextField(channelNameController, TextInputAction.next,
                            TextInputType.text, Constant.channelname, false),
                        space(0.03),
                        myTextField(emailController, TextInputAction.next,
                            TextInputType.text, Constant.email, false),
                        space(0.03),
                        myTextField(
                            numberController,
                            Platform.isIOS
                                ? TextInputAction.next
                                : TextInputAction.done,
                            TextInputType.number,
                            Constant.mobile,
                            true),
                        space(0.02),
                        space(0.03),
                        InkWell(
                          onTap: () async {
                            dynamic image;
                            dynamic coverImage;
                            String fullname = nameController.text.toString();
                            String channelName =
                                channelNameController.text.toString();
                            String email = emailController.text.toString();

                            if (iseditimg) {
                              image = File(_image?.path ?? "");
                            } else {
                              image = File("");
                            }

                            if (iseditcoverImg) {
                              coverImage = File(_coverImage?.path ?? "");
                            } else {
                              coverImage = File("");
                            }

                            final updateprofileProvider =
                                Provider.of<UpdateprofileProvider>(context,
                                    listen: false);
                            Utils.showProgress(context);

                            await updateprofileProvider.getupdateprofile(
                                Constant.userID.toString(),
                                fullname,
                                channelName,
                                email,
                                mobilenumber,
                                countrycode,
                                countryname,
                                image,
                                coverImage);

                            if (!updateprofileProvider.loading) {
                              if (updateprofileProvider
                                      .updateprofileModel.status ==
                                  200) {
                                if (!context.mounted) return;
                                Utils.showSnackbar(
                                    context,
                                    "${updateprofileProvider.updateprofileModel.message}",
                                    false);

                                Utils().hideProgress(context);
                                getApi();
                              } else {
                                if (!context.mounted) return;
                                Utils.showSnackbar(
                                    context,
                                    "${updateprofileProvider.updateprofileModel.message}",
                                    false);

                                Utils().hideProgress(context);
                              }
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7)),
                              gradient: LinearGradient(
                                colors: [
                                  colorAccent.withOpacity(0.6),
                                  white.withOpacity(0.50),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: MyText(
                                color: white,
                                text: "submit",
                                multilanguage: true,
                                textalign: TextAlign.center,
                                fontsizeNormal: 16,
                                maxline: 6,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget gender() {
    return Theme(
      data: Theme.of(context).copyWith(
          unselectedWidgetColor: gray,
          disabledColor: white,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: colorAccent)),
      child: Row(
        children: [
          Radio<String>(
              activeColor: colorAccent,
              value: "Male",
              groupValue: gendarvalue,
              onChanged: (value) {
                setState(() {
                  gendarvalue = value!;
                });
                log("gender==$gendarvalue");
              }),
          MyText(
              color: gendarvalue == "Male" ? colorAccent : white,
              text: "Male",
              fontsizeNormal: 14,
              fontwaight: FontWeight.w500,
              maxline: 3,
              textalign: TextAlign.left,
              fontstyle: FontStyle.normal),
          Radio<String>(
              activeColor: colorAccent,
              value: "Female",
              groupValue: gendarvalue,
              onChanged: (value) {
                setState(() {
                  gendarvalue = value!;
                });
                log("gender==$gendarvalue");
              }),
          MyText(
              color: gendarvalue == "Female" ? colorAccent : white,
              text: "Female",
              fontsizeNormal: 14,
              fontwaight: FontWeight.w500,
              maxline: 3,
              textalign: TextAlign.left,
              fontstyle: FontStyle.normal),
          Radio<String>(
              activeColor: colorAccent,
              value: "Other",
              groupValue: gendarvalue,
              onChanged: (value) {
                setState(() {
                  gendarvalue = value!;
                });
                log("gender==$gendarvalue");
              }),
          MyText(
              color: gendarvalue == "Other" ? colorAccent : white,
              text: "Other",
              fontsizeNormal: 14,
              fontwaight: FontWeight.w500,
              maxline: 3,
              textalign: TextAlign.left,
              fontstyle: FontStyle.normal),
        ],
      ),
    );
  }

  Widget myTextField(
      controller, textInputAction, keyboardType, labletext, isMobile) {
    log("code==> ${updateprofileProvider.profileModel.result?[0].countryName.toString() ?? ""}");
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
                    fontSize: 14,
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
              style: Utils.googleFontStyle(
                  4, 16, FontStyle.normal, white, FontWeight.w500),
              showCountryFlag: true,
              showDropdownIcon: false,
              initialCountryCode: updateprofileProvider
                              .profileModel.result?[0].countryName ==
                          "" ||
                      updateprofileProvider
                              .profileModel.result?[0].countryName ==
                          null
                  ? "IN"
                  : updateprofileProvider.profileModel.result?[0].countryName
                          .toString() ??
                      "IN",
              dropdownTextStyle: Utils.googleFontStyle(
                  4, 16, FontStyle.normal, white, FontWeight.w500),
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              decoration: InputDecoration(
                labelText: labletext,
                fillColor: transparent,
                border: InputBorder.none,
                labelStyle: Utils.googleFontStyle(
                    4, 14, FontStyle.normal, white, FontWeight.w500),
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
}
