import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receitas_de_pao/components/btn_premium.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/state/ads_state/ads_cubit.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:receitas_de_pao/views/modal/modal_premium_plans.dart';

class NewAppBar extends StatefulWidget {
  bool showSearchBar;
  void Function(String text) onSearch;
  void Function() onNovaReceitaPressed;
  NewAppBar({
    this.showSearchBar = false,
    this.onSearch,
    this.onNovaReceitaPressed,
  });

  @override
  State<NewAppBar> createState() => _NewAppBarState();
}

class _NewAppBarState extends State<NewAppBar> {
  bool receitaClicked;
  AdsCubit _adsCubit;

  @override
  void initState() {
    super.initState();
    _adsCubit = context.read<AdsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.pink[600],
      actions: [
        Container(
          padding: EdgeInsets.all(8),
          child: Row(children: [
            //_btnFavoritas(),
            SizedBox(width: 15),
            BtnPremium(),
            _btnTimer(),
            SizedBox(width: 15),
            _btnLoja(),
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

  _btnTimer() {
    return GestureDetector(
      child: Icon(Icons.timer_outlined),
      onTap: () {
        _adsCubit.showAd();
        NavKeys.initialPage.currentState.pushNamed(AppRoutes.timerPage);
      },
    );
  }

  _btnLoja() {
    return GestureDetector(
      onTap: () {
        NavKeys.initialPage.currentState.pushNamed(AppRoutes.lojaPage);
      },
      child: Icon(Icons.shopping_basket),
    );
  }

  _btnNovaReceita() {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.pink[900])),
        onPressed: widget.onNovaReceitaPressed,
        child: Row(
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            Text('Adicionar receita')
          ],
        ));
  }

  _btnPesquisa(BuildContext context) {
    if (!widget.showSearchBar) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        widget.onSearch.call('');
      },
      child: Icon(
        Icons.search,
        color: Colors.white,
      ),
    );
  }
}
