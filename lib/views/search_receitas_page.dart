import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/banner_widget_novo.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/arguments/receita_page_arguments.dart';
import 'package:receitas_de_pao/components/banner_widget.dart';
import 'package:receitas_de_pao/components/circular_border_radius.dart';
import 'package:receitas_de_pao/components/new_appbar.dart';
import 'package:receitas_de_pao/components/rounded.dart';
import 'package:receitas_de_pao/components/snack_message.dart';
import 'package:receitas_de_pao/factory/choice_chips_factory.dart';
import 'package:receitas_de_pao/models/my_app/choice_chip_model.dart';
import 'package:receitas_de_pao/models/my_app/filter_receitas.dart';
import 'package:receitas_de_pao/repository/firebase_repository.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/views/modal/modal_fale_conosco.dart';

import '../components/app_textfield.dart';
import '../routes/app_routes.dart';
import '../keys/nav_keys.dart';
import '../models/my_app/receita.dart';
import '../state/ads_state/ads_cubit.dart';
import '../style/palete.dart';
import '../utils/list_utils.dart';
import '../utils/screen.dart';
import '../utils/string_utils.dart';

class SearchReceitasPage extends StatefulWidget {
  SearchReceitasPage();
  @override
  State<SearchReceitasPage> createState() => _SearchReceitasPageState();
}

class _SearchReceitasPageState extends State<SearchReceitasPage> {
  TextEditingController _searchController = TextEditingController();
  List<ChoiceChipModel> _choiceChips;
  StreamController _streamReceitas = StreamController<List<Receita>>();
  Screen _screen;
  StreamBuilder _receitaStream;
  AdsCubit _adsCubit;
  //BannerAd banner;
  PremiumCubit _premiumCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_loadAd();
  }

  @override
  void initState() {
    super.initState();
    _adsCubit = context.read<AdsCubit>();
    _premiumCubit = context.read<PremiumCubit>();
    _choiceChips = ChoiceChipsFactory().create();
    _initReceitasStream();
    _cleanReceitas();
  }

  _cleanReceitas() {
    List<Receita> emptyReceitas = [];
    _streamReceitas.add(emptyReceitas);
  }

  @override
  Widget build(BuildContext context) {
    _screen = Screen(context);
    return WillPopScope(
      onWillPop: _backPage,
      child: Scaffold(
          body: SafeArea(
        child: Container(
          height: _screen.height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                color: Colors.pink[600],
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _backIcon(),
                          Row(
                            children: [
                              Icon(Icons.search, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Buscar receitas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ]),
              ),
              Container(
                  padding: EdgeInsets.all(12),
                  child: _searchBar(),
                  color: Colors.pink[900]),
              Expanded(child: _receitaStream),
            ],
          ),
        ),
      )),
    );
  }

  _searchBar() {
    return Container(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppTextField(
                  onChanged: (value) {
                    _buscarReceitas();
                  },
                  required: true,
                  hint: 'Que receita está a buscar?',
                  controller: _searchController,
                ),
              ),
              _btnPesquisa()
            ],
          ),
        ],
      ),
    );
  }

  _btnPesquisa() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
          color: Colors.purple[900],
          borderRadius: BorderRadius.all(Radius.circular(8))),
      padding: EdgeInsets.all(12),
      child: Icon(
        Icons.search,
        color: Colors.white,
      ),
    );
  }

  // _filtros() {
  //   return Wrap(
  //     children: [..._choiceChips.map((e) => _choiceChip(e)).toList()],
  //   );
  // }

  _initReceitasStream() {
    _receitaStream = StreamBuilder(
      stream: _streamReceitas.stream,
      builder: ((context, snapshot) {
        log('reloading stream');
        ConnectionState connectionState = snapshot.connectionState;
        if (connectionState == null ||
            connectionState == ConnectionState.waiting ||
            connectionState == ConnectionState.none) {
          Widget widget = Center(child: CircularProgressIndicator());
          return _contentWithBanner(widget);
        } else if (snapshot.hasError) {
          Widget widget = Center(
            child: Text('Erro ao buscar receitas! Tente novamente mais tarde!'),
          );
          return _contentWithBanner(widget);
        } else {
          Widget widget = _receitasWidget(snapshot.data);
          return _contentWithBanner(widget);
        }
      }),
    );
  }

  _contentWithBanner(Widget content) {
    return Column(children: [Expanded(child: content), _banner()]);
  }

  _banner() {
    if (_premiumCubit.isPremiumMode()) {
      return Container();
    }
    return BannerWidgetNovo(
      adId: MyAds.searchReceitasAd,
      background: Colors.pink[900],
    );
  }

  _receitasWidget(List<Receita> receitas) {
    String search = _searchController.text;

    if (StringUtils.isNullOrEmpty(search)) {
      return _initialSearchWidget();
    } else if (ListUtils.isNullOrEmpty(receitas)) {
      return _emptyReceitasList();
    } else {
      return _receitasList(receitas);
    }
  }

  _initialSearchWidget() {
    return Container(
      padding: EdgeInsets.all(14),
      child: Text(
        'Pesquisa pelo nome da receita :)',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  _emptyReceitasList() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 12, left: 18),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        'Nenhuma receita encontrada!',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            _showModalSugestoes();
          },
          child: Container(
            padding: EdgeInsets.only(top: 8, left: 18),
            child: Row(
              children: [
                Text(
                  'Clique aqui ',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Palete().DARK_PINK,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'para pedir sua receita',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Palete().DARK_PINK,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  _showModalSugestoes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: DraggableScrollableSheet(
            initialChildSize: 1,
            minChildSize: 0.5,
            maxChildSize: 1,
            builder: (_, scrollController) {
              return Rounded(
                radius: CircularBorderRadius.onlyTop(15),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    top: 20,
                    right: 20,
                    left: 20,
                    bottom: 20,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: ModalFaleConosco(
                      onComplete: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  _receitasList(List<Receita> receitas) {
    return SingleChildScrollView(
      child: Card(
        elevation: 10,
        color: Colors.red[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: receitas.length,
                  itemBuilder: (context, position) {
                    Receita receita = receitas.elementAt(position);
                    return _receitaViewModel(receita: receita);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  _buscarReceitas() async {
    log('query receitas');
    String search = _searchController.text;
    if (StringUtils.isNullOrEmpty(search)) {
      _cleanReceitas();
      return;
    }

    FilterReceitas filter = FilterReceitas(descricao: search);
    List<Receita> receitas =
        await FirebaseRepository.filterReceitas(filterReceitas: filter);
    _streamReceitas.add(receitas);
  }

  _choiceChip(ChoiceChipModel choiceChipModel) {
    bool selected = choiceChipModel.selected;
    String descricao = choiceChipModel.descricao;
    return Container(
      padding: EdgeInsets.only(top: 5, right: 5, left: 5),
      child: ChoiceChip(
        selectedColor: Colors.pink,
        disabledColor: Colors.black,
        label: Text(
          descricao,
          style: TextStyle(fontSize: 16),
        ),
        selected: selected,
        labelStyle: selected
            ? TextStyle(color: Colors.white)
            : TextStyle(color: Colors.black),
        onSelected: (value) {},
      ),
    );
  }

  _receitaViewModel({Receita receita}) {
    return GestureDetector(
      onTap: () async {
        _adsCubit.showAd();

        List<Receita> receitasSemelhantes =
            await FirebaseRepository.getReceitasByCategoria(
                receita.categoria, 0, 50)
              ..shuffle();
        NavKeys.initialPage.currentState.pushNamed(AppRoutes.receitaPage,
            arguments: ReceitaPageArguments(receitasSemelhantes, receita.id));
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
    );
  }

  _backIcon() {
    return InkWell(
      onTap: () {
        _backPage();
      },
      child: Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
    );
  }

  Future<bool> _backPage() async {
    _adsCubit.showAd();
    Navigator.of(context).pop();
    return false;
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
  //               adUnitId: MyAds.searchReceitasAd,
  //               size: size,
  //               request: AdRequest(),
  //               listener: adState.adListener)
  //             ..load();
  //         })
  //       });
  // }
}
