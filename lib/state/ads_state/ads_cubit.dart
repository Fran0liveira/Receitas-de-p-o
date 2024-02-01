import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:receitas_de_pao/repository/preferences_repository.dart';

import '../../ads/ad_state.dart';
import 'ads_state.dart';

class AdsCubit extends Cubit<AdsState> {
  AdsCubit() : super(AdsState());

  bool adShowed = false;

  showAd() {
    log('showing ad: $adShowed');

    if (adShowed) {
      return;
    }

    emit(ShowAdState());
    adShowed = true;

    Future.delayed(const Duration(seconds: 50), () {
      emit(LoadAdState());
    });

    Future.delayed(const Duration(minutes: 1), () {
      adShowed = false;
      log('setting show ad again');
    });
  }
}
