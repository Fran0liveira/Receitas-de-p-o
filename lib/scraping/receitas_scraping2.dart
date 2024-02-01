import 'dart:developer';

import 'package:receitas_de_pao/enums/app_categorias.dart';
import 'package:receitas_de_pao/models/my_app/avaliacoes.dart';
import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/models/my_app/ingrediente.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/models/my_app/secao_receita.dart';
import 'package:receitas_de_pao/utils/list_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:web_scraper/web_scraper.dart';

class ReceitasScraping2 {
  Future<Receita> fetchReceita() async {
    String site = 'https://www.tudogostoso.com.br';
    String linkReceita = '/receita/45839-pao-de-cenoura.html';
    String fullLink = '$site$linkReceita';
    final scraper = WebScraper(site);

    String image = _formatUrlImage(
        'https://static.itdg.com.br/images/640-420/d0cd993c7a32a781e535a19fbb41b96d/18936-original.jpg');

    if (!await scraper.loadWebPage(linkReceita)) {
      return null;
    }

    var nomeReceita =
        scraper.getElement('header > span.u-title-page', [])?.first['title'];

    var tempoPreparo =
        scraper.getElement('div.recipe-info-item', [])?.first['title'];

    var ingredients = scraper
        .getElement('span.recipe-ingredients-item-label', [])
        .map((e) => Ingrediente(descricao: e['title']))
        .toList();

    var etapas = scraper
        .getElement('div.recipe-steps-text', [])
        .map((e) => EtapaPreparo(descricao: e['title']))
        .toList();

    var porcoes = scraper
        .getElement('section.recipe-section > header > h2', [])?.first['title'];

    var extranInfoElement =
        scraper.getElement('div.recipe-advice-content > div.is-wysiwyg', []);

    var extraInfo;
    if (!ListUtils.isNullOrEmpty(extranInfoElement)) {
      extraInfo = extranInfoElement.first['title'];
    }

    return Receita(
      id: Uuid().v1(),
      nome: nomeReceita,
      tempoPreparo: _formatTime(tempoPreparo),
      secoes: [
        SecaoReceita(
          ingredientes: ingredients,
          modoDePreparo: etapas,
        )
      ],
      porcoes: _formatPortion(porcoes),
      urlVideo: '',
      avaliacoes: Avaliacoes.empty(),
      extraInfo: extraInfo,
      dificuldade: 'Fácil',
      adicaoScraping: true,
      fonteScraping: 'Tudo Gostoso',
      idScraping: '',
      categoria: CategoriaReceita.TRADICIONAIS,
      dateTime: DateTime.now(),
      favorito: false,
      images: [ImageUploaded(url: image)],
      linkScraping: fullLink,
      numberOfFavorites: 0,
      userId: 'Gc7McS9lWAX0wlzVjrATH5xY28z2',
    );
  }

  int _formatPortion(String portion) {
    int formattedPortion = onlyNumbers(portion);
    return formattedPortion;
  }

  Duration _formatTime(String time) {
    int formattedTime = onlyNumbers(time);
    return Duration(minutes: formattedTime);
  }

  int onlyNumbers(String value) {
    return int.parse(value.replaceAll(RegExp('[^0-9]'), ''));
  }

  _formatUrlImage(String url) {
    int indexEnd = -1;

    String formatation = '?mode=crop&width=600&height=480';

    indexEnd = url.lastIndexOf('.jpg');
    if (indexEnd != -1) {
      String urlAfter = url.replaceRange(indexEnd + 4, url.length, '');

      log('url image before: $url. after: $urlAfter');
      return urlAfter + formatation;
    }

    indexEnd = url.lastIndexOf('.png');
    if (indexEnd != -1) {
      String urlAfter = url.replaceRange(indexEnd + 4, url.length, '');

      log('url image before: $url. after: $urlAfter');
      return urlAfter + formatation;
    }
    String urlFinal = (url + formatation).replaceAll('640-420', '600-480');
    return urlFinal;
  }
}
