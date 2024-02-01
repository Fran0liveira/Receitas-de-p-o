import 'package:flutter/material.dart';
import 'package:receitas_de_pao/models/action_menu.dart';

class MenuActions {
  static edit(Function action) {
    return MenuAction(
      name: 'Editar',
      icon: Icons.edit,
      action: () {
        action.call();
      },
    );
  }

  static delete(Function action) {
    return MenuAction(
      name: 'Excluir',
      icon: Icons.delete,
      action: () {
        action.call();
      },
    );
  }
}
