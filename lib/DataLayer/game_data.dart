import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'square.dart';
import 'tetromino.dart';

const int GRID_WIDTH = 20;
const int GRID_HEIGHT = 32;
const Duration DURATION = Duration(milliseconds: 250);
const int COOL_DOWN_INIT = 15;

// data that can't stay inside GameState and must be exposed to other widgets
class GameData with ChangeNotifier {
  bool isLaunched = false;
  int roundNumber = 0;

  List<int> scores = [0, 0, 0, 0];
  List<Color> playerColors = [
    Colors.orange, Colors.blue, Colors.green, Colors.yellow];

  int nextPlayer = 1;
  List<Tetromino> curTetrominos = <Tetromino>[];
  List<Tetromino> nextTetrominos = <Tetromino>[];
  List<Square> groundSquares = <Square>[];
  int coolDownFall = 0;
  int coolDownSpeed = 1;
  int coolDownUntilReset = 0;

  int antagonist = 0;
  double energy = 0.0;

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

    for (int _ in [0,1,2]) {
      nextTetrominos.add(Tetromino.random(playerColors[nextPlayer]));
      _incrementNextPlayer();
    }

    coolDownFall = 0;
    coolDownSpeed = 1;
    coolDownUntilReset = 0;
    //_sendNextTetromino();

    groundSquares = <Square>[];

    energy = 0.9;

    timer = Timer.periodic(DURATION, onPlay);

    notifyListeners();
  }

  void endGame() {
    isLaunched = false;

    _incrementAntagonist();

    groundSquares.clear();
    curTetrominos.clear();
    nextTetrominos.clear();

    timer.cancel();

    notifyListeners();
  }

  // Don't listen to command coming from wrong player (-1 to bypass check)
  bool applyCommand(String command, [int playerSendingCommand=-1]) {
    if (!isLaunched) {
      return false;
    }

    if (command.startsWith("Antagonist:")) {
      double energyNeeded = 0.0;
      if (command.startsWith("Antagonist:TriggerTetromino")) { // + digit
        int tetrominoIndex = int.parse(command[command.length-1]);
        energyNeeded = 0.4;
        if (energy < energyNeeded) {
          return false;
        }
        if (nextTetrominos.isEmpty) {
          return false;
        }
        nextTetrominos[0] = Tetromino.fromType(
            tetrominoIndex, nextTetrominos[0].color, 0);
      } else if (command == "Antagonist:SendCombo") {
        // send 3 tetrominos almost at the same time
        energyNeeded = 0.7;
        if (energy < energyNeeded) {
          //return false;
        }
        coolDownFall = 10000;
        coolDownSpeed = COOL_DOWN_INIT ~/ 4;
        coolDownUntilReset = 3;
      } else if (command.startsWith("Antagonist:All")) { // ex: AllTurnLeft
          energyNeeded = 0.6;
          if (energy < energyNeeded) {
            return false;
          }
          command = command.substring("Antagonist:All".length);
          for (Tetromino curTetromino in curTetrominos) {
            curTetromino.tryToApply(command, curTetrominos, groundSquares,
                GRID_HEIGHT, GRID_WIDTH);
          }
      } else if (command.startsWith("Antagonist:SwitchNext")) { // + 2 digits
        // switch the tetrominos' shapes (not the colors) from the Next list
        energyNeeded = 0.1;
        if (energy < energyNeeded) {
          return false;
        }
        int i1 = int.parse(command[command.length-2]);
        int i2 = int.parse(command[command.length-1]);
        if (nextTetrominos.length < max(i1, i2)) {
          return false;
        }
        Tetromino t = nextTetrominos[i1];
        nextTetrominos[i1] = nextTetrominos[i2];
        nextTetrominos[i2] = t;
        Color c = nextTetrominos[i1].color;
        nextTetrominos[i1].color = nextTetrominos[i2].color;
        nextTetrominos[i2].color = c;
      } else if (command == "Antagonist:SwitchFalling") {
        // switch the two lowest falling tetrominos' shapes and colors
        energyNeeded = 0.3;
        if (energy < energyNeeded) {
          return false;
        }
        List<Tetromino> newCurTetrominos = <Tetromino>[];
        for (Tetromino tetromino in curTetrominos) {
          newCurTetrominos.add(tetromino.copy());
        }
        int x = newCurTetrominos[0].x;
        newCurTetrominos[0].x = newCurTetrominos[1].x;
        newCurTetrominos[1].x = x;
        int y = newCurTetrominos[0].y;
        newCurTetrominos[0].y = newCurTetrominos[1].y;
        newCurTetrominos[1].y = y;
        Color c = newCurTetrominos[0].color;
        newCurTetrominos[0].color = newCurTetrominos[1].color;
        newCurTetrominos[1].color = c;
        for (Tetromino tetromino in newCurTetrominos) {
          if (!tetromino.isValid(newCurTetrominos, groundSquares,
              GRID_HEIGHT, GRID_WIDTH)) {
            return false;
          }
        }
        curTetrominos = newCurTetrominos;
      } else {
        nextTetrominos[0].color = Colors.grey;
        print("[game_data.dart/applyCommand] Tried to apply an unknown antagonist command");
      }
      energy -= energyNeeded;
      notifyListeners();
      return true;
    } else {
      bool applied = false;
      for (Tetromino curTetromino in curTetrominos) {
        Color playerColor = curTetromino.color;
        if (playerSendingCommand != -1) {
          playerColor = playerColors[playerSendingCommand];
        }

        if (playerColor == curTetromino.color) {
          if (applied |= curTetromino.tryToApply(
              command, curTetrominos, groundSquares,
              GRID_HEIGHT, GRID_WIDTH)) {
            notifyListeners();
          }
        }
      }
      return applied;
    }
  }

  void onPlay(Timer timer) {
    // Change tetrominos which reached the ground into ground squares
    for (int iCur = curTetrominos.length-1; iCur >= 0; iCur--) {
      Tetromino curTetromino = curTetrominos[iCur];
      if (!curTetromino.tryToApply("Down", curTetrominos, groundSquares,
          GRID_HEIGHT, GRID_WIDTH)) {
        if (!curTetromino.addSquaresTo(groundSquares)) {
          // Not fully inside the screen when reached ground squares: game over
          return endGame();
        }
        _deleteFullLines();
        _removeFromCurTetrominos(curTetromino);
      }
    }
    // if cool down variables allow it, send the next tetromino to the board
    coolDownFall -= coolDownSpeed;
    if (curTetrominos.isEmpty || coolDownFall <= 0) {
      if (!_sendNextTetromino()) {
        // Can't send next tetromino: game over
        return endGame();
      }
      coolDownFall = COOL_DOWN_INIT;
      if (coolDownSpeed != 1) {
        coolDownUntilReset -= 1;
        if (coolDownUntilReset <= 0) {
          coolDownSpeed = 1; // reset potential change made by antagonist
        }
      }
    }
    // increment antagonist energy
    energy = min(1, energy+0.02);
    notifyListeners();
  }

  bool _removeFromCurTetrominos(Tetromino onGround) {
    return curTetrominos.remove(onGround);
  }

  // Try to send a new tetromino to the board. Returns if a game over happened
  bool _sendNextTetromino() {
    if (curTetrominos.length >= 3) {
      // exit the function but don't trigger a game over
      return true;
    }

    Tetromino curTetromino = nextTetrominos[0];
    curTetrominos.add(curTetromino);
    if (coolDownFall < curTetromino.height) {
      coolDownFall = curTetromino.height;
    }
    nextTetrominos.remove(curTetromino);
    nextTetrominos.add(Tetromino.random(playerColors[nextPlayer]));
    _incrementNextPlayer();

    // Test game over condition
    return !curTetromino.collidesWithGroundSquares(groundSquares);
  }

  // When a line is completed, delete its ground squares
  // and move one level down all squares above
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
