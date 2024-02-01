import 'dart:convert';
import 'dart:developer';

import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
import 'package:receitas_de_pao/models/my_app/ingrediente.dart';

class SecaoReceita {
  String descricao;
  List<Ingrediente> ingredientes;
  List<EtapaPreparo> modoDePreparo;

  SecaoReceita(
      {this.descricao = '',
      List<Ingrediente> ingredientes,
      List<EtapaPreparo> modoDePreparo})
      : ingredientes = ingredientes ?? [],
        modoDePreparo = modoDePreparo ?? [];

  static SecaoReceita fromJson(Map<String, dynamic> json) {
    List<dynamic> listEtapas = json['modoDePreparo'];

    List<EtapaPreparo> etapas =
        listEtapas.map((etapa) => EtapaPreparo.fromJson(etapa)).toList();

    List<dynamic> list = json['ingredientes'];
    List<Ingrediente> ing = list.map((i) => Ingrediente.fromJson(i)).toList();
    return SecaoReceita(
      descricao: json['descricao'],
      modoDePreparo: etapas,
      ingredientes: ing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'modoDePreparo': modoDePreparo.map((e) => e.toJson()).toList(),
      'ingredientes': ingredientes.map((e) => e.toJson()).toList(),
    };
  }
}
