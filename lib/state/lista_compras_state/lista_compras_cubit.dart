import 'package:bloc/bloc.dart';

import '../../db/app_db.dart';
import '../../models/my_app/item_compra.dart';
import '../../models/my_app/lista_compras.dart';
import 'lista_compras_state.dart';

class ListaComprasCubit extends Cubit<ListaComprasState> {
  List<ListaCompras> allListasCompras = [];
  ListaComprasCubit() : super(InitialListaComprasState());

  init(String userId) async {
    emit(LoadingListaComprasState());
    await _fetch(userId);
    emit(ListaComprasState());
  }

  insertListaCompras(
      ListaCompras listaCompras, bool expand, String userId) async {
    await AppDb.instance.insertListaCompras(listaCompras);
    emit(LoadingListaComprasState());
    await _fetch(userId);
    if (expand) {
      allListasCompras.first.expanded = true;
    }
    emit(ListaComprasState());
  }

  insertListaComprasWithItens(
      ListaCompras listaCompras, bool expand, String userId) async {
    int idListaCompras = await AppDb.instance.insertListaCompras(listaCompras);

    List<ItemCompra> itensCompra = listaCompras.itens;
    for (ItemCompra itemCompra in itensCompra) {
      itemCompra.idListaCompras = idListaCompras;
    }
    await AppDb.instance.insertItensCompra(idListaCompras, itensCompra);
    emit(LoadingListaComprasState());
    await _fetch(userId);
    if (expand) {
      allListasCompras.first.expanded = true;
    }
    emit(ListaComprasState());
  }

  _fetch(String userId) async {
    allListasCompras = await _selectAllListaCompras(userId);
  }

  Future<List<ListaCompras>> _selectAllListaCompras(String userId) {
    return AppDb.instance.selectAllListaCompras(userId);
  }

  deleteItemCompraById(ItemCompra itemCompra) async {
    await AppDb.instance.deleteItemCompraById(itemCompra.id);
    for (ListaCompras listaCompras in allListasCompras) {
      listaCompras.itens.removeWhere((element) => element.id == itemCompra.id);
    }
    emit(ListaComprasState());
  }

  switchSelecionado(ItemCompra itemCompra) {
    itemCompra.selecionado = !itemCompra.selecionado;
    emit(ListaComprasState());
  }

  deleteListaComprasById(ListaCompras listaCompras) async {
    await AppDb.instance.deleteAllItensComprasByIdListaCompras(listaCompras.id);
    await AppDb.instance.deleteListaComprasById(listaCompras.id);

    allListasCompras.removeWhere(
      (element) => element.id == listaCompras.id,
    );
    emit(ListaComprasState());
  }

  insertItemCompra(ListaCompras listaCompras, ItemCompra itemCompra) async {
    await AppDb.instance.insertItemCompra(listaCompras.id, itemCompra);
    ListaCompras listaBuscada = allListasCompras
        .where((element) => element.id == listaCompras.id)
        .first;

    listaBuscada.itens.add(itemCompra);
    emit(ListaComprasState());
  }

  updateDescricaoItemCompraById(String descricao, ItemCompra itemCompra) async {
    itemCompra.descricao = descricao;
    await AppDb.instance.updateItemCompraById(itemCompra);
    emit(ListaComprasState());
  }

  updateDescricaoListaComprasById(
      String descricao, ListaCompras listaCompras) async {
    listaCompras.descricao = descricao;
    await AppDb.instance.updateListaComprasById(listaCompras);
    emit(ListaComprasState());
  }

  switchItemCompraSelecionado(ItemCompra itemCompra) async {
    itemCompra.selecionado = !itemCompra.selecionado;
    await AppDb.instance.updateItemCompraById(itemCompra);
    emit(ListaComprasState());
  }
}
