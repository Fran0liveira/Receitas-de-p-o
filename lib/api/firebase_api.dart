import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/models/my_app/user_chef.dart';
import 'package:receitas_de_pao/utils/characters_check.dart';

import '../enums/app_categorias.dart';
import '../enums/storage_paths.dart';
import '../models/my_app/avaliacao.dart';
import '../models/my_app/avaliacoes.dart';
import 'dart:io';
import '../models/my_app/filter_receitas.dart';
import '../models/my_app/interacao_receita_usuario.dart';
import '../repository/firebase_repository.dart';
import '../utils/list_utils.dart';
import '../utils/string_utils.dart';

class FirebaseApi {
  static Future<Receita> getReceitaById({String idReceita}) async {
    var collection = await FirebaseFirestore.instance
        .collection('receitas')
        .where('id', isEqualTo: idReceita)
        .get();

    return collection.docs
        .map((doc) {
          return Receita.fromJson(doc.data());
        })
        .toList()
        .first;
  }

  static Future<List<Receita>> getReceitasByIds(
      {List<String> idsReceitas}) async {
    if (ListUtils.isNullOrEmpty(idsReceitas)) {
      return [];
    }
    var collection = await FirebaseFirestore.instance
        .collection('receitas')
        .where('id', whereIn: idsReceitas)
        .get();

    return collection.docs.map((doc) {
      return Receita.fromJson(doc.data());
    }).toList();
  }

  static Future<int> getNumberOfFavorites(String idReceita) async {
    var receitaDoc = await FirebaseFirestore.instance
        .collection('receitas')
        .doc(idReceita)
        .get();

    Receita receita = Receita.fromJson(receitaDoc.data());
    return receita.numberOfFavorites;
  }

  static Future<List<Receita>> filterReceitas(
      {FilterReceitas filterReceitas}) async {
    var collection = await FirebaseFirestore.instance
        .collection('receitas')
        .orderBy('dateTime', descending: true)
        .get();

    String search = _formatToSearch(filterReceitas.descricao);

    return collection.docs.map((doc) {
      return Receita.fromJson(doc.data());
    }).where((receita) {
      String nomeReceita = _formatToSearch(receita.nome);
      return nomeReceita.contains(search);
    }).toList();
  }

  static _formatToSearch(String value) {
    return CharacterCheck.removeAcentos(value).toUpperCase();
  }

  static Future<bool> isFavorite({String userId, String idReceita}) async {
    InteracaoReceitaUsuario interacao =
        await FirebaseRepository.fetchInteracaoReceitaUsuario(
            userId: userId, idReceita: idReceita);

    return interacao.favoritesIdReceitas.contains(idReceita);
  }

  static Future<UserChef> getUserChef({String id}) async {
    var collection =
        await FirebaseFirestore.instance.collection('usuarios').doc(id).get();

    return UserChef.fromJson(collection.data());
  }

  static Future<Avaliacoes> getAvaliacoes({String idReceita}) async {
    var collectionAvaliacoes = await FirebaseFirestore.instance
        .collection('avaliacoes')
        .doc(idReceita)
        .get();

    var avaliacoesData = collectionAvaliacoes.data();

    if (avaliacoesData == null) {
      return Avaliacoes.empty();
    }

    Avaliacoes avaliacoes = Avaliacoes.fromJson(avaliacoesData);
    return avaliacoes;
  }

  static Future<List<Receita>> getReceitas() async {
    var collection = await FirebaseFirestore.instance
        .collection('receitas')
        .orderBy('dateTime', descending: true)
        .get();

    return collection.docs.map((doc) {
      return Receita.fromJson(doc.data());
    }).toList();
  }

  static Future<List<Receita>> getReceitasByCategoria(
      String categoria, int startAt, int endAt) async {
    QuerySnapshot<Map<String, dynamic>> collection;
    if (StringUtils.isNullOrEmpty(categoria) ||
        CategoriaReceita.isSameCategory(categoria, CategoriaReceita.TODAS)) {
      collection =
          await FirebaseFirestore.instance.collection('receitas').get();
    } else {
      collection = await FirebaseFirestore.instance
          .collection('receitas')
          .where('categoria', isEqualTo: categoria)
          .get();
    }

    List<Receita> allReceitas = collection.docs.map((doc) {
      return Receita.fromJson(doc.data());
    }).toList();

    if (endAt > allReceitas.length) {
      endAt = allReceitas.length;
    }

    allReceitas = allReceitas.getRange(startAt, endAt).toList();
    return allReceitas;
  }

  static Future<void> addAvaliacao(
      {Avaliacao avaliacao, String idReceita}) async {
    var avaliacoesDoc = await FirebaseFirestore.instance
        .collection('avaliacoes')
        .doc(idReceita)
        .get();

    Avaliacoes avaliacoes;
    var avaliacoesData = avaliacoesDoc.data();
    if (avaliacoesData == null) {
      avaliacoes = Avaliacoes.empty();
    } else {
      avaliacoes = Avaliacoes.fromJson(avaliacoesData);
    }
    List<Avaliacao> avaliacoesUsuarios = avaliacoes.avaliacoesUsuarios;
    avaliacoesUsuarios.add(avaliacao);

    await FirebaseFirestore.instance
        .collection('avaliacoes')
        .doc(idReceita)
        .set(avaliacoes.toJson());
  }

  static Future<void> deleteReceita(Receita receita) async {
    return FirebaseFirestore.instance
        .collection('receitas')
        .doc(receita.id)
        .delete();
  }

  static Future<UserCredential> loginWithEmailAndPassword({
    String email,
    String password,
  }) async {
    var auth = FirebaseAuth.instance;
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> loginAsGuest() async {
    var auth = FirebaseAuth.instance;
    return await auth.signInAnonymously();
  }

  static Future<List<Receita>> getReceitasUsuario(String userId) async {
    var collection = await FirebaseFirestore.instance
        .collection('receitas')
        .where('userId', isEqualTo: userId)
        .get();

    var list =
        collection.docs.map((doc) => Receita.fromJson(doc.data())).toList();
    list.sort((a, b) => a.nome.compareTo(b.nome));
    return list;
  }

  static Future<void> uploadReceita(Receita receita) async {
    var db = FirebaseFirestore.instance;
    return db.collection('receitas').doc(receita.id).set(receita.toJson());
  }

  static Future<String> uploadImageReceita(ImageUploaded image) async {
    return uploadImage(StoragePaths.IMAGES_RECEITAS, image.file);
  }

  static Future<String> uploadImageUsuario(ImageUploaded image) async {
    return uploadImage(StoragePaths.USUARIOS, image.file);
  }

  static Future<String> uploadImage(String base, File file) async {
    var storage = FirebaseStorage.instance;

    var ref = storage.ref().child('$base${file.path}');
    TaskSnapshot task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  static Future<UserCredential> registerUserWithEmailAndPassword(
      {String email, String password}) {
    var auth = FirebaseAuth.instance;
    return auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<void> saveUserOnDataBase(UserChef userChef) async {
    var db = FirebaseFirestore.instance;
    return db.collection('usuarios').doc(userChef.id).set(userChef.toJson());
  }

  static updateReceitasToFavoritos(
      {String userId, List<String> idsReceitasToAdd}) async {
    var db = FirebaseFirestore.instance;
    var userFavorites = db.collection('interacaoReceitaUsuario').doc(userId);

    var docJson = await userFavorites.get();
    InteracaoReceitaUsuario receitasFavoritasUsuario =
        InteracaoReceitaUsuario.fromJson(docJson.data());

    List<String> idsFavoritas = receitasFavoritasUsuario.favoritesIdReceitas;

    idsReceitasToAdd.forEach((idReceita) {
      if (!idsFavoritas.contains(idReceita)) {
        idsFavoritas.add(idReceita);
      }
    });

    List<String> idsReceitas = receitasFavoritasUsuario.favoritesIdReceitas;
    log('idsReceitas to favorites: ${idsReceitas}');
    if (ListUtils.isNullOrEmpty(idsReceitas)) {
      userFavorites.delete();
    } else {
      userFavorites.set(receitasFavoritasUsuario.toJson());
    }

    idsReceitasToAdd.forEach((idReceita) async {
      log('looping idsReceitasToAdd before');
      Receita receita = await getReceitaById(idReceita: idReceita);
      log('looping idsReceitasToAdd after');

      int numberOfFavorites = receita.numberOfFavorites;
      numberOfFavorites++;

      receita.numberOfFavorites = numberOfFavorites;
      await uploadReceita(receita);
    });
  }

  static Future<bool> updateReceitaToFavoritos(
      {String userId, String idReceita}) async {
    var db = FirebaseFirestore.instance;
    var userFavorites = db.collection('interacaoReceitaUsuario').doc(userId);

    var docJson = await userFavorites.get();
    InteracaoReceitaUsuario receitasFavoritasUsuario =
        InteracaoReceitaUsuario.fromJson(docJson.data());

    List<String> idsFavoritas = receitasFavoritasUsuario.favoritesIdReceitas;

    bool isFavorite;
    if (idsFavoritas.contains(idReceita)) {
      log('removing idreceita');
      idsFavoritas.remove(idReceita);
      isFavorite = false;
    } else {
      log('adding idreceita');
      idsFavoritas.add(idReceita);
      isFavorite = true;
    }

    List<String> idsReceitas = receitasFavoritasUsuario.favoritesIdReceitas;
    if (ListUtils.isNullOrEmpty(idsReceitas)) {
      userFavorites.delete();
    } else {
      userFavorites.set(receitasFavoritasUsuario.toJson());
    }

    Receita receita = await getReceitaById(idReceita: idReceita);

    int numberOfFavorites = receita.numberOfFavorites;
    if (isFavorite) {
      numberOfFavorites++;
    } else {
      numberOfFavorites--;
    }

    receita.numberOfFavorites = numberOfFavorites;
    await uploadReceita(receita);

    return isFavorite;
  }

  static Future<bool> countPlusOrMinusFavoritesReceita(
      {bool isFavorite, String idReceita}) async {
    Receita receita = await getReceitaById(idReceita: idReceita);

    int numberOfFavorites = receita.numberOfFavorites;
    if (isFavorite) {
      numberOfFavorites++;
    } else {
      numberOfFavorites--;
    }

    receita.numberOfFavorites = numberOfFavorites;
    await uploadReceita(receita);

    return isFavorite;
  }

  static Future<List<Receita>> fetchReceitasFavoritas({String userId}) async {
    InteracaoReceitaUsuario interacao =
        await fetchInteracaoReceitaUsuario(userId: userId);

    var db = FirebaseFirestore.instance;

    List<String> idsFavoritas = interacao.favoritesIdReceitas;

    if (ListUtils.isNullOrEmpty(idsFavoritas)) {
      return [];
    }

    var jsonReceitas = await db
        .collection('receitas')
        .where('id', whereIn: idsFavoritas)
        .get();

    List<Receita> receitasFavoritas =
        jsonReceitas.docs.map((doc) => Receita.fromJson(doc.data())).toList();

    return receitasFavoritas;
  }

  static Future<InteracaoReceitaUsuario> fetchInteracaoReceitaUsuario(
      {String userId}) async {
    var db = FirebaseFirestore.instance;
    var doc = db.collection('interacaoReceitaUsuario').doc(userId);

    var interacaoJson = await doc.get();

    return InteracaoReceitaUsuario.fromJson(interacaoJson.data());
  }
}
