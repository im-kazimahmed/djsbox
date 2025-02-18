import 'package:yourappname/model/getpagesmodel.dart';
import 'package:yourappname/model/profilemodel.dart';
import 'package:yourappname/model/sociallinkmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class SettingProvider extends ChangeNotifier {
  SuccessModel updateprofileModel = SuccessModel();
  ProfileModel profileModel = ProfileModel();
  GetpagesModel getpagesModel = GetpagesModel();
  SocialLinkModel socialLinkModel = SocialLinkModel();
  SuccessModel successModel = SuccessModel();
  bool loading = false;
  String isUserpanelType = "on";
  bool isActive = true;
  int isActiveType = 1;
  bool isPasswordVisible = false;

  getActiveUserPanel(password, userpanelStatus) async {
    loading = true;
    updateprofileModel =
        await ApiService().activeUserPanel(password, userpanelStatus);
    loading = false;
    notifyListeners();
  }

  getPages() async {
    loading = true;
    getpagesModel = await ApiService().getPages();
    loading = false;
    notifyListeners();
  }

  getSocialLink() async {
    loading = true;
    socialLinkModel = await ApiService().getSocialLink();
    loading = false;
    notifyListeners();
  }

  getLogout() async {
    loading = true;
    successModel = await ApiService().logout();
    loading = false;
    notifyListeners();
  }

  selectUserPanel(String userpanelType, bool active) {
    isUserpanelType = userpanelType;
    isActive = active;
    if (userpanelType == "on") {
      isActiveType = 1;
    } else {
      isActiveType = 0;
    }
    notifyListeners();
  }

  passwordHideShow() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  clearUserPanel() {
    updateprofileModel = SuccessModel();
    isUserpanelType = "on";
    isActive = true;
    isActiveType = 1;
  }

  clearProvider() {
    updateprofileModel = SuccessModel();
    profileModel = ProfileModel();
    getpagesModel = GetpagesModel();
    loading = false;
  }
}
