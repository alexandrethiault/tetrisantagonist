import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';

import 'game_widget.dart';
import 'my_decorations.dart';
import '../constants/ui_constants.dart';

class EnergyBar extends StatefulWidget {
  const EnergyBar({Key? key}) : super(key: key);

  @override
  _EnergyBarState createState() => _EnergyBarState();
}

class _EnergyBarState extends State<EnergyBar> {
  @override
  Widget build(BuildContext context) {
    double energy = Provider.of<GameData>(context).energy;
    return AspectRatio(
      aspectRatio: 0.5,
      child: Container(
          decoration: const BoxDecoration(
            color: BACKGROUND_COLOR,//Colors.green,
          ),
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: EnergyBarDecoration(),
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          flex: 100-(energy*100).round(),
                          child: Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(DEFAULT_BORDER_RADIUS-DEFAULT_BORDER_WIDTH),
                                    topRight: Radius.circular(DEFAULT_BORDER_RADIUS-DEFAULT_BORDER_WIDTH)),
                                color: Colors.blue
                            ),
                          )
                        ),
                        Flexible(
                          flex: (energy*100).round(),
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(DEFAULT_BORDER_RADIUS-DEFAULT_BORDER_WIDTH),
                                      bottomRight: Radius.circular(DEFAULT_BORDER_RADIUS-DEFAULT_BORDER_WIDTH)),
                                  color: Colors.yellow
                              ),
                            )
                        )
                      ]
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          )
      ),
    );
  }
}
