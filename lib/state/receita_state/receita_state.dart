import 'package:receitas_de_pao/enums/crud_operation.dart';
import 'package:receitas_de_pao/models/fluxo_receita/etapa_fluxo_receita.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';

class ReceitaState {
  Receita receita;
  EtapaFluxoReceita currentEtapa;
  CrudOperation crudOperationIngrediente;
  ReceitaState(
      {this.receita,
      this.crudOperationIngrediente = CrudOperation.CREATE,
      this.currentEtapa});
}
