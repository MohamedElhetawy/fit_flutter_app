import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CustomNetworkStatus { notDetermined, on, off }

final connectivityStatusProvider =
    StateNotifierProvider<ConnectivityStatusNotifier, CustomNetworkStatus>(
        (ref) {
  return ConnectivityStatusNotifier();
});

class ConnectivityStatusNotifier extends StateNotifier<CustomNetworkStatus> {
  ConnectivityStatusNotifier() : super(CustomNetworkStatus.notDetermined) {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet)) {
        state = CustomNetworkStatus.on;
      } else {
        state = CustomNetworkStatus.off;
      }
    });

    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      state = CustomNetworkStatus.on;
    } else {
      state = CustomNetworkStatus.off;
    }
  }
}
