## Quick Setup Scripts

### Server Setup (Windows PowerShell)
```powershell
# Lấy IP của máy hiện tại
$serverIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi" | Where-Object {$_.IPAddress -like "192.168.*"}).IPAddress
Write-Host "Server IP: $serverIP"

# Mở firewall cho port 5000
New-NetFirewallRule -DisplayName "MatchAPI Docker" -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow

# Start Docker
Set-Location "f:\Github\match3\MatchAPI"
docker-compose up -d

# Kiểm tra
docker-compose ps
netstat -an | findstr :5000
Write-Host "API accessible at: http://$serverIP:5000/swagger"
```

### Client Setup (Update mobile app)
```dart
// File: lib/core/api_config.dart
class ApiConfig {
  static void configureForRemoteServer(String serverIP) {
    // Update API service with server IP
    ApiService.setBaseUrl('http://$serverIP:5000/api');
  }
}

// File: lib/main.dart
void main() {
  // Thay 'SERVER_IP_HERE' bằng IP thực của server
  ApiConfig.configureForRemoteServer('192.168.1.100');
  runApp(MyApp());
}
```
