# Hướng dẫn cấu hình MatchAPI cho Multi-Device Setup

## 1. Cấu hình máy chủ Docker (Server)

### Bước 1: Kiểm tra IP của máy chủ
```cmd
ipconfig
```
Ghi nhớ IP của máy chủ (ví dụ: 192.168.1.100)

### Bước 2: Cấu hình Windows Firewall
1. Mở Windows Defender Firewall
2. Chọn "Advanced settings"
3. Tạo "Inbound Rule" mới:
   - Rule Type: Port
   - Protocol: TCP
   - Port: 5000
   - Action: Allow the connection
   - Profile: Domain, Private, Public
   - Name: MatchAPI Docker

### Bước 3: Khởi động Docker với cấu hình mạng
```cmd
cd f:\Github\match3\MatchAPI
docker-compose up -d
```

### Bước 4: Kiểm tra container đang chạy
```cmd
docker-compose ps
netstat -an | findstr :5000
```

## 2. Cấu hình Mobile App (Client)

### Cho Android Emulator trên cùng máy:
```dart
// Trong main.dart, thêm vào initState()
ApiConfig.configureForLocal();
```

### Cho Physical Device hoặc máy khác:
1. Cập nhật IP trong `api_service.dart`:
```dart
static const String _localPhysicalUrl = 'http://192.168.1.100:5000/api'; // Thay bằng IP thực của server
static const String _remoteUrl = 'http://192.168.1.100:5000/api'; // Thay bằng IP thực của server
```

2. Trong main.dart:
```dart
// Cho physical device trên cùng mạng LAN
ApiConfig.configureForPhysicalDevice('192.168.1.100');

// Hoặc cho remote server
ApiConfig.configureForRemote('192.168.1.100');
```

## 3. Kiểm tra kết nối

### Từ máy client:
```cmd
# Test kết nối
ping 192.168.1.100
telnet 192.168.1.100 5000

# Test API
curl http://192.168.1.100:5000/swagger
```

### Từ browser:
Truy cập: `http://192.168.1.100:5000/swagger`

## 4. Troubleshooting

### Lỗi thường gặp:
1. **Connection refused**: Kiểm tra firewall và port 5000
2. **Timeout**: Kiểm tra network connectivity
3. **404 Not Found**: Kiểm tra Docker container status

### Debug commands:
```cmd
# Kiểm tra Docker logs
docker-compose logs server

# Kiểm tra port listening
netstat -an | findstr :5000

# Kiểm tra container network
docker network ls
docker network inspect matchapi_match3-network
```

## 5. Production Setup (Optional)

### Sử dụng domain name:
1. Cấu hình DNS hoặc hosts file
2. Cập nhật URL trong `api_service.dart`
3. Cấu hình HTTPS với SSL certificate

### Load balancer setup:
1. Sử dụng nginx hoặc HAProxy
2. Multiple Docker instances
3. Health check endpoints
