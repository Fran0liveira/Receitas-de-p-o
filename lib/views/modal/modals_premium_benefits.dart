// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
// import 'package:receitas_de_pao/utils/assets.dart';
// import 'package:receitas_de_pao/views/modal/modal_premium_plans.dart';

// class ModalPremiumBenefits {
//   PremiumCubit _premiumCubit;
//   BuildContext context;

//   ModalPremiumBenefits(BuildContext context) {
//     this.context = context;
//     this._premiumCubit = context.read<PremiumCubit>();
//   }

//   show() {
//     showModalBottomSheet(
//         isScrollControlled: true,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             top: Radius.circular(20),
//           ),
//         ),
//         context: context,
//         builder: (widget) {
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _plansHeader(),
//               _modalContent(),
//             ],
//           );
//         });
//   }

//   _modalContent() {
//     if (_premiumCubit.isPremiumMode()) {
//       return Container(
//         color: Colors.pink[900],
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextButton(
//               child: Text(
//                 'Gerir subscrições',
//                 style: TextStyle(
//                   color: Colors.pink[200],
//                 ),
//               ),
//               onPressed: () {
//                 _showModalPremiumPlans();
//               },
//             )
//           ],
//         ),
//       );
//     }
//     return Container(
//       padding: EdgeInsets.only(bottom: 20, right: 10, left: 10),
//       child: Column(
//         children: [
//           _rowModel([
//             Container(
//               padding: EdgeInsets.all(20),
//               child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Container(
//                     child: Image.asset(MyAssets.COOKER),
//                   )),
//             ),
//             _title('Modo comum'),
//             _title('Modo Chef!'),
//           ]),
//           _rowModel([
//             _planoDetail('Sem Anúncios'),
//             _planoDetail('❌'),
//             _planoDetail('✔️'),
//           ]),
//           _rowModel([
//             _planoDetail('Gerar PDF de Receitas'),
//             _planoDetail('❌'),
//             _planoDetail('✔️'),
//           ]),
//           _rowModel([
//             _planoDetail('Acessar Receitas Offline (Em Breve)'),
//             _planoDetail('❌'),
//             _planoDetail('✔️'),
//           ]),
//           _rowModel([
//             _planoDetail('Descontos em Produtos da Loja (Em Breve)'),
//             _planoDetail('❌'),
//             _planoDetail('✔️'),
//           ]),
//           _btnAtivarModoChef()
//         ],
//       ),
//     );
//   }

//   _btnAtivarModoChef() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         ElevatedButton(
//           style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all(Colors.purple[900])),
//           onPressed: () {
//             _showModalPremiumPlans();
//           },
//           child: Container(
//             padding: EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Text(
//                   'Obter o Modo Chef! 👨‍🍳',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   _showModalPremiumPlans() {
//     ModalPremiumPlans(context).show();
//   }

//   _planoDetail(String text) {
//     return Container(
//       padding: EdgeInsets.all(8),
//       child: Text(
//         text,
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           color: Colors.pink[900],
//           fontSize: 16,
//         ),
//       ),
//     );
//   }

//   _rowModel(List<Widget> widgets) {
//     return Row(
//       children: widgets
//           .map((e) => Expanded(
//                 flex: 50,
//                 child: e,
//               ))
//           .toList(),
//     );
//   }

//   _title(String text) {
//     return Container(
//       margin: EdgeInsets.all(2.5),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.all(
//           Radius.circular(10),
//         ),
//       ),
//       padding: EdgeInsets.all(15),
//       child: Text(
//         text,
//         textAlign: TextAlign.center,
//         style: TextStyle(
//             color: Colors.pink[900],
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             decoration: TextDecoration.underline),
//       ),
//     );
//   }

//   _plansHeader() {
//     return Container(
//       color: Colors.transparent,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                   color: Colors.pink[900],
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(20.0),
//                       topRight: Radius.circular(20.0))),
//               child: _headerContent()),
//         ],
//       ),
//     );
//   }

//   _headerContent() {
//     String title;
//     String subtitle;
//     if (_premiumCubit.isPremiumMode()) {
//       title = '👨‍🍳😉\nObrigado por utilizar o Modo Chef!';
//       subtitle = 'Já pode aproveitar seus benefícios!';
//     } else {
//       title = '⭐ Adquira já o Modo Chef!';
//       subtitle = 'Com o Modo Chef você aproveita ainda mais o app!';
//     }
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Flexible(
//               child: Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Flexible(
//               child: Text(
//                 subtitle,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.pink[200],
//                 ),
//               ),
//             ),
//           ],
//         )
//       ],
//     );
//   }
// }
