import 'package:flutter/material.dart';

class TemaViewModel extends ChangeNotifier {
  ThemeMode _modo = ThemeMode.system;

  ThemeMode get modo => _modo;

  void cambiar(ThemeMode nuevo) {
    if (nuevo == _modo) return;
    _modo = nuevo;
    notifyListeners();
  }
}
