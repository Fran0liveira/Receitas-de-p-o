import 'package:firebase_auth/firebase_auth.dart';
import 'package:receitas_de_pao/api/firebase_api.dart';
import 'package:receitas_de_pao/models/my_app/avaliacao.dart';
import 'package:receitas_de_pao/models/my_app/filter_receitas.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/models/my_app/user_chef.dart';
import '../models/my_app/avaliacoes.dart';
import '../models/my_app/interacao_receita_usuario.dart';

class FirebaseRepository {
  static Future<Receita> getReceitaById({String idReceita}) async {
    return FirebaseApi.getReceitaById(idReceita: idReceita);
  }

  static Future<List<Receita>> getReceitasByIds(
      {List<String> idsReceitas}) async {
    return FirebaseApi.getReceitasByIds(idsReceitas: idsReceitas);
  }

  static Future<UserChef> getUserChef({String id}) async {
    return FirebaseApi.getUserChef(id: id);
  }

  static Future<Avaliacoes> getAvaliacoes({
    String idReceita,
  }) {
    return FirebaseApi.getAvaliacoes(idReceita: idReceita);
  }

  static Future<void> uploadReceitas(List<Receita> receitas) {
    for (Receita receita in receitas) {
      uploadReceita(receita);
    }
  }

  static Future<void> uploadReceita(Receita receita) {
    return FirebaseApi.uploadReceita(receita);
  }

  static Future<void> deleteReceita(Receita receita) {
    return FirebaseApi.deleteReceita(receita);
  }

  static Future<int> getNumberOfFavorites(String idReceita) {
    return FirebaseApi.getNumberOfFavorites(idReceita);
  }

  static Future<UserCredential> loginWithEmailAndPassword(
      {String email, String password}) async {
    return await FirebaseApi.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> loginAsGuest() async {
    return await FirebaseApi.loginAsGuest();
  }

  static Future<List<Receita>> getReceitasUsuario(String userId) async {
    return FirebaseApi.getReceitasUsuario(userId);
  }

  static Future<List<Receita>> getReceitas() async {
    return FirebaseApi.getReceitas();
  }

  static Future<List<Receita>> getReceitasByCategoria(
      String categoria, int startAt, int endAt) async {
    return FirebaseApi.getReceitasByCategoria(categoria, startAt, endAt);
  }

  static Future<List<Receita>> filterReceitas({FilterReceitas filterReceitas}) {
    return FirebaseApi.filterReceitas(filterReceitas: filterReceitas);
  }

  static Future<String> uploadImageReceita(ImageUploaded image) {
    return FirebaseApi.uploadImageReceita(image);
  }

  static Future<String> uploadImageUsuario(ImageUploaded image) {
    return FirebaseApi.uploadImageUsuario(image);
  }

  static Future<UserCredential> registerUser(UserChef userChef) async {
    String email = userChef.email;
    String password = userChef.senha;
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    final userCredential =
        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);

    userChef.id = userCredential.user.uid;
    await FirebaseApi.saveUserOnDataBase(userChef);

    return userCredential;
  }

  static Future<void> updateUserOnDataBase(UserChef userChef) async {
    await FirebaseApi.saveUserOnDataBase(userChef);
  }

  static Future<void> addAvaliacao({Avaliacao avaliacao, String idReceita}) {
    return FirebaseApi.addAvaliacao(avaliacao: avaliacao, idReceita: idReceita);
  }

  static updateReceitasToFavoritos({String userId, List<String> idsReceitas}) {
    return FirebaseApi.updateReceitasToFavoritos(
        userId: userId, idsReceitasToAdd: idsReceitas);
  }

  static Future<bool> updateReceitaToFavoritos(
      {String userId, String idReceita}) {
    return FirebaseApi.updateReceitaToFavoritos(
        userId: userId, idReceita: idReceita);
  }

  static Future<bool> countPlusOrMinusFavoriteReceita(
      {bool isFavorite, String idReceita}) {
    return FirebaseApi.countPlusOrMinusFavoritesReceita(
        isFavorite: isFavorite, idReceita: idReceita);
  }

  static Future<List<Receita>> fetchReceitasFavoritas({String userId}) async {
    return FirebaseApi.fetchReceitasFavoritas(userId: userId);
  }

  static Future<InteracaoReceitaUsuario> fetchInteracaoReceitaUsuario(
      {String userId, String idReceita}) {
    return FirebaseApi.fetchInteracaoReceitaUsuario(userId: userId);
  }

  static Future<bool> isFavorite({String userId, String idReceita}) {
    return FirebaseApi.isFavorite(userId: userId, idReceita: idReceita);
  }
}
