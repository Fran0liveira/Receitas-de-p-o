import 'package:bloc/bloc.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';

import '../../models/my_app/user_chef.dart';
import 'register_user_state.dart';

class RegisterUserCubit extends Cubit<RegisterUserState> {
  RegisterUserCubit() : super(RegisterUserState());
  UserChef _userChef = UserChef.empty();
  UserChef get userChef => _userChef;

  bool get isInvalidUser => userChef == null || userChef == UserChef.empty();

  setUserChef(UserChef userChef) {
    if (userChef == null) {
      _userChef = UserChef.empty();
      return;
    }
    _userChef = userChef;
    _emitirEstado();
  }

  updatePicture(ImageUploaded imagePerfil) {
    _userChef.imagePerfil = imagePerfil;
    _emitirEstado();
  }

  _emitirEstado() {
    emit(RegisterUserState());
  }
}
