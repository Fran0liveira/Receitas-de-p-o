import 'dart:developer';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:decimal/decimal.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:receitas_de_pao/components/txt_validation_model.dart';
import 'package:receitas_de_pao/style/palete.dart';

import '../enums/error_append_mode.dart';
import '../utils/string_utils.dart';
import 'app_textfield_style.dart';

class AppTextField extends StatefulWidget {
  String hint;
  String label;
  bool password;
  bool email;
  bool phone;
  bool multiline;
  bool cpf;
  String text;
  String Function(TextEditingController) validator;
  bool required;
  void Function(String) onSaved;
  var controller = TextEditingController();
  AppTextFieldStyle style;
  void Function(String) onChanged;
  int maxLength;
  int minLength;
  var validationModel = TxtValidationModel();
  bool upperRequired;
  bool lowerRequired;
  bool numericRequired;
  bool specialCharactersRequired;
  bool date;
  ErrorAppendMode errorAppendMode;
  TextStyle errorStyle;
  TextAlign textAlign;
  TextInputFormatter mask;
  TextInputType textInputType;
  void Function() onTap;
  Color labelColor;
  bool money;
  Icon prefixIcon;
  Decimal minNumber;
  bool autoFocus;
  int minLines;

  AppTextField({
    this.minLines,
    this.autoFocus = false,
    this.controller,
    this.hint = '',
    this.label = '',
    this.password = false,
    this.email = false,
    this.phone = false,
    this.multiline = false,
    this.cpf = false,
    this.text = '',
    this.validator,
    this.required = false,
    this.onSaved,
    this.style,
    this.onChanged,
    this.maxLength = -1,
    this.minLength = -1,
    this.upperRequired = false,
    this.lowerRequired = false,
    this.numericRequired = false,
    this.specialCharactersRequired = false,
    this.errorAppendMode = ErrorAppendMode.DEFAULT,
    this.date = false,
    this.errorStyle,
    this.textAlign = TextAlign.left,
    this.mask,
    this.textInputType,
    this.onTap,
    this.labelColor,
    this.money = false,
    this.prefixIcon,
    this.minNumber,
  });

  @override
  _AppTextFieldState createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _passwordVisible = false;
  bool changed = false;

  @override
  Widget build(BuildContext context) {
    _buildValidationModel();
    _checkController();
    _initializeTheme();
    _setupText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!StringUtils.isNullOrEmpty(widget.label))
          Text(
            widget.label,
            style: TextStyle(
                fontSize: widget.style.fontSize, color: widget.labelColor),
          ),
        Container(height: 5),
        TextFormField(
          autofocus: widget.autoFocus ?? false,
          textAlign:
              widget.textAlign != null ? widget.textAlign : TextAlign.left,
          scrollPadding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          onChanged: _onTextChanged,
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.disabled,
          validator: _chooseValidator(),
          onTap: widget.onTap,
          enableSuggestions: !widget.password,
          autocorrect: !widget.password,
          obscureText: _obscureText(),
          decoration: InputDecoration(
            errorMaxLines: 10,
            hintText: widget.hint ?? '',
            suffixIcon: _suffixIcon(),
            prefixIcon: widget.prefixIcon,
            filled: true,
            errorStyle: _errorStyle(),
            fillColor: widget.style.fillColor,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: widget.style.enabledColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: widget.style.focusedColor),
            ),
          ),
          keyboardType: _keyboardType(),
          inputFormatters: _chooseMask(),
          minLines: widget.minLines ?? null,
          maxLines: widget.multiline ? null : (widget.minLines ?? 1),
          style: TextStyle(fontSize: widget.style.fontSize),
        ),
      ],
    );
  }

  _onTextChanged(value) {
    if (!changed) {
      setState(() {
        changed = true;
      });
      return;
    }

    var onChanged = widget.onChanged;
    if (onChanged == null) {
      return;
    }

    widget.onChanged(value);
  }

  _setupText() {
    String controllerText = widget.controller.text;
    String initialText = widget.text;

    if (StringUtils.isNullOrEmpty(controllerText) &&
        !StringUtils.isNullOrEmpty(initialText) &&
        !changed) {
      widget.controller.text = widget.text;
    }
  }

  _errorStyle() {
    return widget.errorStyle ??
        TextStyle(
          color: widget.style.errorColor,
          fontSize: 15,
          backgroundColor: Palete().WHITE,
        );
  }

  _buildValidationModel() {
    widget.validationModel = TxtValidationModel(
        required: widget.required,
        maxLength: widget.maxLength,
        minLength: widget.minLength,
        controller: widget.controller,
        upperRequired: widget.upperRequired,
        lowerRequired: widget.lowerRequired,
        numericRequired: widget.numericRequired,
        specialCharactersRequired: widget.specialCharactersRequired,
        errorAppendMode: widget.errorAppendMode,
        minNumber: widget.minNumber,
        money: widget.money);
  }

  _initializeTheme() {
    if (widget.style == null) {
      widget.style = AppTextFieldStyle(
          fontSize: 18,
          fillColor: Colors.red[50],
          enabledColor: Palete().RED_700,
          focusedColor: Palete().RED_700,
          errorColor: Colors.red);
    }
  }

  bool _obscureText() {
    if (!widget.password) {
      return false;
    }
    return !_passwordVisible;
  }

  IconButton _suffixIcon() {
    if (!widget.password) {
      return null;
    }
    return IconButton(
        icon: Icon(
          // Based on passwordVisible state choose the icon
          _passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.pink[900],
        ),
        onPressed: () {
          // Update the state i.e. toogle the state of passwordVisible variable
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        });
  }

  _checkController() {
    if (widget.controller == null) {
      throw Exception(
          'Informe um controller para esse textfield. Hint:${widget.hint}');
    }
  }

  String Function(String) _chooseValidator() {
    if (widget.email) {
      return _chooseEmailValidator();
    } else if (widget.phone) {
      return _choosePhoneValidator();
    } else {
      return _chooseDefaultValidator();
    }
  }

  String Function(String) _choosePhoneValidator() {
    if (widget.validator == null) {
      return (value) => _validatePhone(widget.controller.text);
    } else {
      return (value) => widget.validator.call(widget.controller);
    }
  }

  String _validatePhone(String phone) {
    if (phone.length == 19) {
      return null;
    } else {
      return 'Informe um número válido';
    }
  }

  String Function(String) _chooseDefaultValidator() {
    return widget.validationModel.validate();
  }

  String Function(String) _chooseEmailValidator() {
    if (widget.validator == null) {
      return (value) => _validateEmail(value);
    } else {
      return (value) => widget.validator.call(widget.controller);
    }
  }

  _chooseMask() {
    if (widget.mask != null) {
      return widget.mask;
    } else if (widget.phone) {
      return [
        MaskTextInputFormatter(
            mask: '+55 (##) #####-####', filter: {"#": RegExp(r'[0-9]')})
      ];
    } else if (widget.cpf) {
      return [
        MaskTextInputFormatter(
            mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')})
      ];
    } else if (widget.date) {
      return [
        MaskTextInputFormatter(
            initialText: '##/##/####',
            mask: '##/##/####',
            filter: {"#": RegExp(r'[0-9]')})
      ];
    } else if (widget.money) {
      return [
        CurrencyTextInputFormatter(
          locale: 'pt-br',
          customPattern: 'R\$ ###,###.##',
        ),
      ];
    } else {
      return [MaskTextInputFormatter()];
    }
  }

  _keyboardType() {
    log('widget input: ${widget.textInputType} - hint: ${widget.hint}');
    if (widget.textInputType != null) {
      return widget.textInputType;
    } else if (widget.phone) {
      return TextInputType.phone;
    } else if (widget.multiline) {
      return TextInputType.multiline;
    } else if (widget.money) {
      return TextInputType.number;
    } else {
      return null;
    }
  }

  String _campoEmBranco(String value) {
    if (StringUtils.isNullOrEmpty(value)) {
      return 'Necessário preencher esse campo';
    } else {
      return null;
    }
  }

  String _validateEmail(String value) {
    if (EmailValidator.validate(value)) {
      return null;
    } else {
      var message = 'Informe um email válido';
      return message;
    }
  }
}
