import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';
import 'package:tetrisserver/DataLayer/tetromino.dart';

import 'my_decorations.dart';
import '../constants/ui_constants.dart';

// Next tetromino widget, showing the next tetromino to enter the main game grid

class NextTetromino extends StatefulWidget {
  const NextTetromino({Key? key}) : super(key: key);

  @override
  _NextTetrominoState createState() => _NextTetrominoState();
}

class _NextTetrominoState extends State<NextTetromino> {
  final GlobalKey _keyInnerWidget = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: GameBoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: SIZED_BOX_SIZE),
          const Text(
            'Next',
            style: TextStyle(
              color: BORDERS_COLOR,
              fontWeight: FontWeight.bold,
              fontFamily: FONT,
            ),
          ),
          const SizedBox(height: SIZED_BOX_SIZE),
          Padding(
            padding: const EdgeInsets.all(DEFAULT_BORDER_WIDTH),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                key: _keyInnerWidget,
                decoration: GameBoxDecoration(DEFAULT_BORDER_RADIUS-2*DEFAULT_BORDER_WIDTH),
                child: Center(
                  child: nextTetrominoWidget(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget nextTetrominoWidget() {
    if (!Provider.of<GameData>(context).isLaunched) return Container();

    Tetromino nextTetromino = Tetromino.nullTetromino();
    List<Tetromino> nextTetrominos = Provider.of<GameData>(context).nextTetrominos;
    if (nextTetrominos.isEmpty) {
      return Container();
    } else {
      nextTetromino = nextTetrominos[0];
    }
    int minX = nextTetromino.minX;
    int maxX = nextTetromino.maxX;
    int minY = nextTetromino.minY;
    int maxY = nextTetromino.maxY;
    Color color;
    final RenderBox renderBoxInnerWidget =
      _keyInnerWidget.currentContext!.findRenderObject() as RenderBox;
    double width = renderBoxInnerWidget.size.width * 0.22;

    List<Widget> columns = [];
    for (int y = minY; y <= maxY; ++y) {
      List<Widget> rows = [];
      for (int x = minX; x <= maxX; ++x) {
        color = Colors.transparent;
        for (var square in nextTetromino.baseSquares) {
          if (square.x == x && square.y == y) {
            color = nextTetromino.color;
            break;
          }
        }

        if (color == Colors.transparent) {
          rows.add(Container(width: width, height: width, color: color));
        } else {
          rows.add(Container(width: width, height: width,
                decoration: SquareDecoration(color, nextTetromino.isFrozen)));
        }
      }

      columns.add(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rows
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: columns,
    );
  }
}
