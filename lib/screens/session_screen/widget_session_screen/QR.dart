import 'package:flutter/material.dart';

class CreateQR extends StatefulWidget {
  @override
  _CreateQRState createState() => _CreateQRState();
}

class _CreateQRState extends State<CreateQR> {
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      child: Container(
        child: Icon(
          Icons.center_focus_weak,
          size: 250.0,
        ),
      ),
    );
  }
}
