import 'dart:convert';

import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/buy_page_bloc.dart';
import 'package:app/blocs/chats_page_bloc.dart';
import 'package:app/blocs/root_page_bloc.dart';
import 'package:app/blocs/sell_page_bloc.dart';
import 'package:app/core/config.dart';
import 'package:app/i18n/app_localizations.dart';
import 'package:app/models/app_status_model.dart';
import 'package:app/pages/chats_page.dart';
import 'package:app/pages/sell_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'buy_page.dart';

final rootPageStateKey = new GlobalKey<_RootPageState>();


class RootPage extends StatefulWidget {
  RootPage({
    Key key,
  }) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with TickerProviderStateMixin {
  RootPageBloc _rootPageBloc;
  AnimationController _controllerStatusAppBar;
  AnimationController _controllerStatusFirstConfig;

  Future<void> reloadConfig() async {
    await _rootPageBloc.refreshStreams();
  }

  @override
  void initState() {
    super.initState();
    _rootPageBloc = BlocProvider.of<RootPageBloc>(context);
    _rootPageBloc.setupAsyncServices();
    _controllerStatusAppBar = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _controllerStatusFirstConfig = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  void onItemTab(int index) {
    _rootPageBloc.changeRootSelectedItem(index.toString());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Wrap our widget with a StreamBuilder
      stream: _rootPageBloc.appConfigStream, // pass our Stream getter here
      initialData: null, // provide an initial data
      builder: (context, snapshotAppConfig) {
        if (!(snapshotAppConfig.hasData && snapshotAppConfig.data != null)) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        Map<String, String> appConfig = snapshotAppConfig.data;
        return StreamBuilder(
            // Wrap our widget with a StreamBuilder
            stream: _rootPageBloc.appStatusStream,
            // pass our Stream getter here
            initialData: null,
            // provide an initial data
            builder: (context, snapshotAppStatus) {
              if (!(snapshotAppStatus.hasData &&
                  snapshotAppStatus.data != null)) {
                return SizedBox.expand(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              AppStatusModel status = snapshotAppStatus.data;
              _controllerStatusFirstConfig.reset();
              if (appConfig[DB_APP_IN_FIRST_CONFIG] == "0") {
                if (status == AppStatusModel.CONNECTED ||
                    status == AppStatusModel.IN_SYNC) {
                  Widget statusIconFirstConfig = RotationTransition(
                    turns: Tween(begin: 1.0, end: 0.0)
                        .animate(_controllerStatusFirstConfig),
                    child: Icon(
                      Icons.sync,
                      size: 32,
                      color: Colors.teal[900],
                    ),
                  );
                  _controllerStatusFirstConfig.repeat();
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
                          Row(
                            children: <Widget>[
                              statusIconFirstConfig,
                              SizedBox.fromSize(size: Size(0,10),)
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                          SizedBox.fromSize(
                            size: Size(0.0, 20.0),
                          ),
                          Material(
                              type: MaterialType.transparency,
                              child: Text(
                                  AppLocalizations.of(context)
                                      .translate('firstConfig'),
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
                                      .translate('firstConfigComment'),
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Colors.teal[900],
                                      fontSize: 12))),
                          SizedBox.fromSize(
                            child: SvgPicture.asset(
                              'lib/assets/images/in_sync.svg',
                              allowDrawingOutsideViewBox: true,
                            ),
                            size: Size(150.0, 150.0),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                  );
                } else {
                  //No internet
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
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.offline_bolt,
                                size: 32.0,
                                color: Colors.black12,
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                          SizedBox.fromSize(
                            size: Size(0.0, 20.0),
                          ),
                          Material(
                              type: MaterialType.transparency,
                              child: Text(
                                  AppLocalizations.of(context)
                                      .translate('youAreDisconnected'),
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
                                      .translate('pleaseCheckYourInternet'),
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Colors.teal[900],
                                      fontSize: 12))),
                          SizedBox.fromSize(
                            child: SvgPicture.asset(
                              'lib/assets/images/server_down.svg',
                              allowDrawingOutsideViewBox: true,
                            ),
                            size: Size(150.0, 150.0),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                  );
                }
              }
              // Config is done, show body
              if (_controllerStatusAppBar != null) {
                _controllerStatusAppBar.reset();
              }
              Widget statusIcon = Icon(
                Icons.offline_bolt,
                size: 18.0,
                color: Colors.black12,
              );
              if (status == AppStatusModel.CONNECTED) {
                statusIcon = Icon(
                  Icons.offline_bolt,
                  size: 18.0,
                  color: Colors.tealAccent,
                );
              } else if (status == AppStatusModel.IN_SYNC) {
                statusIcon = RotationTransition(
                  turns: Tween(begin: 1.0, end: 0.0)
                      .animate(_controllerStatusAppBar),
                  child: Icon(
                    Icons.sync,
                    size: 18,
                    color: Colors.tealAccent,
                  ),
                );
                _controllerStatusAppBar.repeat();
              }
              return Scaffold(
                appBar: AppBar(
                  elevation: 1,
                  title: Row(
                    children: <Widget>[
                      statusIcon,
                      SizedBox.fromSize(
                        size: Size(5, 0),
                      ),
                      Text(appConfig[DB_APP_NAME_CONFIG]),
                    ],
                  ),
                  actions: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.search,
                            size: 26.0,
                          ),
                        )),
                    Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.filter_list,
                            size: 26.0,
                          ),
                        )),
                  ],
                ),
                drawer: buildDrawer(context, snapshotAppConfig),
                body: buildBody(int.parse(
                    appConfig[DB_ROOT_PAGE_ITEM_SELECTED_CONFIG])),
                bottomNavigationBar:
                buildBottomNavigationBar(context, appConfig),
              );
            });
      }); // access the data in our Stream here
  }

  Widget buildBody(int index) {
    switch (index) {
      case 0:
        return BlocProvider(
          bloc: BuyPageBloc(),
          child: BuyPage(),
        );
      case 1:
        return BlocProvider(
          bloc: SellPageBloc(),
          child: SellPage(key: sellPageStateKey,),
        );
      case 2:
        return BlocProvider(
          bloc: ChatsPageBloc(),
          child: ChatsPage(),
        );
      default:
        return BlocProvider(
          bloc: BuyPageBloc(),
          child: BuyPage(),
        );
    }
  }

  Widget buildDrawer(
      BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
    Map<String, String> appConfig = snapshot.data;
    var userInfo = jsonDecode(appConfig[DB_USER_INFO_CONFIG]);
    Widget circleAvatar = CircleAvatar(
      radius: 30,
      child: SvgPicture.asset(
        'lib/assets/images/default_avatar.svg',
        allowDrawingOutsideViewBox: true,
      ),
      backgroundColor: Colors.white,
    );
    if (userInfo["picture"] != null &&
        userInfo["picture"]["thumb_key"] != null &&
        userInfo["picture"]["original_key"] != null &&
        userInfo["picture"]["thumb_url"] != null &&
        userInfo["picture"]["original_url"] != null) {
      circleAvatar = ClipOval(
        child: new CachedNetworkImage(
          imageUrl: userInfo["picture"]["thumb_url"],
          height: 60.0,
          width: 60.0,
          fit: BoxFit.cover,
          placeholder: (context, url) => SvgPicture.asset(
            'lib/assets/images/default_avatar.svg',
            allowDrawingOutsideViewBox: true,
          ),
        ),
      );
    }
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 150,
            child: DrawerHeader(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, ROUTE_PROFILE);
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          circleAvatar,
                          SizedBox.fromSize(
                            size: Size(10, 0),
                          ),
                          Container(
                            width: 175,
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  userInfo["name"],
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          size: 26.0,
                          color: Colors.grey[800],
                        ),
                      )
                    ]),
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
            ),
          ),
          ListTile(
            title: Row(
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  color: Colors.grey[800],
                ),
                SizedBox.fromSize(
                  size: Size(10, 0),
                ),
                Text(
                  AppLocalizations.of(context).translate('profile'),
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, ROUTE_PROFILE);
            },
          ),
          ListTile(
            title: Row(
              children: <Widget>[
                Icon(
                  Icons.language,
                  color: Colors.grey[800],
                ),
                SizedBox.fromSize(
                  size: Size(10, 0),
                ),
                Text(
                  AppLocalizations.of(context).translate('language'),
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, ROUTE_LANGUAGE);
            },
          ),
          userInfo["role"] == "admin" ? ListTile(
            title: Row(
              children: <Widget>[
                Icon(
                  Icons.dashboard,
                  color: Colors.grey[800],
                ),
                SizedBox.fromSize(
                  size: Size(10, 0),
                ),
                Text(
                  AppLocalizations.of(context).translate('dashboard'),
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, ROUTE_DASHBOARD);
            },
          ): Container(),
          ListTile(
            title: Row(
              children: <Widget>[
                Icon(
                  Icons.lock,
                  color: Colors.grey[800],
                ),
                SizedBox.fromSize(
                  size: Size(10, 0),
                ),
                Text(
                  AppLocalizations.of(context).translate('logout'),
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              _rootPageBloc.logout();
              Navigator.pushReplacementNamed(context, ROUTE_INDEX);
            },
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar(context, Map<String, String> appConfig) {
    return BottomNavigationBar(
      onTap: onItemTab,
      currentIndex: int.parse(appConfig[DB_ROOT_PAGE_ITEM_SELECTED_CONFIG]),
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.add_shopping_cart),
          title: Text(AppLocalizations.of(context).translate('buy')),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          title: Text(AppLocalizations.of(context).translate('sell')),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          title: Text(AppLocalizations.of(context).translate('chats')),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controllerStatusAppBar.dispose();
    super.dispose();
  }
}
