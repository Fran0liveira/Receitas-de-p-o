import 'package:receitas_de_pao/afiliados/afiliado_identifier.dart';
import 'package:receitas_de_pao/afiliados/prod_afiliado_situation.dart';

class ProdAfiliado {
  String descricao;
  String imgSrc;
  List<String> subimages;
  bool ativo;
  String vendasUrl;
  AfiliadoIdentifier identifier;

  ProdAfiliado(
      {this.descricao = '',
      this.imgSrc = '',
      this.ativo = true,
      this.vendasUrl = '',
      List<String> subimages,
      this.identifier})
      : subimages = subimages ?? [];
}
