import 'package:flutter/material.dart';
import 'square.dart';
//TODO collisions tmtc
const String tetrominoes = """
 X  .    . X  .    .
 X  .XXXX. X  .XXXX.
 X  .    . X  .    .
 X  .    . X  .    .
....................
XX  .XX  .XX  .XX  .
XX  .XX  .XX  .XX  .
    .    .    .    .
    .    .    .    .
....................
XX  . X  .XX  . X  .
 XX .XX  . XX .XX  .
    .X   .    .X   .
    .    .    .    .
....................
 XX .X   . XX .X   .
XX  .XX  .XX  .XX  .
    . X  .    . X  .
    .    .    .    .
....................
XXX .X   . X  . X  .
 X  .XX  .XXX .XX  .
    .X   .    . X  .
    .    .    .    .
....................
XXX .XX  .  X .X   .
X   . X  .XXX .X   .
    . X  .    .XX  .
    .    .    .    .
....................
XX  .XXX . X  .X   .
X   .  X . X  .XXX .
X   .    .XX  .    .
    .    .    .    .
....................
 X  . X  . X  . X  .
X X .X X .X X .X X .
 X  . X  . X  . X  .
    .    .    .    .
....................
""";

class Tetromino {
  int x = 0; // reference position
  int y = 0;
  int rotationIndex = 0; // between 0 and 3
  List<List<Square>> rotations = <List<Square>>[]; // list of 4 rotations

  Tetromino(this.rotations, this.rotationIndex) {
    x = 3;
    y = -height;
  }

  Tetromino.nullTetromino() {
    x = 0;
    y = 0;
    rotationIndex = 0;
    rotations = [[],[],[],[]];
  }

  Tetromino.fromType(int type, Color color, this.rotationIndex) {
    String string = tetrominoes;
    List<String> lines = string.split('\n');
    rotations = [[],[],[],[]];
    for (int i = 0; i < 4; i++) { // iterate through lines 5*type to 5*type+3
      for (int k in [0,1,2,3]) { // iterate through possible rotations
        for (int j = 0; j < 4; j++) { // iterate through columns 5*k to 5*k+3
          if (lines[5*type+i][5*k+j] == "X") {
            rotations[k].add(Square(i, j, color));
          }
        }
      }
    }
    x = 5-width~/2;
    y = -height;
  }

  Color get color {
    return rotations[0][0].color;
  }

  set color(Color color) {
    for (var orientation in rotations) {
      for (var square in orientation) {
        square.color = color;
      }
    }
  }

  int get maxX {
    int maxX = 0;
    for (var square in squares) {
      if (square.x > maxX) maxX = square.x;
    }
    return maxX;
  }

  int get minX {
    int minX = 3;
    for (var square in squares) {
      if (square.x < minX) minX = square.x;
    }
    return minX;
  }

  int get width {
    return maxX - minX + 1;
  }

  int get maxY {
    int maxY = 0;
    for (var square in squares) {
      if (square.y > maxY) maxY = square.y;
    }
    return maxY;
  }

  int get minY {
    int minY = 3;
    for (var square in squares) {
      if (square.y < minY) minY = square.y;
    }
    return minY;
  }

  int get height {
    return maxX - minX + 1;
  }

  get squares {
    return rotations[rotationIndex];
  }

  void apply(String command) {
    if (command == "Down") {
      y += 1;// y=0 = top of the screen
    } else if (command == "Right") {
      x += 1;
    } else if (command == "Left") {
      x -= 1;
    } else if (command == "TurnRight") {
      rotationIndex++;
      if (rotationIndex == 4) rotationIndex = 0;
    } else if (command == "TurnLeft") {
      if (rotationIndex == 0) rotationIndex = 4;
      rotationIndex--;
    }
  }

  bool reachedGround(int GRID_HEIGHT) {
    return (maxY + y >= GRID_HEIGHT);
  }

  void addSquaresTo(List<Square> list) {
    for (Square square in rotations[rotationIndex]) {
      list.add(Square(square.x + x, square.y + y, square.color));
    }
  }

}
