import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardAdLoader {
  RewardedAd _rewardedAd;
  int _rewardedAdLoadAttempts = 0;
  final int _maxFailedLoadAttempts = 3;

  loadAnuncioPremiado(String adId) {
    RewardedAd.load(
        adUnitId: adId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _rewardedAdLoadAttempts = 0;
          },
          onAdFailedToLoad: (error) {
            _rewardedAdLoadAttempts++;
            _rewardedAd = null;
            if (_rewardedAdLoadAttempts <= _maxFailedLoadAttempts) {
              loadAnuncioPremiado(adId);
            }
          },
        ));
  }

  showRewardedAd(
      {void Function(RewardedAd, RewardItem) onUserEarnedReward,
      void Function(RewardedAd, AdError) onUserCancelReward}) {
    _rewardedAd?.show(onUserEarnedReward: onUserEarnedReward);

    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {},
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onUserCancelReward.call(ad, error);
        });
  }

  dispose() {
    _rewardedAd?.dispose();
  }
}
