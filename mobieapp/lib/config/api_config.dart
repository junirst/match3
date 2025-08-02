import '../services/api_service.dart';

class ApiConfig {
  // Method to configure API based on deployment scenario
  static void configureForLocal() {
    // For running on emulator with local Docker
    ApiService.setEnvironment('local_emulator');
  }

  static void configureForPhysicalDevice(String hostIP) {
    // Update the IP in api_service.dart first, then call this
    ApiService.setEnvironment('local_physical');
  }

  static void configureForRemote(String remoteIP) {
    // Update the IP in api_service.dart first, then call this
    ApiService.setEnvironment('remote');
  }
}

// Usage examples:
// 1. For Android emulator with local Docker:
//    ApiConfig.configureForLocal();
//
// 2. For physical device connecting to local Docker:
//    ApiConfig.configureForPhysicalDevice('192.168.1.100');
//
// 3. For connecting to remote server:
//    ApiConfig.configureForRemote('203.0.113.1');
