import 'package:receitas_de_pao/enums/index_fluxo_receita.dart';
import 'package:receitas_de_pao/models/fluxo_receita/etapa_fluxo_receita.dart';

class NomeReceitaEtapa implements EtapaFluxoReceita {
  @override
  int get index => IndexFluxoReceita.NOME_RECEITA;

  @override
  String get title => 'Nome da Receita';
}
