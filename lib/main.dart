import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider;
import 'package:tetrisserver/UI/controller_widget.dart';

import 'DataLayer/game_data.dart';
import 'UI/main_screen.dart';


void main() => runApp(
  const MyApp(),
);

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => Home());
    case 'join':
      return MaterialPageRoute(
          builder: (_) => PlayerControllerWidget());
    case 'host':
      return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
              create: (context) => GameData(),
              child: MainScreen()));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
                child: Text('No route defined for ${settings.name}')),
          ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'join');
              },
              child: Container(
                color: Colors.red,
                child: Center(
                    child: Text(
                      'JOIN',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    )),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'host');
              },
              child: Container(
                color: Colors.green,
                child: Center(
                    child: Text(
                      'HOST',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
