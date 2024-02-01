import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'nav_bar_state.dart';

class NavBarCubit extends Cubit<NavBarState> {
  static const int INDEX_FEED = 0;
  static const int INDEX_FAVORITOS = 1;
  static const int INDEX_MINHAS_RECEITAS = 2;
  //static const int SOBRE_O_APP = 3;
  static const int INDEX_LOJA = 3;

  int currentIndex = INDEX_FEED;

  NavBarCubit() : super(NavBarState());

  reset() {
    currentIndex = INDEX_FEED;
    _emitirEstado();
  }

  updateIndex(int index) {
    currentIndex = index;
    _emitirEstado();
  }

  isSelected(int index) {
    return currentIndex == index;
  }

  _emitirEstado() {
    emit(NavBarState());
  }
}
