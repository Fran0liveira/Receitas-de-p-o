import 'dart:developer';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/app_open_ad_cubit.dart';
import 'package:receitas_de_pao/ads/banner_widget_novo.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/components/app_textfield.dart';
import 'package:receitas_de_pao/components/banner_widget.dart';
import 'package:receitas_de_pao/components/default_modal.dart';
import 'package:receitas_de_pao/components/menu_actions.dart';
import 'package:receitas_de_pao/components/modal_menu.dart';
import 'package:receitas_de_pao/components/snack_message.dart';
import 'package:receitas_de_pao/enums/app_categorias.dart';
import 'package:receitas_de_pao/enums/crud_operation.dart';
import 'package:receitas_de_pao/enums/error_append_mode.dart';
import 'package:receitas_de_pao/extensions/string_extensions.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';
import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/models/my_app/ingrediente.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/models/my_app/secao_receita.dart';
import 'package:receitas_de_pao/repository/firebase_repository.dart';
import 'package:receitas_de_pao/services/detalhes_check.dart';
import 'package:receitas_de_pao/services/image_manager.dart';
import 'package:receitas_de_pao/services/tempo_preparo_check.dart';
import 'package:receitas_de_pao/state/ads_state/ads_cubit.dart';
import 'package:receitas_de_pao/state/auth_state/auth_cubit.dart';
import 'package:receitas_de_pao/state/etapa_cubit.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/state/receita_state/new_receita_cubit.dart';
import 'package:receitas_de_pao/utils/assets.dart';
import 'package:receitas_de_pao/utils/dialogs.dart';
import 'package:receitas_de_pao/utils/duration_utils.dart';
import 'package:receitas_de_pao/utils/list_utils.dart';
import 'package:receitas_de_pao/utils/screen.dart';
import 'package:receitas_de_pao/state/receita_state/receita_state.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';
import 'package:receitas_de_pao/views/video_view.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import '../enums/dificuldade_receita.dart';
import '../state/nav_bar_state/nav_bar_cubit.dart';
import '../style/palete.dart';

class NewEditReceitaPage extends StatefulWidget {
  Receita receita;
  CrudOperation crudOperation;
  NewEditReceitaPage({this.receita, this.crudOperation});
  @override
  _NewEditReceitaPageState createState() => _NewEditReceitaPageState();
}

class _NewEditReceitaPageState extends State<NewEditReceitaPage> {
  var _controllerNomeReceita = TextEditingController();
  var _ingredienteController = TextEditingController();
  var _etapaController = TextEditingController();
  var _secaoController = TextEditingController();
  var _extraInfoController = TextEditingController();
  var _urlVideoController = TextEditingController();
  var _openAppAdCubit = OpenAppAdCubit();
  List<String> _niveis = [
    DificuldadeReceita.FACIL,
    DificuldadeReceita.MEDIA,
    DificuldadeReceita.DIFICIL
  ];

  int _indexNivelSelecionado = 0;
  Screen screen;
  List<DropdownMenuItem<String>> _categorias;
  Dialogs dialogs;
  GlobalKey<FormState> _keyFormIngrediente = GlobalKey<FormState>();
  GlobalKey<FormState> _keyFormEtapa = GlobalKey<FormState>();
  GlobalKey<FormState> _keyFormSecao = GlobalKey<FormState>();
  //BannerAd banner;

  NewReceitaCubit _receitaCubit;
  NavBarCubit _navBarCubit;

  Receita get receita => _receitaCubit.receita;
  SnackMessage _snack;
  EtapaCubit _etapaCubit;
  AdsCubit _adsCubit;

  CrudOperation get crudOperation => widget.crudOperation;
  PremiumCubit _premiumCubit;
  // VideoPlayerController _videoController;
  // ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _initCategorias();
    _snack = SnackMessage(context);
    _premiumCubit = context.read<PremiumCubit>();
    _receitaCubit = context.read<NewReceitaCubit>();
    _etapaCubit = context.read<EtapaCubit>();
    _navBarCubit = context.read<NavBarCubit>();
    _adsCubit = context.read<AdsCubit>();
    _etapaCubit.clean();
    _receitaCubit.clean();

    _receitaCubit.updateDificuldadeReceita(_niveis[_indexNivelSelecionado]);
    _setupReceitaOnEdit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_loadAd();
  }

  _setupReceitaOnEdit() {
    Receita receitaRecebida = widget.receita;
    if (receitaRecebida != null) {
      _receitaCubit.setReceita(receita: receitaRecebida);
    }
  }

  @override
  Widget build(BuildContext context) {
    log('open ad disabling');
    _openAppAdCubit.enable(false);
    screen = Screen(context);
    dialogs = Dialogs(context);

    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            _openAppAdCubit.enable(true);
            return true;
          },
          child: Container(
            height: screen.height,
            child: Column(
              children: [
                BlocBuilder<NewReceitaCubit, ReceitaState>(
                    builder: (context, state) {
                  var nomeReceita = _nomeReceita();
                  return AppBar(
                    backgroundColor: Colors.pink[600],
                    title: StringUtils.isNullOrEmpty(nomeReceita)
                        ? Text('Nova Receita')
                        : Text(nomeReceita),
                  );
                }),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(children: [
                      SizedBox(height: 10),
                      _titleSection(),
                      SizedBox(height: 20),
                      _photosSection(),
                      SizedBox(height: 20),
                      _videoSection(),
                      SizedBox(height: 20),
                      _secoesSection(),
                      SizedBox(height: 20),
                      _btnNovaSecao(),
                      SizedBox(height: 20),
                      _dificuldadeSection(),
                      SizedBox(height: 20),
                      _detalhesSection(),
                      SizedBox(height: 20),
                      _btnFinalizarReceita()
                    ]),
                  ),
                ),
                _banner()
              ],
            ),
          ),
        ),
      ),
    );
  }

  _banner() {
    if (_premiumCubit.isPremiumMode()) {
      return Container();
    }
    return BannerWidgetNovo(
      adId: MyAds.crudReceitaBannerAd,
      background: Colors.pink[900],
    );
  }

  _nomeReceita() {
    return receita.nome.trim().replaceAll('\n', '');
  }

  _videoSection() {
    return BlocBuilder<NewReceitaCubit, ReceitaState>(
      builder: (context, state) {
        log('rebuilding bloc: ${receita.urlVideo}');
        return Card(
          elevation: 10,
          color: Colors.red[100],
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  color: Colors.purple[900],
                  child: Text(
                    'Link para vídeo (opcional)',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Text('Siga o exemplo abaixo para informar o vídeo da receita:',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
                SizedBox(height: 10),
                Image.asset(MyAssets.INFORMATIVO_ID_VIDEO),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Flexible(
                        child: AppTextField(
                          hint: 'Exemplo: youtube.com/watch?v=jNQXAC9IVRw',
                          controller: _urlVideoController,
                          text: receita.urlVideo,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _updateUrlVideo();
                        },
                        child: Icon(Icons.check),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.pink[900]),
                        ),
                      )
                    ],
                  ),
                ),
                _videoViewModel()
              ],
            ),
          ),
        );
      },
    );
  }

  _updateUrlVideo() {
    FocusScope.of(context).requestFocus(FocusNode());
    _hideKeyboard();
    _receitaCubit.updateUrlVideo(_urlVideoController.text);
  }

  _videoViewModel() {
    String urlVideo = receita.urlVideo;
    if (StringUtils.isNullOrEmpty(urlVideo)) {
      return Container();
    }
    return VideoView(
      url: receita.urlVideo,
    );
  }

  // _pickVideo() async {
  //   try {
  //     XFile video = await ImagePicker().pickVideo(source: ImageSource.gallery);
  //     log('video picked: ' + video.path);
  //     if (video == null) {
  //       return;
  //     }
  //     File videoFile = File(video.path);

  //     _videoController = VideoPlayerController.file(videoFile);

  //     await _videoController.initialize();
  //     _chewieController = ChewieController(
  //       videoPlayerController: _videoController,
  //     );
  //     _receitaCubit.salvarVideo(videoFile);
  //     log('video saved chewie: ${_chewieController}');
  //   } on PlatformException catch (e) {
  //     Dialogs(context).showAlert(
  //         message: 'Não foi possível adicionar vídeo! \n ${e.message}');
  //   }
  // }

  _btnFinalizarReceita() {
    return Container(
      padding: EdgeInsets.all(8),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.purple[900])),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Finalizar receita', style: TextStyle(fontSize: 18)),
              Icon(Icons.check_circle),
            ],
          ),
        ),
        onPressed: _finalizarReceita,
      ),
    );
  }

  _btnNovaSecao() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _showDialogCreateSecao(secaoReceita: null);
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.pink[600])),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Icon(Icons.add),
              Text('Nova seção'),
            ],
          ),
        ),
      ),
    );
  }

  _showDialogCreateSecao({SecaoReceita secaoReceita, int secaoPosition}) {
    if (secaoReceita != null) {
      _secaoController.text = secaoReceita.descricao;
    }
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
                  secaoReceita != null ? 'Editar seção' : 'Nova seção',
                  style: TextStyle(fontSize: 22),
                ),
                GestureDetector(
                  onTap: () {
                    _secaoController.text = '';
                    FocusScope.of(context).requestFocus(FocusNode());
                    _hideKeyboard();
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
                BlocBuilder<NewReceitaCubit, ReceitaState>(
                    builder: (context, state) {
                  return Form(
                    key: _keyFormSecao,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                child: Text('Descrição',
                                    style: TextStyle(fontSize: 18))),
                            Tooltip(
                              showDuration: Duration(seconds: 15),
                              child: Icon(Icons.info_outline),
                              triggerMode: TooltipTriggerMode.tap,
                              padding: EdgeInsets.all(8),
                              message:
                                  'Você pode nomear diferentes seções, como a massa e a cobertura de um bolo, por exemplo, ou deixar esse campo em branco caso sua receita possua apenas uma seção.',
                            ),
                          ],
                        ),
                        AppTextField(
                            controller: _secaoController,
                            hint: 'Ex: Cobertura do bolo',
                            multiline: false),
                        SizedBox(height: 5),
                        Text(
                            '*Pode deixar em branco caso seja apenas uma seção')
                      ],
                    ),
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (secaoReceita == null) {
                          _salvarSecao();
                        } else {
                          _updateSecao(secaoPosition: secaoPosition);
                        }
                      },
                      child: Text(
                        'Salvar',
                        style: TextStyle(color: Colors.white),
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

  _salvarSecao() {
    SecaoReceita secao = SecaoReceita(descricao: _secaoController.text);
    _receitaCubit.addSecao(secao);
    _secaoController.text = '';
    FocusScope.of(context).requestFocus(FocusNode());
    _hideKeyboard();
    Navigator.of(context, rootNavigator: true).pop();
  }

  _updateSecao({int secaoPosition}) {
    SecaoReceita secao = receita.secoes.elementAt(secaoPosition);
    secao.descricao = _secaoController.text;
    _receitaCubit.updateSecao(
        secaoReceita: secao, secaoPosition: secaoPosition);
    _secaoController.text = '';
    FocusScope.of(context).requestFocus(FocusNode());
    _hideKeyboard();
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).pop();
  }

  _secoesSection() {
    List<SecaoReceita> secoesReceita = receita.secoes;
    return ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final SecaoReceita item = secoesReceita.removeAt(oldIndex);
          secoesReceita.insert(newIndex, item);
        },
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: secoesReceita.length,
        itemBuilder: (context, position) {
          SecaoReceita secaoReceita = secoesReceita.elementAt(position);
          return Card(
            key: ValueKey(position),
            color: Colors.pink[100],
            child: Column(
              children: [
                _secaoHeader(secaoPosition: position),
                Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _ingredientesSection(
                            ingredientes: secaoReceita.ingredientes,
                            secaoPosition: position),
                        SizedBox(height: 10),
                        _etapasSection(
                            etapas: secaoReceita.modoDePreparo,
                            secaoPosition: position),
                      ],
                    )),
              ],
            ),
          );
        });
  }

  _secaoHeader({int secaoPosition}) {
    SecaoReceita secaoReceita = receita.secoes.elementAt(secaoPosition);
    return Card(
      color: Colors.purple[900],
      child: Container(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  secaoReceita.descricao,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 5),
              IconButton(
                icon: Icon(Icons.more_horiz, color: Colors.white),
                onPressed: () {
                  _showModalEditOrDeleteSecao(secaoPosition: secaoPosition);
                },
              )
            ],
          )),
    );
  }

  _showDialogConfirmacaoReceita(Receita receita) {
    String message = '';
    String btnMessage = '';
    if (CrudOperation.CREATE == crudOperation) {
      message = 'Você finalizou a receita! Deseja salvar ?';
      btnMessage = 'Sim, salvar receita!';
    } else if (CrudOperation.UPDATE == crudOperation) {
      message = 'Você finalizou a receita! Deseja atualizar ?';
      btnMessage = 'Sim, atualizar receita!';
    }

    AlertDialog dialog = AlertDialog(
      title: Text('Confirmação', style: TextStyle(fontSize: 22)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.purple[900])),
            onPressed: () {
              _saveOrUpdateReceita();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(btnMessage, style: TextStyle(fontSize: 18)),
                Icon(Icons.check_circle)
              ],
            )),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.pink[800])),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Continuar editando...',
                        style: TextStyle(fontSize: 18)),
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  _saveOrUpdateReceita() {
    if (crudOperation == CrudOperation.CREATE) {
      _salvarReceita();
    } else if (crudOperation == CrudOperation.UPDATE) {
      _updateReceita();
    }
  }

  _showDialogCorrecoesReceita(List<String> errors) {
    AlertDialog dialog = AlertDialog(
      title: Text('ATENÇÃO'),
      actions: [
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.pink[900])),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text('OK'),
        )
      ],
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Necessário fazer as seguintes correções:\n ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Flexible(
              child: Container(
                width: Screen.of(context).width,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: errors.length,
                    itemBuilder: (context, index) {
                      var error = errors.elementAt(index);
                      return Row(
                        children: [
                          Flexible(
                              child: Text(
                            '$error\n',
                            style: TextStyle(fontSize: 16),
                          )),
                        ],
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  // _printReceita(Receita receita) {
  //   var ingredientes = receita.ingredientes;
  //   return Column(
  //     children: [
  //       Text(
  //         receita.nome,
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       Text('Ingredientes: ',
  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       ListView.builder(
  //           physics: NeverScrollableScrollPhysics(),
  //           shrinkWrap: true,
  //           itemCount: ingredientes.length,
  //           itemBuilder: (context, index) {
  //             var ingre = ingredientes.elementAt(index);
  //             return Text(
  //               '- ${ingre.descricao}',
  //               style: TextStyle(fontSize: 18),
  //             );
  //           }),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       Text(
  //         'Modo de preparo: ',
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  //       ),
  //       SizedBox(
  //         height: 10,
  //       ),
  //       ListView.builder(
  //           physics: NeverScrollableScrollPhysics(),
  //           shrinkWrap: true,
  //           itemCount: receita.secoes.length,
  //           itemBuilder: (context, index) {
  //             EtapaPreparo etapa = receita.secoes[index];
  //             return Text('${index + 1} - ${etapa.descricao}',
  //                 style: TextStyle(fontSize: 18));
  //           }),
  //       _widgetDetalhesPrintReceita(receita),
  //     ],
  //   );
  // }

  // _widgetDetalhesPrintReceita(Receita receita) {
  //   var checkTempoPreparo = TempoPreparoCheck(receita.tempoPreparo);
  //   var checkPorcoes = PorcoesCheck(receita.porcoes);
  //   if (checkTempoPreparo.isNotInformed() && checkPorcoes.isNotInformed()) {
  //     return Container();
  //   }
  //   return Container(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           _tempoLabelPrintReceita(receita.tempoPreparo),
  //           _porcoesLabelPrintReceita(receita.porcoes)
  //         ],
  //       ),
  //       margin: EdgeInsets.all(20),
  //       padding: EdgeInsets.symmetric(vertical: 10),
  //       decoration: BoxDecoration(
  //           border: Border.symmetric(
  //         horizontal: BorderSide(),
  //       )));
  // }

  _tempoLabelPrintReceita(Duration tempoPreparo) {
    var detalhesCheck = TempoPreparoCheck(tempoPreparo);
    if (detalhesCheck.isNotInformed()) {
      return Container();
    }
    String messageMinutos = 'Leva $tempoPreparo';
    return Row(
      children: [
        Icon(Icons.timer_outlined),
        SizedBox(width: 10),
        Text(messageMinutos),
      ],
    );
  }

  _porcoesLabelPrintReceita(int porcoes) {
    var detalhesCheck = PorcoesCheck(porcoes);
    if (detalhesCheck.isNotInformed()) {
      return Container();
    }

    String messagePorcoes = '';
    if (detalhesCheck.isSingular()) {
      messagePorcoes = 'Rende $porcoes porção';
    } else {
      messagePorcoes = 'Rende $porcoes porções';
    }
    return Row(
      children: [
        Icon(Icons.fastfood),
        SizedBox(width: 10),
        Text(messagePorcoes),
      ],
    );
  }

  _finalizarReceita() {
    List<String> errors = _createValidationsReceita();
    if (ListUtils.isNullOrEmpty(errors)) {
      _showDialogConfirmacaoReceita(receita);
    } else {
      _showDialogCorrecoesReceita(errors);
    }
  }

  _createValidationsReceita() {
    String nomeReceita = _nomeReceita();

    List<ImageUploaded> images = receita.images;
    int porcoes = receita.porcoes;
    String categoria = receita.categoria;
    Duration tempoPreparo = receita.tempoPreparo;

    List<String> errors = [];

    bool hasValidImage = images.any((imageReceita) {
      File file = imageReceita.file;
      String url = imageReceita.url;
      return file != null && !StringUtils.isNullOrEmpty(file.path) ||
          !StringUtils.isNullOrEmpty(url);
    });

    if (StringUtils.isNullOrEmpty(nomeReceita)) {
      errors.add('- Informar um nome para a receita.');
    } else if (nomeReceita.length < 3) {
      errors.add('- Nome da receita precisa ter no mínimo 3 caracteres.');
    }

    if (StringUtils.isNullOrEmpty(categoria)) {
      errors.add('- Informar uma categoria para a receita.');
    }

    List<SecaoReceita> secoesReceita = receita.secoes;

    if (ListUtils.isNullOrEmpty(secoesReceita)) {
      errors.add('- Necessário informar pelo menos uma seção à receita.');
    } else {
      for (SecaoReceita secao in secoesReceita) {
        List<Ingrediente> ingredientes = secao.ingredientes;

        if (ListUtils.isNullOrEmpty(ingredientes)) {
          errors.add(
              '- Necessário informar pelo menos um ingrediente em todas as seções.');
          break;
        }
      }

      for (SecaoReceita secao in secoesReceita) {
        List<EtapaPreparo> etapas = secao.modoDePreparo;

        if (ListUtils.isNullOrEmpty(etapas)) {
          errors.add(
              '- Necessário informar pelo menos uma etapa do modo de preparo em todas as seções.');
          break;
        }
      }

      for (SecaoReceita secao in secoesReceita) {
        String descricao = secao.descricao;

        if (StringUtils.isNullOrEmpty(descricao) && secoesReceita.length > 1) {
          errors.add('- Necessário informar a descrição para todas as seções.');
          break;
        }
      }
    }

    if (ListUtils.isNullOrEmpty(images) || !hasValidImage) {
      errors.add('- Informar no mínimo uma imagem para a receita.');
    }

    if (images.length > 5) {
      errors.add('- Número de imagens deve ser menor que 5.');
    }

    if (tempoPreparo == null || tempoPreparo == Duration.zero) {
      errors.add('- Informe o tempo de preparo da receita.');
    }

    if (porcoes <= 0) {
      errors.add('- Informe quantas pessoas a receita serve. ');
    }

    return errors;
  }

  _updateReceita() async {
    Navigator.of(context, rootNavigator: true).pop();
    _showLoadingDialog();

    try {
      receita.dateTime = DateTime.now();
      receita.userId = context.read<AuthCubit>().getUser().uid;
      receita.nome = _controllerNomeReceita.text
        ..trim()
        ..replaceAll('\n', '');
      await _reuploadFotosReceita(receita);
      await FirebaseRepository.uploadReceita(receita);
      _receitaCadastradaSucesso();
    } on Exception catch (e) {
      _erroCadastrarReceita(e);
    }
  }

  _reuploadFotosReceita(Receita receita) async {
    List<ImageUploaded> pickedImages = receita.images.where((image) {
      File file = image.file;
      return file != null && !StringUtils.isNullOrEmpty(file.path);
    }).toList();

    try {
      for (ImageUploaded image in pickedImages) {
        String url = await FirebaseRepository.uploadImageReceita(image);
        image.url = url;
      }
    } catch (e) {
      throw Exception('Erro ao salvar imagens da receita! $e');
    }
  }

  _salvarReceita() async {
    Navigator.of(context, rootNavigator: true).pop();
    _showLoadingDialog();

    try {
      receita.id = Uuid().v1();
      receita.userId = context.read<AuthCubit>().getUser().uid;
      receita.dateTime = DateTime.now();
      receita.nome = _controllerNomeReceita.text
        ..trim()
        ..replaceAll('\n', '');
      await _uploadFotosReceita(receita);
      await FirebaseRepository.uploadReceita(receita);
      _receitaCadastradaSucesso();
    } on Exception catch (e) {
      _erroCadastrarReceita(e);
    }
  }

  _erroCadastrarReceita(Exception e) {
    Navigator.of(context, rootNavigator: true).pop();
    String errorMessage =
        'Não foi possível cadastrar a receita! Tente novamente mais tarde!';
    log('$errorMessage - Erro: ${e.toString()}');

    var dialog = AlertDialog(
      title: Text('ALERTA'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              flex: 70,
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 18),
              )),
          SizedBox(height: 10),
          Flexible(
              flex: 30,
              child: Image.asset(
                MyAssets.SAD_COOKER,
              )),
        ],
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text('OK'))
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  _receitaCadastradaSucesso() {
    String message = '';
    if (crudOperation == CrudOperation.CREATE) {
      message = 'Receita criada com sucesso!';
    } else if (crudOperation == CrudOperation.UPDATE) {
      message = 'Receita atualizada com sucesso!';
    }
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);
    NavKeys.initialPage.currentState.popUntil((route) => route.isFirst);

    _navBarCubit.updateIndex(NavBarCubit.INDEX_FEED);
    String successMessage = message;
    _snack.show(successMessage);
    log(successMessage);
  }

  _uploadFotosReceita(Receita receita) async {
    List<ImageUploaded> images = receita.images;

    try {
      for (ImageUploaded image in images) {
        String url = await FirebaseRepository.uploadImageReceita(image);
        image.url = url;
      }
    } catch (e) {
      throw Exception('Erro ao salvar imagens da receita!');
    }
  }

  _showLoadingDialog() {
    String message = '';
    if (crudOperation == CrudOperation.CREATE) {
      message = 'Salvando receita...';
    } else if (crudOperation == CrudOperation.UPDATE) {
      message = 'Atualizando receita...';
    }
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 8), child: Text(message)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _etapaViewModel(
      {EtapaPreparo etapaPreparo, int position, int secaoPosition}) {
    return Card(
      key: ValueKey(position),
      color: Colors.yellow[200],
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${position + 1} - ${etapaPreparo.descricao}',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            IconButton(
                onPressed: () {
                  _etapaCubit.setEtapaToEdit(etapaPreparo);
                  _showModalEditOrDeleteEtapaPreparo(
                      position: position, secaoPosition: secaoPosition);
                },
                icon: Icon(Icons.more_horiz, color: Colors.black))
          ],
        ),
      ),
    );
  }

  _ingredienteViewModel(
      {Ingrediente ingrediente, int position, int secaoPosition}) {
    return Card(
      key: ValueKey(position),
      color: Colors.yellow[200],
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
                child: Text(
              '- ${ingrediente.descricao}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            )),
            IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                ),
                onPressed: () {
                  _showModalEditOrDeleteIngrediente(
                      ingrediente: ingrediente,
                      position: position,
                      secaoPosition: secaoPosition);
                })
          ],
        ),
      ),
    );
  }

  _popupMenuIngrediente(
      {Ingrediente ingrediente, int position, int secaoPosition}) {
    String descricaoIngrediente = ingrediente.descricao;
    return ModalMenu(
      headerColor: Colors.yellow[300],
      title: descricaoIngrediente,
      textColor: Colors.black,
      actions: [
        MenuActions.edit(() {
          _showDialogCreateIngrediente(
              ingrediente: ingrediente,
              position: position,
              secaoPosition: secaoPosition);
        }),
        MenuActions.delete(() {
          _receitaCubit.deleteIngrediente(
              ingredientePosition: position, secaoPosition: secaoPosition);
          Navigator.pop(context);
        })
      ],
    );
  }

  _showModalEditOrDeleteIngrediente(
      {Ingrediente ingrediente, int position, int secaoPosition}) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return DefaultModal(
              child: _popupMenuIngrediente(
                  ingrediente: ingrediente,
                  position: position,
                  secaoPosition: secaoPosition));
        });
  }

  _detalhesSection() {
    return Card(
        elevation: 10,
        color: Colors.red[100],
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(4),
            color: Colors.purple[900],
            child: Text(
              'Detalhes adicionais',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(
                  Icons.fastfood,
                  size: 30,
                ),
                SizedBox(width: 10),
                Flexible(child: _porcoesPicker())
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(
                  Icons.info_outlined,
                  size: 30,
                ),
                SizedBox(width: 10),
                Flexible(
                  child: AppTextField(
                    text: receita.extraInfo,
                    multiline: true,
                    controller: _extraInfoController,
                    minLength: 5,
                    maxLength: 50,
                    required: false,
                    onChanged: (value) {
                      _receitaCubit.updateExtraInfo(value);
                    },
                    hint: 'Escreva os detalhes...',
                    label: 'Informação adicional (opcional)',
                  ),
                ),
              ],
            ),
          ),
          _tempoPreparoPickerWidget(),
        ]));
  }

  _tempoPreparoPickerWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red[300])),
              onPressed: () async {
                Duration duration = await showDurationPicker(
                    context: context,
                    initialTime: receita.tempoPreparo,
                    snapToMins: 5);
                if (duration != null) {
                  _receitaCubit.updateTempoPreparo(duration);
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 25,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: BlocBuilder<NewReceitaCubit, ReceitaState>(
                        builder: (context, state) {
                      if (receita.tempoPreparo == Duration.zero) {
                        return Text(
                          'Tempo de preparo',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        );
                      }
                      return Text(
                        'Tempo de preparo  (${DurationUtils.formatDefault(receita.tempoPreparo)})',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      );
                    }),
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.white,
                  )
                ],
              )),
        ],
      ),
    );
  }

  _tempoPreparoDurationPicker() {
    return DurationPicker(
      duration: receita.tempoPreparo,
      snapToMins: 5,
      onChange: (value) {
        _receitaCubit.updateTempoPreparo(value);
      },
    );
  }

  _porcoesPicker() {
    int porcoes = receita.porcoes;
    if (porcoes == null || porcoes < 0) {
      porcoes = 0;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Quantas porções serve?',
            style: TextStyle(fontSize: 18),
          ),
        ),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red[50],
          ),
          child: SpinBox(
              decoration: InputDecoration(fillColor: Colors.red[100]),
              min: 0,
              max: 1000,
              value: porcoes.toDouble(),
              onChanged: (value) {
                _receitaCubit.updatePorcoes(value.toInt());
              }),
        ),
      ],
    );
  }

  _photosSection() {
    return Card(
      elevation: 10,
      color: Colors.red[100],
      child: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  color: Colors.purple[900],
                  child: Text(
                    'Selecione uma foto',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(5),
                  height: screen.width / 2,
                  width: screen.width / 2,
                  child: BlocBuilder<NewReceitaCubit, ReceitaState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          Flexible(child: _imageViewModel(position: 0)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _imageViewModel({int position}) {
    return GestureDetector(
      onTap: () {
        _pickImage(position: position);
      },
      child: Stack(
        children: [
          _imageOrPlaceholder(position: position),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 30,
              width: 30,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                  color: Colors.pink, borderRadius: BorderRadius.circular(50)),
            ),
          )
        ],
      ),
    );
  }

  _imageOrPlaceholder({int position}) {
    List<ImageUploaded> images = receita.images;
    ImageUploaded imageReceita = images.elementAt(position);
    File file = imageReceita.file;
    String url = imageReceita.url;

    Widget child;

    if (file != null && !StringUtils.isNullOrEmpty(file.path)) {
      child = Image.file(file);
    } else if (!StringUtils.isNullOrEmpty(url)) {
      child = Image.network(url);
    } else {
      child = Container(color: Colors.grey);
    }

    return ClipRRect(borderRadius: BorderRadius.circular(15), child: child);
  }

  _pickImage({int position}) async {
    try {
      XFile image = await ImagePicker().pickImage(source: ImageSource.gallery);
      _setupImage(position, image);
    } on PlatformException catch (e) {
      dialogs.showAlert(
          message: 'Não foi possível adicionar foto! \n ${e.message}');
    }
  }

  _setupImage(int position, XFile image) async {
    ImageManager imageManager = ImageManager();
    File file = File(image.path);
    File croppedFile =
        await imageManager.crop(file: file, ratioX: 1, ratioY: 0.8);

    log('after crop');

    File formattedFile = await ImageManager().compress(croppedFile);
    ImageUploaded imageReceita = ImageUploaded(file: File(formattedFile.path));
    _receitaCubit.salvarImagem(position: position, image: imageReceita);
    log('after save image');
  }

  _valueDropdownCategoria(Receita receita) {
    String categoria = receita.categoria;
    if (categoria == null) {
      return null;
    }
    return receita.categoria;
  }

  _initCategorias() {
    _categorias = CategoriaReceita.values
        .map((e) => DropdownMenuItem<String>(
              value: e,
              child: Container(
                child: Text(
                  e.capitalize(),
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ))
        .toList();
  }

  _titleSection() {
    return Card(
      elevation: 10,
      color: Colors.red[100],
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4),
              color: Colors.purple[900],
              child: Text(
                'Qual o nome da receita?',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(right: 20, left: 20),
              child: AppTextField(
                text: _nomeReceita(),
                textAlign: TextAlign.center,
                controller: _controllerNomeReceita,
                hint: 'Ex: Pão Caseiro',
                onChanged: (value) {
                  _receitaCubit.updateNomeReceita(value);
                },
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(4),
              color: Colors.purple[900],
              child: Text(
                'Qual o tipo da receita?',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            BlocBuilder<NewReceitaCubit, ReceitaState>(
                builder: (context, state) {
              return DropdownButton<String>(
                  hint: Text('Selecione...'),
                  alignment: Alignment.centerLeft,
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  value: _valueDropdownCategoria(receita),
                  items: _categorias,
                  onChanged: (value) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _receitaCubit.updateCategoria(value);
                  });
            })
          ],
        ),
      ),
    );
  }

  _dificuldadeSection() {
    return Card(
      elevation: 10,
      color: Colors.red[100],
      child: Container(
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(4),
            color: Colors.purple[900],
            child: Text(
              'Nível de Dificuldade',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _niveis.length,
              itemBuilder: (context, index) {
                String nivel = _niveis.elementAt(index);
                return RadioListTile<String>(
                    activeColor: Colors.pink[900],
                    title: Text(
                      nivel,
                      style: TextStyle(fontSize: 18),
                    ),
                    value: nivel,
                    groupValue: receita.dificuldade,
                    onChanged: (value) {
                      setState(() {
                        _indexNivelSelecionado = index;
                        _receitaCubit.updateDificuldadeReceita(value);
                      });
                    });
              }),
        ]),
      ),
    );
  }

  _showDialogCreateIngrediente(
      {Ingrediente ingrediente, int position, int secaoPosition}) {
    if (ingrediente != null) {
      _ingredienteController.text = ingrediente.descricao;
    }
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
                  ingrediente != null
                      ? 'Editar ingrediente'
                      : 'Novo Ingrediente',
                  style: TextStyle(fontSize: 22),
                ),
                GestureDetector(
                  onTap: () {
                    _ingredienteController.text = '';
                    FocusScope.of(context).requestFocus(FocusNode());
                    _hideKeyboard();
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
                BlocBuilder<NewReceitaCubit, ReceitaState>(
                    builder: (context, state) {
                  return Form(
                    autovalidateMode: _receitaCubit.autovalidateModeIngrediente,
                    key: _keyFormIngrediente,
                    child: Column(
                      children: [
                        AppTextField(
                            label: 'Descrição',
                            controller: _ingredienteController,
                            hint: 'Ex: 2 xícaras (chá) de açúcar',
                            required: true,
                            minLength: 3,
                            multiline: false,
                            errorAppendMode: ErrorAppendMode.FIRST),
                      ],
                    ),
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _saveIngredientWidget(
                      ingrediente: ingrediente,
                      secaoPosition: secaoPosition,
                      position: position,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _saveOrUpdateIngrediente(
                          ingrediente: ingrediente,
                          secaoPosition: secaoPosition,
                          position: position,
                          close: true,
                        );
                      },
                      child: Text(
                        'Salvar e fechar',
                        style: TextStyle(color: Colors.white),
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
        builder: (context) {
          return dialog;
        },
        barrierDismissible: false,
        context: context);
  }

  _saveIngredientWidget({
    Ingrediente ingrediente,
    int secaoPosition,
    int position,
  }) {
    //indica que eh atualizacao logo permite apenas salvar e fechar
    if (ingrediente != null) {
      return Container();
    }
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            _saveOrUpdateIngrediente(
              ingrediente: ingrediente,
              secaoPosition: secaoPosition,
              position: position,
              close: false,
            );
          },
          child: Text(
            'Salvar',
            style: TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.pink[800])),
        ),
        SizedBox(width: 5),
      ],
    );
  }

  _saveOrUpdateIngrediente({
    int position,
    int secaoPosition,
    Ingrediente ingrediente,
    bool close,
  }) {
    if (ingrediente == null) {
      _salvarIngrediente(
        secaoPosition: secaoPosition,
        close: close,
      );
    } else {
      _updateIngrediente(
        position: position,
        secaoPosition: secaoPosition,
        close: close,
      );
    }
  }

  // Atencao nesse metodo: foram utilizados buildContext e context para
  //diferenciar o context da pagina do context do dialogo.
  _showDialogCreateEtapa(
      {CrudOperation crudOperation, int position, int secaoPosition}) {
    // configurando como vazio, assim sera utilizado o valor da descricao salvo no cubit
    _etapaController.text = '';

    showDialog(
        barrierDismissible: false,
        builder: (buildContext) {
          return StatefulBuilder(builder: (buildContext, setState) {
            return Dialog(
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 12, right: 12),
                      child: GestureDetector(
                        onTap: () {
                          _etapaController.text = '';
                          FocusScope.of(context).requestFocus(FocusNode());
                          _hideKeyboard();
                          Navigator.of(buildContext, rootNavigator: true).pop();
                        },
                        child: Align(
                          alignment: Alignment.topRight,
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
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BlocBuilder<NewReceitaCubit, ReceitaState>(
                              builder: (buildContext, state) {
                            return Form(
                              autovalidateMode:
                                  _etapaCubit.autovalidateModeEtapa,
                              key: _keyFormEtapa,
                              child: Column(
                                children: [
                                  AppTextField(
                                      text: _etapaCubit.descricao,
                                      label: 'Nova etapa',
                                      controller: _etapaController,
                                      hint: 'Ex: Levar ao forno por 30min',
                                      required: true,
                                      minLength: 3,
                                      multiline: false,
                                      errorAppendMode: ErrorAppendMode.FIRST),
                                ],
                              ),
                            );
                          }),
                          Divider(thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _saveEtapaWidget(
                                crudOperation: crudOperation,
                                position: position,
                                secaoPosition: secaoPosition,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _updateOrCreateEtapa(
                                      crudOperation: crudOperation,
                                      position: position,
                                      secaoPosition: secaoPosition,
                                      close: true);
                                },
                                child: Text(
                                  'Salvar e fechar',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.pink[800])),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
        context: context);
  }

  _saveEtapaWidget({
    CrudOperation crudOperation,
    int secaoPosition,
    int position,
  }) {
    if (crudOperation == CrudOperation.UPDATE) {
      return Container();
    }
    return Row(children: [
      ElevatedButton(
        onPressed: () {
          _updateOrCreateEtapa(
              crudOperation: crudOperation,
              position: position,
              secaoPosition: secaoPosition,
              close: false);
        },
        child: Text(
          'Salvar',
          style: TextStyle(color: Colors.white),
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.pink[800])),
      ),
      SizedBox(width: 5),
    ]);
  }

  _updateOrCreateEtapa(
      {CrudOperation crudOperation,
      int position,
      int secaoPosition,
      bool close}) {
    EtapaPreparo etapaPreparo = EtapaPreparo(
        descricao: _etapaController.text, tempo: _etapaCubit.tempo);

    bool valid = _keyFormEtapa.currentState.validate();
    if (!valid) {
      _etapaCubit
          .updateAutoValidateModeEtapa(AutovalidateMode.onUserInteraction);
      return;
    }

    if (crudOperation == CrudOperation.CREATE) {
      _salvarEtapa(
        etapaPreparo: etapaPreparo,
        secaoPosition: secaoPosition,
        close: close,
      );
    } else {
      _updateEtapa(
        etapaPreparo: etapaPreparo,
        secaoPosition: secaoPosition,
        position: position,
        close: close,
      );
    }
  }

  _salvarEtapa({
    EtapaPreparo etapaPreparo,
    int secaoPosition,
    bool close,
  }) {
    _receitaCubit.addEtapa(etapa: etapaPreparo, secaoPosition: secaoPosition);
    _etapaCubit.updateAutoValidateModeEtapa(AutovalidateMode.disabled);
    _etapaController.text = '';
    if (close) {
      FocusScope.of(context).requestFocus(FocusNode());
      _hideKeyboard();
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  _updateEtapa({
    EtapaPreparo etapaPreparo,
    int position,
    int secaoPosition,
    bool close,
  }) {
    _receitaCubit.updateEtapaPreparo(
        etapaPreparo: etapaPreparo,
        etapaPosition: position,
        secaoPosition: secaoPosition);
    _etapaCubit.updateAutoValidateModeEtapa(AutovalidateMode.disabled);
    if (close) {
      FocusScope.of(context).requestFocus(FocusNode());
      _hideKeyboard();
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
    }
  }

  _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  _updateIngrediente({
    int position,
    int secaoPosition,
    bool close,
  }) {
    bool valid = _keyFormIngrediente.currentState.validate();
    if (!valid) {
      _receitaCubit.updateAutoValidateModeIngrediente(
          AutovalidateMode.onUserInteraction);
      return;
    }
    String descricaoIngrediente = _ingredienteController.text;
    Ingrediente ingrediente = Ingrediente(descricao: descricaoIngrediente);
    _receitaCubit.updateIngrediente(
        ingrediente: ingrediente,
        ingredientePosition: position,
        secaoPosition: secaoPosition);
    _receitaCubit.updateAutoValidateModeIngrediente(AutovalidateMode.disabled);
    _ingredienteController.text = '';

    if (close) {
      FocusScope.of(context).requestFocus(FocusNode());
      _hideKeyboard();
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
    }
  }

  _salvarIngrediente({int secaoPosition, bool close}) {
    bool valid = _keyFormIngrediente.currentState.validate();
    if (!valid) {
      _receitaCubit.updateAutoValidateModeIngrediente(
          AutovalidateMode.onUserInteraction);
      return;
    }
    String descricaoIngrediente = _ingredienteController.text;
    Ingrediente ingrediente = Ingrediente(descricao: descricaoIngrediente);
    _receitaCubit.addIngrediente(
        secaoPosition: secaoPosition, ingrediente: ingrediente);
    _receitaCubit.updateAutoValidateModeIngrediente(AutovalidateMode.disabled);
    _ingredienteController.text = '';

    if (close) {
      FocusScope.of(context).requestFocus(FocusNode());
      _hideKeyboard();
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  _etapasSection({List<EtapaPreparo> etapas, int secaoPosition}) {
    return Card(
      elevation: 10,
      color: Colors.pink[900],
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Modo de Preparo',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 5),
            Container(
              padding: EdgeInsets.all(5),
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.pink)),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Icon(Icons.add),
                        Text('Novo'),
                      ],
                    ),
                  ),
                  onPressed: () {
                    _etapaCubit.setEtapaToEdit(EtapaPreparo.empty());
                    _showDialogCreateEtapa(
                        crudOperation: CrudOperation.CREATE,
                        position: null,
                        secaoPosition: secaoPosition);
                  }),
            )
          ]),
          BlocBuilder<NewReceitaCubit, ReceitaState>(builder: (context, state) {
            return _etapasList(etapas: etapas, secaoPosition: secaoPosition);
          })
        ],
      ),
    );
  }

  _ingredientesSection({List<Ingrediente> ingredientes, int secaoPosition}) {
    return Card(
      color: Colors.pink[900],
      elevation: 10,
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Ingredientes',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.pink)),
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Icon(Icons.add),
                      Text('Novo'),
                    ],
                  ),
                ),
                onPressed: () {
                  _showDialogCreateIngrediente(
                      ingrediente: null,
                      position: null,
                      secaoPosition: secaoPosition);
                },
              ),
            )
          ]),
          BlocBuilder<NewReceitaCubit, ReceitaState>(builder: (context, state) {
            return _ingredientesList(
                ingredientes: ingredientes, secaoPosition: secaoPosition);
          })
        ],
      ),
    );
  }

  _etapasList({List<EtapaPreparo> etapas, int secaoPosition}) {
    if (ListUtils.isNullOrEmpty(etapas)) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: ReorderableListView.builder(
          onReorder: ((oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final EtapaPreparo item = etapas.removeAt(oldIndex);
            etapas.insert(newIndex, item);
          }),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: etapas.length,
          itemBuilder: (context, position) {
            var etapa = etapas.elementAt(position);
            return _etapaViewModel(
                etapaPreparo: etapa,
                position: position,
                secaoPosition: secaoPosition);
          }),
    );
  }

  _showModalEditOrDeleteSecao({int secaoPosition}) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return DefaultModal(
              child: _popupMenuSecao(secaoPosition: secaoPosition));
        });
  }

  _popupMenuSecao({int secaoPosition}) {
    SecaoReceita secao = receita.secoes.elementAt(secaoPosition);
    String descricao = secao.descricao;
    return ModalMenu(
      title: descricao,
      headerColor: Colors.purple[900],
      textColor: Colors.white,
      actions: [
        MenuActions.edit(() {
          _showDialogCreateSecao(
              secaoReceita: secao, secaoPosition: secaoPosition);
        }),
        MenuActions.delete(() {
          _receitaCubit.deleteSecao(
            secaoPosition: secaoPosition,
          );
          Navigator.pop(context);
        })
      ],
    );
  }

  _showModalEditOrDeleteEtapaPreparo({int position, int secaoPosition}) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return DefaultModal(
              child: _popupMenuEtapaPreparacao(
                  position: position, secaoPosition: secaoPosition));
        });
  }

  _popupMenuEtapaPreparacao({int position, int secaoPosition}) {
    String descricao = _etapaCubit.descricao;
    return ModalMenu(
      title: '${position + 1} - $descricao',
      headerColor: Colors.yellow[300],
      textColor: Colors.black,
      actions: [
        MenuActions.edit(() {
          _showDialogCreateEtapa(
              crudOperation: CrudOperation.UPDATE,
              position: position,
              secaoPosition: secaoPosition);
        }),
        MenuActions.delete(() {
          _deleteEtapaPreparacao(
              position: position, secaoPosition: secaoPosition);
          Navigator.pop(context);
        })
      ],
    );
  }

  _deleteEtapaPreparacao({int position, int secaoPosition}) {
    _receitaCubit.deleteEtapaPreparacao(
        position: position, secaoPosition: secaoPosition);
  }

  _ingredientesList({List<Ingrediente> ingredientes, int secaoPosition}) {
    if (ListUtils.isNullOrEmpty(ingredientes)) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: ReorderableListView.builder(
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Ingrediente item = ingredientes.removeAt(oldIndex);
            ingredientes.insert(newIndex, item);
          },
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ingredientes.length,
          itemBuilder: (context, position) {
            var ingrediente = ingredientes.elementAt(position);
            return _ingredienteViewModel(
                ingrediente: ingrediente,
                position: position,
                secaoPosition: secaoPosition);
          }),
    );
  }

  // _videoViewModel() {
  //   log('building receita video path: ${receita.video.path} chewie:${_chewieController.toString()}');
  //   File videoFile = _receitaCubit.receita.video;

  //   Widget child;
  //   if (StringUtils.isNullOrEmpty(videoFile.path) ||
  //       _chewieController == null) {
  //     child = Stack(
  //       children: [
  //         ClipRRect(
  //             borderRadius: BorderRadius.circular(15),
  //             child: Container(color: Colors.grey)),
  //         Positioned(
  //           bottom: 0,
  //           right: 0,
  //           child: Container(
  //             height: 30,
  //             width: 30,
  //             child: Icon(
  //               Icons.add,
  //               color: Colors.white,
  //             ),
  //             decoration: BoxDecoration(
  //                 color: Colors.pink, borderRadius: BorderRadius.circular(50)),
  //           ),
  //         )
  //       ],
  //     );
  //   } else {
  //     child = Container(
  //         color: Palete().darkPurple,
  //         height: 200,
  //         width: screen.width,
  //         child: Chewie(controller: _chewieController));
  //   }
  //   return GestureDetector(
  //       onTap: () {
  //         _pickVideo();
  //       },
  //       child: child);
  // }

  // Future<void> _loadAd() async {
  //   if (_premiumCubit.isPremiumMode()) {
  //     return;
  //   }
  //   AdSize size = await AdUtils.getAdaptativeSize(context);
  //   AdState adState = Provider.of<AdState>(context, listen: false);
  //   adState.initialization.then((value) => {
  //         setState(() {
  //           banner = BannerAd(
  //               adUnitId: MyAds.crudReceitaBannerAd,
  //               size: size,
  //               request: AdRequest(),
  //               listener: adState.adListener)
  //             ..load();
  //         })
  //       });
  // }
}
