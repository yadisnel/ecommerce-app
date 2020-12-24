import 'dart:convert';

import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/profile_page_bloc.dart';
import 'package:app/core/config.dart';
import 'package:app/i18n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    Key key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfilePageBloc _profilePageBloc;

  @override
  void initState() {
    super.initState();
    _profilePageBloc = BlocProvider.of<ProfilePageBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _profilePageBloc.appConfigStream,
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
        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            title: Text(AppLocalizations.of(context).translate('profile')),
          ),
          body: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 100,
                child: DrawerHeader(
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
                            // TODO take a picture
                          },
                          child: Icon(
                            Icons.add_a_photo,
                            size: 26.0,
                            color: Colors.grey[800],
                          ),
                        )
                      ]),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                ),
              ),
              ListTile(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.shop,
                            color: Colors.grey[800],
                          ),
                          SizedBox.fromSize(
                            size: Size(10, 0),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  userInfo["shop"]["name"],
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO edit shop name
                        },
                        child: Icon(
                          Icons.edit,
                          size: 26.0,
                          color: Colors.grey[800],
                        ),
                      )
                    ]),
              ),
            ],
          ),
        );
      }, // access the data in our Stream here
    );
  }
}
