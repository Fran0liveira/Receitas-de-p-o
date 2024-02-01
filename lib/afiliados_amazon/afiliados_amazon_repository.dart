import 'package:receitas_de_pao/afiliados/afiliado_identifier.dart';
import 'package:receitas_de_pao/afiliados/afiliados_assets.dart';
import 'package:receitas_de_pao/models/produto_afiliado.dart';

class AfiliadosAmazonRepository {
  static String path = 'lib/afiliados_amazon/{produto_id}';
  static List<ProdAfiliado> createProdutos() {
    return [
      _portaCondimentoGiratorioInox(),
      _sanduicheiraGrillGourmet(),
      _kit12Potes(),
      _jogoUtensiliosMmHouse(),
      _miniProcessadorAlimentos(),
      _balancaCozinhaInox(),
      _portaMantimentosBambu(),
      _fritadeiraAirFryer(),
      _liquidificadorTurbo(),
      _kit4Potes(),
      _panelaPressaoEletrica(),
      _conjuntoUtensiliosLumai(),
      _garrafaTermicaNordica(),
      _cortadorLegumesMultifuncional(),
      _jogoFacasTramontina(),
      _conjuntoMedidoresInox(),
      _kit3Tabuas(),
      _escorredorDePiaAutoSustentavel(),
      _panelaPressaoTramontina(),
      _mixerAlimentos(),
      _faqueiroEmAcoInox(),
      _tapioqueiraTapy(),
      _escorredorLoucasMetaltru(),
      _copoTermicoStanley(),
      _afiadorFacaMor(),
      _torradeiraElectrolux(),
      _fatiadorLegumesMultifuncional(),
      _jogo3Peneiras(),
      _raladorColetorBrinox()
    ];
  }

  static _raladorColetorBrinox() {
    String produtoId = 'ralador_coletor_brinox';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Ralado c/ Coletor Brinox',
      vendasUrl: 'https://amzn.to/48mqp2B',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _jogo3Peneiras() {
    String produtoId = 'jogo_3_peneiras';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Jogo 3 Peneiras Aço Inox',
      vendasUrl: 'https://amzn.to/46fepOq',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _fatiadorLegumesMultifuncional() {
    String produtoId = 'fatiador_legumes_multifuncional';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Fatiador Legumes Multifuncional',
      vendasUrl: 'https://amzn.to/3POme8m',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _torradeiraElectrolux() {
    String produtoId = 'torradeira_electrolux';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Torradeira Electrolux',
      vendasUrl: 'https://amzn.to/459Zcgy',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _afiadorFacaMor() {
    String produtoId = 'afiador_facas_mor';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Afiador De Facas Linha Assador Mor',
      vendasUrl: 'https://amzn.to/48q50W5',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _copoTermicoStanley() {
    String produtoId = 'copo_termico_stanley';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Copo Térmico Stanley',
      vendasUrl: 'https://amzn.to/453pxgf',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _escorredorLoucasMetaltru() {
    String produtoId = 'escorredor_loucas_metaltru';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Escorredor de Louças Metaltru',
      vendasUrl: 'https://amzn.to/48tOXXu',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _tapioqueiraTapy() {
    String produtoId = 'tapioqueira_tapy';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Tapioqueira Tapy',
      vendasUrl: 'https://amzn.to/3PtHizt',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _faqueiroEmAcoInox() {
    String produtoId = 'faqueiro_aco_inox';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Faqueiro em Aço Inox - 24pçs',
      vendasUrl: 'https://amzn.to/3Zt0BOa',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _mixerAlimentos() {
    String produtoId = 'mixer_alimentos';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Mini Processador de Alimentos',
      vendasUrl: 'https://amzn.to/3ru9PwX',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _panelaPressaoTramontina() {
    String produtoId = 'panela_pressao_tramontina';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Panela de Pressão Antiaderente Tramontina',
      vendasUrl: 'https://amzn.to/3t2FplT',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _escorredorDePiaAutoSustentavel() {
    String produtoId = 'escorredor_de_pia_auto_sustentavel';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Escorredor de Pia Auto Sustentável',
      vendasUrl: 'https://amzn.to/3t6tXFS',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _kit3Tabuas() {
    String produtoId = 'kit_3_tabuas';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Kit 3 Tábuas c/ Suporte Organizador',
      vendasUrl: 'https://amzn.to/3Zsbxvt',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _conjuntoMedidoresInox() {
    String produtoId = 'conjunto_medidores_inox';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Conjunto de Medidores Inox',
      vendasUrl: 'https://amzn.to/3Pvqbxt',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _jogoFacasTramontina() {
    String produtoId = 'jogo_facas_tramontina';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Jogo de Facas Tramontina',
      vendasUrl: 'https://amzn.to/3PPJgvx',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _cortadorLegumesMultifuncional() {
    String produtoId = 'cortador_legumes_multifuncional';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Cortador de Legumes Multifuncional',
      vendasUrl: 'https://amzn.to/3rtWMLZ',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _garrafaTermicaNordica() {
    String produtoId = 'garrafa_termica_nordica';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Garrafa Térmica',
      vendasUrl: 'https://amzn.to/3tbxenc',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _conjuntoUtensiliosLumai() {
    String produtoId = 'conjunto_utensilios_lumai';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Conjunto Utensílios Lumai',
      vendasUrl: 'https://amzn.to/3RsXYKc',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _panelaPressaoEletrica() {
    String produtoId = 'panela_pressao_eletrica';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Panela de Pressão Elétrica',
      vendasUrl: 'https://amzn.to/3t995Oj',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _kit4Potes() {
    String produtoId = 'kit_4_potes';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Kit 4 Potes Herméticos',
      vendasUrl: 'https://amzn.to/3RrlvLA',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _liquidificadorTurbo() {
    String produtoId = 'liquidificador_turbo';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Liquidificador Turbo Mondial',
      vendasUrl: 'https://amzn.to/46mB4Z1',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _fritadeiraAirFryer() {
    String produtoId = 'fritadeira_airfryer';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Fritadeira Air Fryer Mondial',
      vendasUrl: 'https://amzn.to/3PN2BNQ',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _portaMantimentosBambu() {
    String produtoId = 'porta_mantimentos_bambu';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Porta Mantimentos com Tampa de Bambu',
      vendasUrl: 'https://amzn.to/460LdLl',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _balancaCozinhaInox() {
    String produtoId = 'balanca_cozinha_inox';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Balança de Cozinha Inox',
      vendasUrl: 'https://amzn.to/3Pt1G3J',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _miniProcessadorAlimentos() {
    String produtoId = 'mini_processador_alimentos';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Mini Processador de Alimentos',
      vendasUrl: 'https://amzn.to/3ZJJ1Wp',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _portaCondimentoGiratorioInox() {
    String produtoId = 'porta_condimento_giratorio';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Porta Condimento Giratório Inox',
      vendasUrl: 'https://amzn.to/45541aM',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _jogoUtensiliosMmHouse() {
    String produtoId = 'jogo_utensilios_mm_house';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );

    return ProdAfiliado(
      ativo: true,
      descricao: 'Jogo Utensílios MM House',
      vendasUrl: 'https://amzn.to/46pbX7Q',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _kit12Potes() {
    String produtoId = 'kit_12_potes';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );
    return ProdAfiliado(
      ativo: true,
      descricao: 'Kit 12 Potes Herméticos',
      vendasUrl: 'https://amzn.to/45kgKH7',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }

  static _sanduicheiraGrillGourmet() {
    String produtoId = 'sanduicheira_grill_gourmet';
    String produtoPath = path.replaceAll('{produto_id}', produtoId);

    AfiliadoIdentifier afiliado = AfiliadoIdentifier(
      id: produtoId,
      path: produtoPath,
      resourcesPath: '$produtoPath/resources',
    );
    return ProdAfiliado(
      ativo: true,
      descricao: 'Sanduicheira Grill Gourmet',
      vendasUrl: 'https://amzn.to/461biK1',
      identifier: afiliado,
      imgSrc: AfiliadosAssets.getSrc(afiliado, 'capa.png'),
    );
  }
}
