import 'package:receitas_de_pao/models/my_app/receita.dart';

class ReceitaPageArguments {
  String idReceita;
  List<Receita> receitasSemelhantes;

  ReceitaPageArguments(
    List<Receita> receitasSemelhantes,
    String idReceita,
  )   : receitasSemelhantes = receitasSemelhantes ?? [],
        idReceita = idReceita ?? '';
}
