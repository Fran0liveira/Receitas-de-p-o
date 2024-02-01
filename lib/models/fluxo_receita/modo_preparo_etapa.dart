import 'package:receitas_de_pao/enums/index_fluxo_receita.dart';
import 'package:receitas_de_pao/models/fluxo_receita/etapa_fluxo_receita.dart';

class ModoPreparoEtapa implements EtapaFluxoReceita {
  @override
  int get index => IndexFluxoReceita.MODO_DE_PREPARO;

  @override
  String get title => 'Modo de preparo';
}
