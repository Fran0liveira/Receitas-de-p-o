import 'package:flutter/material.dart';
import 'package:receitas_de_pao/builder/dialog_builder.dart';

class Dialogs {
  BuildContext context;

  Dialogs(this.context);

  void showDialogo({DialogBuilder dialog}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return dialog;
        });
  }

  void showAlert({String message, Function confirm}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Atenção'),
          content: Text(message),
          actions: [
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.pink[900])),
                onPressed: () => {
                      if (confirm == null)
                        {Navigator.of(context).pop()}
                      else
                        {confirm.call()}
                    },
                child: Text('OK'))
          ],
        );
      },
    );
  }
}
