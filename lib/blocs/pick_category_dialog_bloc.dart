import 'dart:async';

import 'package:app/blocs/app_config_bloc.dart';
import 'package:app/core/categories_dao.dart';
import 'package:app/models/category_model.dart';
import 'package:rxdart/rxdart.dart';

class PickCategoryDialogBloc extends AppConfigBloc {
  // categories list
  final _listCategoriesController = BehaviorSubject<List<CategoryModel>>();

  Stream<List<CategoryModel>> get listCategoriesStream =>
      _listCategoriesController.stream;

  StreamSink<List<CategoryModel>> get _listCategoriesSink =>
      _listCategoriesController.sink;

  PickCategoryDialogBloc() {
    refreshStreams();
  }

  Future<void> refreshStreams() async {
    super.refreshStreams();
    getCategoriesFromLocalDb();
  }

  Future<void> getCategoriesFromLocalDb() async {
    List<CategoryModel> values =
        await CategoriesDao.dao.getCategoriesFromLocalDb();
    _listCategoriesSink.add(values);
  }

  @override
  void dispose() {
    super.dispose();
    _listCategoriesController.close();
  }
}
