import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart' as sb;

class MyAppBar {
  sb.SearchBar searchBar;
  void Function() onNovaReceitaPressed;
  void Function(String data) onTextChanged;
  void Function(void Function()) setState;
  BuildContext context;
  void Function() onClosed;
  bool showSearchBar;
  MyAppBar(
      {this.onNovaReceitaPressed,
      this.onTextChanged,
      this.setState,
      this.context,
      this.onClosed,
      this.showSearchBar = false}) {
    this.searchBar = _buildSearchBar();
  }

  AppBar buildAppBar() {
    return searchBar.build(context);
  }

  Widget _buildDefaultAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.pink[600],
      actions: [
        Container(
          padding: EdgeInsets.all(8),
          child: Row(children: [
            //_btnFavoritas(),
            SizedBox(width: 15),

            _btnPesquisa(context),
          ]),
        ),
      ],
      title: Row(children: [
        _btnNovaReceita(),
      ]),
    );
  }

  _btnPesquisa(BuildContext context) {
    if (!showSearchBar) {
      return Container();
    }
    IconButton iconButton = searchBar.getSearchAction(context);
    return GestureDetector(
      onTap: iconButton.onPressed,
      child: Icon(
        Icons.search,
        color: Colors.white,
      ),
    );
  }

  _buildSearchBar() {
    return sb.SearchBar(
        inBar: false,
        buildDefaultAppBar: _buildDefaultAppBar,
        setState: setState,
        onChanged: onTextChanged,
        hintText: 'Buscar receita',
        onCleared: () {
          log('cleared');
        },
        onClosed: onClosed);
  }

  _btnNovaReceita() {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.pink[900])),
        onPressed: onNovaReceitaPressed,
        child: Row(
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            Text('Nova receita')
          ],
        ));
  }
}
