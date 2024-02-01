import 'package:flutter/material.dart';

class NavKeys {
  static GlobalKey<NavigatorState> initialPage = GlobalKey();
  static GlobalKey<ScaffoldState> drawer = GlobalKey();
  static GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  static GlobalKey<ScaffoldState> listaComprasKey =
      new GlobalKey<ScaffoldState>();

  static GlobalKey<ScaffoldState> lojaKey = new GlobalKey<ScaffoldState>();
}
