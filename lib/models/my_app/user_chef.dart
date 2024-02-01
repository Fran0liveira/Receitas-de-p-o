import 'dart:developer';
import 'dart:io';

import '../../utils/string_utils.dart';
import 'image_uploaded.dart';

class UserChef {
  String id;
  String nome;
  String sobrenome;
  String email;
  String senha;
  String sexo;
  ImageUploaded imagePerfil;
  int internalUserId;

  UserChef(
      {this.id = '',
      this.nome = '',
      this.email = '',
      this.senha = '',
      this.sexo = '',
      this.sobrenome = '',
      ImageUploaded imagePerfil,
      this.internalUserId = -1})
      : imagePerfil = imagePerfil ?? ImageUploaded(file: File(''), url: '');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': '',
      'sexo': sexo,
      'imagePerfil': StringUtils.getEmptyIfNull(imagePerfil?.url),
      'sobrenome': sobrenome,
      'internalId': internalUserId
    };
  }

  static UserChef empty() {
    return UserChef(
        email: '',
        id: '',
        nome: '',
        imagePerfil: ImageUploaded(file: File(''), url: ''),
        senha: '',
        sexo: '',
        sobrenome: '',
        internalUserId: -1);
  }

  static UserChef fromJson(Map<String, dynamic> json) {
    return UserChef(
        email: json['email'],
        id: json['id'],
        nome: json['nome'],
        senha: '',
        sexo: json['sexo'],
        imagePerfil: ImageUploaded(
          url: StringUtils.getEmptyIfNull(json['imagePerfil']),
          file: File(''),
        ),
        sobrenome: StringUtils.getEmptyIfNull(json['sobrenome']),
        internalUserId: json['internalId']);
  }
}
