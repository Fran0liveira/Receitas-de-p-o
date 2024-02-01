// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:receitas_de_pao/main.dart';
import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
import 'package:receitas_de_pao/models/my_app/ingrediente.dart';
import 'package:receitas_de_pao/models/my_app/secao_receita.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  test('ingredientes encode', () {
    Ingrediente ingre = Ingrediente(descricao: 'Brocolis');
    print('${ingre.toJson()}');
  });

  test('etapa preparo encode', () {
    EtapaPreparo etapaPreparo = EtapaPreparo(
        descricao: 'Levar ao forno por 30 min',
        tempo: Duration(minutes: 30),
        timerAtivado: true);
    print('${etapaPreparo.toJson()}');
  });

  test('secao receita encode', () {
    SecaoReceita secaoReceita =
        SecaoReceita(descricao: 'Cobertura do Bolo', ingredientes: [
      Ingrediente(descricao: 'Açucar'),
    ], modoDePreparo: [
      EtapaPreparo(
          timerAtivado: true,
          tempo: Duration(minutes: 30),
          descricao: 'Levar ao forno por 30min')
    ]);

    print('${secaoReceita.toJson()}');
  });

  test('secoes list encode', () {
    SecaoReceita secaoReceita =
        SecaoReceita(descricao: 'Cobertura do Bolo', ingredientes: [
      Ingrediente(descricao: 'Açucar'),
    ], modoDePreparo: [
      EtapaPreparo(
          timerAtivado: true,
          tempo: Duration(minutes: 30),
          descricao: 'Levar ao forno por 30min')
    ]);

    var secoes = [secaoReceita.toJson()];
    print(secoes);
  });

  test('fromJson Ingrediente', () {
    String json = "";
  });
}
