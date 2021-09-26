import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'p2p_widget.dart';

class PlayerControllerWidget extends StatefulWidget {
  PlayerControllerWidget({Key? key}) : super(key: key);

  @override
  _PlayerControllerWidgetState createState() => _PlayerControllerWidgetState();
}

class _PlayerControllerWidgetState extends State<PlayerControllerWidget> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
              flex: 1,
              child: InkWell(
                onTap: moveLeft,
                child: Container(
                    width: 100,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(Icons.arrow_back_ios),
                    )),
              ),
            ),
            Expanded(
                flex: 4,
                child: GestureDetector(
                  child: Container(
                    child: DevicesListScreen(deviceType: DeviceType.player),
                  ),
                )),
            Flexible(
              flex: 1,
              child: InkWell(
                onTap: moveRight,
                child: Container(
                    width: 100,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(Icons.arrow_forward_ios),
                    )),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void moveLeft() {
    print("[ControllerWidget] Move left");
  }

  void moveRight() {
    print("[ControllerWidget] Move right");
  }
}
