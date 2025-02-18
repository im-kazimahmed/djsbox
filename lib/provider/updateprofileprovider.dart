import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yourappname/model/profilemodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/webservice/apiservice.dart';

class UpdateprofileProvider extends ChangeNotifier {
  SuccessModel updateprofileModel = SuccessModel();
  ProfileModel profileModel = ProfileModel();
  bool loading = false;

  getupdateprofile(
      String userid,
      String fullname,
      String channelName,
      String email,
      String number,
      String countrycode,
      String countryName,
      File image,
      File coverImage) async {
    loading = true;
    updateprofileModel = await ApiService().updateprofile(
      userid,
      fullname,
      channelName,
      email,
      number,
      countrycode,
      countryName,
      image,
      coverImage,
    );
    loading = false;
    notifyListeners();
  }
}
