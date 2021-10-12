
import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

// A few box decorations that are going to be used in several places

BoxDecoration GameBoxDecoration([double radius=DEFAULT_BORDER_RADIUS]) => BoxDecoration(
  color: Colors.black,
  border: Border.all(
    width: DEFAULT_BORDER_WIDTH,
    color: BORDERS_COLOR,
  ),
  borderRadius: BorderRadius.all(Radius.circular(radius)),
);

BoxDecoration EnergyBarDecoration([double radius=DEFAULT_BORDER_RADIUS]) => BoxDecoration(
  border: Border.all(
    width: DEFAULT_BORDER_WIDTH,
    color: BORDERS_COLOR,
  ),
  borderRadius: BorderRadius.all(Radius.circular(radius)),
);

BoxDecoration SquareDecoration(Color squareColor, [bool frozen=false]) => BoxDecoration(
  border: Border.all(
    color: (frozen) ? squareFrozenColor : squareBorderColor,
    width: squareBorderWidth,
  ),
  color: squareColor
);