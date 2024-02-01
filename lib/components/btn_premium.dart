import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/utils/assets.dart';
import 'package:receitas_de_pao/views/modal/modal_premium_plans.dart';
import 'package:receitas_de_pao/views/modal/modals_premium_benefits.dart';

class BtnPremium extends StatefulWidget {
  @override
  State<BtnPremium> createState() => _BtnPremiumState();
}

class _BtnPremiumState extends State<BtnPremium> {
  @override
  Widget build(BuildContext context) {
    return Container();
    // return IconButton(
    //     icon: Icon(
    //       Icons.workspace_premium,
    //       color: Colors.pink[100],
    //     ),
    //     onPressed: () {
    //       ModalPremiumBenefits(context).show();
    //     });
  }
}
