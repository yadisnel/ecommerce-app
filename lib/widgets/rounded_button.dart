import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget{

  RoundedButton({@required this.onPressed, @required this.icon});
  final GestureTapCallback onPressed;
  final Icon icon;


  @override
  Widget build(BuildContext context) {

    return  OutlineButton(
      shape: StadiumBorder(),
      textColor: Colors.white,
      child: icon,
      borderSide: BorderSide(
          color: Colors.blue, style: BorderStyle.solid,
          width: 1),
      onPressed: onPressed,
    );
  }
}