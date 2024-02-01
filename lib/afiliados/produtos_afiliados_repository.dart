import 'dart:collection';
import 'dart:developer';
import 'dart:math' as math;

import 'package:receitas_de_pao/repository/preferences_repository.dart';
import 'package:receitas_de_pao/afiliados/afiliado_identifier.dart';
import 'package:receitas_de_pao/afiliados/afiliados_assets.dart';
import 'package:receitas_de_pao/afiliados/afiliados_identifier_factory.dart';
import 'package:receitas_de_pao/afiliados/descricao_detalhada_afiliado_repository.dart';
import 'package:receitas_de_pao/afiliados/prod_afiliado_situation.dart';
import 'package:receitas_de_pao/models/produto_afiliado.dart';
import 'package:receitas_de_pao/repository/preferences_repository.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';

class ProdsAfiliadosRepository {
  static List<ProdAfiliado> createProdutos() {
    List<ProdAfiliado> afiliados = [
      _createCursoPaesCaseirosRecheados(),
      _createReceitasDeSucesso(),
      _createGeladinhosGourmetDanusa(),
      _createBrigadeirosDeSucesso(),
      _createCursoHamburguerArtesanal(),
      _createDesafio19Dias(),
      _create500ReceitasZero(),
      _createCardapioDoBebe(),
      _createApostilasMaster(),
      _createReceitasParaBebes(),
      _receitasFuncionais(),
      _cursoBrigadeiroGourmet(),
      _receitasSucosDetox53(),
      _cursoMarmitariaFit(),
      _receitasBebes1Ano(),
      _marmitaFit(),
      _cursoSalgadinhosArtesanais(),
      _cursoDocesFinosGourmet(),
      _especialistaBentoCake(),
      _secandoEmCasa30Dias(),
      _marmitaFitCongelada(),
      _cursoBrowniePerfeito(),
      _cursoMestreDoEspetinho(),
      _coposDaFelicidadeLucrativos(),
      _cursoLinguicaArtesanal(),
      _cursoPizzaiolo(),
      _cachorroQuenteGourmet(),

      //_cursoBoloCaseirinho(),
      //_cursoBoloCaseirinho(),
      //_cursoFormacaoConfeiteiros(),
      //_cursoQuitandaEmCasa(),
      //_arteDasTrancasRecheadas(),
      //_receitasAirFryer(),
    ];

    return afiliados;
  }

  static _createCursoPaesCaseirosRecheados() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoPaesCaseirosRecheados();
    return ProdAfiliado(
        identifier: afiliado,
        descricao: 'Curso de Pães Caseiros e Recheados',
        ativo: true,
        vendasUrl: 'https://go.hotmart.com/J84562099M',
        imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.jpg'));
  }

  static _createCursoHamburguerArtesanal() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoHamburguerArtesanal();
    return ProdAfiliado(
        identifier: afiliado,
        descricao: 'Curso Hambúrguer Artesanal!',
        ativo: true,
        vendasUrl: 'https://go.hotmart.com/B74376457T',
        imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'));
  }

  static _createGeladinhosGourmetDanusa() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.geladinhosGourmetDanusa();

    return ProdAfiliado(
        identifier: afiliado,
        descricao: 'De 2 à 5 mil com Geladinho Gourmet!',
        ativo: true,
        vendasUrl: 'https://go.hotmart.com/U74377113V',
        imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'));
  }

  static _createReceitasDeSucesso() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.receitasDeSucesso();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Receitas de Sucesso!',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/C74375786H?ap=0b38',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _createDesafio19Dias() {
    AfiliadoIdentifier afiliado = AfiliadosIdentifierFactory.desafio19Dias();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Desafio 19 Dias',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/L83023924J',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _create500ReceitasZero() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.quinhentasReceitasZero();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: '500 Receitas Zero',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/R83024766U',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _createCardapioDoBebe() {
    AfiliadoIdentifier afiliado = AfiliadosIdentifierFactory.cardapioDoBebe();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Cardápio do Bebê',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/N86431123M',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _createApostilasMaster() {
    AfiliadoIdentifier afiliado = AfiliadosIdentifierFactory.apostilasMaster();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Apostilas Master',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/C83025604R',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _createReceitasParaBebes() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.receitasParaBebes();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'De 6 a 12 Meses - Receitas Para Bebês',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/X83026215T',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _receitasFuncionais() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.receitasFuncionais();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Receitas Funcionais - Para Sua Saúde e Beleza',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/C83026429O',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _receitasAirFryer() {
    AfiliadoIdentifier afiliado = AfiliadosIdentifierFactory.receitasAirFryer();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: '55 Receitas AirFryer',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/V83026879C',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _cursoBrigadeiroGourmet() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoBrigadeiroGourmet();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Curso Brigadeiro Gourmet',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/J83068940L',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.jpg'),
    );
  }

  static _receitasSucosDetox53() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.receitasSucosDetox53();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: '53 Receitas Sucos Detox',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/H83069957I',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _cursoMarmitariaFit() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoMarmitariaFit();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Curso Marmitaria Fit',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/T83070101M',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _receitasBebes1Ano() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.receitasBebes1ano();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'A partir de 1 Ano - Receitas Para Bebês',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/E83070248H',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _marmitaFit() {
    AfiliadoIdentifier afiliado = AfiliadosIdentifierFactory.marmitaFit();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Marmita Fit',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/J83070491N',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _cursoSalgadinhosArtesanais() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoSalgadinhosArtesanais();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Curso Salgadinhos Artesanais',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/G74376614H',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _cursoDocesFinosGourmet() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoDocesFinosGourmet();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Curso Doces Finos Gourmet',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/D83071034V',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _especialistaBentoCake() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.especialistaBentoCake();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Especialista Em Bentô Cake',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/A74376534X',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _secandoEmCasa30Dias() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.secandoEmCasa30Dias();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Secando Em Casa 30 Dias',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/Q83081587F',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _cursoQuitandaEmCasa() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoQuitandaEmCasa();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Curso Quitanda Em Casa',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/I83081704X',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _arteDasTrancasRecheadas() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.arteDasTrancasRecheadas();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'A Arte Das Tranças Recheadas',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/O83077324B',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _marmitaFitCongelada() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.marmitaFitCongelada();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Marmita Fit Congelada',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/E74376512N',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _cursoBoloCaseirinho() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoBoloCaseirinho();
    return ProdAfiliado(
      identifier: afiliado,
      descricao:
          'Curso Bolo Caseirinho com Cobertura Estampada - Doces da Jéssica',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/V83083690B',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.jpg'),
    );
  }

  static _cursoBrowniePerfeito() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoBrowniePerfeito();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'O Brownie Perfeito - Passo a Passo',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/B83083929N',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _cursoMestreDoEspetinho() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoMestreDoEspetinho();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Curso Mestre Do Espetinho',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/W75049347T',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _cursoFormacaoConfeiteiros() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoFormacaoConfeiteiros();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Curso Formação de Confeiteiros de Sucesso',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/K83084423Q',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.jpg'),
    );
  }

  static _cursoLinguicaArtesanal() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cursoLinguicaArtesanal();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Curso de Linguiça Artesanal',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/C83084791M',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _cursoPizzaiolo() {
    AfiliadoIdentifier afiliado = AfiliadosIdentifierFactory.cursoPizzaiolo();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Curso de Pizzaiolo',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/K74376606P',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _coposDaFelicidadeLucrativos() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.coposDaFelicidadeLucrativos();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Copos Da Felicidade Lucrativos',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/D83085131O',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.jpeg'),
    );
  }

  static _cachorroQuenteGourmet() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.cachorroQuenteGourmet();
    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Cachorro Quente Gourmet',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/W75049410G',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.jpeg'),
    );
  }

  // static _quatrocentasReceitasFitLowCarb() {
  //   AfiliadoIdentifier afiliado =
  //       AfiliadosIdentifierFactory.quatrocentasReceitasFitLowCarb();
  //   return ProdAfiliado(
  //     identifier: afiliado,
  //     descricao: '400 Receitas Fit Low Carb',
  //     ativo: true,
  //     vendasUrl: 'https://go.hotmart.com/C83025604R',
  //     imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
  //   );
  // }

  static _createBrigadeirosDeSucesso() {
    AfiliadoIdentifier afiliado =
        AfiliadosIdentifierFactory.brigadeirosDeSucesso();

    return ProdAfiliado(
      identifier: afiliado,
      descricao: 'Brigadeiros de Sucesso!',
      ativo: true,
      vendasUrl: 'https://go.hotmart.com/J74376236D?ap=ea43',
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static Future<String> getNextPromocional() async {
    int indexUlrPromocional =
        await PreferencesRepository.getIndexUrlPromocional();
    List<ProdAfiliado> produtos = createProdutos();
    if (indexUlrPromocional == null || indexUlrPromocional == -1) {
      await PreferencesRepository.setIndexUrlPromocional(0);
      return produtos.elementAt(0).vendasUrl;
    }

    int nextIndex = indexUlrPromocional + 1;
    if (nextIndex >= produtos.length) {
      nextIndex = 0;
    }
    await PreferencesRepository.setIndexUrlPromocional(nextIndex);
    return produtos.elementAt(nextIndex).vendasUrl;

    // String vendasUrl = createProdutos()
    //     .elementAt(math.Random.secure().nextInt(createProdutos().length))
    //     .vendasUrl;

    // log('Vendas url: $vendasUrl');
    // return vendasUrl;
  }

  static Future<ProdAfiliado> getNextProdutoReceita() async {
    int indexUrlPromocional =
        await PreferencesRepository.getIndexUrlProdutoReceita();

    List<ProdAfiliado> produtos = createProdutos();

    if (indexUrlPromocional == null || indexUrlPromocional == -1) {
      await PreferencesRepository.setIndexUrlProdutoReceita(0);
      return produtos.elementAt(0);
    }

    int nextIndex = indexUrlPromocional + 1;
    if (nextIndex >= produtos.length) {
      nextIndex = 0;
    }

    await PreferencesRepository.setIndexUrlProdutoReceita(nextIndex);
    return produtos.elementAt(nextIndex);
  }
}
