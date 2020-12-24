import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/buy_page_bloc.dart';
import 'package:flutter/material.dart';

class BuyPage extends StatefulWidget {
  BuyPage({
    Key key,
  }) : super(key: key);

  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  BuyPageBloc _buyPageBloc;

  @override
  void initState() {
    super.initState();
    _buyPageBloc = BlocProvider.of<BuyPageBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _buyPageBloc.appConfigStream,
      initialData: null,
      builder: (context, snapshot) {
        if (!(snapshot.hasData && snapshot.data != null)) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return SizedBox.expand(
            child: Center(
          child: Text("Buy"),
        ));
      }, // access the data in our Stream here
    );
  }
}
