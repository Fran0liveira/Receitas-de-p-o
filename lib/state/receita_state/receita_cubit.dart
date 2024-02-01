import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receitas_de_pao/enums/crud_operation.dart';
import 'package:receitas_de_pao/models/fluxo_receita/detalhes_etapa.dart';
import 'package:receitas_de_pao/models/fluxo_receita/etapa_fluxo_receita.dart';
import 'package:receitas_de_pao/models/fluxo_receita/ingredientes_etapa.dart';
import 'package:receitas_de_pao/models/fluxo_receita/modo_preparo_etapa.dart';
import 'package:receitas_de_pao/models/fluxo_receita/nome_receita_etapa.dart';
import 'package:receitas_de_pao/models/fluxo_receita/recursos_etapa.dart';
import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/models/my_app/ingrediente.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/utils/list_utils.dart';

import 'receita_state.dart';

class ReceitaCubit extends Cubit<ReceitaState> {
  Receita _receita = Receita.empty();
  Receita get receita => _receita;
  CrudOperation _crudOperationIngrediente = CrudOperation.CREATE;
  CrudOperation _crudOperationEtapaPreparacao = CrudOperation.CREATE;
  int _ingredienteToEditPosition;
  int _etapaPreparacaoToEditPosition;

  CrudOperation get crudOperationIngrediente => _crudOperationIngrediente;
  CrudOperation get crudOperationEtapaPreparacao =>
      _crudOperationEtapaPreparacao;
  int get ingredienteToEditPosition => _ingredienteToEditPosition;
  int get etapaPreparacaoToEditPosition => _etapaPreparacaoToEditPosition;
  bool receitaExpanded = false;
  EtapaFluxoReceita currentEtapa;

  List<EtapaFluxoReceita> etapas = [
    NomeReceitaEtapa(),
    IngredientesEtapa(),
    ModoPreparoEtapa(),
    RecursosEtapa(),
    DetalhesEtapa(),
  ];

  Ingrediente get ingredienteToEdit {
    // List<Ingrediente> ingredientes = receita.ingredientes;

    // if (ListUtils.isNullOrEmpty(ingredientes)) {
    //   return null;
    // }

    // if (ingredienteToEditPosition > ingredientes.length) {
    //   return null;
    // }
    // return ingredientes.elementAt(ingredienteToEditPosition);
  }

  EtapaPreparo get etapaPreparacaoToEdit {
    // List<EtapaPreparo> modoDePreparo = receita.secoesReceita;

    // if (ListUtils.isNullOrEmpty(modoDePreparo)) {
    //   return null;
    // }

    // if (etapaPreparacaoToEditPosition > modoDePreparo.length) {
    //   return null;
    // }
    // return modoDePreparo.elementAt(etapaPreparacaoToEditPosition);
  }

  switchReceitaExpanded() {
    this.receitaExpanded = !receitaExpanded;
    _emitirEstado();
  }

  updateReceitaExpanded(bool expanded) {
    this.receitaExpanded = expanded;
    _emitirEstado();
  }

  updateCategoria(String categoria) {
    receita.categoria = categoria;
    _emitirEstado();
  }

  updatePorcoes(int porcoes) {
    receita.porcoes = porcoes;
    _emitirEstado();
  }

  updateTempoPreparo(Duration tempoPreparo) {
    receita.tempoPreparo = tempoPreparo;
    _emitirEstado();
  }

  ReceitaCubit() : super(ReceitaState(receita: Receita.empty()));

  updateCrudOperationIngrediente(CrudOperation crudOperation) {
    _crudOperationIngrediente = crudOperation;
    _emitirEstado();
  }

  updateCrudOperationEtapaPreparacao(CrudOperation crudOperation) {
    _crudOperationEtapaPreparacao = crudOperation;
    _emitirEstado();
  }

  salvarEtapaModoDePreparo(EtapaPreparo etapaModoDePreparo) {
    // receita.secoesReceita.add(etapaModoDePreparo);
    // _emitirEstado();
  }

  updateName(String name) {
    receita.nome = name;
    _emitirEstado();
  }

  updateEtapa(EtapaFluxoReceita etapa) {
    currentEtapa = etapa;
    _emitirEstado();
  }

  updateIndexFluxo(int index) {
    currentEtapa = etapas[index];
    updateEtapa(currentEtapa);
  }

  avancarEtapa() {
    int index = currentEtapa.index;
    updateEtapa(etapas[++index]);
  }

  salvarIngrediente(Ingrediente ingrediente) {
    // receita.ingredientes.add(ingrediente);
    // _emitirEstado();
  }

  _emitirEstado() {
    emit(ReceitaState(receita: receita, currentEtapa: currentEtapa));
  }

  deleteIngrediente(int position) {
    // receita.ingredientes.removeAt(position);
    // _emitirEstado();
  }

  deleteEtapaPreparacao(int position) {
    receita.secoes.removeAt(position);
    _emitirEstado();
  }

  putIngredienteToEditPosition(int position) {
    _ingredienteToEditPosition = position;
  }

  putEtapaPreparacaoPosition(int position) {
    _etapaPreparacaoToEditPosition = position;
  }

  updateDescricaoIngrediente(String descricao) {
    if (ingredienteToEditPosition == null) {
      return;
    }
    ingredienteToEdit.descricao = descricao;
    _emitirEstado();
  }

  updateEtapaPreparacao(String descricao) {
    // log('Etapa position: $etapaPreparacaoToEditPosition');
    // if (etapaPreparacaoToEditPosition == null) {
    //   return;
    // }
    // List<EtapaPreparo> modoDePreparo = receita.secoesReceita;
    // if (ListUtils.isNullOrEmpty(modoDePreparo)) {
    //   return null;
    // }
    // if (etapaPreparacaoToEditPosition > modoDePreparo.length) {
    //   return null;
    // }
    // modoDePreparo[etapaPreparacaoToEditPosition].descricao = descricao;
    // _emitirEstado();
  }

  salvarImagem(ImageUploaded image) {
    receita.images.add(image);
    _emitirEstado();
  }

  salvarImagens(List<ImageUploaded> images) {
    receita.images.addAll(images);
    _emitirEstado();
  }

  setReceita(Receita receita) {
    _receita = receita;
    _emitirEstado();
  }

  reset() {
    currentEtapa = etapas[0];
    _receita = Receita.empty();
    updateCrudOperationIngrediente(CrudOperation.CREATE);
    updateCrudOperationEtapaPreparacao(CrudOperation.CREATE);
    _emitirEstado();
  }
}
