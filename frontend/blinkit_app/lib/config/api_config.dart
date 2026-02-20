import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost';
    }
    // Android emulator uses 10.0.2.2 to reach host machine's localhost
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2';
    }
    // iOS simulator / desktop
    return 'http://localhost';
  }

  static String get userServiceUrl => '$baseUrl:8001';
  static String get productServiceUrl => '$baseUrl:8002';
  static String get cartOrderServiceUrl => '$baseUrl:8003';
  static String get deliveryServiceUrl => '$baseUrl:8004';
}
