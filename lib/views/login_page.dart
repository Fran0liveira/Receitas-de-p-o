import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receitas_de_pao/adapters/firebase_message_adapter.dart';
import 'package:receitas_de_pao/components/app_textfield.dart';
import 'package:receitas_de_pao/components/background_page.dart';
import 'package:receitas_de_pao/components/snack_message.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/repository/firebase_repository.dart';
import 'package:receitas_de_pao/state/auth_state/auth_cubit.dart';
import 'package:receitas_de_pao/utils/screen.dart';

import '../models/my_app/user_chef.dart';
import '../state/register_user_state/register_user_cubit.dart';
import '../utils/arguments.dart';
import '../utils/string_utils.dart';

class LoginPage extends StatefulWidget {
  String redirectPage;

  LoginPage(this.redirectPage);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Screen screen;
  AuthCubit _authCubit;
  var _emailController = TextEditingController();
  var _senhaController = TextEditingController();
  var errorMessage = '';
  SnackMessage _snack;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextStyle _errorStyle;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  RegisterUserCubit _userCubit;
  String get redirectPage => widget.redirectPage;

  @override
  void initState() {
    super.initState();
    _authCubit = context.read<AuthCubit>();
    _snack = SnackMessage(context);
    _userCubit = context.read<RegisterUserCubit>();
    _errorStyle = TextStyle(
      fontSize: 16,
      color: Colors.white,
      backgroundColor: Colors.blue[900],
    );
  }

  @override
  Widget build(BuildContext context) {
    screen = Screen(context);

    return SafeArea(
      child: Scaffold(
        body: BackgroundPage(
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.max, children: [
          _appTitle(),
          _form(),
        ]))),
      ),
    );
  }

  _form() {
    return Form(
      autovalidateMode: _autovalidateMode,
      key: _formKey,
      child: Container(
        width: screen.width * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppTextField(
              hint: 'Email',
              controller: _emailController,
              email: true,
              required: true,
              errorStyle: _errorStyle,
            ),
            SizedBox(
              height: 20,
            ),
            AppTextField(
              hint: 'Senha',
              password: true,
              controller: _senhaController,
              required: true,
              errorStyle: _errorStyle,
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.pink),
              ),
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.yellow)),
                child: Text(
                  'Entrar',
                  style: TextStyle(fontSize: 18, color: Colors.pink[900]),
                ),
                onPressed: _loginWithEmailAndPassword),
            // ElevatedButton(
            //     style: ButtonStyle(
            //         backgroundColor: MaterialStateProperty.all(Colors.red)),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text('Entrar com Google',
            //             style: TextStyle(color: Colors.white)),
            //         FaIcon(
            //           FontAwesomeIcons.google,
            //           color: Colors.white,
            //         ),
            //       ],
            //     ),
            //     onPressed: _loginWithGoogle),
            SizedBox(
              height: 5,
            ),
            TextButton(
                onPressed: _cadastrar,
                child: Text(
                    '   Ainda não possui cadastro?   \n   Cadastre-se   ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.pink[800],
                        fontSize: 18))),
            SizedBox(height: 20),
            GestureDetector(
                child: Text(
                  'Continuar como convidado (a)',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      backgroundColor: Colors.blue[900]),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.initialPage, (route) => false);
                })
          ],
        ),
      ),
    );
  }

  _appTitle() {
    return Container(
        height: screen.height * .3,
        child: Center(
            child: Text(
          ' Receitas do \n Chef! ',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 40,
              backgroundColor: Colors.pink[800],
              color: Colors.white,
              fontWeight: FontWeight.bold),
        )));
  }

  _cadastrar() {
    log('cadastrando...');
    Navigator.pushNamed(context, AppRoutes.registerUserPage);
  }

  // _loginWithGoogle() {
  //   _googleCubit.loginWithGoogle();
  // }

  _loginWithEmailAndPassword() async {
    if (!_formKey.currentState.validate()) {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      return;
    }
    var email = _emailController.text;
    var password = _senhaController.text;

    try {
      UserCredential credentials = await _authCubit.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      _redirectOnLogged();
    } on Exception catch (e) {
      _handleLoginError(e);
    }
  }

  _redirectOnLogged() {
    Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.initialPage, (route) => false,
        arguments: redirectPage);
  }

  _handleLoginError(Exception e) {
    if (e is FirebaseException) {
      _handleFirebaseException(e);
    } else {
      _snack.show('Não foi possível fazer login. Tente novamente mais tarde.');
    }
    log('Erro ao fazer login: Message: ${e.toString()}');
  }

  _handleFirebaseException(FirebaseException e) {
    log('codigo login: ' + e.code);
    String message = FirebaseMessageAdapter().adaptar(e);
    _snack.show('Não foi possível fazer login. $message');
  }

  updateErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }
}
