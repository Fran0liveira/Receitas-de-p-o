import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:receitas_de_pao/models/my_app/credentials.dart';

class UserStorageService {
  static final _storage = FlutterSecureStorage();

  static const _keyEmail = 'email';
  static const _keyPassword = 'password';
  static const _keyUid = 'uid';

  static Future<Credentials> getCredentials() async {
    var email = await _storage.read(key: _keyEmail);
    var password = await _storage.read(key: _keyPassword);
    var uid = await _storage.read(key: _keyUid);

    return Credentials(email: email, password: password, uid: uid);
  }

  static void clearCredentials() {
    _storage.delete(key: _keyEmail);
    _storage.delete(key: _keyPassword);
    _storage.delete(key: _keyUid);
  }

  static void setCredentials({String email, String password, String uid}) {
    _storage.write(key: _keyPassword, value: password);
    _storage.write(key: _keyEmail, value: email);
    _storage.write(key: _keyUid, value: uid);
  }
}
