import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/components/banner_widget.dart';
import 'package:receitas_de_pao/components/btn_premium.dart';
import 'package:receitas_de_pao/components/my_nav_bar.dart';
import 'package:receitas_de_pao/components/new_appbar.dart';
import 'package:receitas_de_pao/components/reward_ad_loader.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';
import 'package:receitas_de_pao/resources/dicas_culinarias.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/state/ads_state/ads_cubit.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:receitas_de_pao/utils/screen.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';

class DicasCulinariasPage extends StatefulWidget {
  void Function() onNovaReceitaPressed;
  DicasCulinariasPage({this.onNovaReceitaPressed});
  @override
  State<DicasCulinariasPage> createState() => _DicasCulinariasPageState();
}

class _DicasCulinariasPageState extends State<DicasCulinariasPage> {
  List<String> dicas;
  String dica;
  AdsCubit _adsCubit;
  BannerAd banner;
  Palete palete = Palete();
  PremiumCubit _premiumCubit;

  @override
  void initState() {
    super.initState();
    _adsCubit = context.read<AdsCubit>();
    //_premiumCubit = context.read<PremiumCubit>();
    dicas = DicasCulinarias().create();
    _fetchDica();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadBanner();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildNewAppBar(),
        MyNavBar(),
        Expanded(child: _cardDica()),
        //_banner()
      ],
    );
  }

  // _banner() {
  //   if (_premiumCubit.isPremiumMode()) {
  //     return Container();
  //   }
  //   return BannerWidget(
  //     banner: banner,
  //   );
  // }

  _buildNewAppBar() {
    return NewAppBar(
      showSearchBar: true,
      onSearch: (value) {
        NavKeys.initialPage.currentState
            .pushNamed(AppRoutes.searchReceitasPage);
      },
      onNovaReceitaPressed: () {
        widget.onNovaReceitaPressed.call();
      },
    );
  }

  _cardDica() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.pink[900]),
                color: Colors.pink[100],
              ),
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 5,
                    color: palete.DARK_PINK,
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.all(25),
                              child: Text(
                                '"$dica"',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.pink[900],
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 5,
                    color: palete.DARK_PINK,
                  ),
                ],
              ),
            ),
          ),
          _btnNovaDica()
        ],
      ),
    );
  }

  _btnNovaDica() {
    return Container(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _fetchDica();
          });
        },
        child: Container(
          padding: EdgeInsets.all(10),
          color: Colors.purple[900],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nova Dica',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.tips_and_updates,
                color: Colors.orange[300],
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _fetchDica() {
    dica = _sortearDica();
  }

  _sortearDica() {
    int max = dicas.length - 1;
    int min = 0;

    int position = random(min, max);
    return dicas.elementAt(position);
  }

  int random(min, max) {
    return min + Random().nextInt(max - min);
  }

  Future<void> _loadBanner() async {
    if (_premiumCubit.isPremiumMode()) {
      return Container();
    }
    AdSize size = await AdUtils.getAdaptativeSize(context);
    AdState adState = Provider.of<AdState>(context, listen: false);
    adState.initialization.then((value) => {
          setState(() {
            banner = BannerAd(
                adUnitId: MyAds.dicasCulinariasBanner,
                size: size,
                request: AdRequest(),
                listener: adState.adListener)
              ..load();
          })
        });
  }
}
