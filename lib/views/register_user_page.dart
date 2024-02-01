import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:receitas_de_pao/components/app_textfield.dart';
import 'package:receitas_de_pao/components/snack_message.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/models/my_app/user_chef.dart';
import 'package:receitas_de_pao/repository/firebase_repository.dart';
import 'package:receitas_de_pao/services/user_storage_service.dart';
import 'package:receitas_de_pao/utils/screen.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';

import '../adapters/firebase_message_adapter.dart';
import '../services/image_manager.dart';
import '../state/register_user_state/register_user_cubit.dart';
import '../state/register_user_state/register_user_state.dart';
import '../utils/dialogs.dart';
import '../utils/keyboard.dart';

class RegisterUserPage extends StatefulWidget {
  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  var _nomeController = TextEditingController();
  var _sobrenomeController = TextEditingController();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();

  List<String> _sexos = ['Mulher', 'Homem', 'Não informar'];
  int _indexSexoSelecionado = 0;
  String _sexoSelecionado = 'Mulher';
  Screen screen;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  SnackMessage _snack;
  Dialogs _dialogs;
  RegisterUserCubit _registerUserCubit;
  TextStyle errorStyle;

  @override
  void initState() {
    super.initState();
    _snack = SnackMessage(context);
    _dialogs = Dialogs(context);
    _registerUserCubit = context.read<RegisterUserCubit>();
    _initErrorStyle();
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
    screen = Screen(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: Icon(Icons.person),
            title: Text('Cadastrar-se'),
            backgroundColor: Colors.pink[600]),
        body: SingleChildScrollView(
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
                  // SizedBox(height: 20),
                  _dadosPessoais(),
                  SizedBox(height: 20),
                  _dadosSexo(),
                  SizedBox(height: 20),
                  _dadosDoUsuario(),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.purple[900])),
                    onPressed: _cadastrarUsuario,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cadastrar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.check_circle)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
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
  //                 Container(
  //                   padding: EdgeInsets.all(5),
  //                   height: screen.width / 2,
  //                   width: screen.width / 2,
  //                   child: BlocBuilder<RegisterUserCubit, RegisterUserState>(
  //                       builder: (context, state) {
  //                     return Row(
  //                       children: [
  //                         Flexible(child: _imageViewModel()),
  //                       ],
  //                     );
  //                   }),
  //                 )
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
  //       await imageManager.crop(file: file, ratioX: 0.60, ratioY: 0.48);

  //   File formattedFile = await ImageManager().compress(croppedFile);
  //   ImageUploaded imageReceita = ImageUploaded(file: File(formattedFile.path));
  //   _registerUserCubit.updatePicture(imageReceita);
  // }

  // _imageOrPlaceholder() {
  //   File fileImagePerfil = _registerUserCubit.userChef.imagePerfil.file;
  //   Widget child;
  //   if (fileImagePerfil != null &&
  //       !StringUtils.isNullOrEmpty(fileImagePerfil.path)) {
  //     child = Image.file(
  //       fileImagePerfil,
  //     );
  //   } else {
  //     child = Container(color: Colors.grey);
  //   }

  //   return ClipRRect(borderRadius: BorderRadius.circular(30), child: child);
  // }

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
              ),
              SizedBox(height: 10),
              AppTextField(
                  hint: 'Sobrenome',
                  controller: _sobrenomeController,
                  required: true,
                  minLength: 3,
                  maxLength: 50,
                  errorStyle: errorStyle),
              // SizedBox(height: 20),
              // AppTextField(
              //     hint: 'dd/mm/yyyy',
              //     label: 'Data de Nascimento',
              //     date: true,
              //     controller: _dataNascimentoController,
              //     text: _dataNascimento != null
              //         ? DateFormat('dd/MM/yyyy').format(_dataNascimento)
              //         : ''),
            ],
          ),
        ));
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

  _dadosDoUsuario() {
    return Card(
      elevation: 10,
      color: Colors.red[100],
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' Dados do usuário ',
              style: TextStyle(
                  fontSize: 22,
                  backgroundColor: Colors.purple[900],
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            AppTextField(
                hint: 'Email',
                email: true,
                controller: _emailController,
                errorStyle: errorStyle),
            SizedBox(height: 10),
            AppTextField(
                hint: 'Senha',
                password: true,
                lowerRequired: true,
                upperRequired: true,
                numericRequired: true,
                required: true,
                minLength: 8,
                controller: _passwordController,
                errorStyle: errorStyle),
          ],
        ),
      ),
    );
  }

  _cadastrarUsuario() async {
    if (!_formKey.currentState.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });

      return;
    }
    String nome = _nomeController.text;
    String email = _emailController.text;
    String senha = _passwordController.text;
    String sobrenome = _sobrenomeController.text;

    UserChef userChef = UserChef(
        nome: nome,
        email: email,
        senha: senha,
        sexo: _sexoSelecionado,
        sobrenome: sobrenome,
        imagePerfil: _registerUserCubit.userChef.imagePerfil);

    try {
      _showDialogSavingUser();
      await _uploadFotoUsuario();
      UserCredential userCredential =
          await FirebaseRepository.registerUser(userChef);
      await FirebaseRepository.loginWithEmailAndPassword(
        email: email,
        password: senha,
      );
      _dismissSavingUserDialog();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.initialPage, (route) => false);
    } on Exception catch (e) {
      _handleErrorOnSaveUser(e);
    }
  }

  // _updateFirebaseIdOnDatabase(UserCredential userCredential) async {
  //   UserChefDao dao = UserChefDao.instance;
  //   UserDbModel internalUser = await dao.getLoggedUserChef();

  //   String uid = userCredential.user.uid;

  //   UserDbModel userDbModel = UserDbModel(
  //     firebaseUserId: uid,
  //     internalUserId: internalUser.internalUserId,
  //   );
  //   dao.updateUserByInternalId(userDbModel);
  // }

  _handleErrorOnSaveUser(Exception e) {
    _dismissSavingUserDialog();
    if (e is FirebaseException) {
      _handleFirebaseException(e);
    } else {
      _handleException(e);
    }
  }

  _dismissSavingUserDialog() {
    FocusScope.of(context).requestFocus(FocusNode());
    Keyboard.hide(context);
    Navigator.of(context).pop();
  }

  _showDialogSavingUser() {
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

  _handleException(Exception e) {
    log('Não foi possível cadastrar o usuário. Erro: ${e.toString()}');
    _snack.show('Não foi possível cadastrar o usuário. $e');
  }

  _handleFirebaseException(FirebaseException e) {
    String message = FirebaseMessageAdapter().adaptar(e);
    _snack.show('Não foi possível cadastrar o usuário. $message');
  }

  _uploadFotoUsuario() async {
    try {
      UserChef userChef = _registerUserCubit.userChef;
      ImageUploaded image = userChef.imagePerfil;
      File file = image.file;
      if (file != null && !StringUtils.isNullOrEmpty(file.path)) {
        String url = await FirebaseRepository.uploadImageUsuario(image);
        image.url = url;
      }
    } catch (e) {
      throw Exception('Erro ao salvar foto de perfil! $e');
    }
  }
}
