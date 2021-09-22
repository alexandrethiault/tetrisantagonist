import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

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

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];

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

    curTetromino = Tetromino.fromType(
        Random().nextInt(7), playerColors[nextPlayer], Random().nextInt(4));
    groundSquares = <Square>[];

    _incrementNextPlayer();
    nextTetromino = Tetromino.fromType(
        Random().nextInt(7), playerColors[nextPlayer], Random().nextInt(4));

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

  void onPlay(Timer timer) {
    if (!curTetromino.reachedGround(GRID_HEIGHT)) {
      curTetromino.y += 1;
    } else {
      curTetromino.addSquaresTo(groundSquares);
      _sendNextTetromino();
    }
    notifyListeners();
  }

  void _sendNextTetromino() {
    curTetromino = nextTetromino;
    _incrementNextPlayer();
    nextTetromino = Tetromino.fromType(
        Random().nextInt(7), playerColors[nextPlayer], Random().nextInt(4));
  }

  void shiftRight() async {
    curTetromino.x += 1;
    await flutterBlue.startScan(timeout: const Duration(seconds: 10));
    flutterBlue.connectedDevices.asStream().listen(
      (List<BluetoothDevice> devices) {
        for (BluetoothDevice device in devices) {
          _addDeviceTolist(device);
        }
      }
    );
    flutterBlue.scanResults.listen(
      (List<ScanResult> results) {
        for (ScanResult result in results) {
          _addDeviceTolist(result.device);
        }
      }
    );
    notifyListeners();
  }

  void _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      devicesList.add(device);
      print("[GameData] "+device.name);
    }
  }


}
