import 'package:flutter/material.dart';
import 'package:receitas_de_pao/utils/screen.dart';

class BackgroundPage extends StatelessWidget {
  Widget child;
  Screen screen;

  BackgroundPage({this.child});
  @override
  Widget build(BuildContext context) {
    screen = Screen(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black, BlendMode.softLight),
            child: Image.asset(
              'lib/assets/background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(child: Container(child: child))
        ],
      ),
    );
  }
}
