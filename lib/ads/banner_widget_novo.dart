import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/utils/screen.dart';

class BannerWidgetNovo extends StatefulWidget {
  String adId;
  Color background;

  BannerWidgetNovo({this.adId, this.background});

  @override
  State<BannerWidgetNovo> createState() => _BannerWidgetNovoState();
}

class _BannerWidgetNovoState extends State<BannerWidgetNovo> {
  BannerAd bannerAd;
  bool isLoaded = false;
  int tentativas = 0;
  int maxTentativas = 5;
  AdSize size;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerWidget();
  }

  _bannerWidget() {
    return isLoaded
        ? Container(
            child: AdWidget(ad: bannerAd),
            height: getHeight(),
            width: Screen.of(context).width,
            color: widget.background,
          )
        : Container(color: widget.background, height: getHeight());
  }

  getHeight() {
    return size != null
        ? size.height.toDouble()
        : AdSize.banner.height.toDouble();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    _createBanner();
  }

  _createBanner() async {
    size = await AdUtils.getAdaptativeSize(context);
    bannerAd = BannerAd(
      size: size,
      adUnitId: widget.adId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            tentativas = 0;
            isLoaded = true;
          });
        },
        onAdImpression: (ad) {
          log('adbanner impression');
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            tentativas++;
            isLoaded = false;
            ad.dispose();

            if (tentativas < maxTentativas) {
              _createBanner();
            }
          });
        },
      ),
      request: AdRequest(),
    );
    _loadAd();
    setState(() {});
  }

  _loadAd() {
    bannerAd.load();
  }
}
