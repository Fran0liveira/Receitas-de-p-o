import 'package:receitas_de_pao/enums/index_fluxo_receita.dart';
import 'package:receitas_de_pao/models/fluxo_receita/etapa_fluxo_receita.dart';

class IngredientesEtapa implements EtapaFluxoReceita {
  @override
  int get index => IndexFluxoReceita.INGREDIENTES;

  @override
  String get title => 'Ingredientes';
}
