import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/banner_widget_novo.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/arguments/receita_page_arguments.dart';
import 'package:receitas_de_pao/components/banner_widget.dart';
import 'package:receitas_de_pao/repository/preferences_repository.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';

import '../components/my_appbar.dart';
import '../components/my_nav_bar.dart';
import '../components/new_appbar.dart';
import '../routes/app_routes.dart';
import '../keys/nav_keys.dart';
import '../models/my_app/receita.dart';
import '../repository/firebase_repository.dart';
import '../state/ads_state/ads_cubit.dart';
import '../style/palete.dart';
import '../utils/list_utils.dart';
import '../utils/screen.dart';
import '../utils/string_utils.dart';

class ReceitasFavoritasPage extends StatefulWidget {
  void Function() onNovaReceitaPressed;
  void Function(Receita receita) onEditReceitaPressed;
  User user;

  ReceitasFavoritasPage(
      {this.onNovaReceitaPressed, this.onEditReceitaPressed, this.user});

  @override
  State<ReceitasFavoritasPage> createState() => _ReceitasFavoritasPageState();
}

class _ReceitasFavoritasPageState extends State<ReceitasFavoritasPage> {
  // MyAppBar _myAppBar;
  Screen _screen;
  //BannerAd banner;
  PremiumCubit _premiumCubit;

  User get user => widget.user;
  AdsCubit _adsCubit;
  @override
  void initState() {
    super.initState();
    _premiumCubit = context.read<PremiumCubit>();
    _adsCubit = context.read<AdsCubit>();
    // _myAppBar = _buildAppBar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _loadAd();
  }

  @override
  Widget build(BuildContext context) {
    _screen = Screen(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNewAppBar(),
        MyNavBar(),
        Expanded(child: _receitasFuture()),
      ],
    );
  }

  _receitasFuture() {
    return FutureBuilder(
      future: _getReceitasFavoritas(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case (ConnectionState.waiting):
            Widget widget = Center(child: CircularProgressIndicator());
            return _contentWithBanner(widget);
          default:
            if (snapshot.hasError) {
              Widget widget = Center(
                child: Text('Erro!' + snapshot.error.toString()),
              );
              return _contentWithBanner(widget);
            } else {
              Widget widget = _showReceitas(snapshot.data);
              return _contentWithBanner(widget);
            }
        }
      },
    );
  }

  _contentWithBanner(Widget content) {
    return Column(children: [
      Expanded(
        child: Stack(
          children: [
            content,
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(20),
                child: FloatingActionButton(
                  child: Icon(
                    Icons.shopping_cart,
                    size: 30,
                  ),
                  backgroundColor: Palete().PINK_700,
                  onPressed: () {
                    _adsCubit.showAd();
                    NavKeys.initialPage.currentState
                        .pushNamed(AppRoutes.listaComprasPage);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      _banner(),
    ]);
  }

  _banner() {
    if (_premiumCubit.isPremiumMode()) {
      return Container();
    }
    return BannerWidgetNovo(
      adId: MyAds.receitasFavoritasBannerAd,
      background: Colors.pink[900],
    );
  }

  Future<List<Receita>> _getReceitasFavoritas() async {
    return FirebaseRepository.fetchReceitasFavoritas(userId: user.uid);
  }

  _showReceitas(List<Receita> receitas) {
    if (ListUtils.isNullOrEmpty(receitas)) {
      return _emptyReceitasList();
    } else {
      return _receitasList(receitas);
    }
  }

  _receitasList(List<Receita> receitas) {
    return ListView.builder(
        itemCount: receitas.length,
        shrinkWrap: true,
        itemBuilder: (context, positionReceita) {
          var receita = receitas.elementAt(positionReceita);
          return _receitaViewModel(receita: receita);
        });
  }

  _receitaViewModel({Receita receita}) {
    return Flexible(
      child: GestureDetector(
        onTap: () async {
          List<Receita> receitasSemelhantes =
              await FirebaseRepository.getReceitasByCategoria(
                  receita.categoria, 0, 50)
                ..shuffle();
          NavKeys.initialPage.currentState.pushNamed(AppRoutes.receitaPage,
              arguments: ReceitaPageArguments(receitasSemelhantes, receita.id));

          _adsCubit.showAd();
        },
        child: Container(
          width: _screen.width,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            color: Palete().DARK_PINK,
          ),
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 30,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      receita.images.first.url,
                      fit: BoxFit.cover,
                    )),
              ),
              SizedBox(width: 10),
              Flexible(
                flex: 70,
                child: Container(
                    child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        receita.nome,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
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

  List<Receita> _filterReceitas(List<Receita> receitas, String valueToFilter) {
    return receitas.where((receita) {
      String nomeReceita =
          StringUtils.getEmptyIfNull(receita.nome.toLowerCase().trim());

      String busca =
          StringUtils.getEmptyIfNull(valueToFilter.toLowerCase().trim());

      //nao aplicar filtro se estiver vazio
      if (StringUtils.isNullOrEmpty(busca)) {
        return true;
      }

      return nomeReceita.contains(busca);
    }).toList();
  }

  _emptyReceitasList() {
    return Center(
      child: Text(
        'Você ainda não possui nenhuma receita favorita!',
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }

  _buildAppBar() {
    return MyAppBar(
        onNovaReceitaPressed: widget.onNovaReceitaPressed,
        onTextChanged: _changes,
        setState: setState,
        context: context,
        showSearchBar: true);
  }

  void _changes(String value) {
    setState(() {});
  }

  // Future<void> _loadAd() async {
  //   if (_premiumCubit.isPremiumMode()) {
  //     return;
  //   }
  //   AdSize size = await AdUtils.getAdaptativeSize(context);
  //   AdState adState = Provider.of<AdState>(context, listen: false);
  //   adState.initialization.then((value) => {
  //         setState(() {
  //           banner = BannerAd(
  //               adUnitId: MyAds.receitasFavoritasBannerAd,
  //               size: size,
  //               request: AdRequest(),
  //               listener: adState.adListener)
  //             ..load();
  //         })
  //       });
  // }
}
