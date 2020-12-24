import 'dart:convert';

import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/welcome_page_bloc.dart';
import 'package:app/core/config.dart';
import 'package:app/i18n/app_localizations.dart';
import 'package:app/widgets/circle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class WelcomePage extends StatefulWidget {
  WelcomePage({
    Key key,
  }) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  WelcomePageBloc _welcomePageBloc;
  var facebookLogin = FacebookLogin();
  bool isLoggedIn = false;
  var profileData;

  @override
  void initState() {
    super.initState();
    // Thanks to the BlocProvider providing this page with the NotesBloc,
    // we can simply use this to retrieve it.
    _welcomePageBloc = BlocProvider.of<WelcomePageBloc>(context);
  }

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  void initiateFacebookLogin(
      BuildContext context, Map<String, String> appConfig) async {
    var facebookLoginResult = await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        var graphResponse = await http.get(
            "https://graph.facebook.com/v6.0/me?fields=name,first_name,last_name,picture,email&access_token=${facebookLoginResult.accessToken.token}");
        if (graphResponse.statusCode == 200) {
          var profileDecoded = json.decode(graphResponse.body);
          var ipHostIpConfig = appConfig[DB_API_HOST_IP_CONFIG];
          var body = {};
          body["username"] = profileDecoded["id"];
          print(profileDecoded["id"]);
          body['password'] = facebookLoginResult.accessToken.token;
          print(facebookLoginResult.accessToken.token);
          var dtodoTokenResponse =
              await http.post('http://$ipHostIpConfig/token', body: body);
          if (dtodoTokenResponse.statusCode == 200) {
            var tokenDecoded =
                json.decode(utf8.decode(dtodoTokenResponse.bodyBytes));
            print(tokenDecoded.toString());
            var dtodoUserInfoResponse = await http
                .post("http://$ipHostIpConfig/users/info", headers: {
              "Authorization": "bearer " + tokenDecoded["access_token"]
            });
            if (dtodoUserInfoResponse.statusCode == 200) {
              var userInfoDecoded =
                  json.decode(utf8.decode(dtodoUserInfoResponse.bodyBytes));
              if (userInfoDecoded["name"] != null) {
                await _welcomePageBloc
                    .updateToken(tokenDecoded["access_token"]);
                await _welcomePageBloc
                    .updateUserInfo(jsonEncode(userInfoDecoded));
                Navigator.pushReplacementNamed(context, ROUTE_INDEX);
              }
            }
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Wrap our widget with a StreamBuilder
      stream: _welcomePageBloc.appConfigStream, // pass our Stream getter here
      initialData: null, // provide an initial data
      builder: (context, snapshotAppConfig) {
        if (!(snapshotAppConfig.hasData && snapshotAppConfig.data != null)) {
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
              child: CircularProgressIndicator(),
            ),
          );
        }
        Map<String, String> appConfig = snapshotAppConfig.data;
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
                    'lib/assets/images/logo.svg',
                    allowDrawingOutsideViewBox: true,
                  ),
                  size: Size(100.0, 100.0),
                ),
                Material(
                    type: MaterialType.transparency,
                    child: Text(appConfig[DB_APP_NAME_CONFIG],
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.teal[900],
                            fontSize: 25))),
                SizedBox.fromSize(
                  size: Size(0.0, 10.0),
                ),
                Material(
                    type: MaterialType.transparency,
                    child: Text(
                        AppLocalizations.of(context).translate('slogan'),
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.teal[900],
                            fontSize: 12))),
                SizedBox.fromSize(
                  child: SvgPicture.asset(
                    'lib/assets/images/welcome.svg',
                    allowDrawingOutsideViewBox: true,
                  ),
                  size: Size(200.0, 200.0),
                ),
                Row(
                  children: <Widget>[
                    CircleButton(
                      onPressed: () {
                        initiateFacebookLogin(context, appConfig);
                      },
                      title: AppLocalizations.of(context)
                          .translate('login')
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
      }, // access the data in our Stream here
    );
  }
}
