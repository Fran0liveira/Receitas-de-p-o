import 'dart:async';
import 'dart:developer';

import 'package:receitas_de_pao/db/tb_itens_compra.dart';
import 'package:receitas_de_pao/db/tb_lista_compras.dart';
import 'package:sqflite/sqflite.dart';

import '../models/my_app/item_compra.dart';
import '../models/my_app/lista_compras.dart';
import '../utils/list_utils.dart';

class AppDb {
  static final AppDb instance = AppDb._init();

  static Database _database;

  AppDb._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDb('app_db');
    return _database;
  }

  Future<Database> _initDb(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$filePath';
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<dynamic> _onUpgrade(Database db, int version, int data) async {
    await db.execute('''ALTER TABLE ${TbListaCompras.TB_LISTA_COMPRAS} 
    ADD ${TbListaCompras.ID_RECEITA} TEXT ''');

    await db.execute('''ALTER TABLE ${TbListaCompras.TB_LISTA_COMPRAS} 
    ADD ${TbListaCompras.ID_USUARIO} TEXT ''');
  }

  Future _createDb(Database db, int version) async {
    await _createTbListaCompras(db);
    await _createTbItensCompra(db);
  }

  _createTbItensCompra(Database db) async {
    await db.execute('''
      CREATE TABLE ${TbItensCompra.TB_ITENS_COMPRA} 
      (
        ${TbItensCompra.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TbItensCompra.DESCRICAO} TEXT NOT NULL,
        ${TbItensCompra.ID_LISTA_COMPRAS} INTEGER NOT NULL,
        ${TbItensCompra.SELECIONADO} INTEGER NOT NULL
      )
      ''');
  }

  resetDatabase() async {
    final db = await instance.database;
    await db.delete(TbItensCompra.TB_ITENS_COMPRA);
    await db.delete(TbListaCompras.TB_LISTA_COMPRAS);
  }

  deleteListaComprasById(int idListaCompras) async {
    final db = await instance.database;
    await db.delete(
      TbListaCompras.TB_LISTA_COMPRAS,
      where: '${TbListaCompras.ID} = ?',
      whereArgs: [idListaCompras],
    );
  }

  deleteAllItensComprasByIdListaCompras(int idListaCompras) async {
    final db = await instance.database;
    await db.delete(
      TbItensCompra.TB_ITENS_COMPRA,
      where: '${TbItensCompra.ID_LISTA_COMPRAS} = ?',
      whereArgs: [idListaCompras],
    );
  }

  deleteItemCompraById(int idItemCompra) async {
    final db = await instance.database;
    await db.delete(
      TbItensCompra.TB_ITENS_COMPRA,
      where: '${TbItensCompra.ID} = ?',
      whereArgs: [idItemCompra],
    );
  }

  _createTbListaCompras(Database db) async {
    await db.execute('''
      CREATE TABLE ${TbListaCompras.TB_LISTA_COMPRAS} 
      (
        ${TbListaCompras.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TbListaCompras.DESCRICAO} TEXT NOT NULL,
        ${TbListaCompras.UPDATED_DATE} TEXT NOT NULL,
        ${TbListaCompras.ID_RECEITA} TEXT,
        ${TbListaCompras.ID_USUARIO} TEXT
      )
      ''');
  }

  Future<int> insertListaCompras(ListaCompras listaCompras) async {
    final db = await instance.database;
    final id =
        await db.insert(TbListaCompras.TB_LISTA_COMPRAS, listaCompras.toJson());

    listaCompras.id = id;
    return id;
  }

  updateItemCompraById(ItemCompra itemCompra) async {
    final db = await instance.database;
    await db.update(
      TbItensCompra.TB_ITENS_COMPRA,
      itemCompra.toJson(),
      where: '${TbItensCompra.ID} = ?',
      whereArgs: [itemCompra.id],
    );
  }

  updateListaComprasById(ListaCompras listaCompras) async {
    final db = await instance.database;
    await db.update(
      TbListaCompras.TB_LISTA_COMPRAS,
      listaCompras.toJson(),
      where: '${TbListaCompras.ID} = ?',
      whereArgs: [listaCompras.id],
    );
  }

  Future<ItemCompra> insertItemCompra(
      int idListaCompras, ItemCompra itemCompra) async {
    final db = await instance.database;
    final id =
        await db.insert(TbItensCompra.TB_ITENS_COMPRA, itemCompra.toJson());

    itemCompra.id = id;
    return itemCompra;
  }

  Future<List<ItemCompra>> insertItensCompra(
      int idListaCompras, List<ItemCompra> itensCompra) async {
    final db = await instance.database;

    for (ItemCompra itemCompra in itensCompra) {
      final id =
          await db.insert(TbItensCompra.TB_ITENS_COMPRA, itemCompra.toJson());
      itemCompra.id = id;
    }
    return itensCompra;
  }

  Future<List<ListaCompras>> selectAllListaCompras(String userId) async {
    log('id do usuario compras: $userId');
    final db = await instance.database;
    final result = await db.query(TbListaCompras.TB_LISTA_COMPRAS,
        orderBy: '${TbListaCompras.UPDATED_DATE} DESC',
        where: '${TbListaCompras.ID_USUARIO} = ?',
        whereArgs: [userId]);

    if (result.isEmpty) {
      log('banco listas compras is empty');
      return [];
    }

    List<ListaCompras> allListasCompras =
        result.map((e) => ListaCompras.fromJson(e)).toList();

    for (ListaCompras listaCompras in allListasCompras) {
      List<ItemCompra> itensCompra =
          await _selectItensCompraFromListaId(listaCompras.id);
      listaCompras.itens = itensCompra;

      if (!ListUtils.isNullOrEmpty(listaCompras.itens)) {
        log('listas compras fetched: $allListasCompras itens size: ${itensCompra.first.toJson()}}');
      }
    }

    return allListasCompras;
  }

  Future<List<ItemCompra>> _selectItensCompraFromListaId(
      int idListaCompras) async {
    try {
      log('fetching banco itens compra!');
      final db = await instance.database;
      final result = await db.query(
        TbItensCompra.TB_ITENS_COMPRA,
        where: '${TbItensCompra.ID_LISTA_COMPRAS} = ?',
        whereArgs: [idListaCompras],
      );

      if (result.isEmpty) {
        return [];
      }

      log('banco itens compra: $result');
      List<ItemCompra> itensCompra =
          result.map((e) => ItemCompra.fromJson(e)).toList();

      return itensCompra;
    } on Exception catch (e) {
      log('erro banco itens compras $e');
      return [];
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
