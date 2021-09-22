import 'package:flutter/material.dart';

abstract class Bloc {
  void dispose();
}
/*
class BlocProvider<T extends Bloc> extends StatefulWidget {
  final Widget child;
  final T bloc;

  BlocProvider({Key? key, required this.child, required this.bloc})
      : super(key: key);

  static T of<T extends Bloc>(BuildContext context) {
    final type = _providerType<BlocProvider<T>>();
    final BlocProvider<T> provider = findAncestorWidgetOfExactType(type);
    return provider.bloc;
  }

  static Type _providerType<T>() => T;

  @override
  State createState() => _BlocProviderState();
}
class _BlocProviderState extends State<BlocProvider> {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}
*/