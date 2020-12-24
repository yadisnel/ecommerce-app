import 'dart:convert';

import 'package:app/blocs/add_product_page_bloc.dart';
import 'package:app/blocs/bloc_provider.dart';
import 'package:app/core/config.dart';
import 'package:app/i18n/app_localizations.dart';
import 'package:app/models/base_model.dart';
import 'package:app/models/category_model.dart';
import 'package:app/models/province_model.dart';
import 'package:app/models/sub_category_model.dart';
import 'package:app/widgets/pick_category/pick_category.dart';
import 'package:app/widgets/pick_province/pick_province.dart';
import 'package:app/widgets/pick_sub_category/pick_sub_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

final addProductStateKey = new GlobalKey<_AddProductPageState>();

class AddProductPage extends StatefulWidget {
  AddProductPage({
    Key key,
  }) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  AddProductPageBloc _addProductPageBloc;
  ProvinceModel _selectedProvince;
  CategoryModel _selectedCategory;
  SubCategoryModel _selectedSubCategory;
  String _productName;
  String _productDescription;
  String _price;
  List<SubCategoryModel> subCategories;

  @override
  void initState() {
    super.initState();
    this.subCategories = [];
    this._selectedProvince = null;
    this._selectedCategory = null;
    this._selectedSubCategory = null;
    this._productName = null;
    this._price = null;
    this._addProductPageBloc = BlocProvider.of<AddProductPageBloc>(context);
  }

  bool isFormValid() {
    return this._selectedProvince != null &&
        this._selectedCategory != null &&
        this._selectedSubCategory != null &&
        this._productName != null &&
        this._productDescription != null &&
        this._productName.trim().isNotEmpty &&
        this._productDescription.trim().isNotEmpty &&
        this._price != null &&
        this._price.trim().isNotEmpty &&
        double.tryParse(this._price.trim()) != null;
  }

  void onChangeProvince(BaseModel model) {
    setState(() {
      _selectedProvince = model as ProvinceModel;
    });
  }

  void onChangeCategory(BaseModel model) {
    setState(() {
      _selectedCategory = model as CategoryModel;
      _selectedSubCategory = null;
      pickSubCategoryStateKey.currentState.resetState();
      subCategories = _selectedCategory.json["sub_categories"]
          .map<SubCategoryModel>((s) => SubCategoryModel(
                id: s['id'],
                name: s['name'],
              ))
          .toList();
      ;
    });
  }

  void onChangeSubCategory(BaseModel model) {
    setState(() {
      _selectedSubCategory = model as SubCategoryModel;
    });
  }

  void onChangeProductName(String productName) {
    setState(() {
      _productName = productName;
    });
  }

  void onChangeProductDescription(String productDescription) {
    setState(() {
      _productDescription = productDescription;
    });
  }

  void onChangePrice(String price) {
    setState(() {
      this._price = price;
    });
  }

  void refreshStreams() {
    _addProductPageBloc.refreshStreams();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _addProductPageBloc.appConfigStream,
      initialData: null,
      builder: (context, snapshotAppConfig) {
        if (!(snapshotAppConfig.hasData && snapshotAppConfig.data != null)) {
          return SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          );
        }
        Map<String, String> appConfig = snapshotAppConfig.data;
        var userInfo = jsonDecode(appConfig[DB_USER_INFO_CONFIG]);
        return Scaffold(
            appBar: AppBar(
              elevation: 10,
              title: Text(AppLocalizations.of(context).translate('addProduct')),
            ),
            body: Center(
                child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox.fromSize(
                    child: SvgPicture.asset(
                      'lib/assets/images/add_product_dialog.svg',
                      allowDrawingOutsideViewBox: true,
                    ),
                    size: Size(100.0, 100.0),
                  ),
                  SizedBox.fromSize(
                    size: Size(0.0, 10.0),
                  ),
                  userInfo["shop"] != null &&
                          userInfo["shop"]["province"] == null
                      ? PickProvinceWidget(
                          onChanged: onChangeProvince,
                          textStyle: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.grey[700],
                              fontSize: 16),
                          hintText: AppLocalizations.of(context)
                              .translate('pickProvince'),
                        )
                      : Container(),
                  TextField(
                      onChanged: onChangeProductName,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.grey[700],
                          fontSize: 16),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AppLocalizations.of(context)
                              .translate('productName'))),
                  TextField(
                      onChanged: onChangeProductDescription,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.grey[700],
                          fontSize: 16),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AppLocalizations.of(context)
                              .translate('productDescription'))),
                  TextField(
                      onChanged: onChangePrice,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.grey[700],
                          fontSize: 16),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AppLocalizations.of(context)
                              .translate('price'))),
                  PickCategoryWidget(
                    onChanged: onChangeCategory,
                    textStyle: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.grey[700],
                        fontSize: 16),
                    hintText:
                        AppLocalizations.of(context).translate('pickCategory'),
                  ),
                  PickSubCategoryWidget(
                    key: pickSubCategoryStateKey,
                    onChanged: onChangeSubCategory,
                    subCategories: subCategories,
                    textStyle: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.grey[700],
                        fontSize: 16),
                    hintText: AppLocalizations.of(context)
                        .translate('pickSubCategory'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('cancel')
                                .toUpperCase(),
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.teal[900],
                                fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      FlatButton(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('add')
                                .toUpperCase(),
                            style: this.isFormValid()
                                ? TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Colors.teal[900],
                                    fontSize: 16)
                                : TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Colors.grey[400],
                                    fontSize: 16),
                          ),
                          onPressed: this.isFormValid()
                              ? () {
                                  //TODO
                                }
                              : null)
                    ],
                  )
                ],
              ),
            )));
      }, // access the data in our Stream here
    );
  }
}
