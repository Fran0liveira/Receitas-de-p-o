import 'package:flutter/material.dart';

class DefaultModal extends StatelessWidget {
  Widget child;
  DefaultModal({this.child});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          color: Color(0xFF737373),
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: child),
        ),
      ],
    );
  }
}
