import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/sell_page_bloc.dart';
import 'package:app/core/config.dart';
import 'package:app/i18n/app_localizations.dart';
import 'package:app/models/product_model.dart';
import 'package:app/widgets/circle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

final sellPageStateKey = new GlobalKey<_SellPageState>();


class SellPage extends StatefulWidget {
  SellPage({
    Key key,
  }) : super(key: key);

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  SellPageBloc _sellPageBloc;

  void reloadConfig() {
    _sellPageBloc.refreshStreams();
  }

  @override
  void initState() {
    super.initState();
    _sellPageBloc = BlocProvider.of<SellPageBloc>(context);
  }

  @override
  void dispose() {
    _sellPageBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _sellPageBloc.appConfigStream,
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
        return StreamBuilder(
          stream: _sellPageBloc.existsOwnProductsStream,
          initialData: null,
          builder: (context, snapshotExistsOwnProducts) {
            if (!(snapshotExistsOwnProducts.hasData &&
                snapshotExistsOwnProducts.data != null)) {
              return SizedBox.expand(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (!snapshotExistsOwnProducts.data) {
              return SizedBox.expand(
                child: Container(
                  decoration: BoxDecoration(
                    // Box decoration takes a gradient
                    gradient: LinearGradient(
                      // Where the linear gradient begins and ends
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      // Add one stop for each color. Stops should increase from 0 to 1
                      stops: [0.1, 0.9],
                      colors: [
                        // Colors are easy thanks to Flutter's Colors class.
                        Colors.teal[50],
                        Colors.teal[100],
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      SizedBox.fromSize(
                        child: SvgPicture.asset(
                          'lib/assets/images/add_product.svg',
                          allowDrawingOutsideViewBox: true,
                        ),
                        size: Size(100.0, 100.0),
                      ),
                      SizedBox.fromSize(
                        size: Size(0.0, 20.0),
                      ),
                      Material(
                          type: MaterialType.transparency,
                          child: Text(
                              AppLocalizations.of(context)
                                  .translate('withoutProduct'),
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Colors.teal[900],
                                  fontSize: 18))),
                      SizedBox.fromSize(
                        size: Size(0.0, 10.0),
                      ),
                      Material(
                          type: MaterialType.transparency,
                          child: Text(
                              AppLocalizations.of(context)
                                  .translate('addProductComment'),
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Colors.teal[900],
                                  fontSize: 12))),
                      SizedBox.fromSize(
                        size: Size(0.0, 30.0),
                      ),
                      Row(
                        children: <Widget>[
                          CircleButton(
                            onPressed: () {
                              Navigator.pushNamed(context, ROUTE_ADD_PRODUCT);
                            },
                            title: AppLocalizations.of(context)
                                .translate('addProduct')
                                .toUpperCase(),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ),
              );
            }
            return StreamBuilder(
              stream: _sellPageBloc.listOwnProductsStream,
              initialData: null,
              builder: (context, snapshotOwnProducts) {
                if (!(snapshotOwnProducts.hasData &&
                    snapshotOwnProducts.data != null)) {
                  return SizedBox.expand(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                List<ProductModel> products = snapshotOwnProducts.data;
                return ListView.builder(
                  itemCount: snapshotOwnProducts.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    ProductModel product = products[index];

                    return GestureDetector(
                      onTap: () {
                         // TODO go to product details page
                      },
                      child: Container(
                        height: 40,
                        child: Text(
                          'Product ' + product.json["name"],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  },
                );
              }, // access the data in our Stream here
            );
          }, // access the data in our Stream here
        );
      }, // access the data in our Stream here
    );
  }
}
