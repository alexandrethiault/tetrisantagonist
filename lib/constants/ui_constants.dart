
import 'package:flutter/material.dart';


const int GRID_TO_SIDEBAR_RATIO = 4;
const double DEFAULT_BORDER_RADIUS = 10.0;
const double DEFAULT_BORDER_WIDTH = 2.0;
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

List<Color> playerColors = [Colors.grey, Colors.red, Colors.blue, Colors.green, Colors.yellow];