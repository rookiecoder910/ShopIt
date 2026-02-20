import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  // Set to true for local development with adb reverse, false for cloud (Render)
  static const bool useLocalBackend = false;

  static String get userServiceUrl {
    if (useLocalBackend) return '${_localBaseUrl}:8001';
    return 'https://shopit-user-service.onrender.com';
  }

  static String get productServiceUrl {
    if (useLocalBackend) return '${_localBaseUrl}:8002';
    return 'https://shopit-product-service.onrender.com';
  }

  static String get cartOrderServiceUrl {
    if (useLocalBackend) return '${_localBaseUrl}:8003';
    return 'https://shopit-cart-order-service.onrender.com';
  }

  static String get deliveryServiceUrl {
    if (useLocalBackend) return '${_localBaseUrl}:8004';
    return 'https://shopit-delivery-service.onrender.com';
  }

  static String get _localBaseUrl {
    if (kIsWeb) return 'http://localhost';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://127.0.0.1';
    return 'http://localhost';
  }
}
