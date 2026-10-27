# PRM393 Project Group 5 - Tủ Truyện

Dự án môn **PRM393** (Lập trình ứng dụng di động - FPT University) gồm 2 thành phần chính:

```
prm393_project_g5/
├── backend/       # REST API Backend xây dựng bằng Java Spring Boot & Spring Security 6 & JWT
└── mobile_app/    # Ứng dụng di động xây dựng bằng Flutter (Provider Pattern, Material 3)
```

---

## 1. Backend (`backend/`)
- **Công nghệ**: Java 21, Spring Boot 3.5.6, Spring Security 6, Nimbus JWT, HSQLDB.
- **Tính năng**:
  - Xác thực & Phân quyền (Authentication & Authorization) bằng JWT (Access Token + Refresh Token).
  - Đăng ký, Đăng nhập, Làm mới token, Đăng xuất, Đăng nhập Google, Đổi mật khẩu.
  - Phân quyền theo vai trò `ROLE_USER`, `ROLE_ADMIN`.
  - Quản lý danh sách truyện, thể loại, chương đọc, bảng xếp hạng.
  - Đồng bộ Tủ truyện: Lịch sử đọc, tiến độ đọc từng chương, truyện đánh dấu yêu thích.
- **Khởi động**:
  ```powershell
  cd backend
  .\mvnw.cmd spring-boot:run
  ```
- **Kiểm thử**:
  ```powershell
  cd backend
  .\mvnw.cmd test
  ```

---

## 2. Mobile App (`mobile_app/`)
- **Công nghệ**: Flutter 3.47.x, Dart 3.13.x, Provider Pattern, Material 3.
- **Tính năng**:
  - Khung điều hướng 4 tab: Tủ Truyện, Khám Phá, Xếp Hạng, Tài Khoản.
  - Tủ truyện cá nhân (Tab Lịch sử đọc & Tab Đánh dấu).
  - Khám phá truyện với Responsive Grid (3 cột dọc, 5 cột xoay ngang), lọc truyện theo trạng thái (Đang ra / Hoàn thành).
  - Trình đọc truyện: Chuyển chương, tăng/giảm font chữ, tự động lưu tiến độ đọc.
  - Tìm kiếm truyện theo tên, tác giả, thể loại theo thời gian thực.
- **Cài đặt & Khởi động**:
  ```powershell
  cd mobile_app
  flutter pub get
  flutter run
  ```
- **Kiểm thử**:
  ```powershell
  cd mobile_app
  flutter test
  ```
