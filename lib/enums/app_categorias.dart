import 'package:receitas_de_pao/extensions/list_extensions.dart';

import '../utils/string_utils.dart';

class CategoriaReceita {
  static const String TODAS = 'TODAS';
  static const String TRADICIONAIS = 'TRADICIONAIS';
  // static const String ARTESANAIS = 'ARTESANAIS';
  // static const String ESPECIAIS = 'ESPECIAIS';
  // static const String DOCES = 'DOCES';
  // static const String REGIONAIS = 'REGIONAIS';
  // static const String SEM_GLUTEN = 'SEM GLÚTEN';

  //static const String VEGANO = 'VEGANO';

  static List<String> get values {
    List<String> list = [
      TRADICIONAIS,
      // ARTESANAIS,
      // ESPECIAIS,
      // ESPECIAIS,
      // DOCES,
      // REGIONAIS,
      // SEM_GLUTEN,
      //VEGANO
    ]..alphabetically();

    return list;
  }

  static bool isSameCategory(String category, String category2) {
    return _format(category) == _format(category2);
  }

  static _format(String data) {
    return StringUtils.getEmptyIfNull(data).trim().toUpperCase();
  }

  static String getDescricaoExibicao(String value) {
    return value;
  }
}
