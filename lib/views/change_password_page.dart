import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receitas_de_pao/components/app_textfield.dart';

import '../state/auth_state/auth_cubit.dart';
import '../utils/screen.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextStyle errorStyle;
  var _passwordController = TextEditingController();
  var _newPasswordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  AuthCubit _authCubit;
  Screen _screen;

  @override
  void initState() {
    super.initState();
    _authCubit = context.read<AuthCubit>();
    _screen = Screen(context);
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink[600],
          automaticallyImplyLeading: true,
          title: Text(
            'Atualizar perfil',
          ),
        ),
        body: Container(
          height: _screen.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  elevation: 10,
                  color: Colors.red[100],
                  child: Column(children: [
                    _txtAdvice(),
                    SizedBox(height: 20),
                    _btnEnviar(),
                    SizedBox(height: 20)
                  ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _formPasswords() {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              color: Colors.purple[900],
              child: Text(
                'Alterar senha',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            AppTextField(
              hint: 'Senha atual',
              password: true,
              controller: _passwordController,
              errorStyle: errorStyle,
            ),
            AppTextField(
              hint: 'Nova senha',
              password: true,
              lowerRequired: true,
              upperRequired: true,
              numericRequired: true,
              required: true,
              minLength: 8,
              controller: _newPasswordController,
              errorStyle: errorStyle,
            ),
          ],
        ),
      ),
    );
  }

  _txtAdvice() {
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        'Um email com código para gerar a senha será enviado em seu email',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  _btnEnviar() {
    return ElevatedButton(
      style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(12)),
          backgroundColor: MaterialStateProperty.all(Colors.purple[900])),
      onPressed: _enviarCodigoGerarSenha,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enviar código',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(width: 5),
          Icon(Icons.send)
        ],
      ),
    );
  }

  _enviarCodigoGerarSenha() {
    _authCubit.sendResetPasswordCode();
    log('sending reset code');
  }

  // String Function(TextEditingController controller) _senhasConferemValidator() {
  //   return (controller) {
  //     String password = _passwordController.text;
  //     String passwordConfirm = _newPasswordController.text;

  //     if (password == passwordConfirm) {
  //       return '';
  //     } else {
  //       return 'Senhas não conferem!';
  //     }
  //   };
  // }
}
