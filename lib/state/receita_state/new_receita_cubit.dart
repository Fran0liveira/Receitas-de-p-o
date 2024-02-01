import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receitas_de_pao/enums/crud_operation.dart';
import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/models/my_app/ingrediente.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/models/my_app/secao_receita.dart';

import 'receita_state.dart';

class NewReceitaCubit extends Cubit<ReceitaState> {
  Receita _receita = Receita.empty();
  AutovalidateMode _autovalidateModeIngrediente = AutovalidateMode.disabled;

  NewReceitaCubit() : super(ReceitaState(receita: Receita.empty()));

  Receita get receita => _receita;
  AutovalidateMode get autovalidateModeIngrediente =>
      _autovalidateModeIngrediente;

  updateNomeReceita(String nome) {
    _receita.nome = nome;
    log('atualizando nome: $nome');
    _emitirEstado();
  }

  updateUrlVideo(String urlVideo) {
    _receita.urlVideo = '';
    _emitirEstado();

    Future.delayed(Duration(seconds: 1), () {
      _receita.urlVideo = urlVideo;
      _emitirEstado();
    });
  }

  updateExtraInfo(String extraInfo) {
    receita.extraInfo = extraInfo;
    _emitirEstado();
  }

  setReceita({Receita receita}) {
    _receita = receita;
    _emitirEstado();
  }

  updateDificuldadeReceita(String dificuldade) {
    _receita.dificuldade = dificuldade;
    _emitirEstado();
  }

  addSecao(SecaoReceita secaoReceita) {
    receita.secoes.add(secaoReceita);
    _emitirEstado();
  }

  addIngrediente({Ingrediente ingrediente, int secaoPosition}) {
    receita.secoes.elementAt(secaoPosition).ingredientes.add(ingrediente);
    _emitirEstado();
  }

  addEtapa({EtapaPreparo etapa, int secaoPosition}) {
    receita.secoes.elementAt(secaoPosition).modoDePreparo.add(etapa);
    _emitirEstado();
  }

  updatePorcoes(int porcoes) {
    receita.porcoes = porcoes;
    _emitirEstado();
  }

  updateCategoria(String categoria) {
    _receita.categoria = categoria;
    log('atualizando categoria para $categoria');
    _emitirEstado();
  }

  updateAutoValidateModeIngrediente(AutovalidateMode autovalidateMode) {
    _autovalidateModeIngrediente = autovalidateMode;
    _emitirEstado();
  }

  salvarImagem({int position, ImageUploaded image}) {
    _receita.images[position] = image;
    _emitirEstado();
  }

  updateTempoPreparo(Duration duration) {
    receita.tempoPreparo = duration;
    _emitirEstado();
  }

  updateIngrediente(
      {Ingrediente ingrediente, int secaoPosition, int ingredientePosition}) {
    receita.secoes[secaoPosition].ingredientes[ingredientePosition] =
        ingrediente;
    _emitirEstado();
  }

  updateSecao({SecaoReceita secaoReceita, int secaoPosition}) {
    receita.secoes[secaoPosition] = secaoReceita;
    _emitirEstado();
  }

  updateEtapaPreparo(
      {EtapaPreparo etapaPreparo, int secaoPosition, int etapaPosition}) {
    receita.secoes[secaoPosition].modoDePreparo[etapaPosition] = etapaPreparo;
    _emitirEstado();
  }

  deleteEtapaPreparacao({int position, int secaoPosition}) {
    receita.secoes.elementAt(secaoPosition).modoDePreparo.removeAt(position);
    _emitirEstado();
  }

  deleteSecao({int secaoPosition}) {
    receita.secoes.removeAt(secaoPosition);
    _emitirEstado();
  }

  deleteIngrediente({int ingredientePosition, int secaoPosition}) {
    receita.secoes
        .elementAt(secaoPosition)
        .ingredientes
        .removeAt(ingredientePosition);
    _emitirEstado();
  }

  _emitirEstado() {
    emit(ReceitaState(receita: _receita));
  }

  clean() {
    _receita = Receita.empty();
    _emitirEstado();
  }
}
