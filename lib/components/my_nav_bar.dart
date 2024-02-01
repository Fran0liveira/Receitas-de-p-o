import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:receitas_de_pao/animation/scroll_animation.dart';
import 'package:receitas_de_pao/factory/animaton_factory.dart';
import 'package:receitas_de_pao/models/menu_tela_option.dart';
import 'package:receitas_de_pao/repository/asset_repository.dart';
import 'package:receitas_de_pao/utils/screen.dart';

import '../routes/app_routes.dart';
import '../keys/nav_keys.dart';
import '../state/ads_state/ads_cubit.dart';
import '../state/auth_state/auth_cubit.dart';
import '../state/nav_bar_state/nav_bar_cubit.dart';
import '../state/nav_bar_state/nav_bar_state.dart';
import '../utils/assets.dart';
import 'dialog_login.dart';

class MyNavBar extends StatefulWidget {
  @override
  State<MyNavBar> createState() => MyNavigationBarState();
}

class MyNavigationBarState extends State<MyNavBar> {
  AuthCubit _authCubit;
  NavBarCubit _navBarCubit;
  AdsCubit _adsCubit;
  Screen _screen;

  @override
  void initState() {
    super.initState();

    _screen = Screen(context);
    _authCubit = context.read<AuthCubit>();
    _navBarCubit = context.read<NavBarCubit>();
    _adsCubit = context.read<AdsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return _newBlocBuilder();
    // return BlocBuilder<NavBarCubit, NavBarState>(builder: (context, state) {
    //   return BottomNavigationBar(
    //     backgroundColor: Colors.pink[900],
    //     selectedLabelStyle: TextStyle(color: _selectedColor()),
    //     unselectedLabelStyle: TextStyle(color: _unselectedColor()),
    //     selectedIconTheme: IconThemeData(color: _selectedColor()),
    //     unselectedIconTheme: IconThemeData(color: _unselectedColor()),
    //     fixedColor: _selectedColor(),
    //     unselectedItemColor: _unselectedColor(),
    //     currentIndex: _navBarCubit.currentIndex,
    //     type: BottomNavigationBarType.fixed,
    //     items: [
    //       BottomNavigationBarItem(
    //           tooltip: 'Buscar por novas receitas!',
    //           icon: Container(
    //             height: IconTheme.of(context).size,
    //             child: Container(),
    //           ),
    //           label: 'Descobrir Receitas'),
    //       BottomNavigationBarItem(
    //         tooltip: 'As receitas que você gostou!',
    //         icon: Icon(Icons.favorite),
    //         label: 'Favoritas',
    //       ),
    //       BottomNavigationBarItem(
    //         tooltip: 'As receitas que você já criou!',
    //         icon: Icon(Icons.file_copy),
    //         label: 'Minhas receitas',
    //       ),
    //       BottomNavigationBarItem(
    //         tooltip: 'Lista de Compras',
    //         icon: Icon(Icons.check_box),
    //         label: 'Salve os itens que deseja!',
    //       ),
    //     ],
    //     onTap: (index) {
    //       if (index == NavBarCubit.INDEX_FEED) {
    //         _navigateToReceitasFeed();
    //       } else if (index == NavBarCubit.INDEX_MINHAS_RECEITAS) {
    //         _navigateToMinhasReceitasPage();
    //       } else if (index == NavBarCubit.INDEX_FAVORITOS) {
    //         _navigateToReceitasFavoritasPage();
    //       }
    //     },
    //   );
    // });
  }

  _newBlocBuilder() {
    return BlocBuilder<NavBarCubit, NavBarState>(builder: (context, state) {
      return Container(
          color: Colors.pink[800],
          height: 60,
          width: _screen.width,
          child: _tabBar());
    });
  }

  _tabBar() {
    List<MenuTelaOption> options = _createMenuTelaOptions();

    List<Widget> widgets = options
        .map(
          (e) => _navbarOptionViewModel(e),
        )
        .toList();

    log('widgets test: $widgets');

    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      ...widgets
          .map((e) => Flexible(
                child: e,
              ))
          .toList()
    ]);
  }

  _navigateToReceitasFavoritasPage() {
    _navBarCubit.updateIndex(NavBarCubit.INDEX_FAVORITOS);
  }

  _navigateToReceitasFeed() {
    _navBarCubit.updateIndex(NavBarCubit.INDEX_FEED);
  }

  _navigateToMinhasReceitasPage() {
    User user = _authCubit.getUser();
    if (user == null || user.isAnonymous) {
      _showDialogLogin();
      return;
    }
    _navBarCubit.updateIndex(NavBarCubit.INDEX_MINHAS_RECEITAS);
  }

  _showDialogLogin() {
    DialogLogin().show(context);
  }

  _unselectedColor() {
    return Colors.white;
  }

  _selectedColor() {
    return Colors.red[300];
  }

  Widget _navbarOptionViewModel(MenuTelaOption option) {
    int index = option.index;
    bool selected = _navBarCubit.isSelected(index);
    return GestureDetector(
      onTap: () {
        if (index == NavBarCubit.INDEX_FEED) {
          _navigateToReceitasFeed();
        } else if (index == NavBarCubit.INDEX_MINHAS_RECEITAS) {
          _navigateToMinhasReceitasPage();
        } else if (index == NavBarCubit.INDEX_FAVORITOS) {
          _navigateToReceitasFavoritasPage();
        } else if (index == NavBarCubit.INDEX_LOJA) {
          _navigateToLojaPage();
        }
      },
      child: Container(
        padding: EdgeInsets.all(2.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: _icon(option, index)),
            Text(
              option.descricao,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: selected ? _selectedColor() : _unselectedColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _navigateToLojaPage() {
    _navBarCubit.updateIndex(NavBarCubit.INDEX_LOJA);
  }

  _icon(MenuTelaOption option, int index) {
    bool selected = _navBarCubit.isSelected(index);
    if (option.icon is IconData) {
      return Icon(
        option.icon,
        color: selected ? _selectedColor() : _unselectedColor(),
      );
    } else if (index == NavBarCubit.INDEX_FEED) {
      return _feedIcon(selected);
    }
  }

  _feedIcon(bool selected) {
    return Container(
      height: IconTheme.of(context).size,
      child: Image.asset(
        MyAssets.BUSCAR_RECEITAS,
        color: selected ? _selectedColor() : _unselectedColor(),
      ),
    );
  }

  _createMenuTelaOptions() {
    return [
      MenuTelaOption(
        descricao: 'Receitas',
        icon: Image.asset(
          MyAssets.BUSCAR_RECEITAS,
        ),
        index: NavBarCubit.INDEX_FEED,
      ),
      MenuTelaOption(
        descricao: 'Favoritas',
        icon: Icons.favorite,
        index: NavBarCubit.INDEX_FAVORITOS,
      ),
      // MenuTelaOption(
      //   descricao: 'Lista Compras',
      //   icon: Icons.checklist_rounded,
      //   index: NavBarCubit.INDEX_LISTA_COMPRAS,
      // ),
      MenuTelaOption(
        descricao: 'Minhas Receitas',
        icon: Icons.copy,
        index: NavBarCubit.INDEX_MINHAS_RECEITAS,
      ),
      MenuTelaOption(
        descricao: 'Promoções',
        icon: Icons.local_offer_outlined,
        index: NavBarCubit.INDEX_LOJA,
      ),
      // MenuTelaOption(
      //   descricao: 'Dicas culinárias',
      //   icon: Icons.lightbulb_outline_rounded,
      // ),
    ];
  }
}
