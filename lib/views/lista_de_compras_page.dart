import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/banner_widget_novo.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/components/app_drawer.dart';
import 'package:receitas_de_pao/components/banner_widget.dart';
import 'package:receitas_de_pao/components/btn_premium.dart';
import 'package:receitas_de_pao/components/my_nav_bar.dart';
import 'package:receitas_de_pao/components/new_appbar.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';
import 'package:receitas_de_pao/models/my_app/lista_compras.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/state/ads_state/ads_cubit.dart';
import 'package:receitas_de_pao/state/auth_state/auth_cubit.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:receitas_de_pao/utils/screen.dart';

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

class ListaComprasPage extends StatefulWidget {
  void Function() onNovaReceitaPressed;

  ListaComprasPage({this.onNovaReceitaPressed});
  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  Screen screen;
  ListaComprasCubit _listaComprasCubit;

  TextEditingController _controllerDescricaoListaCompras =
      TextEditingController();

  TextEditingController _controllerDescricaoItemCompra =
      TextEditingController();

  AuthCubit _authCubit;

  GlobalKey<FormState> _formKeyDescricaoListaCompras = GlobalKey<FormState>();
  GlobalKey<FormState> _formKeyDescricaoItemCompra = GlobalKey<FormState>();
  AutovalidateMode _autovalidateModeDescricaoListaCompras =
      AutovalidateMode.disabled;
  AutovalidateMode _autovalidateModeDescricaoItemCompra =
      AutovalidateMode.disabled;

  ScrollController scrollController = ScrollController();
  Scroll scroll;
  AdsCubit _adsCubit;
  //BannerAd banner;
  PremiumCubit _premiumCubit;

  initState() {
    super.initState();
    _listaComprasCubit = context.read<ListaComprasCubit>();
    _adsCubit = context.read<AdsCubit>();
    screen = Screen(context);
    scroll = Scroll(scrollController);
    _authCubit = context.read<AuthCubit>();
    _listaComprasCubit.init(_getUserId());
    _premiumCubit = context.read<PremiumCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _adsCubit.showAd();
        return Future.value(true);
      },
      child: Scaffold(
        key: NavKeys.listaComprasKey,
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
    return Stack(
      children: [
        SingleChildScrollView(
          controller: scrollController,
          child: _buildPanel(),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.all(10),
            child: FloatingActionButton(
              backgroundColor: Colors.pink[900],
              child: Icon(Icons.add),
              onPressed: () {
                _showDialogCreateOrEditListaCompras(null);
              },
            ),
          ),
        ),
      ],
    );
  }

  _banner() {
    if (_premiumCubit.isPremiumMode()) {
      return Container();
    }
    return BannerWidgetNovo(
      adId: MyAds.listaComprasBannerAd,
      background: Colors.pink[900],
    );
  }

  _buildNewAppBar() {
    return AppBar(
      backgroundColor: Colors.pink[600],
      actions: [BtnPremium()],
      title: Text('Lista de Compras'),
    );
  }

  _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  _showDialogCreateOrEditListaCompras(ListaCompras listaCompras) {
    _autovalidateModeDescricaoListaCompras = AutovalidateMode.disabled;
    Dialog dialog = Dialog(
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        listaCompras == null
                            ? 'Nova Lista de Compras'
                            : 'Editar Lista de Compras',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _closeDialogNovaListaCompras();
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
            Container(height: 5),
            Form(
              autovalidateMode: _autovalidateModeDescricaoListaCompras,
              key: _formKeyDescricaoListaCompras,
              child: AppTextField(
                  required: true,
                  minLength: 3,
                  controller: _controllerDescricaoListaCompras,
                  label: 'Descrição',
                  hint: 'Ex: Itens para Pão Caseiro',
                  text: listaCompras != null
                      ? listaCompras.descricao
                      : _controllerDescricaoListaCompras.text),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.pink[900]),
                  ),
                  onPressed: () async {
                    bool success = true;
                    if (listaCompras == null) {
                      success = await _criarListaCompras();
                    } else {
                      success = await _updateListaCompras(listaCompras);
                    }

                    if (success) {
                      _adsCubit.showAd();
                    }
                  },
                  child: Text('Salvar'),
                )
              ],
            )
          ],
        ),
      ),
    );

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  Future<bool> _updateListaCompras(ListaCompras listaCompras) async {
    String descricaoListaCompras = _controllerDescricaoListaCompras.text;
    if (!_formKeyDescricaoListaCompras.currentState.validate()) {
      _autovalidateModeDescricaoListaCompras =
          AutovalidateMode.onUserInteraction;
      return false;
    }
    _listaComprasCubit.updateDescricaoListaComprasById(
        descricaoListaCompras, listaCompras);

    _closeDialogNovaListaCompras();
    Navigator.of(context).pop();
    return true;
  }

  Future<bool> _criarListaCompras() async {
    String descricaoListaCompras = _controllerDescricaoListaCompras.text;
    if (!_formKeyDescricaoListaCompras.currentState.validate()) {
      _autovalidateModeDescricaoListaCompras =
          AutovalidateMode.onUserInteraction;
      return false;
    }
    ListaCompras listaCompras = ListaCompras(
        descricao: descricaoListaCompras,
        updatedDate: DateTime.now(),
        idUsuario: _getUserId());

    _closeDialogNovaListaCompras();
    await _listaComprasCubit.insertListaCompras(
        listaCompras, true, _getUserId());
    scroll.scrollToTop();
    return true;
  }

  _getUserId() {
    return _authCubit.getUser().uid;
  }

  _closeDialogNovaListaCompras() {
    _controllerDescricaoListaCompras.text = '';
    FocusScope.of(context).requestFocus(FocusNode());
    _hideKeyboard();
    Navigator.of(context, rootNavigator: true).pop();
  }

  _closeDialogNovoItemCompra() {
    _controllerDescricaoItemCompra.text = '';
    FocusScope.of(context).requestFocus(FocusNode());
    _hideKeyboard();
    Navigator.of(context, rootNavigator: true).pop();
  }

  _itensCompraViewModel(int index, ListaCompras listaCompras) {
    List<ItemCompra> itensCompra = listaCompras.itens;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: itensCompra.length,
            itemBuilder: (context, index) {
              ItemCompra item = itensCompra.elementAt(index);
              return _itemCompraViewModel(listaCompras, item);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () {
                  _showDialogCreateOrEditItemCompra(listaCompras, null);
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.pink[200],
                    border: Border.all(color: Colors.pink[200]),
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'Novo Item',
                          style: TextStyle(color: Colors.pink[900]),
                        ),
                      ),
                      IconButton(
                        onPressed: null,
                        icon: Icon(Icons.add),
                        color: Colors.pink[900],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPanel() {
    return BlocBuilder<ListaComprasCubit, ListaComprasState>(
        builder: (context, state) {
      if (state == null ||
          state is InitialListaComprasState ||
          state is LoadingListaComprasState) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      List<ListaCompras> allListasCompras = _listaComprasCubit.allListasCompras;
      if (ListUtils.isNullOrEmpty(allListasCompras)) {
        return _emptyListasCompras();
      } else {
        return Container(
          padding: EdgeInsets.all(5),
          child: ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.all(5),
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  allListasCompras[index].expanded = !isExpanded;
                });
              },
              children: _childrens(allListasCompras)),
        );
      }
    });
  }

  _childrens(List<ListaCompras> allListasCompras) {
    return allListasCompras
        .asMap()
        .entries
        .map<ExpansionPanel>((MapEntry<Object, ListaCompras> mapListaCompras) {
      ListaCompras listaCompras = mapListaCompras.value;
      int index = mapListaCompras.key;
      return ExpansionPanel(
        backgroundColor: Colors.red[100],
        headerBuilder: (BuildContext context, bool isExpanded) {
          return Container(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      listaCompras.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.pink[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showModalEditOrDeleteListaCompras(listaCompras);
                  },
                  icon: Icon(Icons.more_vert),
                  color: Colors.pink[900],
                ),
              ],
            ),
          );
        },
        body: _itensCompraViewModel(index, listaCompras),
        isExpanded: listaCompras.expanded,
      );
    }).toList();
  }

  _showDialogCreateOrEditItemCompra(
      ListaCompras listaCompras, ItemCompra itemCompra) {
    _autovalidateModeDescricaoItemCompra = AutovalidateMode.disabled;
    Dialog dialog = Dialog(
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    itemCompra == null ? 'Novo Item' : 'Editar Item',
                    style: TextStyle(fontSize: 22),
                  ),
                  GestureDetector(
                    onTap: () {
                      _closeDialogNovoItemCompra();
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
            Container(height: 5),
            Form(
              autovalidateMode: _autovalidateModeDescricaoItemCompra,
              key: _formKeyDescricaoItemCompra,
              child: AppTextField(
                required: true,
                minLength: 3,
                controller: _controllerDescricaoItemCompra,
                label: 'Descrição',
                hint: 'Ex: 1kg de açúcar',
                text: itemCompra != null
                    ? itemCompra.descricao
                    : _controllerDescricaoItemCompra.text,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.pink[900]),
                  ),
                  onPressed: () {
                    if (itemCompra == null) {
                      _criarItemCompra(listaCompras);
                    } else {
                      _updateItemCompra(itemCompra);
                    }
                  },
                  child: Text('Salvar'),
                )
              ],
            )
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return dialog;
        });
  }

  _updateItemCompra(ItemCompra itemCompra) {
    String descricaoItemCompra = _controllerDescricaoItemCompra.text;
    if (!_formKeyDescricaoItemCompra.currentState.validate()) {
      _autovalidateModeDescricaoItemCompra = AutovalidateMode.onUserInteraction;
      return;
    }
    _listaComprasCubit.updateDescricaoItemCompraById(
        descricaoItemCompra, itemCompra);

    _closeDialogNovoItemCompra();
    Navigator.of(context).pop();
  }

  _criarItemCompra(ListaCompras listaCompras) async {
    String descricaoItemCompra = _controllerDescricaoItemCompra.text;
    if (!_formKeyDescricaoItemCompra.currentState.validate()) {
      _autovalidateModeDescricaoItemCompra = AutovalidateMode.onUserInteraction;
      return;
    }
    ItemCompra itemCompra = ItemCompra(
        descricao: descricaoItemCompra, idListaCompras: listaCompras.id);

    _listaComprasCubit.insertItemCompra(listaCompras, itemCompra);

    _closeDialogNovoItemCompra();
  }

  _emptyListasCompras() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            height: screen.height * 0.3,
          ),
          Container(
            child: Text(
              'Clique abaixo para criar sua Lista de Compras! :)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Container(height: 10),
          TextButton(
            onPressed: () {
              _showDialogCreateOrEditListaCompras(null);
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
                  Text('Nova lista de compras',
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
    );
  }

  _itemCompraViewModel(ListaCompras listaCompras, ItemCompra itemCompra) {
    return Container(
      width: screen.width,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: () {
            _listaComprasCubit.switchItemCompraSelecionado(itemCompra);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AbsorbPointer(
                child: Checkbox(
                  activeColor: Colors.pink[700],
                  fillColor: MaterialStateProperty.all(Colors.pink[700]),
                  value: itemCompra.selecionado,
                  onChanged: null,
                ),
              ),
              SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: screen.width / 2,
                  child: Text(
                    itemCompra.descricao,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.pink[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(fit: FlexFit.loose, child: Container()),
        IconButton(
          onPressed: () {
            _showModalEditOrDeleteItemCompra(listaCompras, itemCompra);
          },
          icon: Icon(Icons.more_vert),
          color: Colors.pink[700],
        ),
      ]),
    );
  }

  _showModalEditOrDeleteListaCompras(ListaCompras listaCompras) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return DefaultModal(child: _popupMenuListaCompras(listaCompras));
        });
  }

  _popupMenuListaCompras(ListaCompras listaCompras) {
    return ModalMenu(
      title: listaCompras.descricao,
      headerColor: Colors.pink[900],
      textColor: Colors.white,
      actions: [
        MenuActions.edit(() {
          _showDialogCreateOrEditListaCompras(listaCompras);
        }),
        MenuActions.delete(() {
          _deleteListaCompras(listaCompras);
        }),
      ],
    );
  }

  _deleteListaCompras(ListaCompras listaCompras) async {
    _listaComprasCubit.deleteListaComprasById(listaCompras);
    log('lista compras deleted successfully!');
    Navigator.of(context).pop();
  }

  _showModalEditOrDeleteItemCompra(
      ListaCompras listaCompras, ItemCompra itemCompra) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return DefaultModal(
              child: _popupMenuItemCompra(listaCompras, itemCompra));
        });
  }

  _popupMenuItemCompra(ListaCompras listaCompras, ItemCompra itemCompra) {
    return ModalMenu(
      title: itemCompra.descricao,
      headerColor: Colors.pink[900],
      textColor: Colors.white,
      actions: [
        MenuActions.edit(() {
          _showDialogCreateOrEditItemCompra(listaCompras, itemCompra);
        }),
        MenuActions.delete(() {
          _deleteItemCompra(itemCompra);
        }),
      ],
    );
  }

  _deleteItemCompra(ItemCompra itemCompra) async {
    _listaComprasCubit.deleteItemCompraById(itemCompra);
    log('item compra deleted successfully!');
    Navigator.of(context).pop();
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
  //               adUnitId: MyAds.listaComprasBannerAd,
  //               size: size,
  //               request: AdRequest(),
  //               listener: adState.adListener)
  //             ..load();
  //         })
  //       });
  // }
}
