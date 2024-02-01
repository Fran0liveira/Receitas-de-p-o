import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseApi {
  static const _apiKey = 'goog_PlgfqUExIHGnNIbtMFIbaFTSyic';

  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(_apiKey);
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      log('current: $current');
      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      return [];
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } catch (e) {
      log('compra purchased error: $e');
      return false;
    }
  }
}
