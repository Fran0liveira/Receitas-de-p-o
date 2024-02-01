import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/src/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/banner_widget_novo.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/api/firebase_api.dart';
import 'package:receitas_de_pao/arguments/receita_page_arguments.dart';
import 'package:receitas_de_pao/components/banner_widget.dart';
import 'package:receitas_de_pao/components/default_modal.dart';
import 'package:receitas_de_pao/components/menu_actions.dart';
import 'package:receitas_de_pao/components/modal_menu.dart';
import 'package:receitas_de_pao/components/my_appbar.dart';
import 'package:receitas_de_pao/components/my_nav_bar.dart';
import 'package:receitas_de_pao/components/snack_message.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/repository/firebase_repository.dart';
import 'package:receitas_de_pao/state/auth_state/auth_cubit.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/utils/assets.dart';
import 'package:receitas_de_pao/utils/list_utils.dart';
import 'package:receitas_de_pao/utils/screen.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';

import '../components/new_appbar.dart';
import '../state/ads_state/ads_cubit.dart';
import '../style/palete.dart';

class MinhasReceitasPage extends StatefulWidget {
  void Function() onNovaReceitaPressed;
  void Function(Receita receita) onEditReceitaPressed;
  MinhasReceitasPage({this.onNovaReceitaPressed, this.onEditReceitaPressed});
  @override
  _MinhasReceitasPageState createState() => _MinhasReceitasPageState();
}

class _MinhasReceitasPageState extends State<MinhasReceitasPage> {
  Screen _screen;
  //MyAppBar myAppBar;
  List<Receita> receitas = [];
  SnackMessage _snack;
  StreamController _streamReceitas = StreamController<List<Receita>>();
  AdsCubit _adsCubit;
  //BannerAd banner;
  PremiumCubit _premiumCubit;

  @override
  void initState() {
    super.initState();
    _loadUserRecipes('');
    //myAppBar = _buildAppBar();
    _premiumCubit = context.read<PremiumCubit>();
    _adsCubit = context.read<AdsCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_loadAd();
  }

  _loadUserRecipes(String filter) async {
    AuthCubit _authCubit = context.read<AuthCubit>();
    User user = _authCubit.getUser();
    String userId;
    if (user == null || user.isAnonymous) {
      userId = '';
    } else {
      userId = user.uid;
    }
    List<Receita> receitas =
        await FirebaseRepository.getReceitasUsuario(userId);
    _streamReceitas.add(receitas);
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

  @override
  Widget build(BuildContext context) {
    _screen = Screen(context);
    _snack = SnackMessage(context);
    log('build state');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //myAppBar.buildAppBar(),
        _buildNewAppBar(),
        MyNavBar(),
        Flexible(child: _contentWithBanner())
      ],
    );
  }

  _contentWithBanner() {
    return Column(children: [
      Expanded(
        child: Stack(
          children: [
            _streamBuilder(),
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
      adId: MyAds.minhasReceitasBannerAd,
      background: Colors.pink[900],
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

  _streamBuilder() {
    return StreamBuilder(
      stream: _streamReceitas.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case (ConnectionState.waiting):
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return Center(
                child: Text('Erro!' + snapshot.error.toString()),
              );
            } else {
              return _showReceitas(snapshot.data);
            }
        }
      },
    );
  }

  // FutureBuilder<List<Receita>> _receitasFuture() {
  //   return FutureBuilder(
  //     future: json,
  //     builder: (context, AsyncSnapshot<List<Receita>> snapshot) {
  //       switch (snapshot.connectionState) {
  //         case (ConnectionState.waiting):
  //           return Center(child: CircularProgressIndicator());
  //         default:
  //           if (snapshot.hasError) {
  //             return Center(
  //               child: Text('Erro!' + snapshot.error.toString()),
  //             );
  //           } else {
  //             return _showReceitas(snapshot.data);
  //           }
  //       }
  //     },
  //   );
  // }

  _showReceitas(List<Receita> receitas) {
    if (ListUtils.isNullOrEmpty(receitas)) {
      return _emptyReceitasList();
    } else {
      return _receitasList(receitas);
    }
  }

  // List<Receita> _filterReceitas(List<Receita> receitas, String valueToFilter) {
  //   return receitas.where((receita) {
  //     String nomeReceita =
  //         StringUtils.getEmptyIfNull(receita.nome.toLowerCase().trim());

  //     String busca =
  //         StringUtils.getEmptyIfNull(valueToFilter.toLowerCase().trim());

  //     //nao aplicar filtro se estiver vazio
  //     if (StringUtils.isNullOrEmpty(busca)) {
  //       return true;
  //     }

  //     return nomeReceita.contains(busca);
  //   }).toList();
  // }

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
    return GestureDetector(
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
                  SizedBox(width: 10),
                  GestureDetector(
                    child: Icon(Icons.more_horiz, color: Colors.white),
                    onTapDown: (details) {
                      _showModalEditOrDeleteReceita(receita: receita);
                    },
                  )
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  _showModalEditOrDeleteReceita({Receita receita}) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return DefaultModal(child: _popupMenuReceita(receita: receita));
        });
  }

  _popupMenuReceita({Receita receita}) {
    return ModalMenu(
      title: receita.nome,
      headerColor: Colors.pink[600],
      textColor: Colors.white,
      actions: [
        MenuActions.edit(() {
          log('image receita teste : ${receita.images.length}');
          _editReceita(receita: receita);
        }),
        MenuActions.delete(() {
          _deleteReceita(receita: receita);
        }),
      ],
    );
  }

  _editReceita({Receita receita}) {
    NavKeys.initialPage.currentState
        .pushNamed(AppRoutes.editReceitaPage, arguments: receita);
  }

  _deleteReceita({Receita receita}) async {
    try {
      await FirebaseRepository.deleteReceita(receita);
      Navigator.of(context).pop();
      _loadUserRecipes('');
    } on Exception catch (e) {
      _snack.show('Não foi possível excluir a receita. ${e.toString()}');
    }
  }

  _emptyReceitasList() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Flexible(
                flex: 70,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Você ainda não possui receitas',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Clique abaixo para criar uma nova :)',
                          style: TextStyle(
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          widget.onNovaReceitaPressed.call();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle,
                                color: Colors.pink[900],
                                size: 30,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Nova receita',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.pink[900],
                                  )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
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
  //               adUnitId: MyAds.minhasReceitasBannerAd,
  //               size: size,
  //               request: AdRequest(),
  //               listener: adState.adListener)
  //             ..load();
  //         })
  //       });
  // }
}
