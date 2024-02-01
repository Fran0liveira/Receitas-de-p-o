import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  static const String keyAdsPoints = 'ads_points';
  static const String keyUrlPromocional = 'url_promocional';
  static const String keyInitTimePromocional = 'init_time_promocional';
  static const String keyIndexUrlPromocional = 'index_url_promocional';
  static const String keyIndexUrlProdutoReceita = 'index_url_produto_receita';
  static const String keyEsconderPromocoes = 'esconder_promocoes';
  static const String keyCounterProdutoReceita = 'counter_produto_receita';

  static Future<SharedPreferences> _getPrefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<double> getAdsPoints() async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.getDouble(keyAdsPoints) ?? 3;
  }

  static void setAdsPoints(double adsPoints) async {
    SharedPreferences prefs = await _getPrefs();
    prefs.setDouble(keyAdsPoints, adsPoints);
  }

  static Future<String> getInitTimePromocional() async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.getString(keyInitTimePromocional) ?? '';
  }

  static Future<void> setInitTimePromocional(String initTimePromocional) async {
    SharedPreferences prefs = await _getPrefs();
    prefs.setString(keyInitTimePromocional, initTimePromocional);
  }

  static Future<int> getIndexUrlPromocional() async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.getInt(keyIndexUrlPromocional) ?? -1;
  }

  static Future<void> setIndexUrlPromocional(int indexUrlPromocional) async {
    SharedPreferences prefs = await _getPrefs();
    prefs.setInt(keyIndexUrlPromocional, indexUrlPromocional);
  }

  static Future<String> getUrlPromocional() async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.getString(keyUrlPromocional) ?? '';
  }

  static Future<void> setUrlPromocional(String urlPromocional) async {
    SharedPreferences prefs = await _getPrefs();
    prefs.setString(keyUrlPromocional, urlPromocional);
  }

  static Future<int> getIndexUrlProdutoReceita() async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.getInt(keyIndexUrlProdutoReceita) ?? -1;
  }

  static Future<void> setIndexUrlProdutoReceita(int indexUrl) async {
    SharedPreferences prefs = await _getPrefs();
    prefs.setInt(keyIndexUrlProdutoReceita, indexUrl);
  }

  static Future<bool> getEsconderPromocoes() async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.getBool(keyEsconderPromocoes) ?? false;
  }

  static Future<void> setEsconderPromocoes(bool esconderPromocoes) async {
    SharedPreferences prefs = await _getPrefs();
    prefs.setBool(keyEsconderPromocoes, esconderPromocoes);
  }

  static Future<int> getCounterProdutoReceita() async {
    SharedPreferences prefs = await _getPrefs();
    return prefs.getInt(keyCounterProdutoReceita) ?? 1;
  }

  static Future<void> setCounterProdutoReceita(int counter) async {
    SharedPreferences prefs = await _getPrefs();
    prefs.setInt(keyCounterProdutoReceita, counter);
  }
}
