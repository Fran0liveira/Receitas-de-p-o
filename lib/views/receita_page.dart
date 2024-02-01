import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/banner_widget_novo.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/afiliados/produtos_afiliados_repository.dart';
import 'package:receitas_de_pao/afiliados_amazon/afiliados_amazon_repository.dart';
import 'package:receitas_de_pao/arguments/receita_page_arguments.dart';
import 'package:receitas_de_pao/components/app_textfield.dart';
import 'package:receitas_de_pao/components/banner_widget.dart';
import 'package:receitas_de_pao/components/circular_border_radius.dart';
import 'package:receitas_de_pao/components/rounded.dart';
import 'package:receitas_de_pao/components/snack_message.dart';
import 'package:receitas_de_pao/components/timer_widget.dart';
import 'package:receitas_de_pao/db/app_db.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';
import 'package:receitas_de_pao/models/my_app/avaliacao.dart';
import 'package:receitas_de_pao/models/my_app/avaliacoes.dart';
import 'package:receitas_de_pao/models/my_app/direct_link.dart';
import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/models/my_app/ingrediente.dart';
import 'package:receitas_de_pao/models/my_app/item_compra.dart';
import 'package:receitas_de_pao/models/my_app/lista_compras.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/models/my_app/secao_receita.dart';
import 'package:receitas_de_pao/models/my_app/user_chef.dart';
import 'package:receitas_de_pao/models/produto_afiliado.dart';
import 'package:receitas_de_pao/repository/firebase_repository.dart';
import 'package:receitas_de_pao/services/detalhes_check.dart';
import 'package:receitas_de_pao/services/pdf_service.dart';
import 'package:receitas_de_pao/services/receita_pdf.dart';
import 'package:receitas_de_pao/services/share_service.dart';
import 'package:receitas_de_pao/services/tempo_preparo_check.dart';
import 'package:receitas_de_pao/state/carousel_state/carousel_cubit.dart';
import 'package:receitas_de_pao/state/lista_compras_state/lista_compras_cubit.dart';
import 'package:receitas_de_pao/state/nav_bar_state/nav_bar_cubit.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/state/timer_state/timer_cubit.dart';
import 'package:receitas_de_pao/state/timer_state/timer_state.dart';
import 'package:receitas_de_pao/utils/duration_utils.dart';
import 'package:receitas_de_pao/utils/list_utils.dart';
import 'package:receitas_de_pao/utils/screen.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';
import 'package:receitas_de_pao/views/modal/modal_premium_plans.dart';
import 'package:receitas_de_pao/views/modal/modal_premium_plans.dart';
import 'package:receitas_de_pao/views/modal/modals_premium_benefits.dart';
import 'package:receitas_de_pao/views/video_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../components/dialog_login.dart';
import '../models/my_app/comentario.dart';
import '../repository/preferences_repository.dart';
import '../routes/app_routes.dart';
import '../state/ads_state/ads_cubit.dart';
import '../state/auth_state/auth_cubit.dart';
import '../state/carousel_state/carousel_state.dart';
import '../style/palete.dart';
import '../utils/assets.dart';
import '../utils/dialogs.dart';
import '../utils/keyboard.dart';

class ReceitaPage extends StatefulWidget {
  ReceitaPageArguments receitaArguments;

  ReceitaPage(this.receitaArguments);

  @override
  _ReceitaPageState createState() => _ReceitaPageState();
}

class _ReceitaPageState extends State<ReceitaPage> {
  Screen screen;
  // InterstitialAd _interstitialAd;
  // int _interstitialLoadAttempts = 0;
  // int _maxFailedLoadAttempts = 3;
  Receita _receita = Receita.empty();
  var _controllerComentario = TextEditingController();
  //BannerAd banner;

  double nota;
  SnackMessage _snack;
  StreamController<Avaliacoes> _streamAvaliacoes = StreamController();
  StreamController<bool> _streamFavorito = StreamController();
  StreamController<int> _streamNumberOfFavorites = StreamController();
  AuthCubit _authCubit;
  UserChef _userChef;
  Palete palete = Palete();
  CarouselController _carouselController = CarouselController();
  FutureBuilder _futureReceita;
  CarouselCubit _carouselCubit;
  AdsCubit _adsCubit;
  ListaComprasCubit _listaComprasCubit;
  PremiumCubit _premiumCubit;
  TimerCubit _timerCubit;
  StreamController _esconderPromocoes = StreamController.broadcast();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_loadAd();
  }

  String getIdReceita() {
    String idReceita = widget.receitaArguments.idReceita;
    if (!StringUtils.isNullOrEmpty(idReceita)) {
      return idReceita;
    } else if (_receita != null && !StringUtils.isNullOrEmpty(_receita.id)) {
      return _receita.id;
    }
  }

  _showModal() async {
    int counterProdutoReceita =
        await PreferencesRepository.getCounterProdutoReceita();
    bool esconderPromocoes = await PreferencesRepository.getEsconderPromocoes();

    bool show = !esconderPromocoes &&
        (counterProdutoReceita == 1 || counterProdutoReceita % 10 == 0);
    log('counter $counterProdutoReceita');
    ++counterProdutoReceita;
    await PreferencesRepository.setCounterProdutoReceita(counterProdutoReceita);

    if (!show) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Palete().RED_100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (widget) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Rounded(
                radius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: Container(
                  padding: EdgeInsets.all(15),
                  color: Palete().PINK_700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.new_releases, color: Palete().WHITE),
                      Icon(Icons.new_releases, color: Palete().WHITE),
                      Text(
                        '😱 SUPER PROMOÇÃO! 😱',
                        style: TextStyle(
                            fontSize: 20,
                            color: Palete().WHITE,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.new_releases, color: Palete().WHITE),
                      Icon(Icons.new_releases, color: Palete().WHITE),
                    ],
                  ),
                ),
              ),
              StreamBuilder(
                stream:
                    ProdsAfiliadosRepository.getNextProdutoReceita().asStream(),
                builder: (context, snapshot) {
                  ConnectionState state = snapshot.connectionState;
                  log('snapshot test: $state');
                  if (state == null ||
                      state == ConnectionState.waiting ||
                      state == ConnectionState.none) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return _afiliadoViewModel2(snapshot.data);
                },
              ),
            ],
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.red[900],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _premiumCubit = context.read<PremiumCubit>();
    _authCubit = context.read<AuthCubit>();
    _carouselCubit = context.read<CarouselCubit>();
    _listaComprasCubit = context.read<ListaComprasCubit>();
    _adsCubit = context.read<AdsCubit>();
    _snack = SnackMessage(context);
    _timerCubit = context.read<TimerCubit>();

    //_createInterstitialAd();
    _createFutureReceita();

    _showModal();
  }

  _loadAvaliacoes(String idReceita) async {
    Avaliacoes avaliacoes =
        await FirebaseRepository.getAvaliacoes(idReceita: idReceita);
    _streamAvaliacoes.add(avaliacoes);
  }

  _loadFavorito() async {
    User user = _authCubit.getUser();
    _fetchFavoritoFromFirebase(user);
  }

  _fetchFavoritoFromFirebase(User user) async {
    bool favorite = await FirebaseRepository.isFavorite(
        idReceita: getIdReceita(), userId: user.uid);
    _streamFavorito.add(favorite);
  }

  @override
  Widget build(BuildContext context) {
    screen = Screen(context);
    return Center(
      child: Scaffold(
        appBar: _appBar(),
        body: _content(),
      ),
    );
  }

  _fetchAllData() async {
    String idReceita = getIdReceita();
    _receita = await FirebaseRepository.getReceitaById(idReceita: idReceita);
    _userChef = await FirebaseRepository.getUserChef(id: _receita.userId);
    _loadFavorito();
    _updateNumberOfFavorites(idReceita);
  }

  _createFutureReceita() {
    _futureReceita = FutureBuilder(
      future: _fetchAllData(),
      builder: ((context, snapshot) {
        switch (snapshot.connectionState) {
          case (ConnectionState.waiting):
            Widget widget = Center(
              child: CircularProgressIndicator(),
            );
            return _contentWithBanner(widget);
          default:
            if (snapshot.hasError) {
              Widget widget = _contentReceitaErro(snapshot.error.toString());
              return _contentWithBanner(widget);
            } else {
              Widget widget = _contentReceita();
              return _contentWithBanner(widget);
            }
        }
      }),
    );
  }

  _content() {
    return _futureReceita;
  }

  _contentReceitaErro(String message) {
    log('Erro ao visualizar receita! Message: $message');
    return Center(
      child: Text(
        'Erro ao visualizar receita! Tente novamente mais tarde!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  _contentReceita() {
    return SingleChildScrollView(
      child: Card(
        elevation: 50,
        child: Column(children: [
          _imageReceita(),
          _nomeReceitaSection(),
          _detalhesSection(),
          _numberOfFavoritesSection(),
          _secoesSection(),
          _extraInfoSection(),
          _optionsSection(),
          _usuarioSection(),
          _receitasSemelhantesSection(),

          _afiliadosSection()
          //_comentariosSection()
        ]),
      ),
    );
  }

  _afiliadosSection() {
    List<ProdAfiliado> prodsAfiliados =
        AfiliadosAmazonRepository.createProdutos();

    return Container(
      color: Palete().RED_50,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          Text(
            'Do app para sua cozinha! 🤩',
            style: TextStyle(
                fontSize: 18,
                color: Palete().DARK_PINK,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
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
    );
  }

  _receitasSemelhantesSection() {
    List<Receita> receitasSemelhantes = widget
        .receitaArguments.receitasSemelhantes
        .where((element) => element.id != _receita.id)
        .toList();

    if (ListUtils.isNullOrEmpty(receitasSemelhantes)) {
      return Container();
    }

    return Container(
      color: Palete().RED_50,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          Text(
            'Você também pode gostar 🤩',
            style: TextStyle(
                fontSize: 18,
                color: Palete().DARK_PINK,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: Screen.of(context).width,
            height: Screen.of(context).height * 0.20,
            child: Row(
              children: [
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      int newIndex = index % receitasSemelhantes.length;

                      Receita receita = receitasSemelhantes.elementAt(newIndex);

                      if (receita.id == _receita.id) {
                        return Container();
                      }
                      return _receitaViewModel(receita);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  _afiliadoViewModel2(ProdAfiliado prodAfiliado) {
    double width = Screen.of(context).width;
    return Container(
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
            ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  prodAfiliado.imgSrc,
                  width: width,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, obj, stk) {
                    return Image.asset(MyAssets.IMAGE_ERROR);
                  },
                )),
            Center(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Text(
                  prodAfiliado.descricao,
                  style: TextStyle(
                    fontSize: 26,
                    color: Palete().PINK_700,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Rounded(
              radius: BorderRadius.all(Radius.circular(15)),
              child: TextButton(
                onPressed: null,
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.purple[900])),
                child: Text(
                  'Clique aqui para saber mais...',
                  style: TextStyle(fontSize: 22, color: Palete().WHITE),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flexible(
                  //   child: StreamBuilder(
                  //     stream: _esconderPromocoes.stream,
                  //     initialData: false,
                  //     builder: (context, snapshot) {
                  //       bool esconderPromocoes = snapshot.data;
                  //       return CheckboxListTile(
                  //         value: esconderPromocoes,
                  //         title: Text('Não ver mais promoções'),
                  //         onChanged: (value) async {
                  //           await PreferencesRepository.setEsconderPromocoes(
                  //               value);
                  //           _loadEsconderPromocoes();
                  //         },
                  //         controlAffinity: ListTileControlAffinity.leading,
                  //       );
                  //     },
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () {
                      ShareReceitaService().shareProdutoAfiliado(prodAfiliado);
                    },
                    child: Column(
                      children: [
                        Text(
                          'Compartilhar',
                          style:
                              TextStyle(color: Palete().PINK_700, fontSize: 18),
                        ),
                        Icon(Icons.share, color: Palete().PINK_700),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loadEsconderPromocoes() async {
    bool esconderPromocoes = await PreferencesRepository.getEsconderPromocoes();
    _esconderPromocoes.add(esconderPromocoes);
  }

  _receitaViewModel(Receita receita) {
    double width = Screen.of(context).width / 2;
    return Container(
      padding: EdgeInsets.all(2.5),
      width: width,
      child: GestureDetector(
        onTap: () async {
          List<Receita> receitasSemelhantes =
              await FirebaseRepository.getReceitasByCategoria(
                  receita.categoria, 0, 50)
                ..shuffle();

          _adsCubit.showAd();
          NavKeys.initialPage.currentState.pushNamed(AppRoutes.receitaPage,
              arguments: ReceitaPageArguments(receitasSemelhantes, receita.id));
        },
        child: Column(
          children: [
            Flexible(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    receita.images.first.url,
                    width: width,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, obj, stk) {
                      return Image.asset(MyAssets.IMAGE_ERROR);
                    },
                  )),
            ),
            Center(
              child: Text(
                receita.nome,
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

  _optionsSection() {
    return Container(
      width: screen.width,
      padding: EdgeInsets.all(8),
      child: Wrap(
        children: [
          _listaComprasWidget(),
          TimerWidget(seconds: _receita.tempoPreparo.inSeconds)

          //_btnGerarPdf(),
        ],
      ),
    );
  }

  _btnGerarPdf() {
    return TextButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.picture_as_pdf,
            color: palete.RED_700,
          ),
          SizedBox(width: 5),
          Text(
            'Gerar PDF',
            style: TextStyle(
              color: palete.RED_700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      onPressed: () {
        _generatePdf();
      },
    );
  }

  _listaComprasWidget() {
    return TextButton(
      onPressed: () {
        _showDialogNovaListaCompras();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_rounded,
            color: palete.DARK_PINK,
          ),
          SizedBox(width: 5),
          Text(
            'Criar Lista Compras!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: palete.DARK_PINK,
            ),
          ),
        ],
      ),
    );
  }

  _btnEditarReceita() {
    if (_receita.userId != _getUserId()) {
      return Container();
    }
    return TextButton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit, color: palete.RED_100),
          SizedBox(width: 5),
          Text(
            'Editar\nReceita',
            style:
                TextStyle(color: palete.RED_100, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      onPressed: () {
        Navigator.of(context)
            .pushNamed(AppRoutes.editReceitaPage, arguments: _receita);
      },
    );
  }

  _showDialogNovaListaCompras() {
    var dialog = AlertDialog(
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confirmação',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.pink[900],
                  fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Container(
                height: 30,
                width: 30,
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                    color: Colors.pink[800],
                    borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ],
        ),
      ),
      content: Text(
        'Deseja criar uma Lista de Compras para esta receita?',
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.pink[800])),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_rounded),
              SizedBox(width: 5),
              Text(
                'Voltar',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.pink[800])),
          onPressed: () {
            _adsCubit.showAd();
            _criarListaCompras();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_shopping_cart),
              SizedBox(width: 5),
              Text(
                'Criar Lista!',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => dialog,
    );
    return dialog;
  }

  _criarListaCompras() async {
    List<ItemCompra> itensCompra = _createItensCompra();
    ListaCompras listaCompras = ListaCompras(
        descricao: _receita.nome.trim(),
        updatedDate: DateTime.now(),
        itensCompra: itensCompra,
        idReceita: _receita.id,
        idUsuario: _getUserId());

    await _listaComprasCubit.insertListaComprasWithItens(
        listaCompras, true, _getUserId());

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.of(context).pushNamed(AppRoutes.listaComprasPage);
  }

  _createItensCompra() {
    return _receita.secoes
        .expand((secao) => secao.ingredientes)
        .map((ing) => ItemCompra(descricao: ing.descricao))
        .toList();
  }

  _extraInfoSection() {
    String extraInfo = _receita.extraInfo;
    if (StringUtils.isNullOrEmpty(extraInfo)) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _headerTitle(
            'Informações adicionais',
            color: Colors.red[100],
            textColor: Colors.pink[900],
          ),
          Text(
            extraInfo,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  _appBar() {
    return AppBar(
      title: Text('Vamos preparar...'),
      leading: GestureDetector(
        child: Icon(Icons.arrow_back),
        onTap: () {
          NavigatorState state = NavKeys.initialPage.currentState;
          if (state != null) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.receitasFeedPage, (route) => false);
          } else {
            Navigator.of(context).pop();
          }
          _adsCubit.showAd();
        },
      ),
      backgroundColor: Colors.pink[700],
      actions: _appBarActions(),
    );
  }

  _usuarioSection() {
    if (_userChef == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.pink[900],
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: _enviadaPorLabel(),
            ),
            //Flexible(child: _socialIcons())
          ]),
    );
  }

  _enviadaPorLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: _enviadoPorSection()),
        _btnEditarReceita(),
      ],
    );
  }

  _enviadoPorSection() {
    return Row(
      children: [
        Container(height: screen.height * 0.08, child: _userImage()),
        SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.pink[600],
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Enviada por',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      backgroundColor: Colors.pink[600]),
                ),
              ),
              Container(
                color: Colors.pink[600],
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${_userChef.nome} ${_userChef.sobrenome}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _socialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          child: Column(
            children: [
              FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
              FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  '@fran0liv',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Column(
            children: [
              FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
              FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  '@francisco',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // _userChefWidget() {
  //   if (userChef == null) {
  //     return Container();
  //   }
  //   return Container(
  //     padding: EdgeInsets.all(8),
  //     color: Colors.white,
  //     child: Column(
  //         mainAxisSize: MainAxisSize.max,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Container(height: screen.height * 0.1, child: _userImage()),
  //           SizedBox(width: 10),
  //           Text(
  //             'Enviada por \n${userChef.nome}',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: Colors.black,
  //               fontSize: 16,
  //             ),
  //           )
  //         ]),
  //   );
  // }

  _userImage() {
    String urlImage = _userChef.imagePerfil.url;
    Widget child;
    if (StringUtils.isNullOrEmpty(urlImage)) {
      child = Image.asset(MyAssets.COOKER);
    } else {
      child = Image.network(urlImage);
    }
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.pink[800],
            width: 2,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(100),
          )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: child,
      ),
    );
  }

  _comentariosSection() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _comentariosLabel(),
            _btnAvaliar(),
          ]),
          _avaliacoesList()
        ],
      ),
    );
  }

  _comentariosLabel() {
    return Row(
      children: [
        Text(
          'Comentários',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(width: 5),
      ],
    );
  }

  _avaliacoesList() {
    _loadAvaliacoes(getIdReceita());

    return StreamBuilder<Avaliacoes>(
        stream: _streamAvaliacoes.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          List<Avaliacao> avaliacoesUsuarios =
              _getSortedAvaliacoes(snapshot.data);
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: avaliacoesUsuarios.length,
              itemBuilder: (context, position) {
                Avaliacao avaliacao = avaliacoesUsuarios.elementAt(position);

                return _avaliacaoViewModel(avaliacao);
              });
        });
  }

  _avaliacaoViewModel(Avaliacao avaliacao) {
    return Card(
      shadowColor: Colors.pink[900],
      child: Column(
        children: [
          _cardAvaliacao(avaliacao),
        ],
      ),
    );
  }

  _cardAvaliacao(Avaliacao avaliacao) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.grey[200],
      child: Container(
        child: Column(
          children: [
            _comentarioTop(avaliacao),
          ],
        ),
      ),
    );
  }

  _comentarioTop(Avaliacao avaliacao) {
    Comentario comentario = avaliacao.comentario;
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(children: [
        Row(children: [
          Flexible(flex: 20, child: _imagePerfilAvaliacao(comentario)),
          SizedBox(width: 10),
          Flexible(flex: 80, child: _nameAndRating(avaliacao))
        ]),
        _contentComentario(avaliacao)
      ]),
    );
  }

  _nameAndRating(Avaliacao avaliacao) {
    Comentario comentario = avaliacao.comentario;
    String nomeUsuario = comentario.nomeUsuario;
    return Row(
      children: [
        Expanded(
            child: Text(
          nomeUsuario,
          style: TextStyle(fontSize: 20),
        )),
        RatingBar(
          ignoreGestures: true,
          itemSize: 18,
          onRatingUpdate: (value) => {
            //do nothing
          },
          initialRating: avaliacao.nota,
          tapOnlyMode: true,
          ratingWidget: RatingWidget(
              empty: Icon(
                Icons.star_border,
                color: Colors.amber[900],
              ),
              half: Icon(Icons.star_half, color: Colors.amber[900]),
              full: Icon(Icons.star, color: Colors.amber[900])),
        ),
      ],
    );
  }

  _getSortedAvaliacoes(Avaliacoes avaliacoes) {
    List<Avaliacao> avaliacoesUsuarios = avaliacoes.avaliacoesUsuarios.toList();
    avaliacoesUsuarios.sort((v1, v2) {
      DateTime d1 = v1.comentario.dataPublicacao;
      DateTime d2 = v2.comentario.dataPublicacao;
      return d1.isAfter(d2) ? -1 : 1;
    });
    return avaliacoesUsuarios;
  }

  _showDialogLogin() {
    DialogLogin().show(context);
  }

  _showDialogAvaliar() {
    User user = _authCubit.getUser();
    if (user == null || user.isAnonymous) {
      _showDialogLogin();
      return;
    }
    _controllerComentario.text = '';
    Dialog dialog = Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comentário',
                  style: TextStyle(fontSize: 22),
                ),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Keyboard.hide(context);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.pink[800],
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child: Text('Deixe aqui sua opinião!',
                                  style: TextStyle(fontSize: 18))),
                        ],
                      ),
                      AppTextField(
                        hint: 'Ex: Adorei! (opcional)',
                        controller: _controllerComentario,
                        multiline: true,
                      ),
                      _ratingWidget()
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _publicarAvaliacao();
                      },
                      child: Row(
                        children: [
                          Text(
                            'Publicar',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.send)
                        ],
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.pink[800])),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
    showDialog(
        barrierDismissible: false,
        builder: (context) {
          return dialog;
        },
        context: context);
  }

  _publicarAvaliacao() async {
    if (nota == null || nota == 0) {
      Dialogs(context).showAlert(message: 'Informe uma nota para a receita!');
      return;
    }
    try {
      String userId = _getUserId();
      var id = Uuid().v1();
      Avaliacao avaliacao = Avaliacao(
        nota: nota,
        comentario: Comentario(
            id: id,
            conteudo: _controllerComentario.text,
            dataPublicacao: DateTime.now(),
            respostas: [],
            idUsuario: userId,
            imageUsuario: _userChef.imagePerfil.url,
            nomeUsuario: _userChef.nome),
      );
      await FirebaseRepository.addAvaliacao(
        avaliacao: avaliacao,
        idReceita: getIdReceita(),
      );
      _avaliacaoPublicadaSucesso();
    } on Exception catch (e) {
      _erroPublicarAvaliacao(e);
    }
  }

  _erroPublicarAvaliacao(Exception e) {
    log('Não foi possível publicar a avaliação! Erro: ${e.toString()}');
    Navigator.of(context, rootNavigator: true).pop();
    Keyboard.hide(context);
    _snack.show(
        'Não foi possível publicar a avaliação! Tente novamente mais tarde!');
  }

  _avaliacaoPublicadaSucesso() {
    Navigator.of(context, rootNavigator: true).pop();
    Keyboard.hide(context);
    _snack.show('Obrigado por avaliar! :)');
    _loadAvaliacoes(getIdReceita());
  }

  _contentComentario(Avaliacao avaliacao) {
    Comentario comentario = avaliacao.comentario;
    return Column(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            comentario.conteudo,
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  _imagePerfilAvaliacao(Comentario comentario) {
    String imageUrl = comentario.imageUsuario;
    Widget imageWidget;
    if (StringUtils.isNullOrEmpty(imageUrl)) {
      imageWidget = Image.asset(MyAssets.CHEF_PERFIL);
    } else {
      imageWidget = Image.network(imageUrl);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: imageWidget,
    );
  }

  _nomeReceitaSection() {
    return Container(
      color: palete.DARK_PINK,
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _receita.nome,
              style: TextStyle(fontSize: 24, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  _secoesSection() {
    List<SecaoReceita> secoes = _receita.secoes;
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: secoes.length,
        shrinkWrap: true,
        itemBuilder: (context, position) {
          SecaoReceita secao = secoes.elementAt(position);
          return Container(
            child: Column(children: [
              _headerSecao(secao),
              _ingredientes(secaoPosition: position),
              _modoDePreparo(secaoPosition: position)
            ]),
          );
        });
  }

  _headerSecao(SecaoReceita secao) {
    String descricao = secao.descricao;
    if (StringUtils.isNullOrEmpty(descricao)) {
      return Container();
    }
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.pink[600]))),
            padding: EdgeInsets.all(16),
            child: Text(
              secao.descricao.toUpperCase(),
              style: TextStyle(
                  color: Colors.pink[600],
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  _ratingWidget() {
    return Container(
        padding: EdgeInsets.all(8),
        child: RatingBar(
          onRatingUpdate: (rating) {
            nota = rating;
          },
          ratingWidget: RatingWidget(
              empty: Icon(
                Icons.star_border,
                color: Colors.amber[900],
              ),
              half: Icon(Icons.star_half, color: Colors.amber[900]),
              full: Icon(Icons.star, color: Colors.amber[900])),
        ));
  }

  _btnAvaliar() {
    return Align(
        alignment: Alignment.topRight,
        child: ElevatedButton(
          onPressed: () {
            _showDialogAvaliar();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.purple[900]),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avaliar',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 5),
              Icon(Icons.comment)
            ],
          ),
        ));
  }

  String _getUserId() {
    var _authCubit = context.read<AuthCubit>();
    var userId = _authCubit.getUser().uid;
    return userId;
  }

  _appBarActions() {
    return [
      Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            // GestureDetector(
            //   onTap: () {
            //     _generatePdf();
            //   },
            //   child: Icon(Icons.picture_as_pdf),
            // ),
            SizedBox(width: 10),
            GestureDetector(
              child: _favoriteIconStream(),
              onTap: () {
                _toggleReceitaToFavoritos();
              },
            ),
            SizedBox(width: 10),
            GestureDetector(
              child: Icon(Icons.share),
              onTap: () {
                _shareReceita();
              },
            ),
          ]))
    ];
  }

  _generatePdf() async {
    if (_premiumCubit.isPremiumMode()) {
      final pdfFile = await ReceitaPdf(receita: _receita).generate();
      PdfService.openFile(pdfFile);
    } else {
      _showSignPremium();
    }
  }

  _showSignPremium() {
    //ModalPremiumBenefits(context).show();
  }

  StreamBuilder _favoriteIconStream() {
    return StreamBuilder(
      stream: _streamFavorito.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return Container(
            height: 15,
            width: 15,
            child: Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            )),
          );
        }
        bool favorite = snapshot.data;
        return _favoriteIcon(favorite);
      },
    );
  }

  Icon _favoriteIcon(bool favorite) {
    if (favorite) {
      return Icon(Icons.favorite);
    } else {
      return Icon(Icons.favorite_border);
    }
  }

  _toggleReceitaToFavoritos() async {
    // User user = _authCubit.getUser();
    // if (user == null || user.isAnonymous) {
    //   _showDialogLogin();
    //   return;
    // }
    try {
      String idReceita = getIdReceita();
      _loadingFavoriteState();

      await _updateReceitaToFavoritos(idReceita);

      await _loadFavorito();
      await _updateNumberOfFavorites(idReceita);
    } on Exception catch (e) {
      _handleErrorOnAddToFavorite(e);
    }
  }

  _updateReceitaToFavoritos(String idReceita) async {
    User user = _authCubit.getUser();

    await FirebaseRepository.updateReceitaToFavoritos(
        userId: user.uid, idReceita: idReceita);
  }

  _loadingFavoriteState() {
    _streamFavorito.add(null);
  }

  _handleErrorOnAddToFavorite(Exception e) {
    _snack.show('Não foi possível adicionar a receita aos favoritos!');
  }

  // _createInterstitialAd() {
  //   InterstitialAd.load(
  //     adUnitId: MyAds.intersticialCompartilharReceitaAd,
  //     request: AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
  //       _interstitialAd = ad;
  //       _interstitialLoadAttempts = 0;
  //     }, onAdFailedToLoad: (error) {
  //       log('Erro ao carregar anuncio intersticial. Erro: $error');
  //       _interstitialLoadAttempts++;
  //       _interstitialAd = null;
  //       if (_interstitialLoadAttempts <= _maxFailedLoadAttempts) {
  //         _createInterstitialAd();
  //       }
  //     }),
  //   );
  // }

  _updateNumberOfFavorites(String idReceita) async {
    int numberOfFavorites =
        await FirebaseRepository.getNumberOfFavorites(idReceita);

    _streamNumberOfFavorites.add(numberOfFavorites);
  }

  // _loadInterstitialAdAndShareReceita() {
  //   if (_interstitialAd == null) {
  //     return;
  //   }

  //   _interstitialAd.fullScreenContentCallback =
  //       FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
  //     ad.dispose();
  //     _createInterstitialAd();
  //     ShareReceitaService().shareReceita(_receita);
  //   }, onAdFailedToShowFullScreenContent: (ad, error) {
  //     ad.dispose();
  //     _createInterstitialAd();
  //   });
  //   _interstitialAd?.show();
  // }

  _shareReceita() async {
    ShareReceitaService().shareReceita(_receita);
    //_loadInterstitialAdAndShareReceita();
  }

  _detalhesSection() {
    int porcoes = _receita.porcoes;
    Duration tempoPreparo = _receita.tempoPreparo;

    if (PorcoesCheck(porcoes).isNotInformed() &&
        TempoPreparoCheck(tempoPreparo).isNotInformed()) {
      return Container();
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber,
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _labelPorcoes(_receita.porcoes),
          _labelTempo(_receita.tempoPreparo),
          if (isValidDificuldade(_receita.dificuldade))
            _labelDificuldade(_receita.dificuldade),
        ],
      ),
    );
  }

  bool isValidDificuldade(String dificuldade) {
    return !StringUtils.isNullOrEmpty(dificuldade);
  }

  _labelDificuldade(String dificuldade) {
    return Row(
      children: [
        Icon(
          Icons.bar_chart,
          color: Colors.black,
        ),
        Column(children: [
          Text(
            'Dificuldade',
            style: TextStyle(color: Colors.black),
          ),
          Text(
            dificuldade,
            style: TextStyle(color: Colors.black),
          )
        ]),
      ],
    );
  }

  _labelTempo(Duration tempoPreparo) {
    String text = DurationUtils.formatDefault(tempoPreparo);
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          color: Colors.black,
        ),
        Column(
          children: [
            Text(
              'Leva',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              text,
              style: TextStyle(color: Colors.black),
            ),
          ],
        )
      ],
    );
  }

  _labelPorcoes(int porcoes) {
    var porcoesCheck = PorcoesCheck(porcoes);
    String text;
    if (porcoesCheck.isSingular()) {
      text = '$porcoes porção';
    } else {
      text = '$porcoes porções';
    }
    return Row(
      children: [
        Icon(
          Icons.fastfood_outlined,
          color: Colors.black,
        ),
        Column(
          children: [
            Text(
              'Rende',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              text,
              style: TextStyle(color: Colors.black),
            ),
          ],
        )
      ],
    );
  }

  _ingredientes({int secaoPosition}) {
    List<Ingrediente> ingredientes =
        _receita.secoes[secaoPosition].ingredientes;
    return Column(
      children: [
        if (!ListUtils.isNullOrEmpty(ingredientes))
          _headerTitle('Ingredientes'),
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ingredientes.length,
            itemBuilder: (context, index) {
              var ing = ingredientes.elementAt(index);
              return _ingredienteViewModel(ing);
            })
      ],
    );
  }

  _numberOfFavoritesSection() {
    return StreamBuilder(
      stream: _streamNumberOfFavorites.stream,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        int numberOfFavorites = snapshot.data;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _favoritesWidget(numberOfFavorites),
          ],
        );
      },
    );
  }

  _favoritesWidget(int numberOfFavorites) {
    if (numberOfFavorites == null || numberOfFavorites <= 0) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$numberOfFavorites ${numberOfFavorites > 1 ? 'favoritos' : 'favorito'}',
            style: TextStyle(color: Colors.pink[900]),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.favorite,
            color: Colors.pink[900],
          ),
        ],
      ),
    );
  }

  _ingredienteViewModel(Ingrediente ingrediente) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        ' - ${ingrediente.descricao}',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  _modoDePreparo({int secaoPosition}) {
    List<EtapaPreparo> etapas = _receita.secoes[secaoPosition].modoDePreparo;
    return Column(
      children: [
        _headerTitle('Modo de Preparo'),
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: etapas.length,
            itemBuilder: (context, index) {
              var etapa = etapas.elementAt(index);
              return _etapaViewModel(index, etapa);
            })
      ],
    );
  }

  _headerTitle(String title, {Color color, Color textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          color: color ?? Colors.pink[600],
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
          margin: EdgeInsets.all(8),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: textColor ?? Colors.white),
          ),
        ),
      ],
    );
  }

  _etapaViewModel(int index, EtapaPreparo etapa) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        ' ${index + 1} - ${etapa.descricao}',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  _imageReceita() {
    List<Widget> widgetsCarousel = _createWidgetsCarousel();
    if (ListUtils.isNullOrEmpty(widgetsCarousel)) {
      return Container();
    }

    return BlocBuilder<CarouselCubit, CarouselState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                    viewportFraction: 1,
                    height: screen.height * 0.4,
                    onPageChanged: (index, reason) {
                      log('current carousel index: $index');
                      _carouselCubit.updateIndex(index);
                    }),
                items: widgetsCarousel,
              ),
              _indicatorsCarousel(widgetsCarousel)
            ],
          ),
        );
      },
    );
  }

  List<Widget> _createWidgetsCarousel() {
    List<Widget> widgets = [];

    String urlVideo = _receita.urlVideo;
    if (!StringUtils.isNullOrEmpty(urlVideo)) {
      Widget videoWidget = VideoView(
        url: urlVideo,
      );
      widgets.add(videoWidget);
    }

    if (!ListUtils.isNullOrEmpty(_receita.images)) {
      Widget imageWidget = Image.network(
        _receita.images.first.url,
        fit: BoxFit.cover,
      );
      widgets.add(imageWidget);
    }
    return widgets;
  }

  _indicatorsCarousel(List<Widget> children) {
    if (ListUtils.isNullOrEmpty(children) || children.length <= 1) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => _carouselController.animateToPage(entry.key),
          child: Container(
            width: 12.0,
            height: 12.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: _getCurrentColor(entry)),
          ),
        );
      }).toList(),
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
      adId: MyAds.paginaReceitaBannerAd,
      background: Colors.pink[900],
    );
  }

  _getCurrentColor(var entry) {
    int currentCarouselIndex = _carouselCubit.index;
    log('current carousel index color: $currentCarouselIndex');
    return (Theme.of(context).brightness == Brightness.dark
            ? Colors.pink[900]
            : Colors.pink)
        .withOpacity(currentCarouselIndex == entry.key ? 0.9 : 0.4);
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
  //               adUnitId: MyAds.paginaReceitaBannerAd,
  //               size: size,
  //               request: AdRequest(),
  //               listener: adState.adListener)
  //             ..load();
  //         })
  //       });
  // }
}
