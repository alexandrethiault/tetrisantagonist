import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';
import 'package:tetrisserver/DataLayer/square.dart';
import 'package:tetrisserver/DataLayer/tetromino.dart';
import 'package:tetrisserver/UI/antagonist_widget.dart';

import 'my_decorations.dart';
import '../constants/ui_constants.dart';


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
      child: GestureDetector(
        onPanEnd: (DragEndDetails d) =>
            Provider.of<GameData>(context, listen: false).applyCommand(
              (d.velocity.pixelsPerSecond.dx < 0) ? "Left" : "Right"),
        onTapDown: (TapDownDetails d)
        {
        Provider.of<GameData>(context, listen: false).applyCommand("TurnRight");
          Provider.of<GameData>(context, listen: false).applyCommand("Antagonist:SwitchFalling");},
        child: Container(
          key: _keyGameWidget,
          decoration: GameBoxDecoration(),
          child: _squareStack(),
        ),
      ),
    );
  }

  Stack _squareStack() {
    List<Positioned> stackChildren = <Positioned>[];
    List<Square> groundSquares = Provider.of<GameData>(context).groundSquares;
    List<Tetromino> curTetrominos = Provider.of<GameData>(context).curTetrominos;
    if (groundSquares.isEmpty && curTetrominos.isEmpty) {
      return Stack(children: stackChildren);
    }

    final RenderBox renderBoxTetris = _keyGameWidget.currentContext!.findRenderObject() as RenderBox;
    double width = (renderBoxTetris.size.width - 2*DEFAULT_BORDER_WIDTH)/ GRID_WIDTH;

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

    for (Tetromino curTetromino in curTetrominos) {
      List<Square> fallingSquares = curTetromino.rotations[curTetromino.rotationIndex];
      for (Square square in fallingSquares) {
        stackChildren.add(
            Positioned(
              left: (square.x + curTetromino.x) * width,
              top: (square.y + curTetromino.y) * width,
              child: Container(
                width: width - 1,
                height: width - 1,
                decoration: BoxDecoration(color: square.color),
              ),
            )
        );
      }
    }

    stackChildren.add(
        const Positioned(
          top: 0,
          child: Antagonist(),
        )
    );

    return Stack(children: stackChildren);
  }

}
