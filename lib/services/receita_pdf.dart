import 'dart:io';

import 'package:flutter/material.dart' as mt;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:receitas_de_pao/components/circular_border_radius.dart';
import 'package:receitas_de_pao/components/rounded.dart';
import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
import 'package:receitas_de_pao/models/my_app/ingrediente.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/models/my_app/secao_receita.dart';
import 'package:receitas_de_pao/services/detalhes_check.dart';
import 'package:receitas_de_pao/services/pdf_service.dart';
import 'package:receitas_de_pao/services/tempo_preparo_check.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:pdf/widgets.dart';
import 'package:receitas_de_pao/utils/duration_utils.dart';

class ReceitaPdf {
  Receita receita;
  Palete palete = Palete();

  ReceitaPdf({this.receita});

  Future<File> generate() async {
    final pdf = Document();

    Widget qrCode = await _qrCode();
    Widget appLogo = await _appLogo();

    pdf.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _header(qrCode, appLogo),
        build: (context) => _secoes(),
      ),
    );

    return PdfService.saveDocument(
      name: '${receita.nome.trim()}.pdf',
      pdf: pdf,
    );
  }

  _extraInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações',
          style: TextStyle(
              color: PdfColors.purple900,
              fontStyle: FontStyle.italic,
              fontSize: 18),
        ),
        SizedBox(height: 5),
        _labelPorcoes(),
        _labelTempo(),
        _labelDificuldade(),
      ],
    );
  }

  _appLogo() async {
    final imageJpg = (await rootBundle.load('lib/assets/rounded_logo.png'))
        .buffer
        .asUint8List();

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
          border: Border.all(
            width: 3,
            color: PdfColors.white,
            style: BorderStyle.solid,
          ),
        ),
        child: Image(
          MemoryImage(imageJpg),
        ));
  }

  _qrCode() async {
    final imageJpg = (await rootBundle.load('lib/assets/qr_code_app_link.png'))
        .buffer
        .asUint8List();

    return Column(children: [
      Text('Acesso ao app:'),
      Image(MemoryImage(imageJpg)),
    ]);
  }

  _labelPorcoes() {
    int porcoes = receita.porcoes;
    var porcoesCheck = PorcoesCheck(porcoes);
    String text;
    if (porcoesCheck.isSingular()) {
      text = '$porcoes porção';
    } else {
      text = '$porcoes porções';
    }
    return Container(
        child: Text(
          '- Rende $text',
          style: TextStyle(fontSize: 16),
        ),
        padding: EdgeInsets.all(5));
  }

  _labelTempo() {
    Duration tempoPreparo = receita.tempoPreparo;
    String text = DurationUtils.formatDefault(tempoPreparo);
    return Container(
      child: Text(
        '- Leva $text',
        style: TextStyle(fontSize: 16),
      ),
      padding: EdgeInsets.all(5),
    );
  }

  _labelDificuldade() {
    String dificuldade = receita.dificuldade;
    return Container(
        child: Text(
          '- Dificuldade $dificuldade',
          style: TextStyle(fontSize: 16),
        ),
        padding: EdgeInsets.all(5));
  }

  _header(Widget qrCode, Widget appLogo) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 80,
              child: Container(
                child: Text(
                  receita.nome,
                  style: TextStyle(
                      color: PdfColors.pink700,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                padding: EdgeInsets.only(right: 10),
              ),
            ),
            Flexible(flex: 25, child: appLogo),
            Flexible(flex: 30, child: qrCode),
          ],
        ),
        SizedBox(height: 20)
      ],
    );
  }

  _secoes() {
    List<SecaoReceita> secoes = receita.secoes;

    List<Widget> widgets = [];

    widgets.add(_extraInfo());
    widgets.add(SizedBox(height: 20));
    for (SecaoReceita secao in secoes) {
      Widget widgetSecao = _createWidgetSecao(secao);
      widgets.add(widgetSecao);
    }
    return widgets;
  }

  _createWidgetSecao(SecaoReceita secao) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _createSecaoIngredientes(secao),
        SizedBox(height: 20),
        _createSecaoModoDePreparo(secao)
      ],
    );
  }

  _createSecaoModoDePreparo(SecaoReceita secao) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(secao.descricao),
        Text(
          'Modo de Preparo',
          style: TextStyle(
              color: PdfColors.purple900,
              fontStyle: FontStyle.italic,
              fontSize: 18),
        ),
        SizedBox(height: 5),
        _createWidgetModoDePreparo(secao),
      ],
    );
  }

  _createSecaoIngredientes(SecaoReceita secao) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(secao.descricao),
        Text(
          'Ingredientes',
          style: TextStyle(
              color: PdfColors.purple900,
              fontStyle: FontStyle.italic,
              fontSize: 18),
        ),
        SizedBox(height: 5),
        _createWidgetIngredientes(secao),
      ],
    );
  }

  _createWidgetIngredientes(SecaoReceita secao) {
    List<Ingrediente> ingredientes = secao.ingredientes;
    List<Widget> widgetsIngredientes = [];
    for (Ingrediente ingrediente in ingredientes) {
      Widget ingredienteWidget = _ingredienteViewModel(ingrediente);
      widgetsIngredientes.add(ingredienteWidget);
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgetsIngredientes);
  }

  _createWidgetModoDePreparo(SecaoReceita secao) {
    List<EtapaPreparo> etapas = secao.modoDePreparo;
    List<Widget> widgetsModoDePreparo = [];
    for (int i = 0; i < etapas.length; i++) {
      EtapaPreparo etapa = etapas.elementAt(i);
      Widget etapaWidget = _etapaViewModel(i, etapa);
      widgetsModoDePreparo.add(etapaWidget);
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgetsModoDePreparo);
  }

  _ingredienteViewModel(Ingrediente ingrediente) {
    return Container(
        padding: EdgeInsets.all(5),
        child: Text(
          '- ${ingrediente.descricao}',
          style: TextStyle(fontSize: 16),
        ));
  }

  _etapaViewModel(int index, EtapaPreparo etapa) {
    return Container(
      child: Text(
        '${index + 1}- ${etapa.descricao}',
        style: TextStyle(fontSize: 16),
      ),
      padding: EdgeInsets.all(5),
    );
  }
}
