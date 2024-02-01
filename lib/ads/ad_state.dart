import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  BannerAdListener get adListener => BannerAdListener(onAdLoaded: (ad) {
        log('ad loaded successfully');
      }, onAdFailedToLoad: (ad, loadError) {
        log('ad error: ' + loadError.message);
      });
}
