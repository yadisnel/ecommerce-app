import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/language_page_bloc.dart';
import 'package:app/core/config.dart';
import 'package:app/i18n/app_localizations.dart';
import 'package:app/models/language_model.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class LanguagePage extends StatefulWidget {
  LanguagePage({
    Key key,
  }) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  LanguagePageBloc _languagePageBloc;

  @override
  void initState() {
    super.initState();
    _languagePageBloc = BlocProvider.of<LanguagePageBloc>(context);
  }

  List<LanguageModel> _languages = [
    LanguageModel(
        index: 0,
        languageCode: "",
        countryCode: "",
        languageName: "System",
        flag: "lib/assets/flags/us.png"),
    LanguageModel(
        index: 1,
        languageCode: "us",
        countryCode: "US",
        languageName: "English",
        flag: "lib/assets/flags/us.png"),
    LanguageModel(
        index: 2,
        languageCode: "es",
        countryCode: "ES",
        languageName: "Español",
        flag: "lib/assets/flags/es.png"),
  ];

  @override
  Widget build(BuildContext context) {
    int _currentIndex;
    return StreamBuilder(
      stream: _languagePageBloc.appConfigStream,
      initialData: null,
      builder: (context, snapshot) {
        if (!(snapshot.hasData && snapshot.data != null)) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        Map<String, String> appConfig = snapshot.data;
        bool languageFounded = false;
        if (appConfig[DB_COUNTRY_CODE_CONFIG].isNotEmpty &&
            appConfig[DB_LANGUAGE_CODE_CONFIG].isNotEmpty) {
          for (LanguageModel lang in _languages) {
            String countryCode = appConfig[DB_COUNTRY_CODE_CONFIG];
            String languageCode = appConfig[DB_LANGUAGE_CODE_CONFIG];
            if (lang.countryCode == countryCode &&
                lang.languageCode == languageCode) {
              languageFounded = true;
              _currentIndex = lang.index;
            }
          }
        }
        if (!languageFounded) {
          _currentIndex = 0;
        }
        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            title: Text(AppLocalizations.of(context).translate('language')),
          ),
          body: ListView(
            padding: EdgeInsets.all(8.0),
            children: _languages
                .map((language) => RadioListTile(
                      groupValue: _currentIndex,
                      title: Row(
                        children: <Widget>[
                          Image.asset(
                            language.flag,
                            width: 20.0,
                          ),
                          SizedBox.fromSize(
                            size: Size(5, 0),
                          ),
                          Text(language.languageName),
                        ],
                      ),
                      value: language.index,
                      onChanged: (val) {
                        LanguageModel langSelected = _languages[val];
                        _languagePageBloc.changeLocale(
                            languageCode: langSelected.languageCode,
                            countryCode: langSelected.countryCode);
                        dtodoAppStateKey.currentState.reloadConfig();
                      },
                    ))
                .toList(),
          ),
        );
      }, // access the data in our Stream here
    );
  }
}
