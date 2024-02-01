// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:receitas_de_pao/utils/screen.dart';

// class BannerWidget extends StatefulWidget {
//   BannerAd banner;

//   BannerWidget({this.banner});
//   @override
//   State<BannerWidget> createState() => _BannerWidgetState();
// }

// class _BannerWidgetState extends State<BannerWidget> {
//   Screen _screen;
//   BannerAd get banner => widget.banner;

//   @override
//   void initState() {
//     super.initState();
//     _screen = Screen(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (banner == null) {
//       return SizedBox(height: 60);
//     } else {
//       return Container(
//         height: 60,
//         color: Colors.pink[900],
//         width: _screen.width,
//         child: AdWidget(ad: banner),
//       );
//     }
//   }
// }
