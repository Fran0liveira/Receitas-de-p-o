import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/state/auth_state/auth_cubit.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';

class DialogLogin {
  AlertDialog show(BuildContext context, {String message, String title}) {
    AuthCubit _authCubit = context.read<AuthCubit>();
    var dialog = AlertDialog(
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _titleValue(title),
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
        _messageValue(message),
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.pink[800])),
            onPressed: () {
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(
                      AppRoutes.loginPage, (route) => false,
                      arguments: AppRoutes.editReceitaPage);
            },
            child: Text('Fazer login')),
      ],
    );
    showDialog(
        context: context, barrierDismissible: false, builder: (_) => dialog);
    return dialog;
  }

  _titleValue(String title) {
    return StringUtils.isNullOrEmpty(title) ? 'Login necessário' : title;
  }

  _messageValue(String message) {
    return StringUtils.isNullOrEmpty(message)
        ? 'É necessário fazer login para acessar essa área!'
        : message;
  }
}
