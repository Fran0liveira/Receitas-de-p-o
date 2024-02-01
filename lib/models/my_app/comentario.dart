import 'user_chef.dart';

class Comentario {
  String id;
  String idUsuario;
  String nomeUsuario;
  String conteudo;
  List<Comentario> respostas;
  String imageUsuario;
  DateTime dataPublicacao;

  Comentario(
      {this.id = '',
      this.idUsuario = '',
      this.nomeUsuario = '',
      this.conteudo = '',
      List<Comentario> respostas,
      this.imageUsuario = '',
      this.dataPublicacao})
      : respostas = respostas ?? [];

  factory Comentario.empty() {
    return Comentario(
      conteudo: '',
      id: '',
      idUsuario: '',
      nomeUsuario: '',
      respostas: [],
      imageUsuario: '',
      dataPublicacao: DateTime.now(),
    );
  }

  static Comentario fromJson(Map<String, dynamic> json) {
    List<Comentario> respostas =
        List.of(json['respostas']).map((e) => Comentario.fromJson(e)).toList();

    return Comentario(
      id: json['id'],
      conteudo: json['conteudo'],
      idUsuario: json['idUsuario'],
      nomeUsuario: json['nomeUsuario'],
      respostas: respostas,
      imageUsuario: json['imageUsuario'],
      dataPublicacao: DateTime.parse(json['dataPublicacao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUsuario': idUsuario,
      'nomeUsuario': nomeUsuario,
      'conteudo': conteudo,
      'respostas': respostas.map((respostas) => respostas.toJson()).toList(),
      'imageUsuario': imageUsuario,
      'dataPublicacao': dataPublicacao.toString(),
    };
  }
}
