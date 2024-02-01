import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:receitas_de_pao/utils/show_start_rate.dart';

class RateAppInitWidget extends StatefulWidget {
  final Widget Function(RateMyApp) builder;
  RateAppInitWidget({this.builder});
  @override
  State<RateAppInitWidget> createState() => _RateAppInitWidgetState();
}

class _RateAppInitWidgetState extends State<RateAppInitWidget> {
  RateMyApp _rateMyApp;
  @override
  Widget build(BuildContext context) {
    return RateMyAppBuilder(
      rateMyApp: RateMyApp(
        googlePlayIdentifier: 'com.ksoft.receitas_de_pao',
        minDays: 0,
        minLaunches: 2,
        remindDays: 1,
        remindLaunches: 1,
      ),
      onInitialized: (context, rateMyApp) {
        setState(() {
          _rateMyApp = rateMyApp;
        });

        if (rateMyApp.shouldOpenDialog) {
          ShowStarRate(context: context, rateMyApp: rateMyApp).show();
        }
      },
      builder: (context) => _rateMyApp == null
          ? Center(child: CircularProgressIndicator())
          : widget.builder(_rateMyApp),
    );
  }
}
