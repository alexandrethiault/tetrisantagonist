
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';

import 'ui_constants.dart';
// TODO mettre des FittedBox partout partout partout partout et le score sous le "Player"
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
          scoreContainer(0), const SizedBox(width: 5),
          scoreContainer(1), const SizedBox(width: 5),
          scoreContainer(2), const SizedBox(width: 5),
          scoreContainer(3),
        ],
      ),
    );
  }

  Container scoreContainer(int i) {
    bool isAntagonist = (Provider.of<GameData>(context).antagonist == i);
    Color normalColor = Provider.of<GameData>(context, listen: false).playerColors[i];

    Color scoreContainerColor = normalColor;
    return Container(
      decoration: BoxDecoration(
          color: scoreContainerColor,
          border: Border.all(
            width: 5.0,
            color: isAntagonist ? BORDERS_COLOR: normalColor,
          ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text(
              'Player ${i+1}: ${Provider.of<GameData>(context).scores[i]}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
