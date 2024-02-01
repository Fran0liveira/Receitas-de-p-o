import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:receitas_de_pao/enums/crud_operation.dart';
import 'package:receitas_de_pao/models/my_app/etapa_preparo.dart';
import 'package:receitas_de_pao/state/etapa_state.dart';

class EtapaCubit extends Cubit<EtapaState> {
  bool _timerAtivado;
  Duration _tempo;
  String _descricao;
  AutovalidateMode _autovalidateModeEtapa = AutovalidateMode.disabled;

  EtapaCubit() : super(EtapaState());

  AutovalidateMode get autovalidateModeEtapa => _autovalidateModeEtapa;
  Duration get tempo => _tempo;
  String get descricao => _descricao;

  updateTimerAtivado(bool timerAtivado) {
    _timerAtivado = timerAtivado;

    if (_timerAtivado == false) {
      _tempo = Duration.zero;
    }
    _emitirEstado();
  }

  updateAutoValidateModeEtapa(AutovalidateMode autovalidateMode) {
    _autovalidateModeEtapa = autovalidateMode;
    _emitirEstado();
  }

  updateTempo(Duration tempo) {
    _tempo = tempo;
    _emitirEstado();
  }

  setEtapaToEdit(EtapaPreparo etapaPreparo) {
    _tempo = etapaPreparo.tempo;
    _descricao = etapaPreparo.descricao;
    _emitirEstado();
  }

  _emitirEstado() {
    emit(EtapaState());
  }

  clean() {
    _timerAtivado = false;
    _tempo = Duration.zero;
    _descricao = '';
    _emitirEstado();
  }
}
