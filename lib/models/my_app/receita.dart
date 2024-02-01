import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:receitas_de_pao/enums/app_categorias.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/models/my_app/secao_receita.dart';

import 'avaliacao.dart';
import 'avaliacoes.dart';

class Receita {
  String id;
  String nome;
  List<SecaoReceita> secoes;
  List<ImageUploaded> images;
  Duration tempoPreparo;
  int porcoes;
  bool favorito;
  String categoria;
  String userId;
  DateTime dateTime;
  String dificuldade;
  Avaliacoes avaliacoes;
  String extraInfo;
  int numberOfFavorites;
  String urlVideo;
  bool adicaoScraping;
  String fonteScraping;
  String idScraping;
  String linkScraping;

  Receita({
    this.id = '',
    this.nome = '',
    List<SecaoReceita> secoes,
    List<ImageUploaded> images,
    this.porcoes = -1,
    this.tempoPreparo = Duration.zero,
    this.favorito = false,
    this.categoria,
    this.userId = '',
    this.dateTime,
    this.dificuldade,
    this.avaliacoes,
    this.extraInfo = '',
    this.numberOfFavorites = 0,
    this.urlVideo = '',
    this.adicaoScraping = false,
    this.fonteScraping = '',
    this.idScraping = '',
    this.linkScraping = '',
  })  : secoes = secoes ?? [],
        images = images ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'secoes': secoes.map((secao) => secao.toJson()).toList(),
      'urlsImages': jsonEncode(images.map((image) => image.url).toList()),
      'porcoes': porcoes,
      'tempoPreparo': tempoPreparo.inMilliseconds,
      'favorito': favorito,
      'categoria': categoria,
      'userId': userId,
      'dateTime': dateTime.toString(),
      'dificuldade': dificuldade,
      'extraInfo': extraInfo,
      'numberOfFavorites': numberOfFavorites,
      'urlVideo': urlVideo,
      'adicaoScraping': adicaoScraping,
      'fonteScraping': fonteScraping,
      'idScraping': idScraping,
      'linkScraping': linkScraping,
    };
  }

  static Receita fromJson(Map<String, dynamic> receita) {
    List<dynamic> listUrls = jsonDecode(receita['urlsImages']);

    List<String> urls = listUrls.map((url) => url.toString()).toList();

    List<ImageUploaded> images =
        urls.map((url) => ImageUploaded(url: url, file: File(''))).toList();

    // String categoria = CategoriaReceita.values.firstWhere((element) =>
    //     receita['categoria'].toString().toUpperCase() == element.toUpperCase());

    List<SecaoReceita> secoes = List.of(receita['secoes'])
        .map((e) => SecaoReceita.fromJson(e))
        .toList();

    return Receita(
      id: receita['id'],
      nome: receita['nome'],
      secoes: secoes,
      images: images,
      porcoes: receita['porcoes'],
      tempoPreparo: Duration(milliseconds: receita['tempoPreparo']),
      favorito: receita['favorito'],
      categoria: receita['categoria'],
      userId: receita['userId'],
      dateTime: DateTime.parse(receita['dateTime']),
      dificuldade: receita['dificuldade'],
      extraInfo: receita['extraInfo'],
      numberOfFavorites: receita['numberOfFavorites'],
      urlVideo: receita['urlVideo'],
      adicaoScraping: receita['adicaoScraping'],
      fonteScraping: receita['fonteScraping'],
      idScraping: receita['idScraping'],
      linkScraping: receita['linkScraping'],
    );
  }

  factory Receita.empty() {
    return Receita(
      nome: '',
      secoes: [],
      images: List.filled(1, ImageUploaded(file: File(''), url: '')),
      porcoes: -1,
      tempoPreparo: Duration.zero,
      favorito: false,
      categoria: null,
      userId: '',
      dateTime: DateTime.now(),
      dificuldade: '',
      avaliacoes: Avaliacoes.empty(),
      extraInfo: '',
      numberOfFavorites: 0,
      urlVideo: '',
      adicaoScraping: false,
      fonteScraping: '',
      idScraping: '',
      linkScraping: '',
    );
  }
}
