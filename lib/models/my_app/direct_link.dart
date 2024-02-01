import 'package:flutter/material.dart';
import 'package:receitas_de_pao/models/produto_afiliado.dart';
import 'package:receitas_de_pao/views/produto_afiliado_details_page.dart';

class DirectLink {
  String url;
  ProdAfiliado produto;

  DirectLink({
    this.url = '',
    this.produto,
  });
}
