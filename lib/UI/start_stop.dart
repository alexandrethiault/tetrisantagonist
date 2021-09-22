
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';

import 'my_decorations.dart';
import 'ui_constants.dart';

class StartStop extends StatefulWidget {
  const StartStop({Key? key}) : super(key: key);

  @override
  _StartStopState createState() => _StartStopState();
}

class _StartStopState extends State<StartStop> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: GameBoxDecoration(),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),

        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            Provider.of<GameData>(context).isLaunched ? 'Stop' : 'Start',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: FONT,
              color: BORDERS_COLOR,
            ),
          ),
        ),
        onPressed: () {
          var data = Provider.of<GameData>(context, listen: false);
          data.isLaunched ? data.endGame() : data.startGame(MediaQuery.of(context).size.width);
        },
      ),
    );
  }
}


