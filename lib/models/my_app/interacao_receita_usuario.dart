import 'dart:convert';

import 'receita.dart';

class InteracaoReceitaUsuario {
  List<String> favoritesIdReceitas;

  InteracaoReceitaUsuario({List<String> favoritesIdReceitas})
      : favoritesIdReceitas = favoritesIdReceitas ?? [];

  Map<String, dynamic> toJson() {
    return {
      'receitasFavoritas': jsonEncode(favoritesIdReceitas),
    };
  }

  static InteracaoReceitaUsuario fromJson(Map<String, dynamic> json) {
    if (json == null || json.isEmpty) {
      return InteracaoReceitaUsuario.empty();
    }

    List<dynamic> listIds = jsonDecode(json['receitasFavoritas']);
    return InteracaoReceitaUsuario(
      favoritesIdReceitas: listIds.map((e) => e.toString()).toList(),
    );
  }

  static InteracaoReceitaUsuario empty() {
    return InteracaoReceitaUsuario(favoritesIdReceitas: []);
  }
}
