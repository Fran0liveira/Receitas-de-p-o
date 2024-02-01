import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/banner_widget_novo.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/arguments/receita_page_arguments.dart';
import 'package:receitas_de_pao/components/banner_widget.dart';
import 'package:receitas_de_pao/components/my_appbar.dart';
import 'package:receitas_de_pao/components/new_appbar.dart';
import 'package:receitas_de_pao/components/timer_widget.dart';
import 'package:receitas_de_pao/enums/app_categorias.dart';
import 'package:receitas_de_pao/factory/scroll.dart';
import 'package:receitas_de_pao/main.dart';
import 'package:receitas_de_pao/models/menu_tela_option.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/notification/notification_service.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/repository/firebase_repository.dart';
import 'package:receitas_de_pao/scraping/receitas_scraping2.dart';
import 'package:receitas_de_pao/state/ads_state/ads_cubit.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:receitas_de_pao/utils/assets.dart';
import 'package:receitas_de_pao/utils/list_utils.dart';
import 'package:receitas_de_pao/utils/screen.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';

import '../components/my_nav_bar.dart';
import '../scraping/receitas_scraping.dart';
import '../state/auth_state/auth_cubit.dart';

class NewReceitasFeedPage extends StatefulWidget {
  void Function() onNovaReceitaPressed;
  NewReceitasFeedPage({this.onNovaReceitaPressed});
  @override
  _NewReceitasFeedPageState createState() => _NewReceitasFeedPageState();
}

class _NewReceitasFeedPageState extends State<NewReceitasFeedPage> {
  Screen screen;
  StreamController<List<Receita>> _streamReceitas = StreamController();

  //MyAppBar myAppBar;

  AuthCubit _authCubit;
  int indexCategoria = 0;
  AdsCubit _adsCubit;
  ScrollController _scrollControllerReceitas;
  String categoriaReceita;
  List<Receita> receitasExibicao = [];
  bool hasMore = true;
  //BannerAd banner;
  PremiumCubit _premiumCubit;

  AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _premiumCubit = context.read<PremiumCubit>();
    _scrollControllerReceitas = ScrollController();
    _scrollControllerReceitas.addListener(
      () {
        if (_scrollControllerReceitas.position.maxScrollExtent ==
            _scrollControllerReceitas.offset) {
          _fetchReceitas(categoriaReceita);
        }
      },
    );
    _fetchReceitas(CategoriaReceita.TODAS);
    //myAppBar = _buildAppBar();
    _adsCubit = context.read<AdsCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //_loadAd();
  }

  _fetchReceitas(String categoria) async {
    log('fetching receitas');

    int limit = 8;

    List<Receita> receitas = await FirebaseRepository.getReceitasByCategoria(
        categoria, receitasExibicao.length, receitasExibicao.length + limit);

    if (receitas.length < limit) {
      hasMore = false;
    }
    receitasExibicao.addAll(receitas);
    _streamReceitas.add(receitasExibicao);
  }

  // _buildAppBar() {
  //   return MyAppBar(
  //       onNovaReceitaPressed: widget.onNovaReceitaPressed,
  //       onTextChanged: _changes,
  //       setState: setState,
  //       context: context,
  //       showSearchBar: true);
  // }

  _btnFavoritas() {
    return Column(
      children: [
        Flexible(
          child: Icon(
            Icons.favorite_outline,
          ),
        ),
        FittedBox(
          child: Text(
            'Favoritas',
            maxLines: 2,
          ),
        )
      ],
    );
  }

  void _changes(String value) {
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    screen = Screen(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //myAppBar.buildAppBar(),
        _buildNewAppBar(),
        MyNavBar(),
        //_categorias(),
        // ElevatedButton(
        //   child: Text('Web scraping'),
        //   onPressed: () {
        //     _doReceitasScraping();
        //   },
        // ),
        // TimerWidget(
        //   seconds: 60,
        // ),
        Expanded(child: _receitasFuture()),
      ],
    );
  }

  _categorias() {
    List<String> categorias = CategoriaReceita.values;

    //categorias.insert(0, CategoriaReceita.TODAS);
    return Container(
      color: Colors.purple[900],
      width: screen.width,
      child: Row(
        children: [
          Icon(
            Icons.arrow_left,
            color: Colors.white,
          ),
          Flexible(
              child: Container(
            height: 50,
            child: ListView.builder(
              itemCount: categorias.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                int newIndex = index % categorias.length;

                if (index >= categorias.length && newIndex == 0) {
                  return Container();
                }

                String categoria = categorias.elementAt(newIndex);
                return _categoriaViewModel(categoria, newIndex);
              },
            ),
          )),
          Icon(
            Icons.arrow_right,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  _categoriaViewModel(String categoria, int position) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          _onCategoriaClick(categoria, position);
        },
        child: Container(
            decoration: BoxDecoration(
                color: position == indexCategoria
                    ? Colors.pink[600]
                    : Colors.purple[900],
                borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.all(12),
            child: Text(
              CategoriaReceita.getDescricaoExibicao(categoria),
              style: TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  _onCategoriaClick(String categoria, int position) async {
    setState(() {
      receitasExibicao = [];
      categoriaReceita = categoria;
      indexCategoria = position;
      hasMore = true;
    });
    await _fetchReceitas(categoria);
    _scrollToTop();
  }

  _doReceitasScraping() async {
    try {
      log('scraping initialized');
      Receita receita = await ReceitasScraping2().fetchReceita();

      log('scraping receitas : ${receita.toJson()}');

      FirebaseRepository.uploadReceitas([receita]);
    } on Exception catch (e) {
      log('Scraping error: ${e}}');
    }
  }

  _buildNewAppBar() {
    return NewAppBar(
      showSearchBar: true,
      onSearch: (value) {
        _adsCubit.showAd();
        NavKeys.initialPage.currentState
            .pushNamed(AppRoutes.searchReceitasPage);
      },
      onNovaReceitaPressed: () {
        widget.onNovaReceitaPressed.call();
      },
    );
  }

  StreamBuilder<List<Receita>> _receitasFuture() {
    return StreamBuilder(
      stream: _streamReceitas.stream,
      builder: (context, AsyncSnapshot<List<Receita>> snapshot) {
        switch (snapshot.connectionState) {
          case (ConnectionState.waiting):
            Widget widget = Center(child: CircularProgressIndicator());
            return _contentWithBanner(widget);
          default:
            if (snapshot.hasError) {
              log(snapshot.error.toString());
              Widget widget = Center(
                child: Text('Erro!' + snapshot.error.toString()),
              );
              return _contentWithBanner(widget);
            } else {
              Widget widget = _createWidgetReceitas(snapshot.data);
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
      adId: MyAds.feedBannerAd,
      background: Colors.pink[900],
    );
  }

  _createWidgetReceitas(List<Receita> receitas) {
    // String searchText =
    //     StringUtils.getEmptyIfNull(myAppBar.searchBar.controller.text);
    // List<Receita> receitasFiltered = _filterReceitas(receitas, searchText);

    if (ListUtils.isNullOrEmpty(receitas)) {
      return _emptyReceitasList();
    } else {
      return _receitasFeedWidget(receitas);
    }
  }

  _emptyReceitasList() {
    log('Nenhuma receita!!!');
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: Text(
              'Desculpe, nenhuma receita encontrada!',
              style: TextStyle(
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
    );
  }

  void dispose() {
    super.dispose();
    _audioPlayer?.dispose();
  }

  // _imageReceita(Receita receita) {
  //   var images = receita.images;
  //   if (ListUtils.isNullOrEmpty(images)) {
  //     return Container();
  //   }
  //   String url = receita.images.first.url;
  //   log('url: $url');

  //   return Container(
  //     child: Stack(
  //       children: [
  //         Image.network(
  //           'https://s2.glbimg.com/115DQucrWsNOUxf_ncmMUisprZI=/0x0:1080x819/984x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_e84042ef78cb4708aeebdf1c68c6cbd6/internal_photos/bs/2020/w/a/cB6VP5QoOByFKEuCleIQ/jonreceitas-109758346-416338779271002-5424220606850697813-n.jpg',
  //           loadingBuilder: (context, child, progress) {
  //             if (progress == null) {
  //               return child;
  //             }
  //             return Center(
  //                 child: CircularProgressIndicator(
  //                     value: progress.expectedTotalBytes != null
  //                         ? progress.cumulativeBytesLoaded /
  //                             progress.expectedTotalBytes
  //                         : null));
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Widget _bottomActions() {
  //   return Container(
  //     padding: EdgeInsets.all(8),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         Icon(
  //           Icons.comment_outlined,
  //           size: 30,
  //         ),
  //         SizedBox(width: 10),
  //         Icon(
  //           Icons.favorite,
  //           color: Colors.red,
  //           size: 30,
  //         ),
  //         SizedBox(width: 5),
  //         Icon(
  //           Icons.mobile_screen_share,
  //           size: 30,
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Card _cardReceita(Receita receita) {
  //   return Card(
  //     elevation: 50,
  //     child: Column(children: [
  //       _imageReceita(receita),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: Container(
  //                 padding: EdgeInsets.all(14),
  //                 child: Text(
  //                   receita.nome,
  //                   style: TextStyle(fontSize: 20),
  //                 )),
  //           ),
  //           _avaliacao(),
  //         ],
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           _detalhes(),
  //           _bottomActions(),
  //         ],
  //       )
  //     ]),
  //   );
  // }

  // _detalhes() {
  //   return Container(
  //       padding: EdgeInsets.all(8),
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               SizedBox(width: 10),
  //               Icon(
  //                 Icons.fastfood,
  //                 size: 20,
  //               ),
  //               SizedBox(width: 5),
  //               Text('Rende 2 porções'),
  //             ],
  //           ),
  //           Row(
  //             children: [
  //               Icon(
  //                 Icons.timer,
  //                 size: 20,
  //               ),
  //               SizedBox(width: 5),
  //               Text('Leva 5 minutos'),
  //             ],
  //           ),
  //         ],
  //       ));
  // }

  // _avaliacao() {
  //   return Container(
  //     padding: EdgeInsets.all(5),
  //     child: Row(children: [
  //       _starIconFilled(),
  //       _starIconFilled(),
  //       _starIconFilled(),
  //       _starIconFilled(),
  //       _starIconEmpty()
  //     ]),
  //   );
  // }

  _starIconEmpty() {
    return Icon(
      Icons.star_border,
      size: 16,
    );
  }

  _starIconFilled() {
    return Icon(
      Icons.star,
      size: 16,
    );
  }

  // _receitaViewModel(Receita receita) {
  //   return Container(
  //     child: _cardReceita(receita),
  //     color: Colors.red[200],
  //   );
  // }

  _receitasFeedWidget(List<Receita> receitas) {
    if (receitas == null) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(5),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        shrinkWrap: true,
        controller: _scrollControllerReceitas,
        physics: ClampingScrollPhysics(),
        itemCount: receitas.length + 1,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          if (index < receitas.length) {
            var receita = receitas[index];
            return _receitaViewModel(receita);
          } else {
            return hasMore
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Container();
          }
        },
      ),
    );
  }

  _scrollToTop() async {
    await Scroll(_scrollControllerReceitas).jumpToTop();
    setState(() {});
  }

  _receitaViewModel(Receita receita) {
    return GestureDetector(
      onTap: () async {
        List<Receita> receitasSemelhantes =
            await FirebaseRepository.getReceitasByCategoria(
                receita.categoria, 0, 50)
              ..shuffle();
        ;
        NavKeys.initialPage.currentState.pushNamed(AppRoutes.receitaPage,
            arguments: ReceitaPageArguments(receitasSemelhantes, receita.id));
        _adsCubit.showAd();
      },
      child: Container(
          width: screen.width / 2,
          child: Column(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: _imageReceita(receita)),
              Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Center(
                    child: Text(
                      receita.nome,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
            ],
          )),
    );
  }

  _imageReceita(Receita receita) {
    List<ImageUploaded> imgs = receita.images;
    if (ListUtils.isNullOrEmpty(imgs)) {
      return Image.asset(MyAssets.IMAGE_ERROR);
    }
    return Container(
      child: Image.network(
        imgs.first.url,
        fit: BoxFit.cover,
        errorBuilder: (context, obj, stk) {
          return Image.asset(MyAssets.IMAGE_ERROR);
        },
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
  //               adUnitId: MyAds.feedBannerAd,
  //               size: size,
  //               request: AdRequest(),
  //               listener: adState.adListener)
  //             ..load();
  //         })
  //       });
  // }
}
