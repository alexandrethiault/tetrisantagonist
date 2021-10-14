import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:tetrisserver/DataLayer/tetromino.dart';
import 'package:tetrisserver/UI/next_tetromino.dart';
import 'package:tetrisserver/constants/ui_constants.dart';

import 'Tetromino.dart';

class PlayerControllerWidget extends StatefulWidget {
  const PlayerControllerWidget({Key? key}) : super(key: key);

  final DeviceType deviceType = DeviceType.player;

  @override
  _PlayerControllerWidgetState createState() => _PlayerControllerWidgetState();
}

class _PlayerControllerWidgetState extends State<PlayerControllerWidget> {
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  bool connected = false;
  PlayerRole role = PlayerRole.awaiting;
  late Device currentHost;
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;

  List<Tetromino> tetrominos = [];

  Color playerColor = Colors.red;

  @override
  void initState() {
    super.initState();
    tetrominos = [Tetromino.random(playerColor), Tetromino.random(playerColor), Tetromino.random(playerColor), Tetromino.random(playerColor)];
    init();
  }

  @override
  void dispose() {
    subscription.cancel();
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  Widget foeInterface() {
    return Container(
      color: Colors.black,
      child: Center(
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tetrominos.length,
            itemBuilder: (context, index) {
              return Container(
                  height: 100,
                  width: 100,
                  child: Center(
                      child: TetrominoWidget(tetrominos[index], 50)));
            },
        ),
      ),
    );
  }

  Widget playerInterface(double buttonSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          InkWell(
            onTap: moveLeft,
            child: Container(
                width: buttonSize,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.arrow_back_ios),
                )),
          ),
          InkWell(
            onTap: rotateLeft,
            child: Container(
                width: buttonSize,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.rotate_left),
                )),
          ),
          Spacer(),
          InkWell(
            onTap: rotateRight,
            child: Container(
                width: buttonSize,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.rotate_right),
                )),
          ),
          InkWell(
            onTap: moveRight,
            child: Container(
                width: buttonSize,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.arrow_forward_ios),
                )),
          ),
        ],
      ),
    );
  }

  Widget p2pListView() {
    return Container(
      color: Colors.white54,
      width: 250,
      height: 100,
      child: ListView.builder(
          itemCount: getItemCount(),
          itemBuilder: (context, index) {
            final device = devices[index];
            return Container(
              margin: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                        onTap: () => _onTabItemListener(device),
                        child: Column(
                          children: [
                            Text(device.deviceName),
                            Text(
                              getStateName(device.state),
                              style:
                                  TextStyle(color: getStateColor(device.state)),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      )),
                      // Request connect
                      GestureDetector(
                        onTap: () => _onButtonClicked(device),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          padding: EdgeInsets.all(8.0),
                          height: 35,
                          width: 100,
                          color: getButtonColor(device.state),
                          child: Center(
                            child: Text(
                              getButtonStateName(device.state),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey,
                  )
                ],
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: playerColor,
          child: Stack(alignment: Alignment.topCenter, children: [
            Center(
              child: connected
                  ? role == PlayerRole.player
                      ? playerInterface(MediaQuery.of(context).size.width / 6)
                      : foeInterface()
                  : Text("Awaiting for role"),
            ),
            Positioned(
              top: 0,
              child: p2pListView(),
            ),
          ]),
        ),
      ),
    );
  }

  void moveLeft() {
    print("[ControllerWidget] Move left");
    nearbyService.sendMessage(currentHost.deviceId, "Left");
  }

  void moveRight() {
    print("[ControllerWidget] Move right");
    nearbyService.sendMessage(currentHost.deviceId, "Right");
  }

  void rotateLeft() {
    print("[ControllerWidget] Turn left");
    nearbyService.sendMessage(currentHost.deviceId, "TurnLeft");
  }

  void rotateRight() {
    print("[ControllerWidget] Turn right");
    nearbyService.sendMessage(currentHost.deviceId, "TurnRight");
  }

  void init() async {
    nearbyService = NearbyService();
    String devInfo = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devInfo = androidInfo.model!;
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devInfo = iosInfo.localizedModel!;
    }
    await nearbyService.init(
        serviceType: 'mpconn',
        deviceName: devInfo,
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          if (isRunning) {
            await nearbyService.stopBrowsingForPeers();
            await Future.delayed(Duration(microseconds: 200));
            await nearbyService.startBrowsingForPeers();
          }
        });
    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        print(
            " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            nearbyService.stopBrowsingForPeers();
          } else {
            nearbyService.startBrowsingForPeers();
          }
        }
      });

      setState(() {
        devices.clear();
        devices.addAll(devicesList);
        connectedDevices.clear();
        connectedDevices.addAll(devicesList
            .where((d) => d.state == SessionState.connected)
            .toList());
      });
    });

    receivedDataSubscription =
        nearbyService.dataReceivedSubscription(callback: (data) {
      print("dataReceivedSubscription: ${jsonEncode(data)}");
      applyCommand(Message.fromJson(data).message.toString());
      showToast(jsonEncode(data),
          context: context,
          axis: Axis.horizontal,
          alignment: Alignment.center,
          position: StyledToastPosition.bottom);
    });
  }

  String getStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  String getButtonStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }

  Color getStateColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Colors.black;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Color getButtonColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  _onTabItemListener(Device device) {
    if (device.state == SessionState.connected) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            final myController = TextEditingController();
            return AlertDialog(
              title: Text("Send message"),
              content: TextField(controller: myController),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Send"),
                  onPressed: () {
                    nearbyService.sendMessage(
                        device.deviceId, myController.text);
                    myController.text = '';
                  },
                )
              ],
            );
          });
    }
  }

  int getItemCount() {
    return devices.length;
  }

  _onButtonClicked(Device device) {
    switch (device.state) {
      case SessionState.notConnected:
        nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );
        currentHost = device;
        connected = true;
        break;
      case SessionState.connected:
        nearbyService.disconnectPeer(deviceID: device.deviceId);
        connected = false;
        break;
      case SessionState.connecting:
        break;
    }
  }

  void applyCommand(String command) {
    if (command.startsWith("id")) {
      playerColor = playerColors[int.parse(command[command.length - 1])];
    }
    ;
    if (command.startsWith("r")) // what role player has
    {
      setState(() => role = command.substring(2) == "PlayerRole.player" ? PlayerRole.player: PlayerRole.foe);
    }
  }
}
