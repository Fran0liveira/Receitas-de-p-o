import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receitas_de_pao/repository/firebase_repository.dart';
import 'package:receitas_de_pao/services/user_storage_service.dart';
import 'package:receitas_de_pao/state/auth_state/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _instance;
  AuthCubit(this._instance) : super(AuthState(null));

  Stream<User> get authStateChanges => _instance.authStateChanges();

  Future<UserCredential> loginWithEmailAndPassword(
      {String email, String password}) async {
    var credentials = await FirebaseRepository.loginWithEmailAndPassword(
        email: email, password: password);

    _storeCredentials(
        email: email, password: password, uid: credentials.user.uid);
    _emitirEstado();
    return credentials;
  }

  Future<UserCredential> loginAsGuest() async {
    var credentials = await FirebaseRepository.loginAsGuest();
    _storeCredentials(email: '', password: '', uid: credentials.user.uid);
    _emitirEstado();
    return credentials;
  }

  User getUser() {
    return _instance.currentUser;
  }

  Future<void> logout() async {
    await _instance.signOut();
    _clearCredentials();
    //_emitirEstado();
  }

  _storeCredentials({String email, String password, String uid}) {
    UserStorageService.setCredentials(
        email: email, password: password, uid: uid);
  }

  sendResetPasswordCode() {
    User user = getUser();
    if (user == null || user.isAnonymous) {
      throw Exception('Usuário não está logado');
    }
    _instance.sendPasswordResetEmail(email: user.email);
  }

  _clearCredentials() {
    UserStorageService.clearCredentials();
  }

  _emitirEstado() {
    emit(AuthState(getUser()));
  }
}
