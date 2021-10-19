import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:tetrisserver/DataLayer/tetromino.dart';
import 'package:tetrisserver/constants/ui_constants.dart';

import 'tetromino_widget.dart';

class PlayerControllerWidget extends StatefulWidget {
  const PlayerControllerWidget({Key? key}) : super(key: key);

  final DeviceType deviceType = DeviceType.player;

  @override
  _PlayerControllerWidgetState createState() => _PlayerControllerWidgetState();
}

class _PlayerControllerWidgetState extends State<PlayerControllerWidget> {
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  int selectedTetromino = 0;
  bool connected = false;
  PlayerRole role = PlayerRole.awaiting;
  late Device currentHost;
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;

  double energy = 0;
  Timer timer = Timer.periodic(DURATION, (timer) => {});

  List<Tetromino> tetrominos = [];

  Color playerColor = Colors.red;
  Color defaultTetroColor = Colors.black54;

  @override
  void initState() {
    super.initState();
    tetrominos = [
      Tetromino.random(defaultTetroColor),
      Tetromino.random(defaultTetroColor),
      Tetromino.random(defaultTetroColor),
      Tetromino.random(defaultTetroColor)
    ];
    timer = Timer.periodic(DURATION, incrementEnergy);
    init();
  }

  void incrementEnergy(Timer timer) {
    setState(() {
      energy = min(1, energy + energyIncrement);
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }



  lockTetromino(int id) {
    tetrominos[id].freeze();
  }

  void swapTetromino(int index, int index2) {
    if (index2 >= 0 && index2 < 4) {
      Tetromino temp = tetrominos[index];
      tetrominos[index] = tetrominos[index2];
      tetrominos[index2] = temp;
      selectedTetromino = index2;
    }
  }

  void sendCursed() {
    if (PayEnergy(0.7))
    setState(() {
      tetrominos[0] =
          Tetromino.fromType(7, defaultTetroColor, 0);
    });
  }

  void sendBomb() {
    if (PayEnergy(0.4))
    setState(() {
      tetrominos[0] =
          Tetromino.fromType(8, defaultTetroColor, 0);
    });
  }

  Widget foeInterface(double buttonSize) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8),
      color: Colors.black54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              bottom: buttonSize/2,
              left: 6*buttonSize/2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: energy > 0.5 ? playerColor : Colors.grey),
                onPressed: () => energy > 0.5 ? sendCombo() : null,
                child: Icon(Icons.arrow_drop_down_circle),
              )),
          Positioned(
              bottom: buttonSize/2,
              left: 4*buttonSize/2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: energy > 0.7 ? playerColor : Colors.grey),
                onPressed: () => energy > 0.7 ?  swithcFalling() : null,
                child: Icon(Icons.switch_left_rounded),
              )),
          Positioned(
            top: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  "You are the antagonist!\n Use your powers to outsmart the other\n players and make them lose!",
                  style: TextStyle(color: playerColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: buttonSize/2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Container(
                      color: Colors.black54,
                      width: buttonSize/4,
                      height: buttonSize*2,
                    ),
                    Container(
                      color: Colors.yellow,
                      width: buttonSize/4,
                      height: buttonSize*2*energy,
                    ),
                  ],
                ),
                SizedBox(width: 10,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: energy > 0.4 ? playerColor : Colors.grey),
                      onPressed: () => energy > 0.5 ? sendBomb() : null,
                      child: TetrominoWidget(
                          Tetromino.fromType(8, defaultTetroColor, 0), 10),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: energy > 0.7 ? playerColor : Colors.grey),
                      onPressed: () => energy > 0.5 ? sendCursed() : null,
                      child: TetrominoWidget(
                          Tetromino.fromType(7, defaultTetroColor, 0), 10),
                    ),
                  ],
                ),
                SizedBox(
                    width: buttonSize / 2,
                    child: FittedBox(
                        child: Icon(
                      Icons.double_arrow,
                      color: playerColor,
                    ))),
                SizedBox(
                  height: buttonSize,
                  width: buttonSize * 5,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tetrominos.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (index != 4) {
                            setState(() {
                              selectedTetromino = index;
                            });
                          }
                        },
                        child: Container(
                            height: buttonSize,
                            width: buttonSize,
                            decoration: BoxDecoration(
                                color: index == selectedTetromino
                                    ? Colors.white70
                                    : Colors.white24,
                                border: Border.all(
                                    width: index == 4 ? buttonSize / 10 : 0,
                                    color: Colors.black54)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TetrominoWidget(
                                    tetrominos[index], buttonSize / 6),
                                if (index == 4)
                                  Positioned(
                                      top: 0,
                                      child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text("next block"))),
                                if (index == selectedTetromino)
                                  Positioned(
                                    left: 0,
                                    width: buttonSize / 3,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          swapTetromino(selectedTetromino,
                                              selectedTetromino - 1);
                                        });
                                      },
                                      child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: const Icon(Icons.arrow_left)),
                                    ),
                                  ),
                                if (index == selectedTetromino)
                                  Positioned(
                                    right: 0,
                                    width: buttonSize / 3,
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            swapTetromino(selectedTetromino,
                                                selectedTetromino + 1);
                                          });
                                        },
                                        child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: const Icon(
                                              Icons.arrow_right,
                                            ))),
                                  ),
                                if (index == selectedTetromino)
                                  Positioned(
                                    top: buttonSize / 20,
                                    left: buttonSize / 20,
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            lockTetromino(selectedTetromino);
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black54,
                                                  offset: const Offset(
                                                    2.0,
                                                    2.0,
                                                  ),
                                                )
                                              ]),
                                          height: buttonSize / 4.5,
                                          width: buttonSize / 4,
                                          child: const Icon(
                                              Icons.lock_outline_rounded),
                                        )),
                                  ),
                              ],
                            )),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget controllerButton(double buttonSize, IconData icon) {
    return Container(
      height: buttonSize,
      width: buttonSize,
      decoration: BoxDecoration(
        color: playerColor,
        borderRadius: BorderRadius.circular(buttonSize / 3),
      ),
      child: GestureDetector(
        onTapDown: moveLeft,
        child: SizedBox(
            width: buttonSize / 2,
            height: buttonSize / 2,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(icon, color: Colors.black87),
            )),
      ),
    );
  }

  Widget playerInterface(double buttonSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10.0),
        color: Colors.white24,
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    "You are a player, \ncollaborate with your teammates \nto defeat the antagonist!",
                    style: TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                controllerButton(buttonSize * 1.2, Icons.arrow_back),
                SizedBox(
                  width: 5,
                ),
                controllerButton(buttonSize, Icons.rotate_left),
                Spacer(),
                controllerButton(buttonSize, Icons.rotate_right),
                SizedBox(
                  width: 5,
                ),
                controllerButton(buttonSize * 1.2, Icons.arrow_forward),
              ],
            ),
            SizedBox(
              height: buttonSize / 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget awaitingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text("searching for host..."),
          SizedBox(
            height: 10,
          ),
          SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color: Colors.white70,
              )),
        ],
      ),
    );
  }

  Widget p2pListView() {
    return Container(
      color: Colors.black54,
      width: 250,
      height: 100,
      child: getItemCount() == 0
          ? awaitingIndicator()
          : ListView.builder(
              itemCount: getItemCount(),
              itemBuilder: (context, index) {
                final device = devices[index];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                            onTap: () => _onTabItemListener(device),
                            child: Column(
                              children: [
                                Text(
                                  device.deviceName,
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  getStateName(device.state),
                                  style: TextStyle(
                                      color: getStateColor(device.state)),
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          )),
                          // Request connect
                          GestureDetector(
                            onTap: () => _onButtonClicked(device),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              padding: const EdgeInsets.all(8.0),
                              height: 35,
                              width: 100,
                              color:
                                  getButtonColor(device.state).withOpacity(0.6),
                              child: Center(
                                child: Text(
                                  getButtonStateName(device.state),
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      const Divider(
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
            Positioned(
              top: 100,
              child: connected
                  ? role == PlayerRole.player
                      ? playerInterface(MediaQuery.of(context).size.width / 7)
                      : foeInterface(MediaQuery.of(context).size.width / 7)
                  : const Text("You don't have a role yet."),
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

  void moveLeft(TapDownDetails details) {
    print("[ControllerWidget] Move left");
    nearbyService.sendMessage(currentHost.deviceId, "Left");
  }

  void moveRight(TapDownDetails details) {
    print("[ControllerWidget] Move right");
    nearbyService.sendMessage(currentHost.deviceId, "Right");
  }

  void rotateLeft(TapDownDetails details) {
    print("[ControllerWidget] Turn left");
    nearbyService.sendMessage(currentHost.deviceId, "TurnLeft");
  }

  void rotateRight(TapDownDetails details) {
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
            await Future.delayed(const Duration(microseconds: 200));
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
              title: const Text("Send message"),
              content: TextField(controller: myController),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Send"),
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

  void sendCombo() {
    nearbyService.sendMessage(currentHost.deviceId, "Antagonist:SendCombo");
  }

  void swithcFalling() {
    nearbyService.sendMessage(currentHost.deviceId, "Antagonist:SwitchFalling");
  }

  bool PayEnergy(double cost) {
    if (energy < cost) return false;
    setState(() {
      energy -= cost;
    });
    nearbyService.sendMessage(
        currentHost.deviceId, "Antagonist:updateEnergy" + energy.toString());
    return true;
  }

  void applyCommand(String command) {
    if (command.startsWith("id")) {
      playerColor = playerColors[int.parse(command[command.length - 1])];
    }
    if (command.startsWith("r")) // what role player has
    {
      setState(() => role = command.substring(2) == "PlayerRole.player"
          ? PlayerRole.player
          : PlayerRole.foe);
    }
    if (command.startsWith("WhatIsNext?")) {
      Tetromino t = tetrominos[3];
      setState(() {
        tetrominos.insert(
            0,
            Random().nextInt(15) == 1
                ? Tetromino.fromType(8, defaultTetroColor)
                : Tetromino.random(defaultTetroColor));
        if (tetrominos.length < 5)
          tetrominos.insert(0, Tetromino.random(defaultTetroColor));
        selectedTetromino = min(selectedTetromino + 1, 3);
      });
      nearbyService.sendMessage(
          currentHost.deviceId, "Antagonist:UpdateNextTetromino" + t.export());
    }
  }
}
