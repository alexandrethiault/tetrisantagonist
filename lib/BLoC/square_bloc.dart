import 'dart:async';

import 'package:tetrisserver/DataLayer/square.dart';

import 'bloc.dart';

class TestBloc implements Bloc {
  Square _square = Square(0,0);
  Square get selectedSquare => _square;

  final _squareController = StreamController<Square>();

  Stream<Square> get squareStream => _squareController.stream;

  void selectSquare(Square square) {
    _square = square;
    _squareController.sink.add(square);
  }

  // 4
  @override
  void dispose() {
    _squareController.close();
  }
}