import 'dart:developer';

import 'package:receitas_de_pao/models/my_app/avaliacoes.dart';
import 'package:receitas_de_pao/models/my_app/comentario.dart';

import '../../utils/string_utils.dart';

class Avaliacao {
  double nota;
  Comentario comentario;

  Avaliacao({this.nota = 0, this.comentario});

  factory Avaliacao.empty() {
    return Avaliacao(
      comentario: Comentario.empty(),
      nota: 0,
    );
  }

  static Avaliacao fromJson(Map<String, dynamic> json) {
    Comentario comentario = Comentario.fromJson(json['comentario']);
    return Avaliacao(
        nota: double.parse(json['nota'].toString()), comentario: comentario);
  }

  Map<String, dynamic> toJson() {
    return {
      'comentario': comentario != null ? comentario.toJson() : '',
      'nota': nota,
    };
  }
}
