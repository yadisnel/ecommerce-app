import 'dart:async';

import 'package:app/blocs/app_config_bloc.dart';
import 'package:app/core/own_products_dao.dart';
import 'package:app/models/product_model.dart';
import 'package:rxdart/rxdart.dart';

class SellPageBloc extends AppConfigBloc {
  // own product list
  final _listOwnProductsController = BehaviorSubject<List<ProductModel>>();
  Stream<List<ProductModel>> get listOwnProductsStream => _listOwnProductsController.stream;
  StreamSink<List<ProductModel>> get _listOwnProductsSink => _listOwnProductsController.sink;
  // exists own products in db
  final _existsOwnProductsController = BehaviorSubject<bool>();
  Stream<bool> get existsOwnProductsStream => _existsOwnProductsController.stream;
  StreamSink<bool> get _existsOwnProductsSink => _existsOwnProductsController.sink;
  
  final int _limit = 20;
  int _offset = -1;
  List<ProductModel> _ownProducts = [];

  SellPageBloc() {
    refreshStreams();
  }

  Future<void> refreshStreams() async {
    super.refreshStreams();
    getNextProductsFromLocalDb();
    existsOwnProductsInDb();
  }


  Future<void> getNextProductsFromLocalDb() async {
    List<ProductModel> values = await OwnProductsDao.dao
        .getOwnProductsFromDatabase(_limit, _offset + 1);
    if (values.length > 0) {
      for (var i = 0; i < _ownProducts.length; i++) {
        _ownProducts.add(values[i]);
      }
      _offset = _offset + 1;
      _listOwnProductsSink.add(values);
    } else {
      _listOwnProductsSink.add([]);
    }
  }

  Future<void> deleteOwnProductsFromLocalDb() async {
    await OwnProductsDao.dao.deleteOwnProductsFromLocalDatabase();
    _listOwnProductsSink.add([]);
    _offset = -1;
  }

  Future<void> addOwnProductToLocalDb(ProductModel productModel) async {
    await OwnProductsDao.dao.addOwnProduct(productModel);
    _offset = -1;
    getNextProductsFromLocalDb();
  }

  Future<void> existsOwnProductsInDb() async {
    this._existsOwnProductsSink.add(await OwnProductsDao.dao.existsOwnProductsInDb());
  }

  @override
  void dispose() {
    super.dispose();
    _listOwnProductsController.close();
    _existsOwnProductsController.close();
  }
}
