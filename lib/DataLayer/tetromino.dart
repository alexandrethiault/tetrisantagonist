import 'dart:math';

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

  Tetromino.fromType(int type, Color color, [this.rotationIndex=0]) {
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
    x = 10-width~/2-minX;
    y = -maxY;
  }

  Tetromino.random(Color color) :
        this.fromType(Random().nextInt(7), color, Random().nextInt(4));

  Tetromino copy() {
    Tetromino copy = Tetromino(rotations, rotationIndex);
    copy.x = x;
    copy.y = y;
    return copy;
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

  get baseSquares {
    return rotations[rotationIndex];
  }

  get squares {
    List<Square> list = <Square>[];
    for (Square square in baseSquares) {
      list.add(Square(square.x+x, square.y+y, color));
    }
    return list;
  }

  int get maxX {
    int maxX = 0;
    for (var square in baseSquares) {
      if (square.x > maxX) maxX = square.x;
    }
    return maxX;
  }

  int get minX {
    int minX = 3;
    for (var square in baseSquares) {
      if (square.x < minX) minX = square.x;
    }
    return minX;
  }

  int get width {
    return maxX - minX + 1;
  }

  int get maxY {
    int maxY = 0;
    for (var square in baseSquares) {
      if (square.y > maxY) maxY = square.y;
    }
    return maxY;
  }

  int get minY {
    int minY = 3;
    for (var square in baseSquares) {
      if (square.y < minY) minY = square.y;
    }
    return minY;
  }

  int get height {
    return maxX - minX + 1;
  }

  // Apply command without safe-checking anything
  void _apply(String command) {
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
    } else {
      color = Colors.grey;
      print("[tetromino.dart/apply] Tried to apply an unknown command");
    }
  }

  // Return the result of "apply" to a copy (without modifying this)
  Tetromino _withApplied(String command) {
    Tetromino copied = copy();
    copied._apply(command);
    return copied;
  }

  // Test if command can be applied, without modifying this for now
  bool _canApply(String command, List<Tetromino> currentTetrominos,
                List<Square> groundSquares, int gridHeight, int gridWidth) {
    Tetromino future = _withApplied(command);

    if (future.isOutOfBounds(gridHeight, gridWidth)) {
      return false;
    }

    if (future.collidesWithGroundSquares(groundSquares)) {
      return false;
    }

    if (command == "Down") {
      return true; // don't test on other tetrominos
    }

    for (Tetromino otherTetromino in currentTetrominos) {
      if (otherTetromino.color != color) {
        if (future.collidesWithOther(otherTetromino)) {
          return false;
        }
      }
    }

    return true;
  }

  // Apply command and return true if canApply returned true, or return false
  bool tryToApply(String command, List<Tetromino> currentTetrominoes,
                  List<Square> groundSquares, int gridHeight, int gridWidth) {
    if (_canApply(command, currentTetrominoes, groundSquares, gridHeight, gridWidth)) {
      _apply(command);
      return true;
    }
    return false;
  }

  bool collidesWithOther(Tetromino other) {
    List<Square> otherSquares = other.squares;
    for (Square square1 in squares) {
      for (Square square2 in otherSquares) {
        if (square1.collidesWith(square2)) {
          return true;
        }
      }
    }
    return false;
  }

  bool collidesWithGroundSquares(List<Square> groundSquares) {
    for (Square square1 in squares) {
      for (Square square2 in groundSquares) {
        if (square1.collidesWith(square2)) {
          return true;
        }
      }
    }
    return false;
  }

  bool isOutOfBounds(int gridHeight, int gridWidth) {
    for (Square square in squares) {
      if (square.isOutOfBounds(gridHeight, gridWidth)) {
        return true;
      }
    }
    return false;
  }

  bool addSquaresTo(List<Square> list) {
    for (Square square in squares) {
      if (square.y < 0) {
        return false;
      }
      list.add(square);
    }
    return true;
  }

}
