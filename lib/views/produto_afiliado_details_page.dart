// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:receitas_de_pao/afiliados/prod_afiliado_situation.dart';
// import 'package:receitas_de_pao/components/app_textfield.dart';
// import 'package:receitas_de_pao/components/btn_premium.dart';
// import 'package:receitas_de_pao/models/my_app/direct_link.dart';
// import 'package:receitas_de_pao/models/produto_afiliado.dart';
// import 'package:receitas_de_pao/routes/app_routes.dart';
// import 'package:receitas_de_pao/style/palete.dart';
// import 'package:receitas_de_pao/utils/keyboard.dart';
// import 'package:receitas_de_pao/utils/screen.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ProdutoAfiliadoDetailsPage extends StatefulWidget {
//   ProdAfiliado prodAfiliado;

//   ProdutoAfiliadoDetailsPage({
//     this.prodAfiliado,
//   });
//   @override
//   State<ProdutoAfiliadoDetailsPage> createState() =>
//       _ProdutoAfiliadoDetailsPageState();
// }

// class _ProdutoAfiliadoDetailsPageState
//     extends State<ProdutoAfiliadoDetailsPage> {
//   ProdAfiliado get prodAfiliado => widget.prodAfiliado;
//   @override
//   void initState() {
//     super.initState();

//     //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           _appBar(),
//           //_header(),
//           Flexible(child: _content()),
//         ],
//       ),
//     );
//   }

//   _appBar() {
//     return AppBar(
//       automaticallyImplyLeading: true,
//       backgroundColor: Colors.pink[600],
//       title: Text(
//         prodAfiliado.descricao,
//       ),
//       actions: [BtnPremium()],
//     );
//   }

//   _content() {
//     List<DirectLink> directLinks = _createDirectLinks();
//     return Card(
//       child: Container(
//         child: Column(
//           children: [
//             Expanded(
//                 child: SingleChildScrollView(child: _superiorCardSection())),
//             Card(
//               elevation: 10,
//               child: Container(
//                 padding: EdgeInsets.all(8),
//                 child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: directLinks.length,
//                     itemBuilder: (context, index) {
//                       DirectLink directLink = directLinks.elementAt(index);
//                       return _directLinkViewModel(directLink);
//                     }),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   _superiorCardSection() {
//     return Column(
//       children: [
//         Container(
//           padding: EdgeInsets.all(8),
//           child: Card(
//             child: Image.asset(prodAfiliado.imgSrc),
//             elevation: 10,
//           ),
//         ),
//         Row(
//           children: [
//             Flexible(
//               child: Container(
//                 padding: EdgeInsets.only(left: 10, right: 10),
//                 child: Card(
//                   elevation: 10,
//                   child: Container(
//                     color: Colors.pink[700],
//                     padding: EdgeInsets.only(
//                         left: 10, right: 10, top: 10, bottom: 10),
//                     child: Text(
//                       prodAfiliado.descricao,
//                       style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Container(
//             padding: EdgeInsets.all(25),
//             child: Text(
//               prodAfiliado.descricaoDetalhada,
//               textAlign: TextAlign.justify,
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 17,
//               ),
//             ))
//       ],
//     );
//   }

//   _createDirectLinks() {
//     return [
//       DirectLink(
//         url: prodAfiliado.vendasUrl,
//         produto: prodAfiliado,
//       ),
//       DirectLink(
//         url: prodAfiliado.checkoutUrl,
//         produto: prodAfiliado,
//       ),
//     ];
//   }

//   _directLinkViewModel(DirectLink directLink) {
//     return ElevatedButton(
//       style: ButtonStyle(
//           backgroundColor: MaterialStateProperty.all(Colors.purple[900])),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             '',
//             style: TextStyle(
//                 color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic),
//           ),
//           SizedBox(width: 10),
//         ],
//       ),
//       onPressed: () {
//         Navigator.of(context).pushNamed(
//           AppRoutes.webViewAfiliadoPage,
//           arguments: directLink,
//         );
//         // launchUrl(
//         //   Uri.parse(directLink.url),
//         //   mode: LaunchMode.inAppWebView,
//         // );
//       },
//     );
//   }
// }
