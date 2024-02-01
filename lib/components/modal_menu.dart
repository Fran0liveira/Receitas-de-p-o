import 'package:flutter/material.dart';
import 'package:receitas_de_pao/models/action_menu.dart';

class ModalMenu extends StatelessWidget {
  String title;
  List<MenuAction> actions;
  Color headerColor;
  Color textColor;

  ModalMenu(
      {this.title,
      this.actions,
      this.headerColor = Colors.red,
      this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          padding: EdgeInsets.all(10),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, color: textColor),
          ),
        ),
        ...actions
      ],
    );
  }
}
