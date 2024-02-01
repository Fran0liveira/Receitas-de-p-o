import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:receitas_de_pao/arguments/receita_page_arguments.dart';
import 'package:receitas_de_pao/resources/dicas_culinarias.dart';
import 'package:receitas_de_pao/views/dicas_culinarias_page.dart';
import 'package:receitas_de_pao/views/loja_page.dart';

import '../views/auth_wrapper.dart';
import '../views/initial_page.dart';
import '../views/login_page.dart';
import '../views/purchase_view.dart';
import '../views/receita_page.dart';
import '../views/register_user_page.dart';
import '../views/search_receitas_page.dart';
import '../views/timer_page.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initialPage:
        String redirectPage = settings.arguments;
        return MaterialPageRoute(
            builder: (_) => AuthWrapper(
                    child: InitialPage(
                  redirectPage,
                )));
      case AppRoutes.registerUserPage:
        return MaterialPageRoute(builder: (_) => RegisterUserPage());
      case AppRoutes.loginPage:
        String redirectPage = settings.arguments;
        return MaterialPageRoute(builder: (_) => LoginPage(redirectPage));
      case AppRoutes.searchReceitasPage:
        return MaterialPageRoute(builder: (_) => SearchReceitasPage());
      // case AppRoutes.receitaPage:
      //   log('loading receitapage');
      //   return MaterialPageRoute(
      //       builder: (_) =>
      //           ReceitaPage(settings.arguments as ReceitaPageArguments));
      // case AppRoutes.lojaPage:
      //   return MaterialPageRoute(builder: (_) => LojaPage());
    }
  }
}
