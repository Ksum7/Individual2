import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showAppSnackBar(BuildContext context, String message){
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 700,
        content: Text(
          "Одно или несколько полей заполнены неверно",
          textAlign: TextAlign.center,
        ),
      )
  );
}