# 📱 NovelVault (Tủ Truyện) - PRM393 Group 5

> **Đồ án môn Lập trình thiết bị di động (PRM393) - Đại học FPT**  
> Hệ thống ứng dụng đọc truyện di động đa nền tảng (Flutter) kết hợp máy chủ REST API (Spring Boot 3) và cơ sở dữ liệu MySQL 8.0.

---

## 📂 1. Cấu trúc thư mục dự án

```text
prm393_project_g5/
├── backend/                  # REST API Server (Java 21, Spring Boot 3.5.6, Spring Security, JWT)
│   ├── database.sql          # Script khởi tạo bảng & dữ liệu mẫu cho MySQL
│   ├── src/                  # Mã nguồn Java (Controllers, Services, Repositories, Models)
│   ├── pom.xml               # Cấu hình Maven dependencies
│   └── mvnw / mvnw.cmd       # Maven Wrapper thực thi không cần cài đặt trước Maven
├── mobile_app/               # Ứng dụng di động Flutter (Material 3, Provider, SQLite)
│   ├── lib/                  # Mã nguồn Dart (Screens, Widgets, Providers, Services)
│   ├── test/                 # Bộ kiểm thử tự động (widget_test.dart)
│   └── pubspec.yaml          # Cấu hình Flutter dependencies
└── README.md                 # Tài liệu hướng dẫn cài đặt môi trường và vận hành
```

---

## 🛠️ 2. Yêu cầu môi trường tiên quyết (Prerequisites)

Để chạy dự án sau khi `git clone`, máy tính của bạn cần cài đặt các công cụ sau:

| Công cụ | Phiên bản khuyến nghị | Kiểm tra trong Terminal / CMD |
| :--- | :--- | :--- |
| **Git** | Mọi phiên bản mới nhất | `git --version` |
| **Java JDK** | **Java 21** (OpenJDK / Oracle / Temurin) | `java -version` |
| **MySQL Server** | **MySQL Community Server 8.0** | `mysql --version` |
| **Flutter SDK** | **Flutter 3.13.2 trở lên** (kênh `stable`) | `flutter --version` |
| **Android Studio** | Bản mới nhất (kèm Android SDK & Emulator) | `flutter doctor` |

> 💡 **Mẹo:** Chạy lệnh `flutter doctor` để kiểm tra xem môi trường Android SDK và Flutter đã sẵn sàng chưa.

---

## 🚀 3. Hướng dẫn cài đặt và chạy dự án (Từng bước)

### Bước 1: Clone dự án về máy tính
```bash
git clone https://github.com/<your-username>/prm393_project_g5.git
cd prm393_project_g5
```

---

### Bước 2: Thiết lập cơ sở dữ liệu MySQL

1. **Khởi động dịch vụ MySQL:**
   * Mở phần mềm quản lý MySQL (như **MySQL Workbench** hoặc **DBeaver**) và kết nối vào tài khoản `root`.
   * Hoặc đảm bảo dịch vụ MySQL Service đang chạy trên máy (mặc định cổng `3306`).

2. **Import dữ liệu mẫu (`database.sql`):**
   * **Cách 1: Dùng MySQL Workbench (Khuyên dùng)**:
     - Mở MySQL Workbench $\rightarrow$ Chọn kết nối `Local instance MySQL80`.
     - Vào menu **File** $\rightarrow$ **Open SQL Script...** $\rightarrow$ Chọn file `backend/database.sql`.
     - Nhấn biểu tượng tia sét ⚡ (**Execute**) để chạy toàn bộ file.
   * **Cách 2: Dùng dòng lệnh (Terminal / CMD)**:
     ```bash
     # Trên Windows (chú ý chỉ định utf8mb4 để không bị lỗi font tiếng Việt):
     mysql -u root -p --default-character-set=utf8mb4 < backend/database.sql
     ```

3. **Cấu hình thông tin kết nối Database trong Backend:**
   * Mở file: `backend/src/main/resources/application.properties`
   * Kiểm tra và sửa lại mật khẩu MySQL của máy bạn (nếu khác `viet2005`):
     ```properties
     spring.datasource.url=jdbc:mysql://localhost:3306/novel_db?createDatabaseIfNotExist=true&useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh&useSSL=false&allowPublicKeyRetrieval=true
     spring.datasource.username=root
     spring.datasource.password=viet2005   # <-- Thay bằng mật khẩu MySQL trên máy của bạn
     ```

---

### Bước 3: Khởi động Backend (Spring Boot Server)

1. Mở cửa sổ Terminal / PowerShell mới và di chuyển vào thư mục `backend`:
   ```bash
   cd backend
   ```

2. Chạy ứng dụng bằng Maven Wrapper:
   * **Trên Windows:**
     ```powershell
     .\mvnw.cmd spring-boot:run
     ```
   * **Trên macOS / Linux:**
     ```bash
     chmod +x mvnw
     ./mvnw spring-boot:run
     ```

3. **Xác nhận Backend hoạt động:**
   * Khi console xuất hiện dòng:
     ```text
     ====================================================================
      Kết nối cơ sở dữ liệu MySQL thành công!
      - Tổng số bộ truyện trong DB : 11
      - Tài khoản mẫu (user@novel.com) : ĐÃ SẴN SÀNG
     ====================================================================
     Started NovelBackendApplication in ... seconds (process running)
     ```
   * Mở trình duyệt truy cập: `http://localhost:8080/api/comics` $\rightarrow$ Thấy danh sách JSON truyện trả về thành công.

---

### Bước 4: Khởi động Mobile App (Flutter)

1. Mở một cửa sổ Terminal / PowerShell **khác** và di chuyển vào thư mục `mobile_app`:
   ```bash
   cd mobile_app
   ```

2. Tải toàn bộ thư viện cần thiết:
   ```bash
   flutter pub get
   ```

3. **Bật thiết bị chạy app:**
   * Mở **Android Studio** $\rightarrow$ Khởi chạy một **Android Emulator** (Ví dụ: Pixel 4/6 API 31+).
   * Hoặc cắm điện thoại Android thật đã bật chế độ *USB Debugging*.

4. **Chạy ứng dụng di động:**
   ```bash
   flutter run
   ```

---

## 🌐 4. Cấu hình kết nối mạng (Network Configuration)

Ứng dụng di động kết nối tới Backend thông qua file cấu hình `mobile_app/lib/services/api_service.dart`:

* **Khi chạy trên Android Emulator (Mặc định):**
  * Android Emulator dùng địa chỉ `http://10.0.2.2:8080` để gọi tới `localhost:8080` trên máy tính. Ứng dụng đã được cấu hình **tự động nhận diện**, bạn không cần sửa gì.
* **Khi chạy trên Thiết bị thật (Physical Device qua Wi-Fi):**
  1. Mở Terminal gõ `ipconfig` (Windows) hoặc `ifconfig` (Mac) để tìm địa chỉ IPv4 nội mạng LAN của máy tính (ví dụ: `192.168.1.15`).
  2. Đảm bảo điện thoại và máy tính kết nối chung một mạng Wi-Fi.
  3. Mở file [api_service.dart](mobile_app/lib/services/api_service.dart) và cập nhật:
     ```dart
     return 'http://192.168.1.15:8080'; // Thay bằng IP máy tính của bạn
     ```

---

## 👤 5. Tài khoản mẫu có sẵn (Demo Accounts)

Sau khi import `backend/database.sql`, hệ thống có sẵn 2 tài khoản mẫu:

| Loại tài khoản | Email | Mật khẩu | Quyền hạn |
| :--- | :--- | :--- | :--- |
| **Thành viên đọc truyện** | `user@novel.com` | `User@123` | Đọc truyện, đánh dấu, đồng bộ tủ truyện cá nhân |
| **Quản trị viên** | `admin@novel.com` | `Admin@123` | Quản trị hệ thống |

> Bạn cũng có thể bấm vào nút **"Đăng ký ngay"** trên màn hình Đăng nhập để tự tạo một tài khoản mới bất kỳ lúc nào.

---

## 🧪 6. Chạy Kiểm Thử Tự Động (Automated Testing)

### Kiểm thử Mobile App (Flutter Widget Tests):
```bash
cd mobile_app
flutter test
```
* Kết quả mong đợi: `All tests passed! (6/6 tests passed)`.

### Kiểm thử Backend (Spring Boot Test Compile):
```bash
cd backend
.\mvnw.cmd test-compile
```
* Kết quả mong đợi: `BUILD SUCCESS`.

---

## ❓ 7. Xử lý các lỗi thường gặp (Troubleshooting / FAQ)

### 1. Lỗi cổng `8080` bị chiếm dụng (`Port 8080 was already in use`)
* **Nguyên nhân:** Có một tiến trình Java hoặc Tomcat cũ đang chạy ngầm trên máy.
* **Cách khắc phục trên Windows:**
  ```powershell
  # Tìm PID của tiến trình đang chiếm cổng 8080:
  netstat -ano | findstr :8080
  # Giết tiến trình (thay <PID> bằng mã số ở cột cuối cùng):
  taskkill /PID <PID> /F
  ```

### 2. Lỗi font chữ tiếng Việt bị biến dạng (Mojibake) khi import database
* **Nguyên nhân:** Windows PowerShell mặc định dùng bảng mã OEM 437/1252 làm mất dấu UTF-8.
* **Cách khắc phục:** Mở file `database.sql` trực tiếp bằng **MySQL Workbench** và nhấn ⚡ Execute để import, hoặc chạy lệnh với `--default-character-set=utf8mb4`.

### 3. Lỗi `JAVA_HOME is not set` khi chạy `mvnw`
* **Nguyên nhân:** Máy tính chưa cấu hình biến môi trường trỏ đến thư mục cài đặt JDK 21.
* **Cách khắc phục:** 
  1. Mở System Properties $\rightarrow$ Environment Variables.
  2. Tạo biến `JAVA_HOME` trỏ tới đường dẫn cài JDK (ví dụ: `C:\Program Files\Java\jdk-21`).
  3. Thêm `%JAVA_HOME%\bin` vào biến `Path`.

### 4. Lỗi Android Emulator không kết nối được Backend
* Đảm bảo Spring Boot đã khởi động thành công trước khi mở app.
* Kiểm tra Firewall của Windows không chặn cổng 8080.
