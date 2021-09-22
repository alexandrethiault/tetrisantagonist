import 'dart:async';

import 'package:tetrisserver/BLoC/bloc.dart';
import 'package:tetrisserver/DataLayer/square.dart';

class SquareQueryBloc implements Bloc {
  final _controller = StreamController<List<Square>>();
  Stream<List<Square>> get locationStream => _controller.stream;

  void submitQuery(String query) async {
    final results = [Square(0,0)];
    _controller.sink.add(results);
  }

  @override
  void dispose() {
    _controller.close();
  }
}