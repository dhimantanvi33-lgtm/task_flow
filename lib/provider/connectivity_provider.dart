import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOffline = false;
  bool get isOffline => _isOffline;

  void setOffline(bool value) {
    if (_isOffline == value) return;
    _isOffline = value;
    notifyListeners();
  }

  void toggle() => setOffline(!_isOffline);
}