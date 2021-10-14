import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:tetrisserver/constants/ui_constants.dart';

import 'square.dart';
import 'tetromino.dart';

const int GRID_WIDTH = 20;
const int GRID_HEIGHT = 32;
const Duration DURATION = Duration(milliseconds: 250);
const int COOL_DOWN_INIT = 15;

// data that can't stay inside GameState and must be exposed to other widgets
class GameData with ChangeNotifier {

  late NearbyService nearbyService;
  HashMap<String, int> deviceIdToPlayerId = HashMap<String, int>();
  HashMap<int, String> playerIdToDeviceId = HashMap<int, String>();

  bool isLaunched = false;
  int roundNumber = 0;

  List<int> scores = [0, 0, 0, 0];

  List<Tetromino> curTetrominos = <Tetromino>[];
  List<Tetromino> nextTetrominos = <Tetromino>[];
  List<Square> groundSquares = <Square>[];
  int coolDownFall = 0;
  int coolDownSpeed = 1;
  int coolDownUntilReset = 0;

  int antagonist = 0; // player id of who's the antagonist
  double energy = 0.0;

  int nextPlayer = 1;
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

  void updatePlayerRoles(List<Device> connectedDevices){
    // notifies each connected player of its id and role
  for (int i = 0; i < connectedDevices.length; i++) {
    Device device = connectedDevices[i];
    nearbyService.sendMessage(
    device.deviceId, 'id=${i}');
    nearbyService.sendMessage(device.deviceId, 'r=${i == antagonist ? PlayerRole.foe :PlayerRole.player}');
  }
}

  void _incrementNextPlayer() {
    nextPlayer++;
    if (nextPlayer == 4) nextPlayer = 0;
    if (nextPlayer == antagonist) nextPlayer++;
    if (nextPlayer == 4) nextPlayer = 0;
  }

  void _incrementAntagonist() {
    antagonist++;
    if (antagonist == 4) antagonist = 0;
    nextPlayer = antagonist+1;
    if (nextPlayer == 4) nextPlayer = 0;
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

  // when a tetromino appears, 3 other tetrominos have been generated
  // so we need another function that accounts for this lag
  int oldDropIndex() {
    int dropIndex = (nextDropIndex + 1) % 4;
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
    for (var i in [0,1,2,3]) {
      scores[i] = 0;
    }
    nextDropIndex = 1;

    for (int _ in [0,1,2]) {
      nextTetrominos.add(Tetromino.random(playerColors[nextPlayer], realDropIndex()));
      _incrementDropIndex();
      _incrementNextPlayer();
    }

    coolDownFall = 0;
    coolDownSpeed = 1;
    coolDownUntilReset = 0;

    groundSquares = <Square>[];

    energy = 0.9;

    timer = Timer.periodic(DURATION, onPlay);

    notifyListeners();
  }

  void triggerGameOver() {
    gameIsOver = true;

    _decrementDropIndex();

    curTetrominos.clear();
    nextTetrominos.clear();

    timer.cancel();
    timer = Timer.periodic(DURATION, onGameOver);

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
      if (command.startsWith("Antagonist:UpdateNextTetrominos")) {
        // ex: UpdateNextTetrominos[7,2,1];[...];[...]
        // first integer = type (0 to 7)
        // second integer = rotationIndex (0 to 3)
        // third integer = isFrozen (0 or 1)
        String strings = command.substring("Antagonist:UpdateNextTetrominos".length);
        List<String> stringList = strings.split(';');
        for (int i in [0,1,2]) {
          String string = stringList[i];
          List<String> sAttributes = string.substring(1, string.length-1).split(',');
          List<int> attributes = [];
          for (String s in sAttributes) {
            attributes.add(int.parse(s));
          }
          nextTetrominos[i] = Tetromino.fromArgList(attributes, nextTetrominos[i]);
        }
      } else if (command.startsWith("Antagonist:TriggerTetromino")) { // + digit [0..7] + digit [1..3]
        // TODO faire ça directement par l'antagoniste, et appeler Antagonist:UpdateNextTetrominos
        // replace tetromino from nextTetrominoes list.
        int tetrominoIndex = int.parse(command[command.length-2]);
        int nextIndex = int.parse(command[command.length-1])-1;
        energyNeeded = 0.4;
        if (energy < energyNeeded) {
          return false;
        }
        if (nextTetrominos.isEmpty) {
          return false;
        }
        nextTetrominos[nextIndex] = Tetromino.fromType(
            tetrominoIndex, nextTetrominos[0].color, 0);
      } else if (command == "Antagonist:SendCombo") {
        // send 3 tetrominos almost at the same time
        energyNeeded = 0.7;
        if (energy < energyNeeded) {
          return false;
        }
        coolDownFall = 10000;
        coolDownSpeed = COOL_DOWN_INIT ~/ 2;
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
      } else if (command.startsWith("Antagonist:Freeze")) { // + digit [1..3]
        // TODO faire ça directement par l'antagoniste, et appeler Antagonist:UpdateNextTetrominos
        // The player won't be able to rotate this tetromino
        energyNeeded = 0.5;
        if (energy < energyNeeded) {
          return false;
        }
        int nextIndex = int.parse(command[command.length-1])-1;
        nextTetrominos[nextIndex].freeze();
      } else if (command.startsWith("Antagonist:SwitchNext")) { // + digit [1..3] + digit [1..3]
        // TODO faire ça directement par l'antagoniste, et appeler Antagonist:UpdateNextTetrominos
        // switch the tetrominos' shapes (not the colors) from the Next list
        energyNeeded = 0.1;
        if (energy < energyNeeded) {
          return false;
        }
        int i1 = int.parse(command[command.length-2])-1;
        int i2 = int.parse(command[command.length-1])-1;
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
    for (int iCur = curTetrominos.length-1; iCur >= 0; iCur--) {
      Tetromino curTetromino = curTetrominos[iCur];
      if (!curTetromino.tryToApply("Down", curTetrominos, groundSquares,
          GRID_HEIGHT, GRID_WIDTH)) {
        if (!curTetromino.addSquaresTo(groundSquares)) {
          // Not fully inside the screen when reached ground squares: game over
          return triggerGameOver();
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
        return triggerGameOver();
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
    energy = min(1, energy+0.005);
    notifyListeners();
  }

  void onGameOver(Timer timer) {
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
