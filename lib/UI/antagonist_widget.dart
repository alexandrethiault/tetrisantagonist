// ignore: import_of_legacy_library_into_null_safe
import 'package:flame/animation.dart' as animation;

// ignore: import_of_legacy_library_into_null_safe
import 'package:flame/flame.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flame/position.dart';
import 'package:flutter/material.dart';

class Antagonist extends StatefulWidget {
  const Antagonist({Key? key}) : super(key: key);

  @override
  _AntagonistState createState() => _AntagonistState();
}

class _AntagonistState extends State<Antagonist> {
  double WIDTH = 64;
  double HEIGHT = 64;
  double FRAME_WIDTH = 64;
  int AMOUNT = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 150,
        width: 150,
        child: FittedBox(
          fit : BoxFit.contain,
          child: Flame.util.animationAsWidget(
              Position(WIDTH, HEIGHT),
              animation.Animation.sequenced('../nemesis.png', AMOUNT,
                  textureWidth: WIDTH, textureHeight: HEIGHT)),
        ));
  }
}
