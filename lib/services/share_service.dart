import 'dart:developer';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
import 'package:receitas_de_pao/models/my_app/ingrediente.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/models/my_app/secao_receita.dart';
import 'package:receitas_de_pao/models/produto_afiliado.dart';
import 'package:receitas_de_pao/services/tempo_preparo_check.dart';
import 'package:receitas_de_pao/utils/duration_utils.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';
import 'package:share_plus/share_plus.dart';

import 'detalhes_check.dart';
import 'emoji_service.dart';

class ShareReceitaService {
  shareReceita(Receita receita) async {
    String printReceita = await _formatReceita(receita);
    Share.share(printReceita, subject: 'Receita - ${receita.nome}');
  }

  _formatReceita(Receita receita) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var packageName = packageInfo.packageName;

    String appLink =
        "http://play.google.com/store/apps/details?id=$packageName";

    var sb = StringBuffer();

    var winkingEmoji = EmojiService.winking();
    var pointingDown = EmojiService.pointingDown();
    var smiling = EmojiService.smiling();
    var festim = EmojiService.festim();

    log('emoji: $winkingEmoji');

    sb.write('Confira esta receita! $winkingEmoji $pointingDown');
    sb.write('\n\n');
    sb.write(_printReceita(receita));
    sb.write('Essa e muitas outras receitas no app *Receitas de Pães*!');
    sb.write('\n\n');
    sb.write('Baixe agora! $smiling $festim $pointingDown');
    sb.write('\n');
    sb.write(appLink);
    return sb.toString();
  }

  _printReceita(Receita receita) {
    var sb = StringBuffer();
    sb.write('*-----${receita.nome.toUpperCase()}-----*');
    sb.write('\n\n');

    for (SecaoReceita secao in receita.secoes) {
      String descricaoSecao = secao.descricao;
      if (!StringUtils.isNullOrEmpty(descricaoSecao)) {
        sb.write('_($descricaoSecao)_');
        sb.write('\n');
      }

      sb.write('*Ingredientes:*');
      sb.write('\n');

      for (Ingrediente ing in secao.ingredientes) {
        sb.write(' - ${ing.descricao}');
        sb.write('\n');
      }

      sb.write('\n');
      sb.write('*Modo de preparo:*');
      sb.write('\n');

      List<EtapaPreparo> modoDePreparo = secao.modoDePreparo;
      for (int i = 0; i < modoDePreparo.length; i++) {
        var etapa = modoDePreparo.elementAt(i);
        sb.write('${i + 1} - ${etapa.descricao}');
        sb.write('\n');
      }
      sb.write('\n');
    }

    int porcoes = receita.porcoes;
    sb.write('-Rende $porcoes porções');
    sb.write('\n');

    Duration tempoPreparo = receita.tempoPreparo;
    sb.write('-Leva ${DurationUtils.formatDefault(tempoPreparo)}');
    sb.write('\n');

    String dificuldade = receita.dificuldade;
    sb.write('-Dificuldade $dificuldade');
    sb.write('\n');

    sb.write('\n');

    return sb.toString();
  }

  shareProdutoAfiliado(ProdAfiliado prod) {
    Share.share(
        'Olá, conheci o(a) \"${prod.descricao}\" e gostaria de recomendá-lo(a) para vc! 🤩 Clique no link para saber mais: ${prod.vendasUrl} 🎉',
        subject: 'Recomendação do ${prod.descricao}');
  }
}
