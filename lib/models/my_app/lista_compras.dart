import 'dart:developer';

import 'package:intl/intl.dart';

import 'item_compra.dart';

class ListaCompras {
  int id;
  String descricao;
  List<ItemCompra> itens;
  bool expanded;
  DateTime updatedDate;
  String idReceita;
  String idUsuario;

  ListaCompras(
      {this.id,
      this.descricao = '',
      this.expanded = false,
      List<ItemCompra> itensCompra,
      this.updatedDate,
      this.idReceita = '',
      this.idUsuario})
      : itens = itensCompra ?? [];

  toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'updated_date': DateFormat("yyyy-MM-dd HH:mm:ss").format(updatedDate),
      'id_receita': idReceita,
      'id_usuario': idUsuario
    };
  }

  static ListaCompras fromJson(Map<String, dynamic> json) {
    log('update date: ${json['updated_date']}');
    return ListaCompras(
        id: json['id'],
        descricao: json['descricao'],
        updatedDate:
            DateFormat("yyyy-MM-dd HH:mm:ss").parse(json['updated_date']),
        idReceita: _idReceita(json),
        idUsuario: _idUsuario(json));
  }

  static _idUsuario(Map<String, dynamic> json) {
    try {
      return json['id_usuario'];
    } on Exception catch (e) {
      return '';
    }
  }

  static _idReceita(Map<String, dynamic> json) {
    try {
      return json['id_receita'];
    } on Exception catch (e) {
      return '';
    }
  }
}
