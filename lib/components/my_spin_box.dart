import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

class MySpinBox extends StatelessWidget {
  String header;
  Function(double) onChanged;
  double value;
  double max;
  double min;
  Icon icon;

  MySpinBox(
      {this.header, this.onChanged, this.value, this.max, this.min, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.blue[900]),
          padding: EdgeInsets.all(10),
          child: Center(
            child: Row(
              children: [
                if (icon != null) icon,
                SizedBox(width: 10),
                Text(
                  header,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        SpinBox(
            min: min,
            max: max,
            value: value,
            onChanged: (value) {
              onChanged.call(value);
            })
      ],
    );
  }
}
