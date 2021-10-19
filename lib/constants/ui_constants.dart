
import 'package:flutter/material.dart';

const int GRID_WIDTH = 15;
const int GRID_HEIGHT = 24;
const Duration DURATION = Duration(milliseconds: 300);
const int COOL_DOWN_INIT = 15;

const int GRID_TO_SIDEBAR_RATIO = 4;
const double DEFAULT_BORDER_RADIUS = 15.0;
const double DEFAULT_BORDER_WIDTH = 3.0;
const double SIZED_BOX_SIZE = 5.0;
const Color BACKGROUND_COLOR = Colors.blueGrey;
const Color BORDERS_COLOR = Colors.white;
const String FONT = "Courier";

const double ANTAGONIST_WIDTH = 64;
const double ANTAGONIST_HEIGHT = 64;
const double ANTAGONIST_FRAME_WIDTH = 64;
const int ANTAGONIST_AMOUNT = 4;

enum DeviceType { host, player }

enum PlayerRole { player, foe, awaiting}

const List<Color> playerColors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
Map<String, int> colorToPlayerId = {
  Colors.red.toString():0, Colors.blue.toString():1,
  Colors.green.toString():2, Colors.yellow.toString():3};

const Color squareBorderColor = Colors.black12;
const Color squareFrozenColor = Colors.grey;
const Color squareBombColor = Colors.black54;
const double squareBorderWidth = 3.0;

const double energyIncrement = 0.005;