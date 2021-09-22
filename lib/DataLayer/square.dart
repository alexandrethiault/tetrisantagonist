import 'package:flutter/material.dart';

class Square {
  int x = 0;
  int y = 0;
  Color color = Colors.grey;

  Square(int x, int y, [Color color = Colors.grey]) {
    this.x = x;
    this.y = y;
    this.color = color;
  }
}