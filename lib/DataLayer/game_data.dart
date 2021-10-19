import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:tetrisserver/constants/ui_constants.dart';

import 'square.dart';
import 'tetromino.dart';

// data that can't stay inside GameState and must be exposed to other widgets
class GameData with ChangeNotifier {

  late NearbyService nearbyService;
  List<Device> _connectedDevices = [];
  HashMap<String, int> deviceIdToPlayerId = HashMap<String, int>();
  HashMap<int, String> playerIdToDeviceId = HashMap<int, String>();
  int maxPlayerId = 0;

  bool isLaunched = false;
  int roundNumber = 0;

  List<int> scores = [0, 0, 0, 0];

  List<Tetromino> curTetrominos = <Tetromino>[];
  List<Tetromino> nextTetrominos = <Tetromino>[];
  List<Square> groundSquares = <Square>[];
  int coolDownFall = 0;
  int coolDownSpeed = 1;
  int coolDownUntilReset = 0;

  int antagonist = 1; // player id of who's the antagonist
  double energy = 0.0;
  int antagonistLives = 0;
  int lineBeingDeletedStep = 0;

  int nextPlayer = 0;
  int nextDropIndex = 2;

  bool gameIsOver = false;

  Timer timer = Timer.periodic(DURATION, (timer) => {});

  @override
  void dispose() {
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  void linkService(NearbyService service) {
    nearbyService = service;
  }

  void updatePlayerRoles(List<Device> connectedDevices) {
    // notifies each connected player of its id and role
    if (connectedDevices.isNotEmpty) {
      _connectedDevices = connectedDevices;
    }
    deviceIdToPlayerId.clear();
    playerIdToDeviceId.clear();
    maxPlayerId = 0;
    for (int i = 0; i < _connectedDevices.length; i++) {
      Device device = _connectedDevices[i];
      nearbyService.sendMessage(device.deviceId, 'id=$i');
      PlayerRole role = (i == antagonist) ? PlayerRole.foe : PlayerRole.player;
      nearbyService.sendMessage(device.deviceId, 'r=$role');
      deviceIdToPlayerId[device.deviceId] = i;
      playerIdToDeviceId[i] = device.deviceId;
      maxPlayerId = max(maxPlayerId, i);
    }
  }

  void _incrementNextPlayer() {
    nextPlayer++;
    if (nextPlayer > maxPlayerId) nextPlayer = 0;
    if (nextPlayer == antagonist) nextPlayer++;
    if (nextPlayer > maxPlayerId) nextPlayer = 0;
  }

  void _incrementAntagonist() {
    antagonist++;
    if (antagonist > maxPlayerId) antagonist = 0;
    nextPlayer = antagonist+1;
    if (nextPlayer > maxPlayerId) nextPlayer = 0;
    updatePlayerRoles([]);
    notifyListeners();
  }

  // 1 or 2 or 3, used to know where to place the next tetromino horizontally
  int realDropIndex() {
    int dropIndex = nextDropIndex;
    if (dropIndex == 0) {
      dropIndex = 2;
    }
    return dropIndex;
  }

  // when a tetromino appears, 2 other tetrominos have been generated
  // so we need another function that accounts for this lag
  int oldDropIndex() {
    int dropIndex = (nextDropIndex + 2) % 4;
    if (dropIndex == 0) {
      dropIndex = 2;
    }
    return dropIndex;
  }

  void _incrementDropIndex() {
    nextDropIndex++;
    if (nextDropIndex == 4)  nextDropIndex = 0;
  }

  // Antagonist widget is normally one step above the current falling tetromino
  // But it must go back to last tetromino when the game is over
  void _decrementDropIndex() {
    nextDropIndex--;
    if (nextDropIndex == -1)  nextDropIndex = 3;
  }

  void startGame(double screenWidth) {
    isLaunched = true;
    roundNumber++;
    nextDropIndex = 1;

    for (int _ in [0,1]) {
      nextTetrominos.add(Tetromino.random(playerColors[nextPlayer], realDropIndex()));
      _incrementDropIndex();
      _incrementNextPlayer();
    }

    coolDownFall = 0;
    coolDownSpeed = 1;
    coolDownUntilReset = 0;

    groundSquares = <Square>[];

    energy = 0.5;
    antagonistLives = 2;

    timer = Timer.periodic(DURATION, onPlay);

    notifyListeners();
  }

  void triggerGameOver(bool antagonistWon) {
    gameIsOver = true;

    _decrementDropIndex();

    curTetrominos.clear();
    nextTetrominos.clear();

    timer.cancel();
    if (antagonistWon) {
      _incrementScoresAntagonistWon();
      timer = Timer.periodic(DURATION, onGameLost);
    } else {
      _incrementScoresAntagonistLost();
      timer = Timer.periodic(DURATION~/4, onGameWon);
    }
    notifyListeners();
  }

  void endGame() {
    gameIsOver = false;
    isLaunched = false;

    _incrementAntagonist();

    groundSquares.clear();
    curTetrominos.clear();
    nextTetrominos.clear();

    timer.cancel();

    notifyListeners();
  }

  // Don't listen to command coming from wrong player ("" to bypass check)
  bool applyCommand(String command, [String deviceId=""]) {
    int playerSendingCommand = -1;
    if (deviceId != "") {
      playerSendingCommand = deviceIdToPlayerId[deviceId] as int;
    }

    if (!isLaunched) {
      return false;
    }

    if (command.startsWith("Antagonist:")) {
      if (playerSendingCommand != -1 && playerSendingCommand != antagonist) {
        return false;
      }
      double energyNeeded = 0.0;
      if (command.startsWith("Antagonist:UpdateNextTetromino")) {
        // ex: UpdateNextTetromino[7,2,1] -> type (0 to 7), rotationIndex (0 to 3), isFrozen (0 or 1)
        String imported = command.substring("Antagonist:UpdateNextTetromino".length);
        List<String> sAttributes = imported.substring(1, imported.length-1).split(',');
        List<int> attributes = [];
        for (String s in sAttributes) {
          attributes.add(int.parse(s));
        }
        nextTetrominos[1] = Tetromino.fromArgList(attributes, nextTetrominos[1]);
      } else if (command.startsWith("Antagonist:UpdateEnergy")) {
        String imported = command.substring("Antagonist:UpdateEnergy".length);
        energy = double.parse(imported);
      } else if (command == "Antagonist:SendCombo") {
        // send 3 tetrominos almost at the same time
        energyNeeded = 0.7;
        if (energy < energyNeeded) {
          return false;
        }
        coolDownFall = 10000;
        coolDownSpeed = COOL_DOWN_INIT ~/ 2;
        coolDownUntilReset = 3;
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
      if (playerSendingCommand != -1 && playerSendingCommand == antagonist) {
        return false;
      }
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
    _deleteFullLines();
    lineBeingDeletedStep = max(lineBeingDeletedStep-1, 0);
    for (int iCur = curTetrominos.length-1; iCur >= 0; iCur--) {
      Tetromino curTetromino = curTetrominos[iCur];
      int? playerId = colorToPlayerId[curTetromino.color.toString()];
      if (!curTetromino.tryToApply("Down", curTetrominos, groundSquares,
          GRID_HEIGHT, GRID_WIDTH)) {
        if (curTetromino.isBomb) {
          detonateBomb(curTetromino);
        } else if (!curTetromino.addSquaresTo(groundSquares)) {
          // Not fully inside the screen when reached ground squares: game over
          return triggerGameOver(true);
        }
        int linesSkipped = _detectFullLines();
        if (linesSkipped > 0) {
          lineBeingDeletedStep = 2;
        }
        _incrementScoresLineDeleted((playerId!=null) ? playerId : -1, linesSkipped);
        _removeFromCurTetrominos(curTetromino);
      } else {
        _incrementScoresTetrominoLanded(curTetromino, (playerId!=null) ? playerId : -1);
      }
    }
    // if cool down variables allow it, send the next tetromino to the board
    coolDownFall -= coolDownSpeed;
    if (curTetrominos.isEmpty || coolDownFall <= 0) {
      if (!_sendNextTetromino()) {
        // Can't send next tetromino: game over
        return triggerGameOver(true);
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
    energy = min(1, energy+energyIncrement);
    if (antagonistLives <= 0) {
      triggerGameOver(false);
    }
    notifyListeners();
  }

  void onGameLost(Timer timer) {
    // Create a lightning effect by making squares switch between yellow and grey
    Color curColor = groundSquares[0].color;
    if (curColor != Colors.grey) {
      for (Square square in groundSquares) {
        square.color = Colors.grey;
      }
    } else {
      for (Square square in groundSquares) {
        square.color = Colors.yellow;
      }
    }
    notifyListeners();
  }

  void onGameWon(Timer timer) {
    // Remove all ground squares one by one and then call endGame
    int maxidx = -1;
    for (Square square in groundSquares) {
      maxidx = max(maxidx, square.y*GRID_WIDTH+square.x);
    }
    Square toRemove = Square(0,0);
    for (Square square in groundSquares) {
      if (maxidx == square.y*GRID_WIDTH+square.x) {
        toRemove = square;
        break;
      }
    }
    if (maxidx != -1) {
      groundSquares.remove(toRemove);
    } else {
      endGame();
      return;
    }
    notifyListeners();
  }

  bool _removeFromCurTetrominos(Tetromino onGround) {
    return curTetrominos.remove(onGround);
  }

  // Try to send a new tetromino to the board. Returns if a game over happened
  bool _sendNextTetromino() {
    if (curTetrominos.length >= 3) {
      // avoid having 2 tetrominos controlled by the same player
      // exit the function but don't trigger a game over
      return true;
    }

    Tetromino curTetromino = nextTetrominos[0];
    curTetrominos.add(curTetromino);
    if (coolDownFall < curTetromino.height) {
      coolDownFall = curTetromino.height;
    }
    nextTetrominos.remove(curTetromino);
    // just a placeholder, the data from antagonist client will overwrite this
    nextTetrominos.add(Tetromino.random(playerColors[nextPlayer], realDropIndex()));
    _incrementDropIndex();
    _incrementNextPlayer();

    String? antagonistId = playerIdToDeviceId[antagonist];
    if (antagonistId != null) {
      nearbyService.sendMessage(antagonistId, "WhatIsNext?");
    }

    // Test game over condition
    return !curTetromino.collidesWithGroundSquares(groundSquares);
  }

  // When a line is completed, delete its ground squares
  // and move one level down all squares above
  int _deleteFullLines() {
    return _detectFullLines(true);
  }

  int _detectFullLines([bool deleteThem=false]) {
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
      return 0;
    }

    int linesSkipped = 0;
    if (!deleteThem) { // just count them
      for (int line = GRID_HEIGHT - 1; line >= 0; line--) {
        if (count[line] == GRID_WIDTH) {
          linesSkipped++;
          for (Square square in groundSquares) {
            if (square.y == line) {
              square.color = Colors.white;
            }
          }
        }
      }
    } else {
      groundSquares.clear();
      for (int line = GRID_HEIGHT - 1; line >= 0; line--) {
        if (count[line] == GRID_WIDTH) {
          linesSkipped++;
        } else {
          for (int column = 0; column < GRID_WIDTH; column++) {
            int idx = line * GRID_WIDTH + column;
            if (tab[idx]) {
              groundSquares.add(
                  Square(column, line + linesSkipped, color[idx]));
            }
          }
        }
      }
    }
    return linesSkipped;
  }

  void _incrementScoresAntagonistWon() {
    scores[antagonist] += 150;
  }

  void _incrementScoresAntagonistLost() {
    for (int i = 0; i <= maxPlayerId; i++) {
      if (i != antagonist) {
        scores[i] += 50;
      }
    }
  }

  void _incrementScoresLineDeleted(int playerId, int linesSkipped) {
    antagonistLives -= linesSkipped;
    for (int i = 0; i <= maxPlayerId; i++) {
      if (i != antagonist) {
        scores[i] += 10 * linesSkipped * (linesSkipped+1) ~/ 2; // 10, 30, 60, 100...
      }
    }
    if (playerId == -1) return;
    scores[playerId] += 20 * linesSkipped * (linesSkipped+1) ~/ 2;
  }

  void _incrementScoresTetrominoLanded(Tetromino curTetromino, int playerId) {
    if (playerId == -1) return;
    for (Square groundSquare in groundSquares) {
      for (Square square in curTetromino.squares) {
        if (square.y == groundSquare.y && (square.x == 0 || square.x-1 == groundSquare.x)) {
          scores[playerId] += 1;
        }
        if (square.y == groundSquare.y && (square.x == GRID_WIDTH-1 || square.x+1 == groundSquare.x)) {
          scores[playerId] += 1;
        }
        if (square.x == groundSquare.x && (square.y == GRID_HEIGHT-1 || square.y+1 == groundSquare.y)) {
          scores[playerId] += 1;
        }
        if (square.x == groundSquare.x && (square.y-1 == groundSquare.y)) {
          scores[playerId] += 2;
        }
      }
    }
  }

  void detonateBomb(Tetromino curTetromino) {
    List<Square> toRemove = [];
    int x = curTetromino.x;
    int y = curTetromino.y;

    for (Square square in groundSquares) {
      int sx = square.x;
      int sy = square.y;
      if ((sx-x)*(sx-x) + (sy-y)*(sy-y) <= 5) {
        toRemove.add(square);
      }
    }

    for (Square square in toRemove) {
      groundSquares.remove(square);
    }
  }

}
