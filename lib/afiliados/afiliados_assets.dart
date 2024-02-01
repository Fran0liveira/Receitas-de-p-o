import 'package:receitas_de_pao/afiliados/afiliado_identifier.dart';

class AfiliadosAssets {
  static String getSrc(AfiliadoIdentifier afiliadoIdentifier, String file) {
    return '${afiliadoIdentifier.resourcesPath}/$file';
  }
}
