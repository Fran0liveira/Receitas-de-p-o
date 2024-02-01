import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/banner_widget_novo.dart';
import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/components/banner_widget.dart';
import 'package:receitas_de_pao/components/snack_message.dart';
import 'package:receitas_de_pao/repository/firebase_repository.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';

import '../adapters/firebase_message_adapter.dart';
import '../api/firebase_api.dart';
import '../components/app_textfield.dart';
import '../routes/app_routes.dart';
import '../keys/nav_keys.dart';
import '../models/my_app/image_uploaded.dart';
import '../models/my_app/user_chef.dart';
import '../services/image_manager.dart';
import '../state/auth_state/auth_cubit.dart';
import '../state/register_user_state/register_user_cubit.dart';
import '../state/register_user_state/register_user_state.dart';
import '../utils/assets.dart';
import '../utils/dialogs.dart';
import '../utils/screen.dart';
import '../utils/string_utils.dart';

class EditUserPage extends StatefulWidget {
  EditUserPage();

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  GlobalKey<FormState> _formKey = GlobalKey();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  Screen _screen;
  RegisterUserCubit _registerUserCubit;
  Dialogs _dialogs;
  var _nomeController = TextEditingController();
  var _sobrenomeController = TextEditingController();
  TextStyle errorStyle;

  UserChef get _userChef => _registerUserCubit.userChef;
  List<String> _sexos = ['Mulher', 'Homem', 'Não informar'];
  int _indexSexoSelecionado = 0;
  String _sexoSelecionado;
  AuthCubit _authCubit;
  SnackMessage _snack;
  //BannerAd banner;
  PremiumCubit _premiumCubit;

  @override
  void initState() {
    super.initState();
    _registerUserCubit = context.read<RegisterUserCubit>();
    _premiumCubit = context.read<PremiumCubit>();
    _dialogs = Dialogs(context);
    _authCubit = context.read<AuthCubit>();
    _snack = SnackMessage(context);
    _initErrorStyle();
    _initSexoInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ;
    //_loadAd();
  }

  _initSexoInfo() {
    _sexoSelecionado = _userChef.sexo;
    _indexSexoSelecionado = _sexos.indexOf(_sexoSelecionado);
  }

  _initErrorStyle() {
    errorStyle = TextStyle(
      color: Colors.pink[900],
      backgroundColor: Colors.red[100],
      fontSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    _screen = Screen(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            actions: [
              Container(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.person),
              )
            ],
            title: Text('Atualizar perfil'),
            backgroundColor: Colors.pink[600]),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.grey[300],
                  padding: EdgeInsets.all(12),
                  child: Form(
                    autovalidateMode: _autovalidateMode,
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _photosSection(),
                        // SizedBox(height: 10),
                        _dadosPessoais(),
                        SizedBox(height: 10),
                        _dadosSexo(),
                        SizedBox(height: 10),
                        _informacoesConta(),
                        SizedBox(height: 20),
                        _btnAtualizarPerfil()
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _banner()
          ],
        ),
      ),
    );
  }

  _banner() {
    if (_premiumCubit.isPremiumMode()) {
      return Container();
    }
    return BannerWidgetNovo(
      adId: MyAds.editUserBannerAd,
      background: Colors.pink[900],
    );
  }

  _informacoesConta() {
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
                'Informações da conta',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            _email(),
            SizedBox(height: 10),
            //_widgetAlterarSenha()
          ],
        ),
      ),
    );
  }

  _widgetAlterarSenha() {
    return TextButton(
      onPressed: _alterarSenha,
      child: Row(
        children: [
          Icon(
            Icons.lock,
            color: Colors.purple[900],
          ),
          SizedBox(width: 10),
          Text(
            'Alterar senha',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  _alterarSenha() {
    Navigator.of(context).pushNamed(AppRoutes.changePassword);
  }

  _dadosSexo() {
    return Card(
      elevation: 10,
      color: Colors.red[100],
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' Eu sou: ',
              style: TextStyle(
                  fontSize: 22,
                  backgroundColor: Colors.purple[900],
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: _sexos.length,
                itemBuilder: (context, index) {
                  String sexo = _sexos.elementAt(index);
                  return RadioListTile<String>(
                      activeColor: Colors.purple[900],
                      title: Text(
                        sexo,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      value: sexo,
                      groupValue: _sexos[_indexSexoSelecionado],
                      onChanged: (value) {
                        setState(() {
                          _indexSexoSelecionado = index;
                          _sexoSelecionado = value;
                        });
                      });
                }),
          ],
        ),
      ),
    );
  }

  _btnAtualizarPerfil() {
    return ElevatedButton(
      style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(12)),
          backgroundColor: MaterialStateProperty.all(Colors.purple[900])),
      onPressed: _atualizarUsuario,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Atualizar perfil',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(width: 5),
          Icon(Icons.check_circle)
        ],
      ),
    );
  }

  _dadosPessoais() {
    return Card(
        elevation: 10,
        color: Colors.red[100],
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ' Dados pessoais ',
                style: TextStyle(
                    fontSize: 22,
                    backgroundColor: Colors.purple[900],
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              AppTextField(
                hint: 'Nome',
                controller: _nomeController,
                required: true,
                minLength: 3,
                maxLength: 50,
                errorStyle: errorStyle,
                text: _userChef.nome,
              ),
              SizedBox(height: 10),
              AppTextField(
                hint: 'Sobrenome',
                controller: _sobrenomeController,
                required: true,
                minLength: 3,
                maxLength: 50,
                errorStyle: errorStyle,
                text: _userChef.sobrenome,
              ),
            ],
          ),
        ));
  }

  _email() {
    User user = _authCubit.getUser();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email cadastrado: ',
          style: TextStyle(color: Colors.purple[900]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.email,
              color: Colors.purple[900],
            ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                user.email,
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // _photosSection() {
  //   return Card(
  //     elevation: 10,
  //     color: Colors.red[100],
  //     child: Container(
  //       padding: EdgeInsets.all(20),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Container(
  //             child: Column(
  //               children: [
  //                 Container(
  //                   padding: EdgeInsets.all(4),
  //                   color: Colors.purple[900],
  //                   child: Text(
  //                     'Imagem de Perfil',
  //                     style: TextStyle(fontSize: 20, color: Colors.white),
  //                   ),
  //                 ),
  //                 SizedBox(height: 10),
  // Container(
  //   padding: EdgeInsets.all(5),
  //   height: _screen.width / 2,
  //   width: _screen.width / 2,
  //   child: BlocBuilder<RegisterUserCubit, RegisterUserState>(
  //       builder: (context, state) {
  //     return Row(
  //       children: [
  //         Flexible(child: _imageViewModel()),
  //       ],
  //     );
  //   }),
  // )
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // _imageViewModel() {
  //   return GestureDetector(
  //     onTap: () {
  //       _pickImage();
  //     },
  //     child: Stack(
  //       children: [
  //         _imageOrPlaceholder(),
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
  //     ),
  //   );
  // }

  // _pickImage({int position}) async {
  //   try {
  //     XFile image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //     _setupImage(position, image);
  //   } on PlatformException catch (e) {
  //     _dialogs.showAlert(
  //         message:
  //             'Não foi possível adicionar salvar foto de perfil! \n ${e.message}');
  //   }
  // }

  // _setupImage(int position, XFile image) async {
  //   ImageManager imageManager = ImageManager();
  //   File file = File(image.path);
  //   File croppedFile =
  //       await imageManager.crop(file: file, ratioX: 1, ratioY: 1);

  //   File formattedFile = await ImageManager().compress(croppedFile);
  //   ImageUploaded imageReceita = ImageUploaded(file: File(formattedFile.path));
  //   _registerUserCubit.updatePicture(imageReceita);
  // }

  // _imageOrPlaceholder() {
  //   ImageUploaded imageUploaded = _registerUserCubit.userChef.imagePerfil;
  //   File fileImagePerfil = imageUploaded.file;
  //   String url = imageUploaded.url;
  //   Widget child;
  //   if (fileImagePerfil != null &&
  //       !StringUtils.isNullOrEmpty(fileImagePerfil.path)) {
  //     child = Image.file(fileImagePerfil);
  //   } else if (!StringUtils.isNullOrEmpty(url)) {
  //     child = Image.network(
  //       url,
  //       errorBuilder: (context, obj, stk) {
  //         return Image.asset(MyAssets.IMAGE_ERROR);
  //       },
  //     );
  //   } else {
  //     child = Container(color: Colors.grey);
  //   }

  //   return ClipRRect(borderRadius: BorderRadius.circular(100), child: child);
  // }

  _atualizarUsuario() async {
    if (!_formKey.currentState.validate()) {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      return;
    }
    UserChef user = _registerUserCubit.userChef;
    UserChef userChef = UserChef(
        nome: _nomeController.text,
        sobrenome: _sobrenomeController.text,
        email: user.email,
        senha: user.senha,
        id: user.id,
        imagePerfil: user.imagePerfil,
        sexo: _sexoSelecionado);

    try {
      _showDialogUpdatingUser();
      await _uploadFoto();
      await FirebaseRepository.updateUserOnDataBase(userChef);
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
      _registerUserCubit.setUserChef(userChef);
      _snack.show('Perfil atualizado!');
    } on FirebaseException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
      _handleError(e);
    }
  }

  _uploadFoto() async {
    try {
      UserChef userChef = _registerUserCubit.userChef;
      ImageUploaded image = userChef.imagePerfil;
      File file = image.file;
      if (file != null && !StringUtils.isNullOrEmpty(file.path)) {
        String url = await FirebaseRepository.uploadImageUsuario(image);
        image.url = url;
      }
    } catch (e) {
      throw Exception('Erro ao atualizar foto de perfil! $e');
    }
  }

  _showDialogUpdatingUser() {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 8), child: Text('Salvando...')),
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

  _handleError(Exception e) {
    if (e is FirebaseException) {
      _handleFirebaseException(e);
    } else {
      _handleException(e);
    }
  }

  _handleException(Exception e) {
    log('Não foi possível atualizar o usuário. Erro: ${e.toString()}');
    _snack.show('Não foi possível cadastrar o usuário. $e');
  }

  _handleFirebaseException(FirebaseException e) {
    String message = FirebaseMessageAdapter().adaptar(e);
    _snack.show('Não foi possível atualizar o usuário. $message');
  }

  // Future<void> _loadAd() async {
  //   AdSize size = await AdUtils.getAdaptativeSize(context);
  //   AdState adState = Provider.of<AdState>(context, listen: false);
  //   adState.initialization.then((value) => {
  //         setState(() {
  //           banner = BannerAd(
  //               adUnitId: MyAds.editUserBannerAd,
  //               size: size,
  //               request: AdRequest(),
  //               listener: adState.adListener)
  //             ..load();
  //         })
  //       });
  // }
}
