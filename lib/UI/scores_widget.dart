
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';

import '../constants/ui_constants.dart';

// The widget that shows all players' scores

class Scores extends StatefulWidget {
  const Scores({Key? key}) : super(key: key);

  @override
  _ScoresState createState() => _ScoresState();
}

class _ScoresState extends State<Scores> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BACKGROUND_COLOR
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          scoreContainer(0), SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          scoreContainer(1), SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          scoreContainer(2), SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          scoreContainer(3),
        ],
      ),
    );
  }

  Container scoreContainer(int i) {
    bool isAntagonist = (Provider.of<GameData>(context).antagonist == i);
    Color normalColor = playerColors[i];

    Color scoreContainerColor = normalColor;
    return Container(
      decoration: BoxDecoration(
          color: scoreContainerColor,
          border: Border.all(
            width: 5.0,
            color: isAntagonist ? BORDERS_COLOR: normalColor,
          ),
      ),
      width: MediaQuery.of(context).size.width * 0.20,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: FittedBox(
          child: Text(
            'Player ${i+1}\n${Provider.of<GameData>(context).scores[i]}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
