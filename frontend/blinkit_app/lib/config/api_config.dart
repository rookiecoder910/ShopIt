import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost';
    }
    // Android (emulator & physical): use 127.0.0.1 with adb reverse port forwarding
    // Run: adb reverse tcp:8001 tcp:8001 (repeat for 8002, 8003, 8004)
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://127.0.0.1';
    }
    // iOS simulator / desktop
    return 'http://localhost';
  }

  static String get userServiceUrl => '$baseUrl:8001';
  static String get productServiceUrl => '$baseUrl:8002';
  static String get cartOrderServiceUrl => '$baseUrl:8003';
  static String get deliveryServiceUrl => '$baseUrl:8004';
}
