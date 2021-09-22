import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider;

import 'DataLayer/game_data.dart';
import 'UI/main_screen.dart';


void main() => runApp(
  ChangeNotifierProvider(
    create: (context) => GameData(),
    child: const MyApp(),
  ),
);


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      title: 'Tetris Antagonist App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MainScreen(),
    );
  }
}

