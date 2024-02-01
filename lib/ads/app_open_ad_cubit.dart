import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:receitas_de_pao/ads/open_app_ad_state.dart';

import 'my_ads.dart';

class OpenAppAdCubit extends Cubit<OpenAppAdState> {
  AppOpenAd _openAd;
  static bool _appPaused = false;
  static bool _loading = false;
  static bool _enabled = true;

  OpenAppAdCubit() : super(OpenAppAdState());

  isAppPaused() {
    return _appPaused;
  }

  updateAppPaused(bool valuePaused) {
    _appPaused = valuePaused;
  }

  enable(bool valueEnabled) {
    _enabled = valueEnabled;
    log('open ad enabled: $_enabled');
  }

  Future<void> loadOpenAd(bool show) async {
    if (_loading || !_enabled) {
      return;
    }
    log('loading open ad $_enabled');
    await AppOpenAd.load(
        adUnitId: MyAds.anucioAbertura,
        request: AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            log('open ad loaded');
            _openAd = ad;
            if (show) {
              showAd();
            }
            _loading = false;
          },
          onAdFailedToLoad: (error) {
            log('open ad failed to load: $error');
            _loading = false;
          },
        ),
        orientation: AppOpenAd.orientationPortrait);
  }

  Future<void> showAd() async {
    if (!_enabled) {
      return;
    }
    log('showing open ad $_enabled');
    if (_openAd == null) {
      loadOpenAd(true);
      return;
    }

    _openAd.fullScreenContentCallback =
        FullScreenContentCallback(onAdShowedFullScreenContent: (ad) {
      log('open ad showed');
    }, onAdFailedToShowFullScreenContent: (ad, error) {
      log('open ad failed to show: $error');
      ad.dispose();
      _openAd = null;
      loadOpenAd(false);
    }, onAdDismissedFullScreenContent: (ad) {
      log('open ad dismissed');
      ad.dispose();
      _openAd = null;
      loadOpenAd(false);
    });
    await _openAd.show();
  }
}
