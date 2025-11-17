import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:skribbl_clone/models/touch_points.dart';

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({required this.pointsList});
  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = [];
  
  @override
  void paint (Canvas canvas, Size size){
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);
    //minuto 1:59:32


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate){
    throw UnimplementedError();
  }

}
