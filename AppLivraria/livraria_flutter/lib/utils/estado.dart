import 'package:flutter/material.dart';
import 'package:flutter_livraria_1/utils/autenticador.dart';

class EstadoApp extends ChangeNotifier {
  bool _logado = false;

  bool get logado => _logado;

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  set usuario(Usuario? usuario) {
    _usuario = usuario;
  }

  void onLogin(Usuario usuario) {
    _usuario = usuario;

    notifyListeners();
  }

  void onLogout() {
    _usuario = null;

    notifyListeners();
  }
}

late EstadoApp estadoApp;
