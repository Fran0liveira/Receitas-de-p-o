import 'package:receitas_de_pao/enums/index_fluxo_receita.dart';
import 'package:receitas_de_pao/models/fluxo_receita/etapa_fluxo_receita.dart';

class DetalhesEtapa implements EtapaFluxoReceita {
  @override
  int get index => IndexFluxoReceita.DETALHES;

  @override
  String get title => 'Detalhes';
}
