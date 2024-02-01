import 'dart:developer';

import 'avaliacao.dart';

class Avaliacoes {
  double mediaAvaliacoes;
  List<Avaliacao> avaliacoesUsuarios;

  Avaliacoes({this.mediaAvaliacoes = 0, List<Avaliacao> avaliacoesUsuarios})
      : avaliacoesUsuarios = avaliacoesUsuarios ?? [];

  factory Avaliacoes.empty() {
    return Avaliacoes(
      mediaAvaliacoes: 0.1,
      avaliacoesUsuarios: [],
    );
  }

  static Avaliacoes fromJson(Map<String, dynamic> json) {
    List<Avaliacao> avaliacoesUsuarios = List.of(json['avaliacoesUsuarios'])
        .map((e) => Avaliacao.fromJson(e))
        .toList();

    return Avaliacoes(
      mediaAvaliacoes: json['mediaAvaliacoes'],
      avaliacoesUsuarios: avaliacoesUsuarios,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaAvaliacoes': mediaAvaliacoes,
      'avaliacoesUsuarios': avaliacoesUsuarios
          .map((avaliacaoUsuario) => avaliacaoUsuario.toJson())
          .toList(),
    };
  }
}
