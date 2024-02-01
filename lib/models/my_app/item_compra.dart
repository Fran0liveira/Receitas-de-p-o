import 'dart:developer';

class ItemCompra {
  int id;
  String descricao;
  int idListaCompras;
  bool selecionado;

  ItemCompra(
      {this.id,
      this.descricao = '',
      this.selecionado = false,
      this.idListaCompras = -1});

  toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'id_lista_compras': idListaCompras,
      'selecionado': selecionado ? 1 : 0
    };
  }

  static ItemCompra fromJson(Map<String, dynamic> json) {
    return ItemCompra(
      id: json['id'],
      descricao: json['descricao'],
      idListaCompras: json['id_lista_compras'],
      selecionado: json['selecionado'] == 1,
    );
  }
}
