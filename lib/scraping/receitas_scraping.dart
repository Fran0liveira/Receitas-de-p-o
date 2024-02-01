// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:html/parser.dart';
// import 'package:receitas_de_pao/enums/app_categorias.dart';
// import 'package:receitas_de_pao/enums/dificuldade_receita.dart';
// import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
// import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
// import 'package:uuid/uuid.dart';
// import 'package:web_scraper/web_scraper.dart';

// import '../models/my_app/avaliacoes.dart';
// import '../models/my_app/ingrediente.dart';
// import '../models/my_app/receita.dart';
// import '../models/my_app/secao_receita.dart';
// import '../utils/list_utils.dart';
// import '../utils/string_utils.dart';
// import 'package:html/dom.dart' as Dom;

// class ReceitasScrapingTudoGostoso {
//   Future<Receita> fetchReceita() async {
//     String site = 'https://www.tudogostoso.com.br';
//     String linkReceita = '/receita/35829-pao-caseiro-rapido-e-fofo.html';
//     String fullLink = '$site$linkReceita';
//     final webScraper = WebScraper(site);

//     if (!await webScraper.loadWebPage(linkReceita)) {
//       return null;
//     }

//     List<Map<String, dynamic>> recipeTitleMaps =
//         webScraper.getElement('div.recipe-title > h1', []);

//     List<Map<String, dynamic>> recipeTimeMaps =
//         webScraper.getElement('span.preptime > time.dt-duration', []);

//     List<Map<String, dynamic>> recipePorcoesMaps =
//         webScraper.getElement('div.serve > data', []);

//     List<Map<String, dynamic>> imgsMaps = webScraper.getElement(
//         'div.recipe-images > ul > li.swiper-slide > picture > img', ['src']);

//     String recipeTitle = (recipeTitleMaps.first['title'] as String).trim()
//       ..replaceAll('\n', '');
//     String time = recipeTimeMaps.first['title'];
//     String porcoes = recipePorcoesMaps.first['title'];

//     List<ImageUploaded> images = imgsMaps
//         .map((map) =>
//             ImageUploaded(url: _formatUrlImage(map['attributes']['src'])))
//         .toList();

//     List<SecaoReceita> secoes = _createSecoes(webScraper);

//     return Receita(
//         id: Uuid().v1(),
//         nome: recipeTitle,
//         tempoPreparo: _formatTime(time),
//         porcoes: _formatPortion(porcoes),
//         secoes: secoes,
//         urlVideo: '',
//         avaliacoes: Avaliacoes.empty(),
//         adicaoScraping: true,
//         fonteScraping: 'Tudo Gostoso',
//         dateTime: DateTime.now(),
//         dificuldade: DificuldadeReceita.FACIL,
//         userId: 'QrDzRoav4QaOb6tfLrS767eXB7a2',
//         favorito: false,
//         extraInfo: '',
//         images: [images.first],
//         numberOfFavorites: 0,
//         idScraping: '',
//         categoria: CategoriaReceita.TRADICIONAIS,
//         linkScraping: fullLink);
//   }

//   _createSecoes(WebScraper webScraper) {
//     String pageContent = webScraper.getPageContent();

//     var document = parse(pageContent);

//     List<Dom.Element> elements =
//         document.getElementsByClassName('ingredients-card');

//     for (Dom.Element element in elements) {
//       List<Dom.Element> children = element.children;

//       if (children.any((child) => child.className == 'card-subtitle')) {
//         return _multipleSecoes(webScraper, children);
//       }
//     }
//     List<Ingrediente> ingredientes = [];
//     List<Dom.Element> childrenIngredients =
//         document.getElementsByClassName('p-ingredient');
//     for (Dom.Element ingredientElement in childrenIngredients) {
//       ingredientes.add(Ingrediente(descricao: ingredientElement.text));
//     }

//     List<EtapaPreparo> etapasPreparo = [];
//     Dom.Element instructions =
//         document.getElementsByClassName('instructions').first;

//     List<Dom.Element> childrenEtapas = instructions.children.first.children;
//     for (Dom.Element etapaElement in childrenEtapas) {
//       etapasPreparo.add(EtapaPreparo(descricao: etapaElement.text));
//     }

//     return [
//       SecaoReceita(
//         ingredientes: ingredientes,
//         modoDePreparo: etapasPreparo,
//       )
//     ];
//   }

//   _multipleSecoes(WebScraper webScraper, List<Dom.Element> children) {
//     List<SecaoReceita> secoes = [];
//     for (Dom.Element child in children) {
//       String descricaoSecao = '';
//       List<Ingrediente> ingredientes = [];

//       if (child.className == 'card-subtitle') {
//         descricaoSecao = child.text;
//         List<Dom.Element> ingredientesElements =
//             child.nextElementSibling.children;

//         ingredientes = ingredientesElements.map((ingredienteElement) {
//           return Ingrediente(descricao: ingredienteElement.text);
//         }).toList();

//         secoes.add(SecaoReceita(
//           descricao: descricaoSecao,
//           ingredientes: ingredientes,
//         ));
//       }
//     }

//     List<List<EtapaPreparo>> etapasList = _createEtapas(webScraper);
//     for (int i = 0; i < etapasList.length; i++) {
//       List<EtapaPreparo> etapas = etapasList.elementAt(i);
//       if (secoes.length > i) {
//         secoes.elementAt(i).modoDePreparo = etapas;
//       } else {
//         SecaoReceita secao = SecaoReceita(
//             descricao: '', ingredientes: [], modoDePreparo: etapas);
//         secoes.add(secao);
//       }
//     }
//     return secoes;
//   }

//   List<List<EtapaPreparo>> _createEtapas(WebScraper webScraper) {
//     String pageContent = webScraper.getPageContent();

//     var document = parse(pageContent);

//     List<List<EtapaPreparo>> allEtapas = [];

//     List<Dom.Element> elements =
//         document.getElementsByClassName('instructions');

//     for (Dom.Element element in elements) {
//       List<Dom.Element> children = element.children;
//       for (Dom.Element child in children) {
//         if (child.className == 'card-subtitle') {
//           List<Dom.Element> etapasElements = child.nextElementSibling.children;

//           List<EtapaPreparo> etapasPreparo = etapasElements.map((etapaElement) {
//             return EtapaPreparo(descricao: etapaElement.text);
//           }).toList();

//           allEtapas.add(etapasPreparo);
//         }
//       }
//     }
//     return allEtapas;
//   }

//   // Future<List<Receita>> fetchReceitasByAllReceitasPage() async {
//   //   final webScraper = WebScraper('https://www.tudogostoso.com.br');

//   //   int page = 3;

//   //   if (!await webScraper.loadWebPage('/receitas?&page=$page')) {
//   //     return [];
//   //   }

//   //   List<Map<String, dynamic>> srcs = webScraper
//   //       .getElement('div.recipe-card > a > picture > img.image', ['src']);

//   //   List<Map<String, dynamic>> titles =
//   //       webScraper.getElement('div.recipe-card > a > div.info > h3.title', []);

//   //   List<Map<String, dynamic>> categories = webScraper
//   //       .getElement('div.recipe-card > a > div.info > div.category > span', []);

//   //   List<Map<String, dynamic>> times = webScraper.getElement(
//   //       'div.recipe-card > a > div.info >  div.hover-box > div.numbers > div.time',
//   //       []);

//   //   List<Map<String, dynamic>> portions = webScraper.getElement(
//   //       'div.recipe-card > a > div.info >  div.hover-box > div.numbers > div.portion',
//   //       []);

//   //   List<Map<String, dynamic>> urls =
//   //       webScraper.getElement('div.recipe-card > a.link', ['href']);

//   //   //log('scraping: $urls');

//   //   return montaReceitas(
//   //     idScraping: Uuid().v1(),
//   //     srcs: srcs,
//   //     titles: titles,
//   //     categories: categories,
//   //     times: times,
//   //     portions: portions,
//   //     urls: urls,
//   //   );
//   // }

//   // Future<List<Receita>> montaReceitas(
//   //     {String idScraping,
//   //     List<Map<String, dynamic>> srcs,
//   //     List<Map<String, dynamic>> titles,
//   //     List<Map<String, dynamic>> categories,
//   //     List<Map<String, dynamic>> times,
//   //     List<Map<String, dynamic>> portions,
//   //     List<Map<String, dynamic>> urls}) async {
//   //   List<Receita> receitas = [];
//   //   for (int i = 0; i < titles.length; i++) {
//   //     String title = titles.elementAt(i)['title'];
//   //     String urlImage = srcs.elementAt(i)['attributes']['src'];
//   //     String category = categories.elementAt(i)['title'];
//   //     String time = times.elementAt(i)['title'];
//   //     String portion = portions.elementAt(i)['title'];
//   //     String url = urls.elementAt(i)['attributes']['href'];

//   //     if (StringUtils.isNullOrEmpty(urlImage) ||
//   //         urlImage.contains(
//   //             'https://img.itdg.com.br/tdg/assets/default/recipe_original.png')) {
//   //       continue;
//   //     }

//   //     List<Ingrediente> ingredientes = await _scrapingIngredientes(url);
//   //     List<EtapaPreparo> etapas = await _scrapingEtapas(url);

//   //     SecaoReceita secao = SecaoReceita(
//   //       descricao: '',
//   //       ingredientes: ingredientes,
//   //       modoDePreparo: etapas,
//   //     );

//   //     Receita receita = Receita(
//   //         id: Uuid().v1(),
//   //         nome: title,
//   //         images: [
//   //           ImageUploaded(url: _formatUrlImage(urlImage)),
//   //         ],
//   //         categoria: i % 2 == 0 ? 'MASSAS' : 'BEBIDAS',
//   //         dateTime: DateTime.now(),
//   //         tempoPreparo: _formatTime(time),
//   //         porcoes: _formatPortion(portion),
//   //         secoes: [secao],
//   //         urlVideo: '',
//   //         numberOfFavorites: 0,
//   //         favorito: false,
//   //         extraInfo: '',
//   //         dificuldade: 'Fácil',
//   //         avaliacoes: Avaliacoes.empty(),
//   //         adicaoScraping: true,
//   //         fonteScraping: 'Tudo gostoso',
//   //         idScraping: idScraping,
//   //         userId: 'QrDzRoav4QaOb6tfLrS767eXB7a2');

//   //     receitas.add(receita);
//   //   }
//   //   return receitas;
//   // }

//   _formatUrlImage(String url) {
//     int indexEnd = -1;

//     String formatation = '?mode=crop&width=600&height=480';

//     indexEnd = url.lastIndexOf('.jpg');
//     if (indexEnd != -1) {
//       String urlAfter = url.replaceRange(indexEnd + 4, url.length, '');

//       log('url image before: $url. after: $urlAfter');
//       return urlAfter + formatation;
//     }

//     indexEnd = url.lastIndexOf('.png');
//     if (indexEnd != -1) {
//       String urlAfter = url.replaceRange(indexEnd + 4, url.length, '');

//       log('url image before: $url. after: $urlAfter');
//       return urlAfter + formatation;
//     }
//     return url + formatation;
//   }

//   // Future<List<EtapaPreparo>> _scrapingEtapas(String href) async {
//   //   final webScraper = WebScraper('https://www.tudogostoso.com.br');
//   //   if (!await webScraper.loadWebPage(href)) {
//   //     return [];
//   //   }

//   //   List<Map<String, dynamic>> etapas =
//   //       webScraper.getElement('div.instructions > ol > li > span ', []);

//   //   return etapas.map((json) {
//   //     return EtapaPreparo(descricao: json['title']);
//   //   }).toList();
//   // }

//   // Future<List<Ingrediente>> _scrapingIngredientes(String href) async {
//   //   final webScraper = WebScraper('https://www.tudogostoso.com.br');

//   //   if (!await webScraper.loadWebPage(href)) {
//   //     return [];
//   //   }

//   //   List<Map<String, dynamic>> ingredientes =
//   //       webScraper.getElement('span.p-ingredient > p', []);

//   //   return ingredientes.map((json) {
//   //     return Ingrediente(descricao: json['title']);
//   //   }).toList();
//   // }

//   int _formatPortion(String portion) {
//     int formattedPortion = onlyNumbers(portion);
//     return formattedPortion;
//   }

//   Duration _formatTime(String time) {
//     int formattedTime = onlyNumbers(time);
//     return Duration(minutes: formattedTime);
//   }

//   int onlyNumbers(String value) {
//     return int.parse(value.replaceAll(RegExp('[^0-9]'), ''));
//   }
// }
