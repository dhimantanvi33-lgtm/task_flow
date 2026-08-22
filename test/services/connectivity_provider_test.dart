import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/provider/connectivity_provider.dart';
import 'package:task_flow/service/connectivity_service.dart';

void main() {
  test('toggle flips offline, updates the shared service, and notifies', () {
    final service = ConnectivityService();
    final provider = ConnectivityProvider(service);
    var notifications = 0;
    provider.addListener(() => notifications++);

    expect(provider.isOffline, false);

    provider.toggle();
    expect(provider.isOffline, true);
    expect(service.isOffline, true);
    expect(notifications, 1);

    provider.setOffline(true);
    expect(notifications, 1);

    provider.setOffline(false);
    expect(provider.isOffline, false);
    expect(notifications, 2);
  });
}