
# Student Management App – Ứng dụng Quản lý Sinh viên

## 1. Giới thiệu dự án

**Student Management App** là ứng dụng quản lý sinh viên được xây dựng bằng Flutter.

Ứng dụng hướng đến việc hỗ trợ quản lý thông tin sinh viên, lớp học và các hoạt động học tập thông qua giao diện đơn giản, trực quan và dễ sử dụng.

### Mục tiêu
- Xây dựng giao diện ứng dụng quản lý sinh viên trên thiết bị di động.
- Thiết kế hệ thống điều hướng giữa các màn hình.
- Phân chia công việc phát triển giao diện theo từng Screen/Page.
- Thực hành làm việc nhóm, quản lý mã nguồn và cập nhật tiến độ trên GitHub.

### Công nghệ sử dụng
- Flutter
- Dart
- Git và GitHub
- Figma

---

## 2. Thành viên và phân công công việc

| STT | Họ và tên | Công việc được giao |
|---|---|---|
| 1 | [Họ tên thành viên 1] | [Nhiệm vụ] |
| 2 | [Họ tên thành viên 2] | [Nhiệm vụ] |
| 3 | Nguyễn Thái Sơn | [Screen/Page được giao] |
| 4 | [Họ tên thành viên 4] | [Nhiệm vụ] |

---

## 3. Thiết kế giao diện – Figma

**Link thiết kế Figma:** [Dán link Figma tại đây]

Các màn hình chính của ứng dụng:

1. Dashboard – Tổng quan
2. Student List – Danh sách sinh viên
3. Class List – Danh sách lớp học
4. Profile – Thông tin cá nhân

Các màn hình bổ sung có thể bao gồm:

- Student Detail – Chi tiết sinh viên
- Add Student – Thêm sinh viên
- Class Detail – Chi tiết lớp học

---

## 4. Chức năng và giao diện chính

### 4.1. Bottom Navigation Bar

Thanh điều hướng dưới cùng giúp người dùng chuyển đổi giữa các màn hình chính của ứng dụng.

Các mục điều hướng:

- Tổng quan
- Sinh viên
- Lớp học
- Cá nhân

**File code:** `lib/main.dart`

### 4.2. Dashboard – Tổng quan

Màn hình tổng quan cung cấp thông tin khái quát về hệ thống quản lý sinh viên.

Các thành phần giao diện:

- Tiêu đề và thông tin người dùng
- Ô tìm kiếm sinh viên, lớp học
- Các thẻ thống kê
- Khu vực truy cập nhanh
- Danh sách hoạt động gần đây

**File code:** `lib/dashboard_screen.dart`

### 4.3. Các màn hình khác

| Màn hình | Mô tả |
|---|---|
| Student List | Hiển thị danh sách sinh viên |
| Class List | Hiển thị danh sách lớp học |
| Profile | Hiển thị thông tin cá nhân |
| Student Detail | Hiển thị thông tin chi tiết sinh viên |
| Add Student | Giao diện thêm sinh viên |

> Các chức năng và dữ liệu thực tế sẽ được cập nhật theo tiến độ phát triển của dự án.

---

## 5. Cấu trúc thư mục

```text
lib/
├── main.dart
└── dashboard_screen.dart
```

- `main.dart`: Khởi tạo ứng dụng và xây dựng Bottom Navigation Bar.
- `dashboard_screen.dart`: Xây dựng giao diện màn hình Dashboard.

Các màn hình khác sẽ được bổ sung vào thư mục `lib/` khi hoàn thiện.

---

## 6. Hướng dẫn cài đặt và chạy ứng dụng

### Yêu cầu

- Đã cài đặt Flutter SDK.
- Đã cài đặt Android Studio hoặc Visual Studio Code.
- Đã cài đặt thiết bị giả lập Android hoặc kết nối điện thoại.

### Các bước thực hiện

1. Clone repository:

```bash
git clone [Link repository GitHub]
```

2. Mở thư mục dự án:

```bash
cd [Tên thư mục dự án]
```

3. Cài đặt các package:

```bash
flutter pub get
```

4. Chạy ứng dụng:

```bash
flutter run
```

---

## 7. Kết quả thực hiện

### Giao diện ứng dụng

- Dashboard: [Chèn ảnh màn hình]
- Danh sách sinh viên: [Chèn ảnh màn hình]
- Danh sách lớp học: [Chèn ảnh màn hình]
- Cá nhân: [Chèn ảnh màn hình]

### Kết quả kiểm thử

- [ ] Ứng dụng chạy thành công.
- [ ] Bottom Navigation Bar chuyển đổi giữa các màn hình.
- [ ] Các màn hình hiển thị đúng theo thiết kế.
- [ ] Đã kiểm tra giao diện trên thiết bị hoặc giả lập.

---

## 8. Repository và lịch sử cập nhật

**Link repository GitHub:** [Dán link repository]

**Link commit của phần việc được giao:** [Dán link commit]

Các cập nhật chính:

- Xây dựng cấu trúc ứng dụng Flutter.
- Xây dựng Bottom Navigation Bar.
- Xây dựng giao diện Dashboard.
- Cập nhật thiết kế và tài liệu dự án.

---

## 9. Tài liệu tham khảo

- Flutter: https://flutter.dev/
- Dart: https://dart.dev/
- Figma: https://www.figma.com/
- GitHub: https://github.com/
