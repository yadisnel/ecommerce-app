import 'dart:async';

import 'package:app/blocs/app_config_bloc.dart';
import 'package:app/core/provinces_dao.dart';
import 'package:app/models/province_model.dart';
import 'package:rxdart/rxdart.dart';

class AddProductPageBloc extends AppConfigBloc {
  // provinces list
  final _listProvincesController = BehaviorSubject<List<ProvinceModel>>();

  Stream<List<ProvinceModel>> get listProvincesStream =>
      _listProvincesController.stream;

  StreamSink<List<ProvinceModel>> get _listProvincesSink =>
      _listProvincesController.sink;

  AddProductPageBloc() {
    refreshStreams();
  }

  Future<void> refreshStreams() async {
    super.refreshStreams();
    getProvincesFromLocalDb();
  }

  Future<void> getProvincesFromLocalDb() async {
    List<ProvinceModel> values =
        await ProvincesDao.dao.getProvincesFromLocalDb();
    _listProvincesSink.add(values);
  }

  @override
  void dispose() {
    super.dispose();
    _listProvincesController.close();
  }
}
