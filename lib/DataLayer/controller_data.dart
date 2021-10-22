import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

import '../constants/ui_constants.dart';
import 'square.dart';
import 'tetromino.dart';

// data that can't stay inside GameState and must be exposed to other widgets
class ControllerData with ChangeNotifier {

  late NearbyService nearbyService;

  bool isLaunched = false;
  int roundNumber = 0;

  List<int> scores = [0, 0, 0, 0];

  List<Tetromino> curTetrominos = <Tetromino>[];
  List<Tetromino> nextTetrominos = <Tetromino>[];
  List<Square> groundSquares = <Square>[];
  int coolDownFall = 0;
  int coolDownSpeed = 1;
  int coolDownUntilReset = 0;

  int antagonist = 0;
  double energy = 0.0;

  int nextPlayer = 1;
  int nextDropIndex = 2;

  bool gameIsOver = false;

  Timer timer = Timer.periodic(DURATION, (timer) => {});

  bool applyCommand(String command) {
    return false;
  }

}
