import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';

import 'my_decorations.dart';
import '../constants/ui_constants.dart';

// The energy bar widget

class EnergyBar extends StatefulWidget {
  const EnergyBar({Key? key}) : super(key: key);

  @override
  _EnergyBarState createState() => _EnergyBarState();
}

class _EnergyBarState extends State<EnergyBar> {
  @override
  Widget build(BuildContext context) {
    double energy = Provider.of<GameData>(context).energy;
    Color antagonistColor = playerColors[Provider.of<GameData>(context).antagonist];
    return AspectRatio(
      aspectRatio: 0.5,
      child: Container(
        decoration: const BoxDecoration(
          color: BACKGROUND_COLOR,
        ),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[ // divide widget width in 3 to make the bar look thin
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
                              topRight: Radius.circular(DEFAULT_BORDER_RADIUS-DEFAULT_BORDER_WIDTH)
                            ),
                            color: Colors.transparent
                          ),
                        )
                      ), // upper part of the energy bar (not filled)
                      Flexible(
                        flex: (energy*100+5).round(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(DEFAULT_BORDER_RADIUS-DEFAULT_BORDER_WIDTH)
                            ),
                            color: antagonistColor
                          ),
                        )
                      ) // lower part of the energy bar (filled)
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
