import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';
import 'package:tetrisserver/DataLayer/square.dart';
import 'package:tetrisserver/DataLayer/tetromino.dart';

import 'my_decorations.dart';
import 'ui_constants.dart';


class GameWidget extends StatefulWidget {
  const GameWidget({Key? key}) : super(key: key);

  @override
  GameWidgetState createState() => GameWidgetState();
}

class GameWidgetState extends State<GameWidget> {
  final GlobalKey _keyGameWidget = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0*GRID_WIDTH/GRID_HEIGHT,
      child: Container(
        key: _keyGameWidget,
        decoration: GameBoxDecoration(),
        child: GestureDetector(
          onTapDown: (TapDownDetails d) =>
            shiftRight(),
            child: _squareStack()
        ),
      ),
    );
  }

  Stack _squareStack() {
    List<Positioned> stackChildren = <Positioned>[];
    List<Square> groundSquares = Provider.of<GameData>(context).groundSquares;
    Tetromino curTetromino = Provider.of<GameData>(context).curTetromino;
    List<Square> fallingSquares = curTetromino.rotations[curTetromino.rotationIndex];
    if (groundSquares.isEmpty && fallingSquares.isEmpty) {
      return Stack(children: stackChildren);
    }

    final RenderBox renderBoxTetris = _keyGameWidget.currentContext!.findRenderObject() as RenderBox;
    double width = (renderBoxTetris.size.width - 2*DEFAULT_BORDER_RADIUS)/ GRID_WIDTH;

    for (Square square in groundSquares) {
      stackChildren.add(
        Positioned(
          left: square.x * width,
          top: square.y * width,
          child: Container(
            width: width - 1,
            height: width - 1,
            decoration: BoxDecoration(color: square.color),
          ),
        )
      );
    }



    for (Square square in fallingSquares) {
      stackChildren.add(
        Positioned(
          left: (square.x+curTetromino.x) * width,
          top: (square.y+curTetromino.y) * width,
          child: Container(
            width: width - 1,
            height: width - 1,
            decoration: BoxDecoration(color: square.color),
          ),
        )
      );
    }

    stackChildren.add(
        const Positioned(
          left: 50,
          top: 50,
          child: Image(image: AssetImage('assets/antagonistlol.png')),
        )
    );

    return Stack(children: stackChildren);
  }

  void shiftRight() {
    Provider.of<GameData>(context, listen: false).shiftRight();

  }
}
