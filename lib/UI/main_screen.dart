
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';

import 'antagonist_widget.dart';
import 'energy_bar.dart';
import 'game.dart';
import 'next_tetromino.dart';
import 'round_number.dart';
import 'scores.dart';
import 'start_stop.dart';
import 'ui_constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<GameWidgetState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tetris Antagonist"),
        centerTitle: true,
      ),
      backgroundColor: BACKGROUND_COLOR,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Scores(),
            //const Antagonist(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    flex: GRID_TO_SIDEBAR_RATIO,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DEFAULT_BORDER_WIDTH*4,
                        DEFAULT_BORDER_WIDTH*4,
                        DEFAULT_BORDER_WIDTH*2,
                        DEFAULT_BORDER_WIDTH*4
                      ),
                      child: GameWidget(key: _key),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DEFAULT_BORDER_WIDTH*2,
                        DEFAULT_BORDER_WIDTH*4,
                        DEFAULT_BORDER_WIDTH*4,
                        DEFAULT_BORDER_WIDTH*4
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const <Widget>[
                          NextTetromino(),
                          SizedBox(height: 30),
                          EnergyBar(),
                          SizedBox(height: 30),
                          RoundNumber(),
                          SizedBox(height: 30),
                          StartStop(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}