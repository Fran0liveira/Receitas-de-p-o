import 'package:firebase_core/firebase_core.dart';

import '../enums/firebase_codes.dart';

class FirebaseMessageAdapter {
  String adaptar(FirebaseException e) {
    if (FirebaseCodes.userAlreadyInUse == e.code) {
      return 'Usuário já está sendo utilizado!';
    } else if (FirebaseCodes.wrongPassword == e.code ||
        FirebaseCodes.userNotFound == e.code) {
      return 'Usuário ou senha inválidos!';
    } else {
      return e.message;
    }
  }
}
