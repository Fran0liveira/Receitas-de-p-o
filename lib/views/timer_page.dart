import 'dart:async';
import 'dart:developer';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/banner_widget_novo.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/components/btn_premium.dart';
import 'package:receitas_de_pao/components/timer_widget.dart';
import 'package:receitas_de_pao/state/ads_state/ads_cubit.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/state/timer_state/timer_state.dart';
import 'package:receitas_de_pao/style/palete.dart';

import '../components/app_textfield.dart';
import '../components/default_modal.dart';
import '../components/menu_actions.dart';
import '../components/modal_menu.dart';
import '../db/app_db.dart';
import '../factory/scroll.dart';
import '../models/my_app/ingrediente.dart';
import '../models/my_app/item_compra.dart';
import '../state/lista_compras_state/lista_compras_cubit.dart';
import '../state/lista_compras_state/lista_compras_state.dart';
import '../utils/list_utils.dart';

class TimerPage extends StatefulWidget {
  void Function() onNovaReceitaPressed;
  TimerState timerState;

  TimerPage({this.onNovaReceitaPressed, this.timerState});
  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  AdsCubit _adsCubit;
  //BannerAd banner;
  PremiumCubit _premiumCubit;

  initState() {
    super.initState();
    _adsCubit = context.read<AdsCubit>();
    _premiumCubit = context.read<PremiumCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _adsCubit.showAd();
        return Future.value(true);
      },
      child: Scaffold(
        body: Column(
          children: [
            _buildNewAppBar(),
            Flexible(child: _content()),
            _banner(),
          ],
        ),
      ),
    );
  }

  _content() {
    return Container(
      padding: EdgeInsets.all(30),
      color: Palete().RED_50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Controle o tempo de preparo da sua receita!',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 30,
          ),
          TimerWidget(
            seconds: Duration(minutes: 1).inSeconds,
          ),
        ],
      ),
    );
  }

  _banner() {
    if (_premiumCubit.isPremiumMode()) {
      return Container();
    }
    return BannerWidgetNovo(
      adId: MyAds.timerBannerAd,
      background: Colors.pink[900],
    );
  }

  _buildNewAppBar() {
    return AppBar(
      backgroundColor: Colors.pink[600],
      actions: [BtnPremium()],
      title: Text('Timer de Preparo'),
    );
  }
}
