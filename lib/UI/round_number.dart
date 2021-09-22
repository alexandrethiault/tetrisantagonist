import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';

import 'my_decorations.dart';
import 'ui_constants.dart';

class RoundNumber extends StatefulWidget {
  const RoundNumber({Key? key}) : super(key: key);

  @override
  _RoundNumberState createState() => _RoundNumberState();
}

class _RoundNumberState extends State<RoundNumber> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: GameBoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: SIZED_BOX_SIZE),
          const Text(
            'Round',
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
                decoration: GameBoxDecoration(DEFAULT_BORDER_RADIUS-2*DEFAULT_BORDER_WIDTH),
                child: Center(
                  child: Text(
                    Provider.of<GameData>(context).roundNumber.toString(),
                    style: const TextStyle(
                        color: BORDERS_COLOR,
                        fontWeight: FontWeight.bold,
                        fontFamily: FONT,
                        fontSize: 32
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}