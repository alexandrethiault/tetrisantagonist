
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';

import 'antagonist_widget.dart';
import 'energy_bar.dart';
import 'game_widget.dart';
import 'next_tetromino.dart';
import 'p2p_widget.dart';
import 'round_number.dart';
import 'scores_widget.dart';
import 'start_stop.dart';
import '../constants/ui_constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<GameWidgetState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitUp,
    ]);
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
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    Row(
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
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                            height: 200,
                            child: DevicesListScreen(deviceType: DeviceType.host)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}