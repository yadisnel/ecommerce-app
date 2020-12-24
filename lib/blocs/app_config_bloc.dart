import 'dart:async';

import 'package:app/blocs/bloc_provider.dart';
import 'package:app/core/config.dart';
import 'package:app/core/configs_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

abstract class AppConfigBloc implements BlocBase {
  final _configController = BehaviorSubject<Map<String, String>>();

  Stream<Map<String, String>> get appConfigStream => _configController.stream;

  StreamSink<Map<String, String>> get _appConfigSink => _configController.sink;

  AppConfigBloc() {
    refreshStreams();
  }

  Future<void> refreshStreams() async {
    var values = await ConfigsDao.dao.getConfigValues();
    _appConfigSink.add(values);
  }

  Future<void> changeRootSelectedItem(String selectedItem) async {
    ConfigsDao.dao
        .updateConfigValue(DB_ROOT_PAGE_ITEM_SELECTED_CONFIG, selectedItem);
    await refreshStreams();
  }

  Future<void> changeLoginPageSelectedItem(String selectedItem) async {
    ConfigsDao.dao
        .updateConfigValue(DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG, selectedItem);
    await refreshStreams();
  }

  Future<void> changeAppFirstConfigStatusToInFistConfig() async {
    ConfigsDao.dao
        .updateConfigValue(DB_APP_IN_FIRST_CONFIG, DB_APP_IN_FIRST_CONFIG_TRUE);
    await refreshStreams();
  }

  Future<void> changeAppFirstConfigStatusToDoneFistConfig() async {
    ConfigsDao.dao
        .updateConfigValue(DB_APP_IN_FIRST_CONFIG, DB_APP_IN_FIRST_CONFIG_FALSE);
    await refreshStreams();
  }

  Future<void> changeLocale(
      {@required String languageCode, @required String countryCode}) async {
    ConfigsDao.dao.updateConfigValue(DB_LANGUAGE_CODE_CONFIG, languageCode);
    ConfigsDao.dao.updateConfigValue(DB_COUNTRY_CODE_CONFIG, countryCode);
    await refreshStreams();
  }

  Future<void> updateToken(String token) async {
    ConfigsDao.dao.updateConfigValue(DB_TOKEN_CONFIG, token);
    await refreshStreams();
  }

  Future<void> updateUserInfo(String userInfo) async {
    ConfigsDao.dao.updateConfigValue(DB_USER_INFO_CONFIG, userInfo);
    await refreshStreams();
  }

  Future<void> logout() async {
    ConfigsDao.dao.updateConfigValue(DB_TOKEN_CONFIG, "");
    await refreshStreams();
  }

  // All stream controllers you create should be closed within this function
  @override
  void dispose() {
    _configController.close();
  }
}
