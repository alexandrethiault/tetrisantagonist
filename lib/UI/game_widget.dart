import 'package:flame/animation.dart' as animation;
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/ui_constants.dart';
import '../DataLayer/game_data.dart';
import '../DataLayer/square.dart';
import '../DataLayer/tetromino.dart';
import 'antagonist_widget_blue.dart';
import 'antagonist_widget_green.dart';
import 'antagonist_widget_red.dart';
import 'antagonist_widget_yellow.dart';
import 'my_decorations.dart';

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
    List<Positioned> squareChildren = <Positioned>[];
    List<Square> groundSquares = Provider.of<GameData>(context).groundSquares;
    List<Tetromino> curTetrominos =
        Provider.of<GameData>(context).curTetrominos;
    int antagId = Provider.of<GameData>(context).antagonist;
    if (groundSquares.isEmpty && curTetrominos.isEmpty) {
      return Stack(children: squareChildren);
    }

    final RenderBox renderBoxTetris =
        _keyGameWidget.currentContext!.findRenderObject() as RenderBox;
    double width =
        (renderBoxTetris.size.width - 2 * DEFAULT_BORDER_WIDTH) / GRID_WIDTH;

    for (Square square in groundSquares) {
      squareChildren.add(Positioned(
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
        squareChildren.add(
          Positioned(
            left: (square.x + curTetromino.x) * width,
            top: (square.y + curTetromino.y) * width,
            child: Container(
              width: width - 1,
              height: width - 1,
              decoration: SquareDecoration(square.color, curTetromino.isFrozen, curTetromino.isBomb),
            )
          )
        );
      }
    }

    int oldIndex = Provider.of<GameData>(context).oldDropIndex();
    double antagOffset = width * GRID_WIDTH / 4 * oldIndex - 5 * width;
    double laserLeftConstraint = width * GRID_WIDTH / 4 * oldIndex - 4 * width;

    List<Widget> stackChildren = [
      ...squareChildren,
      visibilityWidget(antagId == 0, const AntagonistRed(), antagOffset, width),
      visibilityWidget(antagId == 1, const AntagonistBlue(), antagOffset, width),
      visibilityWidget(antagId == 2, const AntagonistGreen(), antagOffset, width),
      visibilityWidget(antagId == 3, const AntagonistYellow(), antagOffset, width),
    ];

    int step = Provider.of<GameData>(context).lineBeingDeletedStep;
    if (step > 0) {
      stackChildren.add(Positioned(
          left: laserLeftConstraint,
          top: width * (GRID_HEIGHT - 18),
          child: SizedBox(
            height: width * 16,
            width: width * 8,
            child: Flame.util.animationAsWidget(
              Position(width * 8, width * 16),
              animation.Animation.sequenced('laser.png', 6,
                  textureWidth: 50, textureHeight: 100,
                  textureX: (step-1) * 150,
                  loop: false, stepTime: 0.1)
          ))
      ));
      stackChildren.add(Positioned(
        top: 0,
        left: antagOffset,
          child: SizedBox(
            height: width * 10,
            width: width * 10,
            child: FittedBox(
              fit : BoxFit.contain,
              child: Flame.util.animationAsWidget(
                  Position(ANTAGONIST_WIDTH, ANTAGONIST_HEIGHT),
                  animation.Animation.sequenced('Nemesis_damage.png', ANTAGONIST_AMOUNT,
                      textureWidth: ANTAGONIST_WIDTH, textureHeight: ANTAGONIST_HEIGHT)),
            ),
          ),
      ));
    }

    return Stack(children: stackChildren);
  }

  Visibility visibilityWidget(bool visible, Widget antagonistWidget,
      double antagonistLeftConstraint, double width) {
    return Visibility(
      visible: visible,
      child: AnimatedPositioned(
        top: 0,
        left: antagonistLeftConstraint,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          height: width * 10,
          width: width * 10,
          child: antagonistWidget,
        ),
      ),
    );
  }
}
