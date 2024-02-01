import 'package:flutter/material.dart';

class MenuAction extends StatelessWidget {
  String name;
  IconData icon;
  Function action;

  MenuAction({this.name, this.icon, this.action});

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(name), onTap: action);
  }
}
