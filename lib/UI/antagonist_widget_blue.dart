// ignore: import_of_legacy_library_into_null_safe
import 'package:flame/animation.dart' as animation;

// ignore: import_of_legacy_library_into_null_safe
import 'package:flame/flame.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetrisserver/DataLayer/game_data.dart';
import 'package:tetrisserver/constants/ui_constants.dart';

class Antagonist_blue extends StatefulWidget {
  const Antagonist_blue({Key? key}) : super(key: key);

  @override
  _AntagonistState createState() => _AntagonistState();
}

class _AntagonistState extends State<Antagonist_blue> {

  @override
  Widget build(BuildContext context) {
    return FittedBox(
          fit : BoxFit.contain,
          child: Flame.util.animationAsWidget(
              Position(ANTAGONIST_WIDTH, ANTAGONIST_HEIGHT),
              animation.Animation.sequenced('Nemesis_blue.png', ANTAGONIST_AMOUNT,
                  textureWidth: ANTAGONIST_WIDTH, textureHeight: ANTAGONIST_HEIGHT)),
        );
  }
}
