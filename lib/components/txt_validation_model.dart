import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:receitas_de_pao/enums/error_append_mode.dart';
import 'package:receitas_de_pao/utils/characters_check.dart';
import 'package:receitas_de_pao/utils/list_utils.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';

class TxtValidationModel {
  bool required;
  int maxLength;
  int minLength;
  bool upperRequired;
  bool lowerRequired;
  bool numericRequired;
  bool specialCharactersRequired;
  var errorAppendMode;
  Decimal minNumber;
  String Function(TextEditingController controller) validator;
  bool money;

  TextEditingController controller;
  TxtValidationModel(
      {this.required = false,
      this.maxLength = -1,
      this.minLength = -1,
      this.controller,
      this.upperRequired = false,
      this.lowerRequired = false,
      this.numericRequired = false,
      this.specialCharactersRequired = false,
      this.errorAppendMode = ErrorAppendMode.DEFAULT,
      this.minNumber,
      this.money = false});

  Function validate2() {
    if (required && StringUtils.isNullOrEmpty(controller.text)) {
      return (value) => _validarRequired(controller.text);
    } else {
      return (value) => _validarMaxMinCaracteres(controller.text);
    }
  }

  String Function(String) validate() {
    return (value) {
      List<String> errors = _makeValidations();
      if (ListUtils.isNullOrEmpty(errors)) {
        return null;
      }
      return _createErrorsBasedOnList(errors);
    };
  }

  List<String> _makeValidations() {
    return [
      _validarValidator(),
      _validarRequired(controller.text),
      _validarMaxMinCaracteres(controller.text),
      _validarMinNumber(controller.text),
      ..._validarCaracteresNecessarios(controller.text)
    ].where((error) => error != null).toList();
  }

  String _validarValidator() {
    if (validator == null) {
      return null;
    } else {
      return validator.call(controller);
    }
  }

  String _createErrorsBasedOnList(List<String> errors) {
    if (ErrorAppendMode.FIRST == errorAppendMode) {
      return errors[0];
    } else if (ErrorAppendMode.ALL == errorAppendMode ||
        _isDefaultAppendMode()) {
      return errors.join('\n');
    } else {
      return null;
    }
  }

  bool _isDefaultAppendMode() {
    return errorAppendMode == null ||
        ErrorAppendMode.DEFAULT == errorAppendMode;
  }

  List<String> _validarCaracteresNecessarios(String value) {
    List<String> errors = [];
    if (!CharacterCheck.containsLower(value) && lowerRequired) {
      errors.add('Necessário conter uma letra minúscula.');
    }
    if (!CharacterCheck.containsUpper(value) && upperRequired) {
      errors.add('Necessário conter uma letra maiúscula.');
    }
    if (!CharacterCheck.containsNumeric(value) && numericRequired) {
      errors.add('Necessário conter um número.');
    }
    if (!CharacterCheck.containsSpecialCharacter(value) &&
        specialCharactersRequired) {
      errors.add('Necessário conter um caractere especial.');
    }
    return errors;
  }

  String _validarRequired(String value) {
    if (StringUtils.isNullOrEmpty(value) && required) {
      return 'Necessário preencher esse campo';
    } else {
      return null;
    }
  }

  String _validarMaxMinCaracteres(String value) {
    if (!qtdMinCaracteresOk(value)) {
      return 'Campo deve ter no mínimo $minLength caracteres';
    } else if (!qtdMaxCaracteresOk(value)) {
      return 'Campo deve ter no máximo $maxLength caracteres';
    } else {
      return null;
    }
  }

  String _validarMinNumber(String value) {
    if (minNumber == null) {
      return null;
    }
    if (StringUtils.isNullOrEmpty(value)) {
      if (money) {
        String descriptionValue = CurrencyTextInputFormatter(
          locale: 'pt-br',
          customPattern: 'R\$ ###,###.##',
        ).format(value);
        return 'Informe um valor maior que $descriptionValue';
      } else {
        return 'Informe um valor maior que 0';
      }
    }
    int intValue = int.parse(value.replaceAll(RegExp('[^0-9]'), ''));
    if (Decimal.fromInt(intValue) <= minNumber) {
      return 'Informe um valor maior que $minNumber';
    }
    return null;
  }

  bool qtdMinCaracteresOk(String value) {
    if (minLength == null || minLength == -1) {
      return true;
    }
    return value.length >= minLength;
  }

  bool qtdMaxCaracteresOk(String value) {
    if (maxLength == null || maxLength == -1) {
      return true;
    }
    return value.length <= maxLength;
  }
}
