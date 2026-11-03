# Student Management App – Ứng dụng Quản lý Sinh viên

## 1. Giới thiệu

Student Management App là ứng dụng quản lý sinh viên được xây dựng bằng Flutter, hướng đến hỗ trợ quản lý thông tin sinh viên, lớp học và các hoạt động học tập.

### Mục tiêu

- Xây dựng giao diện quản lý sinh viên trên thiết bị di động.
- Thiết kế hệ thống điều hướng giữa các màn hình.
- Phân chia công việc phát triển theo từng màn hình.
- Thực hành làm việc nhóm và quản lý mã nguồn trên GitHub.

### Công nghệ và công cụ

- Flutter và Dart.
- Git và GitHub.
- Figma.

## 2. Thành viên

| STT | Họ và tên       |
| --- | --------------- |
| 1   | Đinh Khắc Đại   |
| 2   | Nguyễn Anh Văn  |
| 3   | Nguyễn Thái Sơn |

Phân công công việc chi tiết được trình bày trong báo cáo của nhóm.

## 3. Thiết kế giao diện

[Tham khảo thiết kế giao diện](https://tusk-icing-54303581.figma.site/)

Các màn hình chính:

- Dashboard – Tổng quan.
- Student List – Danh sách sinh viên.
- Class List – Danh sách lớp học.
- Profile – Thông tin cá nhân.

Các màn hình bổ sung:

- Student Detail – Chi tiết sinh viên.
- Add Student – Thêm sinh viên.
- Class Detail – Chi tiết lớp học.

## 4. Chức năng và giao diện

### Thanh điều hướng

Thanh điều hướng dưới cùng hỗ trợ chuyển đổi giữa các mục:

- Tổng quan.
- Sinh viên.
- Lớp học.
- Cá nhân.

### Màn hình tổng quan

Các thành phần giao diện được mô tả trong thiết kế:

- Tiêu đề và thông tin người dùng.
- Ô tìm kiếm sinh viên, lớp học.
- Các thẻ thống kê.
- Khu vực truy cập nhanh.
- Danh sách hoạt động gần đây.

### Các màn hình khác

| Màn hình       | Mô tả                                 |
| -------------- | ------------------------------------- |
| Student List   | Hiển thị danh sách sinh viên          |
| Class List     | Hiển thị danh sách lớp học            |
| Profile        | Hiển thị thông tin cá nhân            |
| Student Detail | Hiển thị thông tin chi tiết sinh viên |
| Add Student    | Giao diện thêm sinh viên              |

Phạm vi chức năng và dữ liệu thực tế cần được đối chiếu với phiên bản mã nguồn hiện tại.

## 5. Hướng dẫn cài đặt và chạy ứng dụng

### Yêu cầu

- Flutter SDK.
- Android Studio hoặc Visual Studio Code.
- Git.
- Thiết bị giả lập Android hoặc điện thoại được kết nối với máy tính.

### Bước 1. Tải mã nguồn

```bash
git clone https://github.com/son111123/nhom_Dai_Son_Van.git
```

### Bước 2. Mở thư mục ứng dụng

```bash
cd nhom_Dai_Son_Van/dai_son_van_eduManagement
```

### Bước 3. Kiểm tra môi trường

```bash
flutter doctor
```

### Bước 4. Cài đặt các thư viện

```bash
flutter pub get
```

### Bước 5. Chạy ứng dụng

Khởi động thiết bị giả lập hoặc kết nối điện thoại, sau đó chạy:

```bash
flutter run
```

## 6. Kiểm tra và minh chứng

Các mục cần xác nhận khi chạy ứng dụng:

- [ ] Ứng dụng khởi động thành công.
- [ ] Thanh điều hướng chuyển đổi đúng giữa các màn hình.
- [ ] Các màn hình hiển thị đúng theo thiết kế.
- [ ] Giao diện đã được kiểm tra trên thiết bị hoặc giả lập.

Ảnh chụp màn hình và kết quả kiểm thử được bổ sung theo phiên bản thực tế của dự án.

## 7. Repository và lịch sử cập nhật

[Repository GitHub](https://github.com/son111123/nhom_Dai_Son_Van)

[Thư mục ứng dụng](https://github.com/son111123/nhom_Dai_Son_Van/tree/main/dai_son_van_eduManagement)

Lịch sử commit trên GitHub được sử dụng để theo dõi thay đổi mã nguồn và tiến độ thực hiện của nhóm.

## 8. Tài liệu tham khảo

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [Figma](https://www.figma.com/)
- [GitHub](https://github.com/)
