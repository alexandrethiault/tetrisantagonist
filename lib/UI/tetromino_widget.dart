import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../DataLayer/tetromino.dart';
import 'my_decorations.dart';

// Display widget for tetrominos.
// Used by next_tetromino.dart and controller_widget.dart

Widget TetrominoWidget(Tetromino tetromino, double width) {
  int minX = tetromino.minX;
  int maxX = tetromino.maxX;
  int minY = tetromino.minY;
  int maxY = tetromino.maxY;
  Color color;

  List<Widget> columns = [];
  for (int y = minY; y <= maxY; ++y) {
    List<Widget> rows = [];
    for (int x = minX; x <= maxX; ++x) {
      color = Colors.transparent;
      for (var square in tetromino.baseSquares) {
        if (square.x == x && square.y == y) {
          color = tetromino.color;
          break;
        }
      }

      if (color == Colors.transparent) {
        rows.add(Container(width: width, height: width, color: color));
      } else {
        rows.add(Container(width: width, height: width,
            decoration: SquareDecoration(color, tetromino.isFrozen, tetromino.isBomb)));
      }
    }

    columns.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rows
    ));
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: columns,
  );
}