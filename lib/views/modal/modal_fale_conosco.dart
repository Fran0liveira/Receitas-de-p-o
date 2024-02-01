import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:receitas_de_pao/components/app_textfield.dart';
import 'package:receitas_de_pao/components/circular_border_radius.dart';
import 'package:receitas_de_pao/components/rounded.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:receitas_de_pao/utils/screen.dart';

class ModalFaleConosco extends StatefulWidget {
  void Function() onComplete;
  ModalFaleConosco({this.onComplete});

  @override
  State<ModalFaleConosco> createState() => _ModalFaleConoscoState();
}

class _ModalFaleConoscoState extends State<ModalFaleConosco> {
  TextEditingController _controllerMessage = TextEditingController();
  TextEditingController _controllerNome = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  @override
  Widget build(BuildContext context) {
    return _dialog();
  }

  _dialog() {
    return Rounded(
      radius: CircularBorderRadius.onlyTop(15),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Palete().DARK_PINK,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: 10),
              Text(
                'Fale conosco!',
                style: TextStyle(
                  color: Palete().DARK_PINK,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Flexible(child: _form()),
          TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.send),
                SizedBox(width: 2.5),
                Text('Enviar'),
              ],
            ),
            onPressed: () async {
              _sendEmail();
            },
          )
        ],
      ),
    );
  }

  _form() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tem alguma dúvida, sugestão ou encontrou algum erro no nosso app?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),
            AppTextField(
              autoFocus: true,
              controller: _controllerNome,
              hint: 'Seu nome',
              minLength: 3,
            ),
            AppTextField(
              controller: _controllerMessage,
              hint:
                  'Nos conte aqui! Sua opinião é muito importante para nós...',
              minLines: 3,
              required: true,
              minLength: 5,
            ),
          ],
        ),
      ),
    );
  }

  _sendEmail() async {
    if (!_formKey.currentState.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
        Screen.of(context).hideKeyboard();
      });

      return;
    }

    String userName = _controllerNome.text;
    final Email email = Email(
      body: _controllerMessage.text,
      subject: 'App Receitas de Pães - Nova Mensagem do $userName',
      recipients: ['ksoftsistemas@gmail.com'],
      //cc: ['cc@example.com'],
      //bcc: ['bcc@example.com'],
      //attachmentPaths: ['/path/to/attachment.zip'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email).then((value) {
      widget?.onComplete();
    });
  }
}
