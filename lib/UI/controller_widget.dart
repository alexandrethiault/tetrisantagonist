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
    init();
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

  Widget foeInterface() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black54,
      child: Column(
        children: [
          const Text(
            "You are the antagonist !",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 50,
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        swapTetromino(selectedTetromino, selectedTetromino - 1);
                      });
                    },
                    child: Container(
                        color: Colors.grey,
                        child: const Icon(Icons.arrow_left))),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        lockTetromino(selectedTetromino);
                      });
                    },
                    child: Container(
                        color: Colors.grey,
                        child: const Icon(Icons.lock_outline_rounded))),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        swapTetromino(selectedTetromino, selectedTetromino + 1);
                      });
                    },
                    child: Container(
                        color: Colors.grey,
                        child: const Icon(Icons.arrow_right))),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tetrominos[selectedTetromino] =
                          Tetromino.fromType(7, defaultTetroColor, 0);
                    });
                  },
                  child: Container(
                      color: Colors.grey,
                      child: TetrominoWidget(
                          Tetromino.fromType(7, defaultTetroColor, 0), 10)),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.8,
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
                      decoration: BoxDecoration(
                          color: index == selectedTetromino
                              ? Colors.white70
                              : Colors.white24,
                          border: Border.all(
                              width: index == 4 ? 8 : 0,
                              color: Colors.black54)),
                      height: 100,
                      width: 100,
                      child: Center(
                          child: TetrominoWidget(tetrominos[index], 20))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget playerInterface(double buttonSize) {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8.0),
      color: Colors.white24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: moveLeft,
            child: SizedBox(
                width: buttonSize,
                child: const FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.arrow_back_ios),
                )),
          ),
          InkWell(
            onTap: rotateLeft,
            child: SizedBox(
                width: buttonSize,
                child: const FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.rotate_left),
                )),
          ),
          const Spacer(),
          InkWell(
            onTap: rotateRight,
            child: SizedBox(
                width: buttonSize,
                child: const FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.rotate_right),
                )),
          ),
          InkWell(
            onTap: moveRight,
            child: SizedBox(
                width: buttonSize,
                child: const FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(Icons.arrow_forward_ios),
                )),
          ),
        ],
      ),
    );
  }

  Widget awaitingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text("searching for host..."),
          SizedBox(height: 10,),
          SizedBox(height: 30, width: 30, child: CircularProgressIndicator(color: Colors.white70,)),
        ],
      ),
    );
  }

  Widget p2pListView() {
    return Container(
      color: Colors.white54,
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
                                Text(device.deviceName),
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
                              color: getButtonColor(device.state),
                              child: Center(
                                child: Text(
                                  getButtonStateName(device.state),
                                  style: const TextStyle(
                                      color: Colors.white,
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
                      ? playerInterface(MediaQuery.of(context).size.width / 6)
                      : foeInterface()
                  : const Text("Awaiting for role"),
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

  void syncEnergy(int energy) {
    nearbyService.sendMessage(
        currentHost.deviceId, "Antagonist:updateEnergy" + energy.toString());
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
        tetrominos.removeAt(tetrominos.length - 1);
        tetrominos.insert(0, Tetromino.random(defaultTetroColor));
        if (tetrominos.length < 5)
          tetrominos.insert(0, Tetromino.random(defaultTetroColor));
      });
      nearbyService.sendMessage(
          currentHost.deviceId, "Antagonist:UpdateNextTetromino" + t.export());
    }
  }
}
