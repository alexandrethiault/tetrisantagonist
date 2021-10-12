import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';
import 'package:tetrisserver/DataLayer/square.dart';
import 'package:tetrisserver/DataLayer/tetromino.dart';
import 'package:tetrisserver/UI/antagonist_widget.dart';

import 'my_decorations.dart';
import '../constants/ui_constants.dart';

// the game grid widget, including tetrominos falling and fallen

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
      aspectRatio: 1.0 * GRID_WIDTH / GRID_HEIGHT,
      child: GestureDetector( // todo remove the gesture detector, that is for testing
        onPanEnd: (DragEndDetails d) =>
            Provider.of<GameData>(context, listen: false).applyCommand(
                (d.velocity.pixelsPerSecond.dx < 0) ? "Left" : "Right"),
        onTapDown: (TapDownDetails d) {
          Provider.of<GameData>(context, listen: false)
              .applyCommand("TurnRight");
        },
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
    List<Tetromino> curTetrominos =
        Provider.of<GameData>(context).curTetrominos;
    if (groundSquares.isEmpty && curTetrominos.isEmpty) {
      return Stack(children: stackChildren);
    }

    final RenderBox renderBoxTetris =
        _keyGameWidget.currentContext!.findRenderObject() as RenderBox;
    double width =
        (renderBoxTetris.size.width - 2 * DEFAULT_BORDER_WIDTH) / GRID_WIDTH;

    for (Square square in groundSquares) {
      stackChildren.add(Positioned(
        left: square.x * width,
        top: square.y * width,
        child: Container(
          width: width - 1,
          height: width - 1,
          decoration: SquareDecoration(square.color),
        ),
      ));
    }

    for (Tetromino curTetromino in curTetrominos) {
      List<Square> fallingSquares =
          curTetromino.rotations[curTetromino.rotationIndex];
      for (Square square in fallingSquares) {
        stackChildren.add(
          Positioned(
            left: (square.x + curTetromino.x) * width,
            top: (square.y + curTetromino.y) * width,
            child: Container(
              width: width - 1,
              height: width - 1,
              decoration: SquareDecoration(square.color, curTetromino.isFrozen),
            )
          )
        );
      }
    }

    double antagonistLeftConstraint = width * GRID_WIDTH / 4;
    int oldIndex = Provider.of<GameData>(context).oldDropIndex();
    antagonistLeftConstraint = width * GRID_WIDTH / 4 * oldIndex - 5 * width;

    return Stack(children: [
      ...stackChildren,
      AnimatedPositioned(
        top: 0,
        left: antagonistLeftConstraint,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          height: width * 10,
          width: width * 10,
          child: const Antagonist(),
        ),
      ),
    ]);
  }
}
