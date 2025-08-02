# MatchAPI Docker Setup

## Cấu hình đã thực hiện

### 1. Database Configuration
- Đã cập nhật connection string để sử dụng Internal IP của Google Cloud SQL: `10.61.48.3`
- Thêm `TrustServerCertificate=True` để bypass SSL certificate validation

### 2. Docker Configuration
- **Port mapping**: Container port 8080 → Host port 5000
- **Environment**: Development mode với Swagger UI enabled
- **Network**: Custom bridge network `match3-network`
- **Restart policy**: unless-stopped

### 3. API Configuration
- CORS đã được cấu hình để cho phép tất cả origins (phù hợp cho development)
- Swagger UI có sẵn tại: http://localhost:5000/swagger
- API endpoints: http://localhost:5000/api/

### 4. Mobile App Configuration
- Đã cập nhật `ApiService.dart` để kết nối với Docker container
- Base URL: `http://10.0.2.2:5000/api` (cho Android emulator)
- Cho iOS simulator: sử dụng `http://localhost:5000/api`

## Cách sử dụng

### Khởi động API
```bash
cd f:\Github\match3\MatchAPI
docker-compose up --build -d
```

### Hoặc sử dụng script
```bash
.\start-docker.bat
```

### Kiểm tra trạng thái
```bash
docker-compose ps
docker-compose logs -f server
```

### Dừng API
```bash
docker-compose down
```

### Hoặc sử dụng script
```bash
.\stop-docker.bat
```

## URLs quan trọng

- **API Base**: http://localhost:5000
- **Swagger UI**: http://localhost:5000/swagger
- **Health Check**: http://localhost:5000/api/health (nếu có)

## Mobile App URLs

### Android Emulator
- Base URL: `http://10.0.2.2:5000/api`

### iOS Simulator  
- Base URL: `http://localhost:5000/api`

### Real Device (cùng mạng WiFi)
- Base URL: `http://[YOUR_COMPUTER_IP]:5000/api`
- Để lấy IP của máy tính: `ipconfig` (Windows) hoặc `ifconfig` (Mac/Linux)

## Troubleshooting

### 1. Container không start
```bash
docker-compose logs server
```

### 2. Database connection issues
- Kiểm tra Internal IP của Google Cloud SQL
- Đảm bảo firewall rules cho phép kết nối từ máy host

### 3. Mobile app không kết nối được
- Android Emulator: sử dụng `10.0.2.2` thay vì `localhost`
- iOS Simulator: sử dụng `localhost` hoặc `127.0.0.1`
- Real device: sử dụng IP thực của máy tính

### 4. CORS issues
- API đã được cấu hình CORS cho phép tất cả origins
- Nếu vẫn có vấn đề, kiểm tra console trong mobile app

## Environment Variables

Các biến môi trường được định nghĩa trong file `.env`:
- `DB_SERVER=10.61.48.3`
- `DB_DATABASE=Match3Game`
- `DB_USER=sqlserver`
- `DB_PASSWORD=123`
- `ASPNETCORE_ENVIRONMENT=Development`

## Security Notes

⚠️ **Chú ý**: Cấu hình hiện tại phù hợp cho development. Đối với production:
1. Thay đổi CORS policy
2. Sử dụng HTTPS
3. Bảo mật database credentials
4. Cấu hình authentication/authorization
