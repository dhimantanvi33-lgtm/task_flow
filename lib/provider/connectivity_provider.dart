import 'package:flutter/foundation.dart';
import '../service/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider(this._service);
  final ConnectivityService _service;

  bool get isOffline => _service.isOffline;

  void setOffline(bool value) {
    if (_service.isOffline == value) return;
    _service.isOffline = value;
    notifyListeners();
  }

  void toggle() => setOffline(!_service.isOffline);
}