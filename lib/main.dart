import 'package:app/pages/router_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'blocs/bloc_provider.dart';
import 'blocs/main_app_bloc.dart';
import 'core/config.dart';
import 'i18n/app_localizations.dart';

final dtodoAppStateKey = new GlobalKey<_DtodoAppState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BlocProvider(
    bloc: MainAppBloc(),
    child: DtodoApp(
      key: dtodoAppStateKey,
    ),
  ));
}

class DtodoApp extends StatefulWidget {
  DtodoApp({
    Key key,
  }) : super(key: key);

  @override
  _DtodoAppState createState() => _DtodoAppState();
}

class _DtodoAppState extends State<DtodoApp> {
  MainAppBloc _mainAppBloc;


  void reloadConfig() {
    _mainAppBloc.refreshStreams();
  }

  @override
  void initState() {
    super.initState();
    _mainAppBloc = BlocProvider.of<MainAppBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _mainAppBloc.appConfigStream,
      initialData: null,
      builder: (context, snapshot) {
        if (!(snapshot.hasData && snapshot.data != null)) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        Map<String, String> appConfig = snapshot.data;
        String languageCode = appConfig[DB_LANGUAGE_CODE_CONFIG];
        String countryCode = appConfig[DB_COUNTRY_CODE_CONFIG];
        Locale savedLocale;
        if (languageCode != null && languageCode.isNotEmpty) {
          savedLocale = Locale(languageCode, countryCode);
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
          ),
          onGenerateRoute: RouterProvider.generateRoute,
          initialRoute: ROUTE_INDEX,
          locale: savedLocale,
          supportedLocales: [
            Locale('en', 'US'),
            Locale('es', 'ES'),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
        );
      }, // access the data in our Stream here
    );
  }
}
