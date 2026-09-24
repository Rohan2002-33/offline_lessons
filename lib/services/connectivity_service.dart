import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Stream<bool> get onStatusChange => Connectivity()
      .onConnectivityChanged
      .map((result) => result != ConnectivityResult.none);

  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}