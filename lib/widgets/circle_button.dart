import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget{

  CircleButton({@required this.onPressed, @required this.title});
  final GestureTapCallback onPressed;
  final String title;


  @override
  Widget build(BuildContext context) {

    return  OutlineButton(
      textColor: Colors.teal[900],
      child: Text(this.title),
      borderSide: BorderSide(
          color: Colors.teal[900], style: BorderStyle.solid,
          width: 1),
      onPressed: onPressed,
    );
  }
}