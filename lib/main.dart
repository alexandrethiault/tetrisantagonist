import 'package:flame/animation.dart' as animation;
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';
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
              create: (context) => GameData(), child: const MainScreen()));
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
  Widget build(BuildContext context)  {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      backgroundColor: Colors.purpleAccent,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.black54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Flame.util.animationAsWidget(
                      Position(100, 43),
                      animation.Animation.sequenced('title.png', 10,
                          textureWidth: 100, textureHeight: 43, loop: false, stepTime: 0.2)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.7,
                    width: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, 'join');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 8,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'JOIN',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40),
                                  ),
                                  Icon(
                                    Icons.videogame_asset,
                                    color: Colors.white,
                                  )
                                ],
                              )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, 'host');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 8,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'HOST',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40),
                                  ),
                                  Icon(
                                    Icons.connected_tv,
                                    color: Colors.white,
                                  )
                                ],
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
