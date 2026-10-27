# Tủ Truyện - Spring Boot Authentication & Novel REST API Backend

Backend cung cấp hệ thống Xác thực (Authentication) & Phân quyền (Authorization) và API Đọc Truyện sử dụng **Java 21**, **Spring Boot 3.5.6**, **Spring Security 6**, **Nimbus JWT** và cơ sở dữ liệu quan hệ **MySQL 8.0** (`novel_db`).

---

## 1. Hướng dẫn cài đặt Cơ sở dữ liệu MySQL

Hệ thống sử dụng cơ sở dữ liệu MySQL thay vì load dữ liệu cứng từ code. Toàn bộ cấu trúc bảng và dữ liệu mẫu được quản lý tập trung trong file [`backend/database.sql`](file:///d:/FPT/HK8/PRM393/prm393_project_g5/backend/database.sql).

### Bước 1: Chạy script khởi tạo MySQL
Mở terminal hoặc MySQL CLI / MySQL Workbench / DBeaver / Navicat và chạy:

```bash
# Cách 1: Chạy trực tiếp từ dòng lệnh đảm bảo mã hóa UTF-8 (tiếng Việt có dấu):
mysql --default-character-set=utf8mb4 -u root -p -e "source database.sql"
```
Hoặc mở file [`database.sql`](file:///d:/FPT/HK8/PRM393/prm393_project_g5/backend/database.sql) trong **MySQL Workbench** / **phpMyAdmin** / **DBeaver** và nhấn **Execute (Ctrl+Shift+Enter)**.

Script sẽ tự động:
1. Tạo database `novel_db` với mã hóa `utf8mb4` (hỗ trợ tiếng Việt và biểu tượng cảm xúc).
2. Tạo 6 bảng quan hệ chuẩn: `users`, `refresh_tokens`, `comics`, `chapters`, `reading_history`, `bookmarks`.
3. Nạp sẵn 2 tài khoản mẫu (BCrypt hash), 11 bộ truyện và các chương truyện mẫu.

### Bước 2: Cấu hình kết nối MySQL trong Backend
Mở [`backend/src/main/resources/application.properties`](file:///d:/FPT/HK8/PRM393/prm393_project_g5/backend/src/main/resources/application.properties) và điều chỉnh tài khoản/mật khẩu MySQL nếu khác mặc định:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/novel_db?createDatabaseIfNotExist=true&useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh&useSSL=false&allowPublicKeyRetrieval=true
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.username=root
spring.datasource.password=your_mysql_password
```

---

## 2. Hướng dẫn chạy Backend

Từ thư mục `backend/`:

```powershell
# Chạy ứng dụng trực tiếp bằng Maven Wrapper (kết nối MySQL novel_db)
.\mvnw.cmd spring-boot:run
```

Chạy kiểm thử tự động (Unit & Integration tests):
```powershell
.\mvnw.cmd test
```

> **Lưu ý**: Server mặc định chạy tại cổng `8080`: `http://localhost:8080` (hoặc `http://10.0.2.2:8080` trên máy ảo Android Emulator).

---

## 3. Tài khoản mẫu có sẵn trong database.sql (Seeded Accounts)

Script SQL đã nạp sẵn 2 tài khoản được băm mật khẩu chuẩn BCrypt:
- **Tài khoản người dùng (USER)**:
  - Email: `user@novel.com`
  - Mật khẩu: `User@123`
  - Role: `ROLE_USER`
- **Tài khoản quản trị (ADMIN)**:
  - Email: `admin@novel.com`
  - Mật khẩu: `Admin@123`
  - Role: `ROLE_ADMIN`

---

## 3. Kiến trúc xác thực & bảo mật đã triển khai

Hệ thống được xây dựng bám sát 8 tiêu chuẩn kiến trúc xác thực:

1. **Authentication vs Authorization**:
   - Authentication qua Email/Password và Google Sign-in.
   - Authorization bằng vai trò `ROLE_USER` và `ROLE_ADMIN` qua `@PreAuthorize` và `SecurityConfig`.
2. **Luồng JWT Token**:
   - **Access Token**: HMAC-SHA256 (HS256) chứa `userId`, `email`, `role`, thời hạn sống ngắn (1 giờ).
   - **Refresh Token**: Chuỗi ngẫu nhiên bảo mật lưu trữ trong database, thời hạn sống dài (7 ngày), hỗ trợ thu hồi (Revoke) khi Logout hoặc đổi mật khẩu.
3. **Quản lý phiên không trạng thái (Stateless Session)**:
   - `SessionCreationPolicy.STATELESS`: Server không lưu session trong RAM, client gửi Bearer Token qua header `Authorization: Bearer <token>`.
4. **Kiểm thực dữ liệu (Form Validation)**:
   - Email: Định dạng chuẩn RFC qua `@Email`, bắt buộc qua `@NotBlank`.
   - Mật khẩu: Tối thiểu 6 ký tự, có ít nhất 1 chữ hoa và 1 chữ số (`@Pattern`).
   - Mật khẩu và Xác nhận mật khẩu (`confirmPassword`) được đối soát tại `AuthService`.
5. **Bảo mật mật khẩu**:
   - Sử dụng `BCryptPasswordEncoder` (tự động băm và thêm muối bảo mật nhiều vòng).
6. **Xử lý lỗi toàn cục (`GlobalExceptionHandler`)**:
   - Trả về mã lỗi HTTP chuẩn: 400 (Validation/Business), 401 (Bad Credentials/Unauthenticated), 403 (Token Expired), 404 (Not Found).
   - Danh sách lỗi validate trực tiếp dạng Key-Value để hiển thị inline validation trên Flutter UI.
7. **Hỗ trợ Google Sign-in**:
   - Endpoint `POST /api/auth/google` tự động tạo tài khoản hoặc liên kết tài khoản và trả về cặp Token JWT.
8. **Đồng bộ Tủ truyện với Flutter**:
   - Đồng bộ Lịch sử đọc (`/api/library/history`), tiến độ đọc (`/api/library/progress`), đánh dấu (`/api/library/bookmarks`).

---

## 4. Danh sách API Endpoints

### 4.1. Xác thực & Tài khoản (`/api/auth`)

| Phương thức | Endpoint | Yêu cầu Token | Mô tả |
|---|---|---|---|
| `POST` | `/api/auth/register` | Không | Đăng ký tài khoản mới |
| `POST` | `/api/auth/login` | Không | Đăng nhập lấy cặp Token (Access + Refresh) |
| `POST` | `/api/auth/refresh` | Không | Cấp Access Token mới từ Refresh Token |
| `POST` | `/api/auth/logout` | Không | Đăng xuất (thu hồi Refresh Token) |
| `POST` | `/api/auth/google` | Không | Đăng nhập bằng Google |
| `GET` | `/api/auth/me` | **Có (Bearer)** | Lấy thông tin cá nhân & thống kê tủ truyện |
| `POST` | `/api/auth/change-password` | **Có (Bearer)** | Đổi mật khẩu tài khoản |

#### Ví dụ Body Đăng nhập (`POST /api/auth/login`):
```json
{
  "email": "user@novel.com",
  "password": "User@123"
}
```

#### Ví dụ Response Đăng nhập thành công (HTTP 200):
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
    "refreshToken": "7849c719e7614e7a83d3...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": 1,
      "email": "user@novel.com",
      "fullName": "Nguyễn Văn Đọc",
      "avatarUrl": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80",
      "role": "ROLE_USER",
      "historyCount": 3,
      "bookmarkCount": 0
    }
  },
  "timestamp": "2026-10-20T08:30:00"
}
```

---

### 4.2. Truyện & Chương (`/api/comics`) - Công khai

| Phương thức | Endpoint | Mô tả |
|---|---|---|
| `GET` | `/api/comics` | Danh sách truyện (Hỗ trợ params `?search=...&status=...`) |
| `GET` | `/api/comics/{id}` | Chi tiết truyện |
| `GET` | `/api/comics/{id}/chapters` | Danh sách chương của truyện |
| `GET` | `/api/comics/{id}/chapters/{number}` | Đọc nội dung chương cụ thể |

---

### 4.3. Tủ Truyện & Đồng bộ (`/api/library`) - Yêu cầu Bearer Token

| Phương thức | Endpoint | Mô tả |
|---|---|---|
| `GET` | `/api/library/history` | Lấy danh sách lịch sử đọc của người dùng |
| `POST` | `/api/library/progress` | Cập nhật chương đang đọc dở (`comicId`, `currentChapter`) |
| `POST` | `/api/library/notify/{comicId}` | Bật/tắt nhận thông báo chương mới cho truyện |
| `DELETE` | `/api/library/history/{comicId}` | Xóa truyện khỏi lịch sử đọc |
| `GET` | `/api/library/bookmarks` | Lấy danh sách truyện đã đánh dấu yêu thích |
| `POST` | `/api/library/bookmarks/{comicId}` | Bật/tắt đánh dấu truyện |
