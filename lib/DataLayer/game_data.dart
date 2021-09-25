import 'dart:async';

import 'package:flutter/material.dart';

import 'square.dart';
import 'tetromino.dart';

const int GRID_WIDTH = 10;
const int GRID_HEIGHT = 16;
const Duration DURATION = Duration(milliseconds: 500);

// Things that can't stay inside GameState and need to be exposed to other widgets
class GameData with ChangeNotifier {
  bool isLaunched = false;
  int roundNumber = 0;

  List<int> scores = [0, 0, 0, 0];
  List<Color> playerColors = [
    Colors.orange, Colors.blue, Colors.green, Colors.yellow];

  int nextPlayer = 1;
  Tetromino curTetromino = Tetromino.nullTetromino();
  Tetromino nextTetromino = Tetromino.nullTetromino();
  List<Square> groundSquares = <Square>[];

  int antagonist = 2;
  double energy = 0.3;

  Timer timer = Timer.periodic(DURATION, (timer) => {});

  void _incrementNextPlayer() {
    nextPlayer++;
    if (nextPlayer == 4) nextPlayer = 0;
    if (nextPlayer == antagonist) nextPlayer++;
    if (nextPlayer == 4) nextPlayer = 0;
  }

  void _incrementAntagonist() {
    antagonist++;
    if (antagonist == 4)  antagonist = 0;
    nextPlayer = antagonist+1;
    if (nextPlayer == 4)  nextPlayer = 0;
    notifyListeners();
  }

  void startGame(double screenWidth) {
    isLaunched = true;
    roundNumber++;
    for (var i in [0,1,2,3]) {
      scores[i] = 0;
    }

    curTetromino = Tetromino.random(playerColors[nextPlayer]);
    groundSquares = <Square>[];

    _incrementNextPlayer();
    nextTetromino = Tetromino.random(playerColors[nextPlayer]);

    timer = Timer.periodic(DURATION, onPlay);

    notifyListeners();
  }

  void endGame() {
    isLaunched = false;

    groundSquares = <Square>[];
    curTetromino = Tetromino.nullTetromino();
    nextTetromino = Tetromino.nullTetromino();
    energy = 1-energy;
    _incrementAntagonist();
    timer.cancel();

    notifyListeners();
  }

  // Don't listen to command coming from wrong player (-1 to bypass check)
  bool applyCommand(String command, [int playerSendingCommand=-1]) {
    if (!isLaunched) {
      return false;
    }

    bool applied = false;
    Color playerColor = curTetromino.color;
    if (playerSendingCommand != -1) {
      playerColor = playerColors[playerSendingCommand];
    }

    if (playerColor == curTetromino.color) {
      if (applied = curTetromino.tryToApply(command, [], groundSquares,
                                            GRID_HEIGHT, GRID_WIDTH)) {
        notifyListeners();
      }
    }
    return applied;
  }

  void onPlay(Timer timer) {
    if (!curTetromino.tryToApply("Down", [], groundSquares,
                                  GRID_HEIGHT, GRID_WIDTH)) {
      if (!curTetromino.addSquaresTo(groundSquares)) {
        // Not fully inside the screen when reached ground squares: game over
        endGame();
      }
      _deleteFullLines();
      if (!_sendNextTetromino()) {
        // Can't send next tetromino: game over
        endGame();
      }
    }
    notifyListeners();
  }

  bool _sendNextTetromino() {
    curTetromino = nextTetromino;
    _incrementNextPlayer();
    nextTetromino = Tetromino.random(playerColors[nextPlayer]);

    // Test game over condition
    return !curTetromino.collidesWithGroundSquares(groundSquares);
  }

  void _deleteFullLines() {
    List<bool> tab = List.filled(GRID_HEIGHT*GRID_WIDTH, false);
    List<Color> color = List.filled(GRID_HEIGHT*GRID_WIDTH, Colors.grey);
    List<int> count = List.filled(GRID_HEIGHT, 0);
    for (Square square in groundSquares) {
      int idx = square.y*GRID_WIDTH+square.x;
      tab[idx] = true;
      color[idx] = square.color;
      count[square.y]++;
    }

    bool nothingToDo = true;
    for (int line=0; line<GRID_HEIGHT; line++) {
      if (count[line] == GRID_WIDTH) {
        nothingToDo = false;
        break;
      }
    }
    if (nothingToDo) {
      return;
    }

    groundSquares.clear();
    int linesSkipped = 0;
    for (int line = GRID_HEIGHT-1; line>=0; line--) {
      if (count[line] == GRID_WIDTH) {
        linesSkipped++;
      } else {
        for (int column = 0; column<GRID_WIDTH; column++) {
          int idx = line*GRID_WIDTH + column;
          if (tab[idx]) {
            groundSquares.add(Square(column, line+linesSkipped, color[idx]));
          }
        }
      }
    }
  }

}
