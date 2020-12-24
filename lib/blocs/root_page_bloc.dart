import 'dart:async';
import 'dart:convert';

import 'package:app/blocs/app_config_bloc.dart';
import 'package:app/core/categories_dao.dart';
import 'package:app/core/config.dart';
import 'package:app/core/configs_dao.dart';
import 'package:app/core/generics.dart';
import 'package:app/core/mqtt_wrapper.dart';
import 'package:app/core/provinces_dao.dart';
import 'package:app/models/app_status_model.dart';
import 'package:app/models/province_model.dart';
import 'package:app/pages/add_product_page.dart';
import 'package:app/widgets/pick_province/pick_province_dialog.dart';
import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import '../main.dart';


class RootPageBloc extends AppConfigBloc {
  // app network status
  final _appStatusController = BehaviorSubject<AppStatusModel>();

  Stream<AppStatusModel> get appStatusStream => _appStatusController.stream;

  StreamSink<AppStatusModel> get appStatusSink => _appStatusController.sink;

  Map<String, String> appConfig;
  CancelableOperation cancellableSyncDatabase;
  MqttWrapper mqttWrapper;

  RootPageBloc() {
    refreshStreams();
  }

  Future<void> refreshStreams() async {
    super.refreshStreams();
  }

  Future<void> setupAsyncServices() async {
    this.appConfig = await ConfigsDao.dao.getConfigValues();
    mqttWrapper = MqttWrapper(
        onConnected, onDisconected, onPayloadReceived, onAutoReconnect);
    var userInfo = jsonDecode(this.appConfig[DB_USER_INFO_CONFIG]);
    mqttWrapper.prepareMqttClient(
        MqttGenerics.instance.subscribeUserTopic(userInfo["id"]),
        MqttGenerics.instance.publishUserTopic(userInfo["id"]),
        this.appConfig[DB_BROKER_HOST_IP_CONFIG],
        int.parse(this.appConfig[DB_BROKER_WS_PORT_CONFIG]),
        this.appConfig[DB_TOKEN_CONFIG],
        this.appConfig[DB_APP_ID_CONFIG]);
  }

  Future<void> onConnected() async {
    var userInfo = jsonDecode(this.appConfig[DB_USER_INFO_CONFIG]);
    mqttWrapper.subscribeToTopic(
        MqttGenerics.instance.subscribeUserTopic(userInfo["id"]));
    mqttWrapper
        .subscribeToTopic(MqttGenerics.instance.subscribeAllUsersTopic());
    this.appStatusSink.add(AppStatusModel.CONNECTED);
    if (cancellableSyncDatabase != null) {
      cancellableSyncDatabase.cancel();
      cancellableSyncDatabase = null;
    }
    cancellableSyncDatabase = CancelableOperation.fromFuture(
      dbSync(),
      onCancel: () => {print('onCancel')},
    );
    cancellableSyncDatabase.value.then((value) => {
      print("then: $value"),
    });
    cancellableSyncDatabase.value.whenComplete(() => {
      print("onDone"),
    });
  }

  Future<void> onDisconected() async {
    this.appStatusSink.add(AppStatusModel.DISCONNECTED);
    if (this.cancellableSyncDatabase != null) {
      this.cancellableSyncDatabase.cancel();
      this.cancellableSyncDatabase = null;
    }
  }

  Future<void> onAutoReconnect() async {
    this.appStatusSink.add(AppStatusModel.DISCONNECTED);
    if (this.cancellableSyncDatabase != null) {
      this.cancellableSyncDatabase.cancel();
      this.cancellableSyncDatabase = null;
    }
  }

  void onPayloadReceived(String payload) async {
    var dataJson = json.decode(utf8.decode(payload.runes.toList()));
    if (dataJson["payload_type"] == null || dataJson["payload"] == null) {
      print("invalid payload in RootPageBloc.onMessageReceived: " +
          dataJson.toString());
      return;
    }
    switch (dataJson["payload_type"]) {
      case PAYLOAD_TYPE_PROVINCE:
        ProvinceModel remoteProvince =
        ProvinceModel.fromServerJson(jsonDecode(dataJson["payload"]));
        await this._processProvinceAsyncPayload(remoteProvince);
        break;
      case PAYLOAD_TYPE_PRODUCT:
        break;
      case PAYLOAD_TYPE_CATEGORY:
        break;
    }
  }

  Future<void> dbSync() async {
    this.appStatusSink.add(AppStatusModel.IN_SYNC);
    var dtodoOffsetsResponse = await http.post(
        "http://${appConfig[DB_API_HOST_IP_CONFIG]}/sync/get-offsets",
        headers: {"Authorization": "bearer " + appConfig[DB_TOKEN_CONFIG]});
    if (dtodoOffsetsResponse.statusCode == 401) {
      await this.updateToken("");
      await this.updateUserInfo("");
      dtodoAppStateKey.currentState.reloadConfig();
    }
    if (dtodoOffsetsResponse.statusCode == 200) {
      var dtodoOffsetsDecoded =
      json.decode(utf8.decode(dtodoOffsetsResponse.bodyBytes));
      bool areProvincesInSync = false;
      bool areCategoriesInSync = false;
      if (dtodoOffsetsDecoded["provinces_offset"] != null) {
        DateTime serverProvincesOffset =
        DateTime.parse(dtodoOffsetsDecoded["provinces_offset"]).toUtc();
        DateTime localProvincesOffset =
        DateTime.parse(this.appConfig[DB_LAST_PROVINCE_OFFSET_CONFIG])
            .toUtc();
        if (serverProvincesOffset != localProvincesOffset) {
          bool isNewDb = false;
          if (localProvincesOffset ==
              DateTime.parse(DB_LAST_PROVINCE_OFFSET_CONFIG_VALUE).toUtc()) {
            isNewDb = true;
          }
          areProvincesInSync =
          await syncProvinces(isNewDb, localProvincesOffset);
        }
      } else {
        areProvincesInSync = true;
      }
      if (dtodoOffsetsDecoded["categories_offset"] != null) {
        DateTime serverCategoriesOffset =
        DateTime.parse(dtodoOffsetsDecoded["categories_offset"]).toUtc();
        DateTime localCategoriesOffset =
        DateTime.parse(this.appConfig[DB_LAST_CATEGORY_OFFSET_CONFIG])
            .toUtc();
        if (serverCategoriesOffset != localCategoriesOffset) {
          bool isNewDb = false;
          if (localCategoriesOffset ==
              DateTime.parse(DB_LAST_CATEGORY_OFFSET_CONFIG_VALUE).toUtc()) {
            isNewDb = true;
          }
          areCategoriesInSync =
          await syncCategories(isNewDb, localCategoriesOffset);
        }
      } else {
        areCategoriesInSync = true;
      }
      if (areProvincesInSync && areCategoriesInSync) {
        await this.changeAppFirstConfigStatusToDoneFistConfig();
      }
    }
    this.appStatusSink.add(AppStatusModel.CONNECTED);
    await this.refreshStreams();
  }

  Future<bool> syncProvinces(bool isNewDb, DateTime lastOffset) async {
    var body = jsonEncode(
        {"is_db_new": isNewDb, "last_offset": lastOffset.toIso8601String()});
    var dtodoSyncResponse = await http.post(
        "http://${appConfig[DB_API_HOST_IP_CONFIG]}/provinces/sync-provinces",
        headers: {
          "Authorization": "bearer " + appConfig[DB_TOKEN_CONFIG],
          "Content-Type": "application/json"
        },
        body: body);
    if (dtodoSyncResponse.statusCode == 401) {
      await this.updateToken("");
      await this.updateUserInfo("");
      dtodoAppStateKey.currentState.reloadConfig();
      return false;
    } else if (dtodoSyncResponse.statusCode == 200) {
      var dtodoOffsetsDecoded =
      json.decode(utf8.decode(dtodoSyncResponse.bodyBytes));
      if (dtodoOffsetsDecoded["provinces"] == null ||
          dtodoOffsetsDecoded["is_last_offset"] == null) {
        return false;
      }
      List provinces = dtodoOffsetsDecoded["provinces"];
      bool isLastOffset = dtodoOffsetsDecoded["is_last_offset"];
      if (provinces.length == 0) {
        return true;
      }
      await ProvincesDao.dao.syncProvinces(provinces);
      if (!isLastOffset) {
        return await syncProvinces(
            isLastOffset,
            DateTime.parse(provinces[provinces.length - 1]["modified"])
                .toUtc());
      }
      return true;
    }
    return false;
  }

  Future<bool> syncCategories(bool isNewDb, DateTime lastOffset) async {
    var body = jsonEncode(
        {"is_db_new": isNewDb, "last_offset": lastOffset.toIso8601String()});
    var dtodoSyncResponse = await http.post(
        "http://${appConfig[DB_API_HOST_IP_CONFIG]}/categories/sync-categories",
        headers: {
          "Authorization": "bearer " + appConfig[DB_TOKEN_CONFIG],
          "Content-Type": "application/json"
        },
        body: body);
    if (dtodoSyncResponse.statusCode == 401) {
      await this.updateToken("");
      await this.updateUserInfo("");
      dtodoAppStateKey.currentState.reloadConfig();
      return false;
    } else if (dtodoSyncResponse.statusCode == 200) {
      var dtodoOffsetsDecoded =
      json.decode(utf8.decode(dtodoSyncResponse.bodyBytes));
      if (dtodoOffsetsDecoded["categories"] == null ||
          dtodoOffsetsDecoded["is_last_offset"] == null) {
        return false;
      }
      List categories = dtodoOffsetsDecoded["categories"];
      bool isLastOffset = dtodoOffsetsDecoded["is_last_offset"];
      if (categories.length == 0) {
        return true;
      }
      await CategoriesDao.dao.syncCategories(categories);
      if (!isLastOffset) {
        return await syncCategories(
            isLastOffset,
            DateTime.parse(categories[categories.length - 1]["modified"])
                .toUtc());
      }
      return true;
    }
    return false;
  }

  Future<void> _processProvinceAsyncPayload(ProvinceModel remoteProvince) async {
    if (!remoteProvince.isValid()) {
      print("invalid province payload in RootPageBloc.onMessageReceived: " +
          remoteProvince.toString());
      return;
    }
    if (await ProvincesDao.dao.isProvinceInDb(remoteProvince.id)) {
      var localProvince =
      await ProvincesDao.dao.getProvinceFromLocalDb(remoteProvince.id);
      if (remoteProvince.json["deleted"]) {
        ProvincesDao.dao.deleteProvince(remoteProvince);
      } else {
        DateTime remoteDate =
        DateTime.parse(remoteProvince.json["modified"]).toUtc();
        DateTime localDate =
        DateTime.parse(localProvince.json["modified"]).toUtc();
        if (remoteDate.isBefore(localDate)) {
          return;
        }
        await ProvincesDao.dao.updateProvince(remoteProvince);
      }
    } else {
      await ProvincesDao.dao.addProvince(remoteProvince);
    }
    if (pickProvinceDialogStateKey != null &&
        pickProvinceDialogStateKey.currentState != null) {
      pickProvinceDialogStateKey.currentState.refreshStreams();
    }
    if (addProductStateKey != null && addProductStateKey.currentState != null) {
      addProductStateKey.currentState.refreshStreams();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _appStatusController.close();
  }
}
