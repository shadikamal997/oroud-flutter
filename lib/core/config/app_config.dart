class AppConfig {
  // For physical device: Use your Mac's IP address on the same WiFi network
  // Find your IP: ifconfig | grep "inet " | grep -v 127.0.0.1
  // For emulator: Use http://10.0.2.2:3000/api
  // For localhost testing: Use http://localhost:3000/api
  // With ADB reverse: Run `adb reverse tcp:3000 tcp:3000` then use localhost
  
  // ✅ PHYSICAL DEVICE: Using Mac's local IP (must be on same WiFi network)
  // Updated: 2026-02-24 - Current Mac IP: 192.168.1.99
  static const String baseUrl = "http://192.168.1.99:3000/api";
  
  // Alternative: Use ADB reverse (requires adb in PATH):
  // Run: adb reverse tcp:3000 tcp:3000
  // Then use: http://localhost:3000/api
}
