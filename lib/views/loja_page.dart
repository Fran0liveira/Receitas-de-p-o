import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/banner_widget_novo.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/components/banner_widget.dart';
import 'package:receitas_de_pao/components/btn_premium.dart';
import 'package:receitas_de_pao/components/my_nav_bar.dart';
import 'package:receitas_de_pao/components/new_appbar.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';
import 'package:receitas_de_pao/models/my_app/direct_link.dart';
import 'package:receitas_de_pao/models/produto_afiliado.dart';
import 'package:receitas_de_pao/afiliados/produtos_afiliados_repository.dart';
import 'package:receitas_de_pao/repository/preferences_repository.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/state/ads_state/ads_cubit.dart';
import 'package:receitas_de_pao/state/nav_bar_state/nav_bar_cubit.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:receitas_de_pao/utils/assets.dart';
import 'package:receitas_de_pao/utils/screen.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';
import 'package:receitas_de_pao/views/produto_afiliado_details_page.dart';
import 'package:receitas_de_pao/views/web_view_afiliado_layout.dart';
import 'package:receitas_de_pao/views/web_view_afiliado_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LojaPage extends StatefulWidget {
  void Function() onNovaReceitaPressed;
  LojaPage({this.onNovaReceitaPressed});

  @override
  State<LojaPage> createState() => _LojaPageState();
}

class _LojaPageState extends State<LojaPage> {
  // BannerAd _banner;
  // Screen _screen;
  // AdsCubit _adsCubit;
  PremiumCubit _premiumCubit;
  Palete _palete;

  @override
  void initState() {
    super.initState();
    // _screen = Screen(context);
    // _adsCubit = context.read<AdsCubit>();
    _premiumCubit = context.read<PremiumCubit>();
    _palete = Palete();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_loadBanner();
  }

  Future<int> _initTimer() async {
    log('init total time');
    String time = await PreferencesRepository.getInitTimePromocional();
    if (StringUtils.isNullOrEmpty(time)) {
      await PreferencesRepository.setUrlPromocional(
          await ProdsAfiliadosRepository.getNextPromocional());
      await PreferencesRepository.setInitTimePromocional(
          DateTime.now().toString());
    }

    String initTime = await PreferencesRepository.getInitTimePromocional();
    log('total time 1 is $initTime');
    DateTime initDateTime = DateTime.parse(initTime);

    log('total time 2 is $initTime');

    Duration passedTime = DateTime.now().difference(initDateTime);

    Duration originalDuration = Duration(hours: 12);
    Duration remainingTime = originalDuration - passedTime;

    if (remainingTime.inMilliseconds <= 0) {
      PreferencesRepository.setUrlPromocional(
          await ProdsAfiliadosRepository.getNextPromocional());
      PreferencesRepository.setInitTimePromocional(DateTime.now().toString());
      remainingTime = originalDuration;
    }

    return DateTime.now().millisecondsSinceEpoch + remainingTime.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _palete.RED_50,
      child: Column(
        children: [
          _buildNewAppBar(),
          MyNavBar(),
          Expanded(child: _content()),
          //_bannerWidget()
        ],
      ),
    );
  }

  _bannerWidget() {
    if (_premiumCubit.isPremiumMode()) {
      return Container();
    }
    return BannerWidgetNovo(
      adId: MyAds.lojaAfiliadosBanner,
    );
  }

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

  _afiliadosSection() {
    List<ProdAfiliado> prodsAfiliados =
        ProdsAfiliadosRepository.createProdutos();

    return ExpansionTile(
      iconColor: Palete().DARK_PINK,
      title: Text(
        'Cursos e Ebooks',
        style: TextStyle(
            fontSize: 18,
            color: Palete().DARK_PINK,
            fontWeight: FontWeight.bold),
      ),
      children: [
        Container(
          color: Palete().RED_50,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              Container(
                width: Screen.of(context).width,
                height: Screen.of(context).height * 0.3,
                child: Row(
                  children: [
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index) {
                          int newIndex = index % prodsAfiliados.length;
                          ProdAfiliado afiliado =
                              prodsAfiliados.elementAt(newIndex);
                          return _afiliadoViewModel(afiliado);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _afiliadoViewModel(ProdAfiliado prodAfiliado) {
    double width = Screen.of(context).width / 2;
    return Container(
      padding: EdgeInsets.all(2.5),
      width: width,
      child: GestureDetector(
        onTap: () async {
          Navigator.of(context).pushNamed(
            AppRoutes.webViewAfiliadoPage,
            arguments: DirectLink(
              url: prodAfiliado.vendasUrl,
              produto: prodAfiliado,
            ),
          );
        },
        child: Column(
          children: [
            Flexible(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    prodAfiliado.imgSrc,
                    width: width,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, obj, stk) {
                      return Image.asset(MyAssets.IMAGE_ERROR);
                    },
                  )),
            ),
            Center(
              child: Text(
                prodAfiliado.descricao,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  _timerSection(Map<String, dynamic> map) {
    return Container(
      color: Colors.pink[900],
      child: CountdownTimer(
        endTime: map['endTime'],
        textStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        onEnd: () async {
          // O que fazer quando o contador regressivo chegar a zero
          print('Contador regressivo concluído!');
        },
        widgetBuilder: (_, CurrentRemainingTime time) {
          // Formate o tempo restante para exibir horas, minutos e segundos
          return Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Oferta por tempo limitado!',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Palete().RED_50),
                    ),
                  ],
                ),
                _textTimer(time)
              ],
            ),
          );
        },
      ),
    );
  }

  _textTimer(CurrentRemainingTime time) {
    if (time == null) {
      return Container();
    }
    return Text(
      '''${time.hours != null ? '${time.hours}h : ' : ''}${time.min != null ? '${time.min}min : ' : ''}${time.sec != null ? '${time.sec}s' : ''}''',
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Palete().WHITE),
    );
  }

  Future<Map<String, dynamic>> _streamWebView() async {
    int endTime = await _initTimer();

    String urlPromocional = await PreferencesRepository.getUrlPromocional();
    if (StringUtils.isNullOrEmpty(urlPromocional)) {
      urlPromocional = await ProdsAfiliadosRepository.getNextPromocional();
      await PreferencesRepository.setUrlPromocional(urlPromocional);
    }

    return {
      'endTime': endTime,
      'urlPromocional': urlPromocional,
    };
  }

  _content() {
    List<ProdAfiliado> prodsAfiliados =
        ProdsAfiliadosRepository.createProdutos();
    return Column(
      children: [
        //_headerParceiros(),
        //_afiliadosSection(),

        Flexible(
          child: Container(
              height: Screen.of(context).height,
              child: StreamBuilder<Map<String, dynamic>>(
                stream: _streamWebView().asStream(),
                builder: (context, snapshot) {
                  ConnectionState connectionState = snapshot.connectionState;
                  if (connectionState == null ||
                      connectionState == ConnectionState.none ||
                      connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == null) {
                    return Container();
                  }
                  return Column(
                    children: [
                      _timerSection(snapshot.data),
                      Flexible(
                        child: WebViewAfiliadoLayout(
                          directLink: DirectLink(
                              produto: prodsAfiliados.first,
                              url: snapshot.data['urlPromocional']),
                          controller: Completer<WebViewController>(),
                        ),
                      ),
                    ],
                  );
                },
              )),
        ),

        // Container(
        //   padding: EdgeInsets.all(8),
        //   child: GridView.builder(
        //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //           crossAxisCount: 2,
        //           mainAxisSpacing: 10,
        //           crossAxisSpacing: 10,
        //           childAspectRatio: 0.9),
        //       physics: NeverScrollableScrollPhysics(),
        //       itemCount: prodsAfiliados.length,
        //       shrinkWrap: true,
        //       itemBuilder: (_, position) {
        //         ProdAfiliado afiliado = prodsAfiliados.elementAt(position);
        //         return _prodAfiliadoViewModel(afiliado);
        //       }),
        // ),
      ],
    );
  }

  _headerParceiros() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Palete().DARK_PINK,
      child: Row(
        children: [
          Flexible(
            flex: 80,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Mude sua vida com...',
                          style: TextStyle(
                            color: Palete().RED_700,
                            fontSize: 18,
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: Palete().RED_100,
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text('Promoções Do Chef! ',
                            style: TextStyle(
                              color: Palete().RED_100,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                  Container(
                    height: 5,
                  ),
                  Text(
                      'Os melhores produtos culinários para você aproveitar... 🤩',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: _palete.WHITE,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(MyAssets.COOKER),
            ),
          )
        ],
      ),
    );
  }

  _prodAfiliadoViewModel(ProdAfiliado prodAfiliado) {
    return Column(children: [
      Flexible(child: _imageWidget(prodAfiliado)),
    ]);
  }

  _imageWidget(ProdAfiliado prodAfiliado) {
    return Card(
      elevation: 10,
      child: GestureDetector(
        child: Image.asset(
          prodAfiliado.imgSrc,
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.webViewAfiliadoPage,
            arguments: DirectLink(
              url: prodAfiliado.vendasUrl,
              produto: prodAfiliado,
            ),
          );
        },
      ),
    );
  }

  // Future<void> _loadBanner() async {
  //   if (_premiumCubit.isPremiumMode()) {
  //     return;
  //   }
  //   AdSize size = await AdUtils.getAdaptativeSize(context);
  //   AdState adState = Provider.of<AdState>(context, listen: false);
  //   adState.initialization.then((value) => {
  //         setState(() {
  //           _banner = BannerAd(
  //               adUnitId: MyAds.lojaAfiliadosBanner,
  //               size: size,
  //               request: AdRequest(),
  //               listener: adState.adListener)
  //             ..load();
  //         })
  //       });
  // }
}
