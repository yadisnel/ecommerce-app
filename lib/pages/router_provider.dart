import 'package:app/blocs/add_product_page_bloc.dart';
import 'package:app/blocs/bloc_provider.dart';
import 'package:app/blocs/dashbboard_page_bloc.dart';
import 'package:app/blocs/index_page_bloc.dart';
import 'package:app/blocs/language_page_bloc.dart';
import 'package:app/blocs/login_page_bloc.dart';
import 'package:app/blocs/profile_page_bloc.dart';
import 'package:app/blocs/welcome_page_bloc.dart';
import 'package:app/core/config.dart';
import 'package:app/pages/add_product_page.dart';
import 'package:app/pages/language_page.dart';
import 'package:app/pages/profile_page.dart';
import 'package:app/pages/welcome_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'index_page.dart';
import 'login_page.dart';

class RouterProvider {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case ROUTE_INDEX:
        return MaterialPageRoute(builder: (context) {
          return BlocProvider(
            bloc: IndexPageBloc(),
            child: IndexPage(),
          );
        });

      case ROUTE_WELCOME:
        return MaterialPageRoute(builder: (context) {
          return BlocProvider(
            bloc: WelcomePageBloc(),
            child: WelcomePage(),
          );
        });
      case ROUTE_LANGUAGE:
        return MaterialPageRoute(builder: (context) {
          return BlocProvider(
            bloc: LanguagePageBloc(),
            child: LanguagePage(),
          );
        });
      case ROUTE_PROFILE:
        return MaterialPageRoute(builder: (context) {
          return BlocProvider(
            bloc: ProfilePageBloc(),
            child: ProfilePage(),
          );
        });
      case ROUTE_LOGIN:
        return MaterialPageRoute(builder: (context) {
          return BlocProvider(
            bloc: LoginPageBloc(),
            child: LoginPage(),
          );
        });
      case ROUTE_ADD_PRODUCT:
        return MaterialPageRoute(builder: (context) {
          return BlocProvider(
            bloc: AddProductPageBloc(),
            child: AddProductPage(key: addProductStateKey,),
          );
        });
      case ROUTE_DASHBOARD:
        return MaterialPageRoute(builder: (context) {
          return BlocProvider(
            bloc: DashboardPageBloc(),
            child: DashboardPage(),
          );
        });
      default:
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: Center(
                      child: Text(
                          'No route defined for ${settings.name}. Add a route in router_provider.dart')),
                ));
    }
  }
}
