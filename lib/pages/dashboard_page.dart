import 'dart:convert';

import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/dashbboard_page_bloc.dart';
import 'package:app/blocs/profile_page_bloc.dart';
import 'package:app/core/config.dart';
import 'package:app/i18n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({
    Key key,
  }) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardPageBloc _dashboardPageBloc;

  @override
  void initState() {
    super.initState();
    _dashboardPageBloc = BlocProvider.of<DashboardPageBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _dashboardPageBloc.appConfigStream,
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
            elevation: 1,
            title: Text(AppLocalizations.of(context).translate('dashboard')),
          ),
          body: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Row(
                  children: <Widget>[
                    Icon(
                      Icons.chat,
                      color: Colors.grey[800],
                    ),
                    SizedBox.fromSize(
                      size: Size(10, 0),
                    ),
                    Text(
                      AppLocalizations.of(context).translate('chats'),
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, ROUTE_LANGUAGE);
                },
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Icon(
                      Icons.insert_chart,
                      color: Colors.grey[800],
                    ),
                    SizedBox.fromSize(
                      size: Size(10, 0),
                    ),
                    Text(
                      AppLocalizations.of(context).translate('metrics'),
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, ROUTE_LANGUAGE);
                },
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Icon(
                      Icons.people,
                      color: Colors.grey[800],
                    ),
                    SizedBox.fromSize(
                      size: Size(10, 0),
                    ),
                    Text(
                      AppLocalizations.of(context).translate('users'),
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, ROUTE_LANGUAGE);
                },
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Icon(
                      Icons.location_city,
                      color: Colors.grey[800],
                    ),
                    SizedBox.fromSize(
                      size: Size(10, 0),
                    ),
                    Text(
                      AppLocalizations.of(context).translate('provinces'),
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, ROUTE_LANGUAGE);
                },
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Icon(
                      Icons.category,
                      color: Colors.grey[800],
                    ),
                    SizedBox.fromSize(
                      size: Size(10, 0),
                    ),
                    Text(
                      AppLocalizations.of(context).translate('categories'),
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, ROUTE_LANGUAGE);
                },
              ),
            ],
          ),
        );
      }, // access the data in our Stream here
    );
  }
}
