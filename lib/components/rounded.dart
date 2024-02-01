import 'package:flutter/material.dart';

class Rounded extends StatefulWidget {
  Widget child;
  BorderRadius radius;

  Rounded({this.child, this.radius});

  @override
  State<Rounded> createState() => _RoundedState();
}

class _RoundedState extends State<Rounded> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      child: widget.child,
      decoration: BoxDecoration(
        borderRadius: widget.radius,
      ),
    );
  }
}
