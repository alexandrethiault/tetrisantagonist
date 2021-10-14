import 'dart:math';

import 'package:flutter/material.dart';
import 'square.dart';

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

// Tetrominos are made of 4 Square and have 4 possible rotations
class Tetromino {
  int x = 0; // reference position
  int y = 0;
  int rotationIndex = 0; // between 0 and 3
  List<List<Square>> rotations = <List<Square>>[]; // list of 4 rotations
  int _type = -1;
  int _dropIndex = 2; // 1 or 2 or 3: spawn on the left/mid/right of the grid
  int _isFrozen = 0; // player can't rotate it if 1

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

  Tetromino.fromType(this._type, Color color, [this.rotationIndex=0, this._dropIndex=2, this._isFrozen=0]) {
    String string = tetrominoes;
    List<String> lines = string.split('\n');
    rotations = [[],[],[],[]];
    for (int i = 0; i < 4; i++) { // iterate through lines 5*type to 5*type+3
      for (int k in [0,1,2,3]) { // iterate through possible rotations
        for (int j = 0; j < 4; j++) { // iterate through columns 5*k to 5*k+3
          if (lines[5*_type+i][5*k+j] == "X") {
            rotations[k].add(Square(i, j, color));
          }
        }
      }
    }

    x = 5*_dropIndex-width~/2-minX;
    y = 5-maxY;
  }

  Tetromino.random(Color color, [int dropIndex=2, int frozen=0]) :
        this.fromType(Random().nextInt(7), color, Random().nextInt(4), dropIndex, frozen);

  // change the shape of the tetromino but keep the color and drop index
  Tetromino.fromArgList(List<int> attributes, Tetromino other) :
        this.fromType(attributes[0], other.color, attributes[1], other._dropIndex, attributes[2]);

  Tetromino copy() {
    Tetromino copy = Tetromino(rotations, rotationIndex);
    copy.x = x;
    copy.y = y;
    copy._dropIndex = _dropIndex;
    copy._isFrozen = _isFrozen;
    copy._type = _type;
    return copy;
  }

  String export() {
    String s = "[";
    s += _type.toString() + ",";
    s += rotationIndex.toString() + ",";
    s += _isFrozen.toString() + "]";
    return s;
  }

  Color get color => rotations[0][0].color;

  set color(Color color) {
    for (var orientation in rotations) {
      for (var square in orientation) {
        square.color = color;
      }
    }
  }

  get baseSquares => rotations[rotationIndex];

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

  int get width => maxX - minX + 1;

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

  int get height => maxX - minX + 1;

  bool get isFrozen => (_isFrozen==1);

  void freeze() {
    _isFrozen = 1;
  }

  // Apply command without safe-checking anything
  void _apply(String command) {
    if (command == "Nothing") {
      // do nothing
    } else if (command == "Down") {
      y += 1;// y=0 = top of the screen
    } else if (command == "Right") {
      x += 1;
    } else if (command == "Left") {
      x -= 1;
    } else if (command == "TurnRight") {
      if (isFrozen) return;
      rotationIndex++;
      if (rotationIndex == 4) rotationIndex = 0;
    } else if (command == "TurnLeft") {
      if (isFrozen) return;
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

  bool isValid(List<Tetromino> currentTetrominoes,
      List<Square> groundSquares, int gridHeight, int gridWidth) {
    return _canApply("Nothing", currentTetrominoes, groundSquares, gridHeight, gridWidth);
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
