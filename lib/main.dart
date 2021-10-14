import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider;
import 'package:tetrisserver/UI/controller_widget.dart';

import 'DataLayer/controller_data.dart';
import 'DataLayer/game_data.dart';
import 'UI/main_screen.dart';

void main() => runApp(
  const MyApp(),
);

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const Home());
    case 'join':
      return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
              create: (context) => ControllerData(),
              child: const PlayerControllerWidget()));
    case 'host':
      return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
              create: (context) => GameData(),
              child: const MainScreen()));
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
    return const MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'join');
              },
              child: Container(
                color: Colors.green,
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'JOIN',
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                        Icon(Icons.videogame_asset, color: Colors.white,)
                      ],
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
                color: Colors.orange,
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'HOST',
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                        Icon(Icons.connected_tv, color: Colors.white,)
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
