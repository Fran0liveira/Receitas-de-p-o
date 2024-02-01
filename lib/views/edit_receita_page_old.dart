// import 'dart:developer';
// import 'dart:io';

// import 'package:bottom_drawer/bottom_drawer.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:full_screen_image/full_screen_image.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:receitas_de_pao/ads/ad_state.dart';
// import 'package:receitas_de_pao/ads/ad_utils.dart';
// import 'package:receitas_de_pao/ads/my_ads.dart';
// import 'package:receitas_de_pao/components/app_textfield.dart';
// import 'package:receitas_de_pao/components/app_textfield_style.dart';
// import 'package:receitas_de_pao/components/default_modal.dart';
// import 'package:receitas_de_pao/components/menu_actions.dart';
// import 'package:receitas_de_pao/components/modal_menu.dart';
// import 'package:receitas_de_pao/components/my_spin_box.dart';
// import 'package:receitas_de_pao/components/snack_message.dart';
// import 'package:receitas_de_pao/enums/app_categorias.dart';
// import 'package:receitas_de_pao/enums/app_routes.dart';
// import 'package:receitas_de_pao/enums/crud_operation.dart';
// import 'package:receitas_de_pao/enums/index_fluxo_receita.dart';
// import 'package:receitas_de_pao/extensions/string_extensions.dart';
// import 'package:receitas_de_pao/models/fluxo_receita/etapa_fluxo_receita.dart';
// import 'package:receitas_de_pao/models/fluxo_receita/ingredientes_etapa.dart';
// import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
// import 'package:receitas_de_pao/models/my_app/image_receita.dart';
// import 'package:receitas_de_pao/models/my_app/ingrediente.dart';
// import 'package:receitas_de_pao/models/my_app/receita.dart';
// import 'package:receitas_de_pao/repository/firebase_repository.dart';
// import 'package:receitas_de_pao/services/detalhes_check.dart';
// import 'package:receitas_de_pao/services/image_manager.dart';
// import 'package:receitas_de_pao/services/tempo_preparo_check.dart';
// import 'package:receitas_de_pao/state/auth_state/auth_cubit.dart';
// import 'package:receitas_de_pao/state/receita_state/receita_cubit.dart';
// import 'package:receitas_de_pao/state/receita_state/receita_state.dart';
// import 'package:receitas_de_pao/style/palete.dart';
// import 'package:receitas_de_pao/utils/arguments.dart';
// import 'package:receitas_de_pao/utils/assets.dart';
// import 'package:receitas_de_pao/utils/dialogs.dart';
// import 'package:receitas_de_pao/utils/list_utils.dart';
// import 'package:receitas_de_pao/utils/screen.dart';
// import 'package:receitas_de_pao/utils/string_utils.dart';
// import 'package:uuid/uuid.dart';
// import 'package:video_player/video_player.dart';

// import '../models/my_app/image_receita.dart';

// class EditReceitaPage extends StatefulWidget {
//   @override
//   _EditReceitaPageState createState() => _EditReceitaPageState();
// }

// class _EditReceitaPageState extends State<EditReceitaPage>
//     with SingleTickerProviderStateMixin {
//   TextEditingController _nomeReceitaController = TextEditingController();
//   TextEditingController _ingredienteController = TextEditingController();
//   TextEditingController _etapaPreparacaoController = TextEditingController();
//   VideoPlayerController _videoController;
//   ChewieController _chewieController;
//   Screen screen;
//   List<DropdownMenuItem<String>> _categorias;

//   List<String> _textTabs = [
//     'Início',
//     'Ingredientes',
//     'Modo de Preparo',
//     'Fotos',
//     'Detalhes',
//   ];

//   TabController _tabController;
//   SnackMessage snackMessage;
//   Dialogs dialogs;
//   Palete palete;
//   ReceitaCubit _receitaCubit;
//   BottomDrawerController bottomDrawerController;
//   int headerHeight = 50;
//   BannerAd banner;
//   InterstitialAd _interstitialAd;
//   int _interstitialLoadAttempts = 0;
//   int _maxFailedLoadAttempts = 3;

//   @override
//   void initState() {
//     super.initState();
//     _createInterstitialAd();
//     _initCategorias();
//     _receitaCubit = context.read<ReceitaCubit>();
//     _receitaCubit.reset();

//     TabController(initialIndex: 0, length: _textTabs.length, vsync: this);
//     palete = Palete();
//     bottomDrawerController = BottomDrawerController();
//   }

//   _createInterstitialAd() {
//     InterstitialAd.load(
//       adUnitId: MyAds.intersticialTerminoCadastroReceitaAd,
//       request: AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
//         _interstitialAd = ad;
//         _interstitialLoadAttempts = 0;
//       }, onAdFailedToLoad: (error) {
//         log('Erro ao carregar anuncio intersticial. Erro: $error');
//         _interstitialLoadAttempts++;
//         _interstitialAd = null;
//         if (_interstitialLoadAttempts <= _maxFailedLoadAttempts) {
//           _createInterstitialAd();
//         }
//       }),
//     );
//   }

//   _initCategorias() {
//     _categorias = CategoriaReceita.values
//         .map((e) => DropdownMenuItem<String>(
//               value: e,
//               child: Container(
//                 child: Text(
//                   e.capitalize(),
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ))
//         .toList();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     //_loadBannerAd();
//   }

//   _setupReceita() {
//     log('handling receita');
//     try {
//       Receita receitaArgument =
//           ModalRoute.of(context).settings.arguments as Receita;
//       log('receita argument: $receitaArgument');
//       if (receitaArgument == null || receitaArgument == Receita.empty()) {
//         //definir criacao
//       } else {
//         //definir edicao
//         _receitaCubit.setReceita(receitaArgument);
//         log('setting receita');
//       }
//     } catch (e) {
//       log('erro argument receita: $e');
//     }
//   }

//   // _loadBannerAd() async {
//   //   AdSize size = await AdUtils.getAdaptativeSize(context);
//   //   final adState = Provider.of<AdState>(context, listen: false);
//   //   adState.initialization.then((value) => {
//   //         setState(() {
//   //           banner = BannerAd(
//   //               adUnitId: MyAds.novaReceitaBannerAd,
//   //               size: size,
//   //               request: AdRequest(),
//   //               listener: adState.adListener)
//   //             ..load();
//   //         })
//   //       });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     screen = Screen(context);
//     snackMessage = SnackMessage(context);
//     dialogs = Dialogs(context);
//     _setupReceita();

//     return DefaultTabController(
//         initialIndex: 0,
//         length: _textTabs.length,
//         child: WillPopScope(
//           onWillPop: _onWillPop,
//           child: Scaffold(
//               resizeToAvoidBottomInset: false,
//               appBar: AppBar(
//                 automaticallyImplyLeading: false,
//                 backgroundColor: Colors.pink[600],
//                 title: BlocBuilder<ReceitaCubit, ReceitaState>(
//                   builder: (context, state) {
//                     DefaultTabController.of(context)
//                         .animateTo(state.currentEtapa.index);
//                     return _tabBarEtapas();
//                   },
//                 ),
//               ),
//               body: SafeArea(
//                   child: Stack(
//                 children: [
//                   Column(
//                     children: [
//                       _anuncio(),
//                       Expanded(
//                         child: Container(
//                           padding: EdgeInsets.all(10),
//                           alignment: Alignment.center,
//                           child: SingleChildScrollView(
//                             child: BlocBuilder<ReceitaCubit, ReceitaState>(
//                               builder: (context, state) {
//                                 return Column(children: [
//                                   _getCurrentWidget(state),
//                                   _nextBackControl(),
//                                   SizedBox(
//                                     height: 40,
//                                   ),
//                                   Container(height: screen.keyboardHeigth)
//                                 ]);
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   BlocBuilder<ReceitaCubit, ReceitaState>(
//                       builder: (context, state) {
//                     return _bottomDrawer();
//                   }),
//                 ],
//               ))),
//         ));
//   }

//   _getCurrentWidget(ReceitaState state) {
//     EtapaFluxoReceita etapa = state.currentEtapa;
//     if (etapa.index == IndexFluxoReceita.NOME_RECEITA) {
//       return _editNomeReceita();
//     } else if (etapa.index == IndexFluxoReceita.INGREDIENTES) {
//       return _ingredientesCard();
//     } else if (etapa.index == IndexFluxoReceita.MODO_DE_PREPARO) {
//       return _modoDePreparoCard();
//     } else if (etapa.index == IndexFluxoReceita.FOTOS) {
//       return _recursosCard();
//     } else if (etapa.index == IndexFluxoReceita.DETALHES) {
//       return _detalhesCard();
//     }
//     return Container();
//   }

//   _categoriaDropDown() {
//     var receita = _receitaCubit.receita;
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(5),
//         color: Colors.green[50],
//       ),
//       padding: EdgeInsets.all(10),
//       width: screen.width,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Qual o tipo da receita? ',
//             style: TextStyle(fontSize: 18),
//           ),
//           DropdownButton<String>(
//               hint: Text('Selecione...'),
//               alignment: Alignment.centerLeft,
//               style: TextStyle(fontSize: 18, color: Colors.black),
//               value: _valueDropdownCategoria(receita),
//               items: _categorias,
//               onChanged: (value) {
//                 _receitaCubit.updateCategoria(value);
//               }),
//         ],
//       ),
//     );
//   }

//   _valueDropdownCategoria(Receita receita) {
//     String categoria = receita.categoria;
//     if (categoria == null || categoria == CategoriaReceita.OUTRA) {
//       return null;
//     }
//     return receita.categoria;
//   }

//   Widget _bottomDrawer() {
//     return BottomDrawer(
//       callback: (opened) {
//         log('expandindo: $opened');

//         _receitaCubit.updateReceitaExpanded(opened);
//       },
//       cornerRadius: 30,
//       controller: bottomDrawerController,
//       header: GestureDetector(
//         child: _titleReceita(),
//         onTap: () {
//           if (_receitaCubit.receitaExpanded) {
//             bottomDrawerController.close();
//           } else {
//             bottomDrawerController.open();
//           }
//           _receitaCubit.switchReceitaExpanded();
//         },
//       ),
//       body: SingleChildScrollView(
//         child: _receitaCompleta(),
//       ),
//       headerHeight: headerHeight.toDouble(),
//       drawerHeight: screen.height * 0.8,
//       color: Colors.amber[300],
//     );
//   }

//   _detalhesCard() {
//     return Column(
//       children: [
//         Container(
//           alignment: Alignment.topLeft,
//           padding: EdgeInsets.all(10),
//           child: Text(
//             'Quantos minutos para preparar?',
//             style: TextStyle(fontSize: 18),
//           ),
//         ),
//         _tempoPreparoPicker(),
//         SizedBox(height: 10),
//         Container(
//           alignment: Alignment.topLeft,
//           padding: EdgeInsets.all(10),
//           child: Text(
//             'Quantas pessoas serve?',
//             style: TextStyle(fontSize: 18),
//           ),
//         ),
//         _porcoesPicker(),
//       ],
//     );
//   }

//   _titleReceita() {
//     String nomeReceita = _receitaCubit.receita.nome;
//     if (StringUtils.isNullOrEmpty(nomeReceita)) {
//       nomeReceita = 'Minha receita';
//     }
//     return Container(
//       height: headerHeight.toDouble(),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         color: Colors.amber[300],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             nomeReceita,
//             style: TextStyle(
//               fontSize: 20,
//               color: Colors.pink[900],
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Icon(
//             _receitaCubit.receitaExpanded
//                 ? Icons.arrow_drop_down_outlined
//                 : Icons.arrow_drop_up_outlined,
//             color: Colors.pink[900],
//           )
//         ],
//       ),
//     );
//   }

//   _tempoPreparoPicker() {
//     Duration tempoPreparo = _receitaCubit.receita.tempoPreparo;
//     var tempoPreparoCheck = TempoPreparoCheck(tempoPreparo);
//     if (tempoPreparoCheck.isNotInformed()) {
//       tempoPreparo = Duration.zero;
//     }
//     return MySpinBox(
//       icon: Icon(
//         Icons.timer,
//         color: Colors.white,
//       ),
//       header: 'Tempo de Preparo',
//       min: 0,
//       max: 1000,
//       value: 0,
//       onChanged: (value) {
//         //_receitaCubit.updateTempoPreparo(value.toInt());
//       },
//     );
//   }

//   _porcoesPicker() {
//     int porcoes = _receitaCubit.receita.porcoes;
//     if (porcoes == null || porcoes < 0) {
//       porcoes = 0;
//     }
//     return MySpinBox(
//       icon: Icon(
//         Icons.fastfood,
//         color: Colors.white,
//       ),
//       header: 'Porções',
//       min: 0,
//       max: 1000,
//       value: porcoes.toDouble(),
//       onChanged: (value) {
//         _receitaCubit.updatePorcoes(value.toInt());
//       },
//     );
//   }

//   _recursosCard() {
//     return Column(
//       children: [
//         Container(
//           alignment: Alignment.topLeft,
//           padding: EdgeInsets.all(10),
//           child: Text(
//             'Vamos adicionar uma foto...',
//             style: TextStyle(fontSize: 30),
//           ),
//         ),
//         SizedBox(height: 30),
//         // _btnAdicionarFotos(),
//         // _imageGallery(),
//         Flexible(child: _newImageWidget()),
//         SizedBox(
//           height: 10,
//         ),
//         // _btnAdicionarVideos(),
//         // _receitaVideo()
//       ],
//     );
//   }

//   _newImageWidget() {
//     return Column(
//       children: [
//         Expanded(
//           child: Container(
//               decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             color: Colors.grey,
//           )),
//         ),
//       ],
//     );
//   }

//   _receitaVideo() {
//     File videoFile = _receitaCubit.receita.video;
//     if (StringUtils.isNullOrEmpty(videoFile.path) ||
//         _chewieController == null) {
//       return Container();
//     }
//     log('video: $videoFile');
//     return Container(
//         color: palete.darkPurple,
//         height: 200,
//         width: screen.width,
//         child: Chewie(controller: _chewieController));
//   }

//   _imageGallery() {
//     Receita receita = _receitaCubit.receita;
//     List<ImageReceita> images = receita.images;
//     if (ListUtils.isNullOrEmpty(images)) {
//       return Container();
//     }
//     return Container(
//       color: palete.darkPurple,
//       child: CarouselSlider.builder(
//         options: CarouselOptions(
//           height: 200,
//           enableInfiniteScroll: false,
//           enlargeCenterPage: true,
//         ),
//         itemCount: images.length,
//         itemBuilder: (context, position, realPosition) {
//           ImageReceita file = images[position];
//           return _imageViewModel(file, position, images);
//         },
//       ),
//     );
//     // return Container(
//     //   height: 300,
//     //   child: ListView.builder(
//     //     scrollDirection: Axis.horizontal,
//     //     shrinkWrap: true,
//     //     itemCount: images.length,
//     //     itemBuilder: (context, position) {
//     //       File fileImage = images[position];
//     //       return _imageViewModel(fileImage);
//     //     },
//     //   ),
//     // );
//   }

//   _imageViewModel(ImageReceita image, int position, List<ImageReceita> images) {
//     return GestureDetector(
//       child: Container(
//         decoration: BoxDecoration(color: Color(0xff430645)),
//         height: 300,
//         width: 300,
//         padding: EdgeInsets.symmetric(vertical: 5),
//         child: FullScreenWidget(
//           child: Hero(
//             tag: '$position',
//             child: Image.file(
//               image.file,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   _btnAdicionarVideos() {
//     return Column(
//       children: [
//         Container(
//           height: 50,
//           child: ElevatedButton(
//             onPressed: _pickVideo,
//             style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.resolveWith(
//                     (states) => Colors.purple[800])),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Adicionar vídeo',
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                 ),
//                 Icon(Icons.ondemand_video),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   _pickVideo() async {
//     try {
//       XFile video = await ImagePicker().pickVideo(source: ImageSource.gallery);
//       if (video == null) {
//         return;
//       }
//       File videoFile = File(video.path);

//       _videoController = VideoPlayerController.file(videoFile);

//       await _videoController.initialize();
//       _chewieController = ChewieController(
//         videoPlayerController: _videoController,
//       );
//       _receitaCubit.salvarVideo(videoFile);
//     } on PlatformException catch (e) {
//       dialogs.showAlert(
//           message: 'Não foi possível adicionar vídeo! \n ${e.message}');
//     }
//   }

//   _btnAdicionarFotos() {
//     return Container(
//         height: 50,
//         child: ElevatedButton(
//           style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.resolveWith(
//                   (states) => Colors.purple[800])),
//           onPressed: _pickImage,
//           child: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Adicionar fotos',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ),
//               Icon(Icons.image),
//             ],
//           ),
//         ));
//   }

//   _pickImage() async {
//     try {
//       List<ImageReceita> imagesReceita = _receitaCubit.receita.images;
//       List<XFile> images = await ImagePicker().pickMultiImage();
//       int imagesTotalSize = imagesReceita.length + images.length;
//       if (imagesTotalSize > 1) {
//         _receitaCubit.receita.images.removeAt(0);
//       }
//       _setupImages(images);
//     } on PlatformException catch (e) {
//       dialogs.showAlert(
//           message: 'Não foi possível adicionar foto! \n ${e.message}');
//     }
//   }

//   _setupImages(List<XFile> images) async {
//     if (ListUtils.isNullOrEmpty(images)) {
//       return;
//     }

//     List<ImageReceita> receitaImages = [];
//     for (XFile file in images) {
//       File formattedFile = await ImageManager().compress(File(file.path));
//       receitaImages.add(ImageReceita(file: File(formattedFile.path)));
//     }
//     _receitaCubit.salvarImagens(receitaImages);
//   }

//   _popupMenuEtapaPreparacao(EtapaPreparo etapaPreparacao, int position) {
//     return ModalMenu(
//       title: _printEtapaPreparacao(etapaPreparacao, position),
//       headerColor: Colors.pink[900],
//       actions: [
//         MenuActions.edit(() {
//           _etapaPreparacaoController.text = etapaPreparacao.descricao;

//           _receitaCubit
//             ..updateCrudOperationEtapaPreparacao(CrudOperation.UPDATE)
//             ..putEtapaPreparacaoPosition(position);

//           Navigator.of(context).pop();
//           _receitaCubit.updateIndexFluxo(IndexFluxoReceita.MODO_DE_PREPARO);
//           bottomDrawerController.close();
//         }),
//         MenuActions.delete(() {
//           _deleteEtapaPreparacao(position);
//           Navigator.pop(context);
//           snackMessage.show("Etapa excluída com sucesso!");
//         })
//       ],
//     );
//   }

//   _popupMenuIngrediente(Ingrediente ingrediente, int position) {
//     String descricaoIngrediente = ingrediente.descricao;
//     return ModalMenu(
//       headerColor: Colors.pink[900],
//       title: descricaoIngrediente,
//       actions: [
//         MenuActions.edit(() {
//           _ingredienteController.text = ingrediente.descricao;

//           _receitaCubit
//             ..updateCrudOperationIngrediente(CrudOperation.UPDATE)
//             ..putIngredienteToEditPosition(position);

//           Navigator.of(context).pop();
//           _receitaCubit.updateEtapa(IngredientesEtapa());
//           bottomDrawerController.close();
//         }),
//         MenuActions.delete(() {
//           _deleteIngrediente(position);
//           Navigator.pop(context);
//           snackMessage.show(
//               "Ingrediente '$descricaoIngrediente' excluído com sucesso!");
//         })
//       ],
//     );
//   }

//   _tabBarEtapas() {
//     return TabBar(
//         onTap: (index) {
//           _receitaCubit.updateIndexFluxo(index);
//         },
//         controller: _tabController,
//         labelStyle: TextStyle(
//           fontSize: 16,
//         ),
//         isScrollable: true,
//         tabs: _textTabs
//             .map((text) => Tab(
//                   text: text,
//                 ))
//             .toList());
//   }

//   _modoDePreparoCard() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Text('Quais são as etapas ?',
//                 style: TextStyle(fontSize: 28),
//                 textAlign: TextAlign.left,
//                 overflow: TextOverflow.fade),
//           ],
//         ),
//         SizedBox(height: 30),
//         Row(mainAxisSize: MainAxisSize.max, children: [
//           Flexible(child: _editTextEtapaPreparacao()),
//           SizedBox(
//             width: 10,
//           ),
//           _btnActionEtapaPreparacao(),
//         ]),
//       ],
//     );
//   }

//   _editTextEtapaPreparacao() {
//     CrudOperation crudOperationEtapaPreparacao =
//         _receitaCubit.crudOperationEtapaPreparacao;

//     if (crudOperationEtapaPreparacao == CrudOperation.CREATE) {
//       return AppTextField(
//         multiline: true,
//         label: 'Nova etapa de preparação',
//         hint: 'Ex: Levar ao forno',
//         controller: _etapaPreparacaoController,
//       );
//     } else {
//       return AppTextField(
//         hint: 'Editar etapa de preparação',
//         multiline: true,
//         controller: _etapaPreparacaoController,
//         onChanged: (value) {
//           _receitaCubit.updateEtapaPreparacao(value);
//         },
//       );
//     }
//   }

//   _salvarEtapaPreparacao() {
//     EtapaPreparo etapaModoDePreparo =
//         EtapaPreparo(descricao: _etapaPreparacaoController.text);
//     if (StringUtils.isNullOrEmpty(etapaModoDePreparo.descricao)) {
//       dialogs.showAlert(
//           message: 'Informe a descrição do etapa do modo de preparo!');
//       return;
//     }
//     _receitaCubit.salvarEtapaModoDePreparo(etapaModoDePreparo);
//     _etapaPreparacaoController.text = '';
//     _hideKeyboard();
//   }

//   _editNomeReceita() {
//     return Container(
//       child: Column(
//         mainAxisSize: MainAxisSize.max,
//         children: [
//           Row(
//             children: [
//               Flexible(
//                 child: Text('O que estamos preparando?',
//                     style: TextStyle(
//                       fontSize: 30,
//                     ),
//                     textAlign: TextAlign.left),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           Align(
//             child: Row(children: [
//               Flexible(flex: 80, child: _categoriaDropDown()),
//               SizedBox(
//                 width: 20,
//               ),
//               Flexible(flex: 20, child: Image.asset(MyAssets.HAPPY_COOKER))
//             ]),
//             alignment: Alignment.topLeft,
//           ),
//           AppTextField(
//             hint: 'Ex: Bolo de Cenoura',
//             label: 'Qual o nome do prato?',
//             controller: _nomeReceitaController,
//             style: AppTextFieldStyle(fontSize: 18),
//             onChanged: (value) {
//               _receitaCubit.updateName(value);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   _ingredientesCard() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Text('Quais são os ingredientes?',
//                 style: TextStyle(fontSize: 28),
//                 textAlign: TextAlign.left,
//                 overflow: TextOverflow.fade),
//           ],
//         ),
//         SizedBox(height: 30),
//         Row(
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Flexible(
//               child: _editTextIngrediente(),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             _btnActionIngrediente(),
//           ],
//         ),
//       ],
//     );
//   }

//   _btnActionIngrediente() {
//     CrudOperation crudOperationIngrediente =
//         _receitaCubit.crudOperationIngrediente;

//     if (crudOperationIngrediente == CrudOperation.CREATE) {
//       return ElevatedButton(
//           onPressed: _salvarIngrediente,
//           child: Icon(
//             Icons.add,
//             color: Colors.white,
//           ));
//     } else {
//       return ElevatedButton(
//           onPressed: _updateIngrediente,
//           child: Icon(
//             Icons.check,
//             color: Colors.white,
//           ));
//     }
//   }

//   _btnActionEtapaPreparacao() {
//     CrudOperation crudOperationEtapaPreparacao =
//         _receitaCubit.crudOperationEtapaPreparacao;

//     if (crudOperationEtapaPreparacao == CrudOperation.CREATE) {
//       return ElevatedButton(
//           onPressed: _salvarEtapaPreparacao,
//           child: Icon(
//             Icons.add,
//             color: Colors.white,
//           ));
//     } else {
//       return ElevatedButton(
//           onPressed: _updateEtapaPreparacao,
//           child: Icon(
//             Icons.check,
//             color: Colors.white,
//           ));
//     }
//   }

//   _updateEtapaPreparacao() {
//     _receitaCubit.updateCrudOperationEtapaPreparacao(CrudOperation.CREATE);
//     _etapaPreparacaoController.text = '';
//     _hideKeyboard();
//   }

//   _updateIngrediente() {
//     _receitaCubit.updateCrudOperationIngrediente(CrudOperation.CREATE);
//     _ingredienteController.text = '';
//     _hideKeyboard();
//   }

//   _editTextIngrediente() {
//     CrudOperation crudOperationIngrediente =
//         _receitaCubit.crudOperationIngrediente;

//     if (crudOperationIngrediente == CrudOperation.CREATE) {
//       return AppTextField(
//         multiline: true,
//         label: 'Novo ingrediente',
//         hint: 'Ex: 2 xícaras de açúcar',
//         controller: _ingredienteController,
//       );
//     } else {
//       return AppTextField(
//         hint: 'Editar Ingrediente',
//         controller: _ingredienteController,
//         onChanged: (value) {
//           _receitaCubit.updateDescricaoIngrediente(value);
//         },
//       );
//     }
//   }

//   _salvarIngrediente() {
//     String descricaoIngrediente = _ingredienteController.text;
//     if (StringUtils.isNullOrEmpty(descricaoIngrediente)) {
//       dialogs.showAlert(
//           message: 'Informe a descrição para salvar o ingrediente!');
//       return;
//     }
//     Ingrediente ingrediente = Ingrediente(descricao: descricaoIngrediente);
//     _receitaCubit.salvarIngrediente(ingrediente);
//     _ingredienteController.text = '';
//     _hideKeyboard();
//   }

//   _receitaCompleta() {
//     Receita receita = _receitaCubit.receita;
//     return Column(
//       children: [
//         _ingredientesSection(receita),
//         SizedBox(height: 10),
//         _modoDePreparoSection(receita),
//         SizedBox(height: 10),
//         _detalhesSection(receita),
//       ],
//     );
//   }

//   _detalhesSection(Receita receita) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       child: Column(
//         children: [
//           _tempoPreparoWidget(receita.tempoPreparo),
//           _porcoesLabel(receita.porcoes),
//         ],
//       ),
//     );
//   }

//   _tempoPreparoWidget(Duration tempoPreparo) {
//     var detalhesCheck = TempoPreparoCheck(tempoPreparo);
//     if (detalhesCheck.isNotInformed()) {
//       return Container();
//     }
//     String messageMinutos = 'Leva $tempoPreparo';
//     return Row(
//       children: [
//         Icon(Icons.timer_rounded),
//         SizedBox(
//           width: 10,
//         ),
//         Text(
//           messageMinutos,
//           style: TextStyle(fontSize: 15),
//         ),
//       ],
//     );
//   }

//   _porcoesLabel(int porcoes) {
//     var detalhesCheck = PorcoesCheck(porcoes);
//     if (detalhesCheck.isNotInformed()) {
//       return Container();
//     }

//     String messagePorcoes = '';
//     if (detalhesCheck.isSingular()) {
//       messagePorcoes = 'Rende $porcoes porção';
//     } else {
//       messagePorcoes = 'Rende $porcoes porções';
//     }
//     return Row(
//       children: [
//         Icon(Icons.fastfood),
//         SizedBox(
//           width: 10,
//         ),
//         Text(
//           messagePorcoes,
//           style: TextStyle(fontSize: 15),
//         ),
//       ],
//     );
//   }

//   _modoDePreparoSection(Receita receita) {
//     // List<EtapaPreparo> modoDePreparo = receita.secoesReceita;
//     // if (ListUtils.isNullOrEmpty(modoDePreparo)) {
//     //   return Container();
//     // }
//     // return Column(
//     //   children: [
//     //     SizedBox(height: 10),
//     //     Text(
//     //       'Modo de preparo',
//     //       style: TextStyle(fontSize: 18),
//     //     ),
//     //     SizedBox(height: 10),
//     //     ReorderableListView.builder(
//     //       physics: NeverScrollableScrollPhysics(),
//     //       shrinkWrap: true,
//     //       itemCount: modoDePreparo.length,
//     //       itemBuilder: (context, position) {
//     //         EtapaPreparo etapaPreparacao =
//     //             receita.secoesReceita.elementAt(position);
//     //         return _etapaPreparacaoViewModel(etapaPreparacao, position);
//     //       },
//     //       onReorder: (oldIndex, newIndex) {
//     //         setState(() {
//     //           if (newIndex > oldIndex) {
//     //             newIndex = newIndex - 1;
//     //           }
//     //           final item = modoDePreparo.removeAt(oldIndex);
//     //           modoDePreparo.insert(newIndex, item);
//     //         });
//     //       },
//     //     )
//     //   ],
//     // );
//   }

//   _etapaPreparacaoViewModel(EtapaPreparo etapaPreparacao, int position) {
//     return Dismissible(
//       key: ValueKey(etapaPreparacao),
//       onDismissed: (direction) {
//         _deleteEtapaPreparacao(position);
//       },
//       child: Card(
//         color: Colors.pink[900],
//         child: Container(
//           padding: EdgeInsets.all(9),
//           child: Row(
//             children: [
//               Expanded(child: _tileEtapaPreparacao(etapaPreparacao, position))
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   _tileEtapaPreparacao(EtapaPreparo etapaPreparacao, int position) {
//     CrudOperation crudOperationEtapaPreparacao =
//         _receitaCubit.crudOperationEtapaPreparacao;

//     int etapaPreparacaoToEditPosition =
//         _receitaCubit.etapaPreparacaoToEditPosition;

//     if (crudOperationEtapaPreparacao == CrudOperation.CREATE ||
//         etapaPreparacaoToEditPosition != position) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Flexible(
//             child: Text(
//               _printEtapaPreparacao(etapaPreparacao, position),
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//           ),
//           GestureDetector(
//               onTap: () {
//                 _showModalEditOrDeleteEtapaPreparacao(
//                     etapaPreparacao, position);
//               },
//               child: Icon(Icons.more_horiz, color: Colors.white))
//         ],
//       );
//     } else {
//       EtapaPreparo text = _receitaCubit.etapaPreparacaoToEdit;
//       return Text(
//         _printEtapaPreparacao(text, position),
//         style: TextStyle(fontSize: 18, color: Colors.white),
//       );
//     }
//   }

//   _printEtapaPreparacao(EtapaPreparo etapaPreparacao, int position) {
//     return '${position + 1} - ${etapaPreparacao.descricao}';
//   }

//   _showModalEditOrDeleteEtapaPreparacao(
//       EtapaPreparo etapaPreparacao, int position) {
//     showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           return DefaultModal(
//               child: _popupMenuEtapaPreparacao(etapaPreparacao, position));
//         });
//   }

//   _deleteEtapaPreparacao(int position) {
//     _receitaCubit.deleteEtapaPreparacao(position);
//   }

//   _ingredientesSection(Receita receita) {
//     // List<Ingrediente> ingredientes = receita.ingredientes;
//     // if (ListUtils.isNullOrEmpty(ingredientes)) {
//     //   return Container();
//     // }
//     // return Align(
//     //     alignment: Alignment.topLeft,
//     //     child: Column(children: [
//     //       SizedBox(
//     //         height: 10,
//     //       ),
//     //       Text(
//     //         'Ingredientes',
//     //         style: TextStyle(fontSize: 18),
//     //       ),
//     //       SizedBox(
//     //         height: 10,
//     //       ),
//     //       ReorderableListView.builder(
//     //           physics: NeverScrollableScrollPhysics(),
//     //           shrinkWrap: true,
//     //           itemBuilder: (context, index) {
//     //             Ingrediente ingrediente = ingredientes[index];
//     //             return _ingredienteViewModel(ingrediente, index);
//     //           },
//     //           itemCount: ingredientes.length,
//     //           onReorder: (oldIndex, newIndex) {
//     //             setState(() {
//     //               if (newIndex > oldIndex) {
//     //                 newIndex = newIndex - 1;
//     //               }
//     //               final item = ingredientes.removeAt(oldIndex);
//     //               ingredientes.insert(newIndex, item);
//     //             });
//     //           }),
//     // ListView.builder(
//     //     physics: NeverScrollableScrollPhysics(),
//     //     itemCount: ingredientes.length,
//     //     shrinkWrap: true,
//     //     itemBuilder: (context, position) {
//     //       Ingrediente ingrediente = ingredientes[position];
//     //       return _ingredienteViewModel(ingrediente, position);
//     //     })
//     // ]));
//   }

//   _ingredienteViewModel(Ingrediente ingrediente, int position) {
//     return Dismissible(
//       key: ValueKey(ingrediente.descricao),
//       onDismissed: (direction) {
//         _deleteIngrediente(position);
//       },
//       child: Card(
//         color: Colors.pink[900],
//         child: Container(
//           padding: EdgeInsets.all(10),
//           child: Row(
//             children: [
//               Expanded(
//                 child: _tileIngredienteText(ingrediente, position),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   _tileIngredienteText(Ingrediente ingrediente, int position) {
//     CrudOperation crudOperationIngrediente =
//         _receitaCubit.crudOperationIngrediente;

//     int ingredienteToEditPosition = _receitaCubit.ingredienteToEditPosition;

//     if (crudOperationIngrediente == CrudOperation.CREATE ||
//         ingredienteToEditPosition != position) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Flexible(
//             child: Text(
//               '- ${ingrediente.descricao}',
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//           ),
//           GestureDetector(
//               onTap: () {
//                 _showModalEditOrDeleteIngrediente(ingrediente, position);
//               },
//               child: Icon(Icons.more_horiz, color: Colors.white))
//         ],
//       );
//     } else {
//       String text = _receitaCubit.ingredienteToEdit.descricao;
//       return Text(
//         '- $text',
//         style: TextStyle(fontSize: 18, color: Colors.white),
//       );
//     }
//   }

//   _showModalEditOrDeleteIngrediente(Ingrediente ingrediente, int position) {
//     showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           return DefaultModal(
//               child: _popupMenuIngrediente(ingrediente, position));
//         });
//   }

//   _deleteIngrediente(int position) {
//     _receitaCubit.deleteIngrediente(position);
//   }

//   _cookImage() {
//     return Align(
//       alignment: Alignment.topRight,
//       child: Container(
//         width: screen.width * 0.4,
//         child: Image.asset(
//           MyAssets.GIRL_COOK,
//         ),
//       ),
//     );
//   }

//   Widget _anuncio() {
//     if (banner == null)
//       return SizedBox(height: 60);
//     else
//       return Container(
//         height: 60,
//         child: AdWidget(ad: banner),
//       );
//   }

//   _nextBackControl() {
//     return _btnAvancarConcluir();
//   }

//   _btnAvancarConcluir() {
//     int index = _receitaCubit.currentEtapa.index;
//     if (index == _receitaCubit.etapas.length - 1) {
//       return _btnFinalizar();
//     } else {
//       return _btnAvancar();
//     }
//   }

//   _btnFinalizar() {
//     return ElevatedButton(
//         onPressed: _finalizarReceita,
//         child: Row(
//           children: [
//             Text(
//               'Finalizar',
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             Icon(
//               Icons.check,
//               color: Colors.white,
//             )
//           ],
//         ));
//   }

//   _finalizarReceita() {
//     Receita receita = _receitaCubit.receita;
//     List<String> errors = _createValidationsReceita(receita);
//     if (ListUtils.isNullOrEmpty(errors)) {
//       _showDialogConfirmacaoReceita(receita);
//     } else {
//       _showDialogCorrecoesReceita(errors);
//     }
//   }

//   _printReceita(Receita receita) {
//     // var ingredientes = receita.ingredientes;
//     // return Column(
//     //   children: [
//     //     Text(
//     //       receita.nome,
//     //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//     //     ),
//     //     SizedBox(
//     //       height: 10,
//     //     ),
//     //     Text('Ingredientes: ',
//     //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//     //     SizedBox(
//     //       height: 10,
//     //     ),
//     //     ListView.builder(
//     //         physics: NeverScrollableScrollPhysics(),
//     //         shrinkWrap: true,
//     //         itemCount: ingredientes.length,
//     //         itemBuilder: (context, index) {
//     //           var ingre = ingredientes.elementAt(index);
//     //           return Text(
//     //             '- ${ingre.descricao}',
//     //             style: TextStyle(fontSize: 18),
//     //           );
//     //         }),
//     //     SizedBox(
//     //       height: 10,
//     //     ),
//     //     Text(
//     //       'Modo de preparo: ',
//     //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//     //     ),
//     //     SizedBox(
//     //       height: 10,
//     //     ),
//     //     ListView.builder(
//     //         physics: NeverScrollableScrollPhysics(),
//     //         shrinkWrap: true,
//     //         itemCount: receita.secoesReceita.length,
//     //         itemBuilder: (context, index) {
//     //           EtapaPreparo etapa = receita.secoesReceita[index];
//     //           return Text('${index + 1} - ${etapa.descricao}',
//     //               style: TextStyle(fontSize: 18));
//     //         }),
//     //     _widgetDetalhesPrintReceita(receita),
//     //   ],
//     // );
//   }

//   _widgetDetalhesPrintReceita(Receita receita) {
//     var checkTempoPreparo = TempoPreparoCheck(receita.tempoPreparo);
//     var checkPorcoes = PorcoesCheck(receita.porcoes);
//     if (checkTempoPreparo.isNotInformed() && checkPorcoes.isNotInformed()) {
//       return Container();
//     }
//     return Container(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _tempoLabelPrintReceita(receita.tempoPreparo),
//             _porcoesLabelPrintReceita(receita.porcoes)
//           ],
//         ),
//         margin: EdgeInsets.all(20),
//         padding: EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//             border: Border.symmetric(
//           horizontal: BorderSide(),
//         )));
//   }

//   _tempoLabelPrintReceita(Duration tempoPreparo) {
//     var detalhesCheck = TempoPreparoCheck(tempoPreparo);
//     if (detalhesCheck.isNotInformed()) {
//       return Container();
//     }
//     String messageMinutos = 'Leva $tempoPreparo';
//     return Row(
//       children: [
//         Icon(Icons.timer),
//         SizedBox(width: 10),
//         Text(messageMinutos),
//       ],
//     );
//   }

//   _porcoesLabelPrintReceita(int porcoes) {
//     var detalhesCheck = PorcoesCheck(porcoes);
//     if (detalhesCheck.isNotInformed()) {
//       return Container();
//     }

//     String messagePorcoes = '';
//     if (detalhesCheck.isSingular()) {
//       messagePorcoes = 'Rende $porcoes porção';
//     } else {
//       messagePorcoes = 'Rende $porcoes porções';
//     }
//     return Row(
//       children: [
//         Icon(Icons.fastfood),
//         SizedBox(width: 10),
//         Text(messagePorcoes),
//       ],
//     );
//   }

//   _showDialogConfirmacaoReceita(Receita receita) {
//     AlertDialog dialog = AlertDialog(
//       title: Text('Parabéns!'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text('Você finalizou a receita! '),
//           SizedBox(height: 5),
//           Flexible(child: SingleChildScrollView(child: _printReceita(receita)))
//         ],
//       ),
//       actions: [
//         ElevatedButton(
//             onPressed: () {
//               _salvarReceita(_receitaCubit.receita);
//             },
//             child: Row(
//               children: [
//                 Text('Salvar receita', style: TextStyle(fontSize: 18)),
//                 Icon(Icons.check)
//               ],
//             )),
//         ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Row(
//               children: [
//                 Text('Continuar editando...', style: TextStyle(fontSize: 18)),
//                 Icon(Icons.arrow_back)
//               ],
//             ))
//       ],
//     );
//     showDialog(
//         context: context,
//         builder: (context) {
//           return dialog;
//         });
//   }

//   _salvarReceita(Receita receita) async {
//     log('salvando receita...');

//     try {
//       _showLoadingDialog();
//       receita.id = Uuid().v1();
//       receita.userId = context.read<AuthCubit>().getUser().uid;
//       await _uploadFotosReceita(receita);

//       FirebaseRepository.uploadReceita(receita).then((value) {
//         _receitaCadastradaSucesso();
//       }).catchError((error) {
//         _erroCadastrarReceita(error, StackTrace.empty);
//       }).onError((error, stackTrace) {
//         _erroCadastrarReceita(error, stackTrace);
//       });
//     } catch (ex, stacktrace) {
//       _erroCadastrarReceita(ex, stacktrace);
//     }
//   }

//   _showLoadingDialog() {
//     AlertDialog alert = AlertDialog(
//       content: Row(
//         children: [
//           CircularProgressIndicator(),
//           Container(
//               margin: EdgeInsets.only(left: 8),
//               child: Text("Salvando receita...")),
//         ],
//       ),
//     );
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }

//   _uploadFotosReceita(Receita receita) async {
//     List<ImageReceita> images = receita.images;

//     for (ImageReceita image in images) {
//       String url = await FirebaseRepository.uploadImageReceita(image);
//       image.url = url;
//     }
//   }

//   _erroCadastrarReceita(error, stacktrace) {
//     Navigator.of(context).pop();
//     String errorMessage =
//         'Não foi possível cadastrar a receita! Tente novamente mais tarde!';
//     log('$errorMessage - Erro: $error - StackTrace: $stacktrace');

//     var dialog = AlertDialog(
//       title: Text('ALERTA'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Flexible(
//               flex: 70,
//               child: Text(
//                 errorMessage,
//                 style: TextStyle(fontSize: 18),
//               )),
//           SizedBox(height: 10),
//           Flexible(
//               flex: 30,
//               child: Image.asset(
//                 MyAssets.SAD_COOKER,
//               )),
//         ],
//       ),
//       actions: [
//         ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('OK'))
//       ],
//     );

//     showDialog(
//         context: context,
//         builder: (context) {
//           return dialog;
//         });
//   }

//   _loadInterstitialAd() {
//     if (_interstitialAd == null) {
//       return;
//     }

//     _interstitialAd.fullScreenContentCallback =
//         FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
//       ad.dispose();
//       _createInterstitialAd();
//     }, onAdFailedToShowFullScreenContent: (ad, error) {
//       ad.dispose();
//       _createInterstitialAd();
//     });
//     _interstitialAd?.show();
//   }

//   _receitaCadastradaSucesso() {
//     Navigator.of(context).pop();
//     _loadInterstitialAd();
//     Navigator.of(context)
//         .pushNamedAndRemoveUntil(AppRoutes.initialPage, (route) => false);
//     String successMessage = 'Receita cadastrada com sucesso!';
//     snackMessage.show(successMessage);
//     log(successMessage);
//   }

//   _createValidationsReceita(Receita receita) {
//     // String nomeReceita = receita.nome;
//     // List<Ingrediente> ingredientes = receita.ingredientes;
//     // List<EtapaPreparo> etapas = receita.secoesReceita;
//     // List<ImageReceita> images = receita.images;

//     // List<String> errors = [];

//     // if (StringUtils.isNullOrEmpty(nomeReceita)) {
//     //   errors.add('- Informar um nome para a receita.');
//     // }

//     // if (ListUtils.isNullOrEmpty(ingredientes)) {
//     //   errors.add('- Informar no mínimo um ingrediente para a receita.');
//     // }
//     // if (ListUtils.isNullOrEmpty(etapas)) {
//     //   errors.add('- Informar no mínimo uma etapa para o modo de preparo.');
//     // }
//     // if (ListUtils.isNullOrEmpty(images)) {
//     //   errors.add('- Informar no mínimo uma imagem para a receita.');
//     // }

//     // if (images.length > 5) {
//     //   errors.add('- Número de imagens deve ser menor que 5.');
//     // }
//     // return errors;
//   }

//   _showDialogCorrecoesReceita(List<String> errors) {
//     AlertDialog dialog = AlertDialog(
//       title: Text('ATENÇÃO'),
//       actions: [
//         ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text('OK'),
//         )
//       ],
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Necessário fazer as seguintes correções:\n ',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           ListView.builder(
//               physics: NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: errors.length,
//               itemBuilder: (context, index) {
//                 var error = errors.elementAt(index);
//                 return Row(
//                   children: [
//                     Flexible(
//                         child: Text(
//                       '$error\n',
//                       style: TextStyle(fontSize: 16),
//                     )),
//                   ],
//                 );
//               })
//         ],
//       ),
//     );

//     showDialog(
//         context: context,
//         builder: (context) {
//           return dialog;
//         });
//   }

//   _btnAvancar() {
//     return ElevatedButton(
//         onPressed: _avancarEtapa,
//         child: Row(
//           children: [
//             Text(
//               'Avançar',
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             Icon(
//               Icons.arrow_forward,
//               color: Colors.white,
//             )
//           ],
//         ));
//   }

//   _avancarEtapa() {
//     _receitaCubit.avancarEtapa();
//   }

//   Future<bool> _onWillPop() async {
//     bool willPop = await showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//               title: Text('ATENÇÃO'),
//               content: Text(
//                   'Tem certeza que deseja sair? Os dados da receita poderão ser perdidos!',
//                   style: TextStyle(fontSize: 18)),
//               actions: [
//                 ElevatedButton(
//                   child: Row(
//                     children: [
//                       Text('Continuar receita', style: TextStyle(fontSize: 18)),
//                       Icon(Icons.arrow_forward)
//                     ],
//                   ),
//                   onPressed: () {
//                     return Navigator.of(context).pop(false);
//                   },
//                 ),
//                 ElevatedButton(
//                   child: Row(
//                     children: [
//                       Text('Sair', style: TextStyle(fontSize: 18)),
//                       Icon(Icons.arrow_back)
//                     ],
//                   ),
//                   onPressed: () {
//                     return Navigator.of(context)
//                         .pushNamed(AppRoutes.initialPage);
//                   },
//                 ),
//               ]);
//         });
//     return willPop ?? false;
//   }

//   _hideKeyboard() {
//     FocusScope.of(context).unfocus();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _videoController.dispose();
//     _chewieController.dispose();
//     _interstitialAd?.dispose();
//   }
// }
