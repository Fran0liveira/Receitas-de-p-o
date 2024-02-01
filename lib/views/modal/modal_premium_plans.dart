// import 'dart:developer';

// import 'package:decimal/decimal.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:money_formatter/money_formatter.dart';
// import 'package:purchases_flutter/object_wrappers.dart';
// import 'package:receitas_de_pao/api/purchase_api.dart';
// import 'package:receitas_de_pao/components/snack_message.dart';
// import 'package:receitas_de_pao/enums/premium_mode.dart';
// import 'package:receitas_de_pao/enums/subscription_id.dart';
// import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';

// class ModalPremiumPlans {
//   BuildContext context;
//   List<Offering> offerings;
//   PremiumCubit premiumCubit;

//   ModalPremiumPlans(BuildContext context) {
//     this.context = context;
//     this.premiumCubit = context.read<PremiumCubit>();
//   }

//   show() async {
//     offerings = await PurchaseApi.fetchOffers();
//     if (offerings.isEmpty) {
//       SnackMessage(context).show('Nenhuma assinatura disponível!');
//     } else {
//       List<Package> packages = offerings
//           .map((offer) => offer.availablePackages)
//           .expand((pair) => pair)
//           .toList();

//       print('printing packages' + packages.toString());
//       _showModal(packages);
//     }
//   }

//   _showModal(List<Package> packages) {
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
//               ListView.builder(
//                   itemCount: packages.length,
//                   shrinkWrap: true,
//                   itemBuilder: (_, index) {
//                     Package package = packages.elementAt(index);
//                     return _planViewModel(package);
//                   })
//             ],
//           );
//         });
//   }

//   _plansHeader() {
//     return Container(
//       color: Colors.transparent,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//               padding: EdgeInsets.all(20),
//               decoration: new BoxDecoration(
//                   color: Colors.pink[900],
//                   borderRadius: new BorderRadius.only(
//                       topLeft: const Radius.circular(20.0),
//                       topRight: const Radius.circular(20.0))),
//               child: _headerContent()),
//         ],
//       ),
//     );
//   }

//   _headerContent() {
//     String title;
//     String subtitle;
//     if (premiumCubit.isFreeMode()) {
//       title = '⭐ Adquira já o Modo Chef!';
//       subtitle = 'Com o Modo Chef você aproveita ainda mais o app!';
//     } else {
//       title = '👨‍🍳😉\nObrigado por utilizar o Modo Chef!';
//       subtitle = 'Já pode aproveitar seus benefícios!';
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

//   _planViewModel(Package package) {
//     Product product = package.product;
//     return GestureDetector(
//       onTap: () async {
//         if (premiumCubit.isPremiumMode() &&
//             !premiumCubit.isCurrentPlan(package)) {
//           SnackMessage(context).show(
//               'Você já faz parte do Modo Chef! Para adquirir outro plano, desvincule o atual!');
//           return;
//         }
//         bool purchased = await premiumCubit.purchasePackage(package);
//         if (purchased) {
//           _onPremiumPurchased();
//         }
//       },
//       child: Container(
//         margin: EdgeInsets.all(5),
//         padding: EdgeInsets.only(right: 10, left: 10, top: 20, bottom: 20),
//         decoration: BoxDecoration(
//           color: Colors.purple[900],
//           borderRadius: BorderRadius.all(
//             Radius.circular(8),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _porcentagemEconomiaLabel(product),
//                 _pricesLabel(product)
//               ],
//             ),
//             SizedBox(height: 5),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   product.title.replaceFirst('(Receitas de Pães!)', ''),
//                   style: TextStyle(color: Colors.pink[200], fontSize: 18),
//                 ),
//                 _getInferiorSection(package),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   _currentPlanIdentifier(Package package) {
//     if (!premiumCubit.isCurrentPlan(package)) {
//       return Container();
//     }
//     return Row(
//       children: [
//         Text(
//           'Plano atual',
//           style: TextStyle(
//             color: Colors.green,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         Icon(
//           Icons.check,
//           color: Colors.green,
//         )
//       ],
//     );
//   }

//   _onPremiumPurchased() {
//     Navigator.of(context).pop();
//     Navigator.of(context).pop();
//     _showThanksDialog();
//   }

//   _showThanksDialog() {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(
//           'Parabéns! Agora você é um(a) Chef!👨‍🍳🤩\nReinicie o app para aplicar as alterações...',
//           style: TextStyle(fontSize: 16),
//         ),
//         duration: Duration(seconds: 15)));
//   }

//   _pricesLabel(Product product) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         _valorAntesLabel(product),
//         SizedBox(width: 5),
//         Text(
//           product.priceString,
//           style: TextStyle(color: Colors.pink[200]),
//         )
//       ],
//     );
//   }

//   _porcentagemEconomiaLabel(Product product) {
//     String idProduct = product.identifier;
//     String descontoLabel;
//     if (idProduct == SubscriptionId.month) {
//       return Container();
//     }
//     if (idProduct == SubscriptionId.three_months) {
//       descontoLabel = 'Economize mais de 5% !';
//     }
//     if (idProduct == SubscriptionId.six_months) {
//       descontoLabel = 'Economize mais de 10% !';
//     }

//     if (idProduct == SubscriptionId.year) {
//       descontoLabel = 'Economize mais de 15% !';
//     }
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 5),
//       color: Colors.yellow[600],
//       child: Text(
//         descontoLabel,
//         style: TextStyle(color: Colors.purple[900]),
//       ),
//     );
//   }

//   _valorAntesLabel(Product product) {
//     double valorAntes;
//     String id = product.identifier;

//     double min = offerings.elementAt(0).monthly.product.price;

//     if (id == SubscriptionId.month) {
//       return Container();
//     } else if (id == SubscriptionId.three_months) {
//       valorAntes = min * 3;
//     } else if (id == SubscriptionId.six_months) {
//       valorAntes = min * 6;
//     } else if (id == SubscriptionId.year) {
//       valorAntes = min * 12;
//     }

//     Locale locale = Localizations.localeOf(context);
//     var format = NumberFormat.simpleCurrency(locale: locale.toString());

//     return Text(
//       MoneyFormatter(
//           amount: valorAntes,
//           settings: MoneyFormatterSettings(
//             thousandSeparator: '.',
//             decimalSeparator: ',',
//             symbol: format.currencySymbol,
//           )).output.symbolOnLeft,
//       style: TextStyle(
//         color: Colors.pink[200],
//         decoration: TextDecoration.lineThrough,
//       ),
//     );
//   }

//   _getInferiorSection(Package package) {
//     String id = package.product.identifier;
//     String message;
//     if (id == SubscriptionId.month) {
//       message = 'Ativa o Modo Chef por 30 dias.';
//     }

//     if (id == SubscriptionId.three_months) {
//       message = 'Ativa o Modo Chef por 3 meses.';
//     }

//     if (id == SubscriptionId.six_months) {
//       message = 'Ativa o Modo Chef por 6 meses.';
//     }
//     if (id == SubscriptionId.year) {
//       message = 'Ativa o Modo Chef por 1 ano.';
//     }

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(message, style: TextStyle(color: Colors.white)),
//         _currentPlanIdentifier(package),
//       ],
//     );
//   }
// }
