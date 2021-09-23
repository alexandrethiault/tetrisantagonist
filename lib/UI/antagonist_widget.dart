
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';

import '../constants/ui_constants.dart';

class Antagonist extends StatefulWidget {
  const Antagonist({Key? key}) : super(key: key);

  @override
  _AntagonistState createState() => _AntagonistState();
}

class _AntagonistState extends State<Antagonist> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: BACKGROUND_COLOR,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Image(image: AssetImage('assets/antagonistlol.png'))
              ),
            )
          ),
          Flexible(
              flex: 1,
              child: Container()
          )
        ],
      ),
    );
  }

}
