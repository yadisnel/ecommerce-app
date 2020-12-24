import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/index_page_bloc.dart';
import 'package:app/blocs/root_page_bloc.dart';
import 'package:app/blocs/welcome_page_bloc.dart';
import 'package:app/core/config.dart';
import 'package:app/pages/root_page.dart';
import 'package:app/pages/welcome_page.dart';
import 'package:flutter/material.dart';

class IndexPage extends StatefulWidget {
  IndexPage({
    Key key,
  }) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  IndexPageBloc _indexPageBloc;

  @override
  void initState() {
    super.initState();
    _indexPageBloc = BlocProvider.of<IndexPageBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _indexPageBloc.appConfigStream,
      initialData: null,
      builder: (context, snapshot) {
        if (!(snapshot.hasData && snapshot.data != null)) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        Map<String, String> appConfig = snapshot.data;
        if (appConfig[DB_TOKEN_CONFIG].isNotEmpty) {
          //User is authenticated.
          return BlocProvider(
            bloc: RootPageBloc(),
            child: RootPage(key: rootPageStateKey,),
          );
        }
        //User is not authenticated.
        return BlocProvider(
          bloc: WelcomePageBloc(),
          child: WelcomePage(),
        );
      }, // access the data in our Stream here
    );
  }
}
