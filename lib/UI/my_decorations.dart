
import 'package:flutter/material.dart';

import '../constants/ui_constants.dart';

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