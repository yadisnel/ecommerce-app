import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/login_page_bloc.dart';
import 'package:app/core/config.dart';
import 'package:app/i18n/app_localizations.dart';
import 'package:app/widgets/country_code_picker/country_code_picker.dart';
import 'package:app/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    Key key,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginPageBloc _loginPageBloc;

  @override
  void initState() {
    super.initState();
    _loginPageBloc = BlocProvider.of<LoginPageBloc>(context);
  }

  Widget buildLoginBody(BuildContext context, String loginMethod) {
    switch (loginMethod) {
      case DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG_MAIL_VALUE:
        return Column(
          children: <Widget>[
            CountryCodePicker(
              onChanged: print,
              // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
              initialSelection: 'IT',
              favorite: ['+39', 'FR'],
              // optional. Shows only country name and flag
              showCountryOnly: false,
              // optional. Shows only country name and flag when popup is closed.
              showOnlyCountryWhenClosed: false,
              // optional. aligns the flag and the Text left
              alignLeft: false,
            )
          ],
        );
        break;
      case DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG_PHONE_VALUE:
        return Text("No yet");
        break;
      default:
        return Text("Not implemented");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Wrap our widget with a StreamBuilder
      stream: _loginPageBloc.appConfigStream, // pass our Stream getter here
      initialData: null, // provide an initial data
      builder: (context, snapshot) {
        if (!(snapshot.hasData && snapshot.data != null)) {
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
                    Colors.blue[800],
                    Colors.blue[900],
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          );
        }
        Map<String, String> appConfig = snapshot.data;

        Color colorPhoneButton;
        Color colorMailButton;

        switch (appConfig[DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG]) {
          case DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG_MAIL_VALUE:
            colorMailButton = Colors.blue[200];
            colorPhoneButton = Colors.white;
            break;
          case DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG_PHONE_VALUE:
            colorMailButton = Colors.white;
            colorPhoneButton = Colors.blue[200];
            break;
        }

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
                  Colors.blue[800],
                  Colors.blue[900],
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
                    child: Text(AppLocalizations.of(context).translate('login'),
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                            fontSize: 20))),
                SizedBox.fromSize(
                  size: Size(0, 20.0),
                ),
                Row(
                  children: <Widget>[
                    RoundedButton(
                      onPressed: () {
                        _loginPageBloc.changeLoginPageSelectedItem(
                            DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG_MAIL_VALUE);
                      },
                      icon: Icon(
                        Icons.mail,
                        size: 26.0,
                        color: colorMailButton,
                      ),
                    ),
                    SizedBox.fromSize(
                      size: Size(20.0, 0.0),
                    ),
                    RoundedButton(
                      onPressed: () {
                        _loginPageBloc.changeLoginPageSelectedItem(
                            DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG_PHONE_VALUE);
                      },
                      icon: Icon(
                        Icons.phone,
                        size: 26.0,
                        color: colorPhoneButton,
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                buildLoginBody(
                    context, appConfig[DB_LOGIN_PAGE_ITEM_SELECTED_CONFIG])
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        );
      }, // access the data in our Stream here
    );
  }
}
