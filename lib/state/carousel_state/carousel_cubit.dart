import 'package:flutter_bloc/flutter_bloc.dart';

import 'carousel_state.dart';

class CarouselCubit extends Cubit<CarouselState> {
  int _index = 0;

  int get index => _index;
  CarouselCubit() : super(CarouselState());

  updateIndex(int index) {
    _index = index;
    _emitirEstado();
  }

  _emitirEstado() {
    emit(CarouselState());
  }
}
