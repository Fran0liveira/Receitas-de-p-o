import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';

class AdUtils {
  static Future<AdSize> getAdaptativeSize(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return AdSize.banner;
    }
    return size;
  }
}
