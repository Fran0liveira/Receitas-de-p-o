import 'dart:developer';

class Ingrediente {
  String descricao;

  Ingrediente({this.descricao});

  Map<String, dynamic> toJson() {
    return {'descricao': descricao};
  }

  static Ingrediente fromJson(Map<String, dynamic> ingrediente) {
    return Ingrediente(
      descricao: ingrediente['descricao'],
    );
  }
}
