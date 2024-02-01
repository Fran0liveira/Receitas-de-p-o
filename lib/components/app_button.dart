import 'package:flutter/material.dart';
import 'package:receitas_de_pao/style/palete.dart';

class AppButton extends StatefulWidget {
  var palete = Palete();
  String text;
  Function onPressed;

  AppButton({this.text, this.onPressed});
  @override
  _AppButtonState createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    var palete = widget.palete;
    return ElevatedButton(
      child: Text(
        widget.text,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      onPressed: widget.onPressed,
      style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(15)),
          backgroundColor:
              MaterialStateProperty.resolveWith((states) => palete.PINK)),
    );
  }
}
