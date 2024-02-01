import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/models/entitlement_info_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:receitas_de_pao/api/purchase_api.dart';
import 'package:receitas_de_pao/enums/premium_mode.dart';
import 'package:receitas_de_pao/state/premium_state/premium_state.dart';
import 'package:receitas_de_pao/utils/list_utils.dart';

class PremiumCubit extends Cubit<PremiumState> {
  PremiumCubit() : super(PremiumState());

  PremiumMode _premiumMode = PremiumMode.FREE;
  PremiumMode get premiumMode => _premiumMode;
  List<EntitlementInfo> _entitlements = [];

  Future init() async {
    //DESCOMENTAR ESSE TRECHO QUANDO FOR USAR ASSINATURA
    // updatePurchaseStatus();
    // Purchases.addPurchaserInfoUpdateListener(
    //   (purchaserInfo) async {
    //     updatePurchaseStatus();
    //   },
    // );
  }

  Future updatePurchaseStatus() async {
    // final purchaserInfo = await Purchases.getPurchaserInfo();

    // var info = await Purchases.getPurchaserInfo();

    // _entitlements = purchaserInfo.entitlements.active.values.toList();
    // log('current entitlements: $_entitlements');
    // if (ListUtils.isNullOrEmpty(_entitlements)) {
    //   _premiumMode = PremiumMode.FREE;
    // } else {
    //   _premiumMode = PremiumMode.CHEF_MODE;
    // }
  }

  String _getEntitlementIdentifier() {
    if (ListUtils.isNullOrEmpty(_entitlements)) {
      return '';
    }
    return _entitlements.first.productIdentifier;
  }

  Future<bool> purchasePackage(Package package) async {
    return PurchaseApi.purchasePackage(package);
  }

  bool isCurrentPlan(Package package) {
    // String entitlementIdentififer = _getEntitlementIdentifier();
    // log('checking $entitlementIdentififer and ${package.product.identifier}');
    // return entitlementIdentififer == package.product.identifier;
  }

  isFreeMode() {
    return PremiumMode.FREE == premiumMode;
  }

  isPremiumMode() {
    bool isPremium = PremiumMode.FREE != premiumMode;
    log('ispremium $isPremium');
    return isPremium;
  }
}
