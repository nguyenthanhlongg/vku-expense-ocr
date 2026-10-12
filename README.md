# VKU Expense OCR 🧾💸

[![Live Demo](https://img.shields.io/badge/Live_Demo-GitHub_Pages-success?style=for-the-badge&logo=github)](https://nguyenthanhlongg.github.io/vku-expense-ocr/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

> **Mini-Project 3 — Tuần 7 Lập trình ứng dụng đa nền tảng Flutter:** Ứng dụng nhận diện hóa đơn thông minh On-Device OCR và quản lý chi tiêu cá nhân.

🌐 **Trải nghiệm bản Web Demo trực tiếp:** [https://nguyenthanhlongg.github.io/vku-expense-ocr/](https://nguyenthanhlongg.github.io/vku-expense-ocr/)

---

## 📱 Tính năng chính

1. **Quét hóa đơn thông minh (On-Device OCR):**
   - Chụp ảnh từ camera hoặc chọn ảnh từ thư viện (`image_picker`).
   - Tự động nhận diện văn bản tiếng Việt/Anh bằng **Google ML Kit Text Recognition** (chạy offline trên thiết bị, bảo mật 100%).
   - Tự động trích xuất: **Tên cửa hàng / Đơn vị**, **Tổng tiền thanh toán**, **Ngày lập hóa đơn**.
2. **Xác nhận & Chỉnh sửa:**
   - Cho phép người dùng kiểm tra, chỉnh sửa thông tin trước khi lưu.
   - Phân loại danh mục chi tiêu trực quan (Ăn uống, Mua sắm, Di chuyển, Hóa đơn,...).
3. **Lưu trữ dữ liệu an toàn:**
   - Cơ sở dữ liệu cục bộ **SQLite** (`sqflite`).
   - Tự động lưu kèm ảnh hóa đơn gốc vào bộ nhớ ứng dụng.
4. **Quản lý danh sách chi tiêu:**
   - Xem danh sách chi tiêu theo thời gian.
   - Vuốt để xóa (Swipe to delete), xem chi tiết hóa đơn kèm ảnh gốc.
5. **Báo cáo & Thống kê trực quan:**
   - Biểu đồ Donut Chart phân tích cơ cấu chi tiêu theo danh mục (`CustomPainter`).
   - Biểu đồ cột Bar Chart thống kê chi tiêu 7 ngày gần nhất.
   - Hỗ trợ giao diện sáng/tối (Material 3 Dark/Light mode).

---

## 🛠️ Công nghệ sử dụng (Tech Stack)

- **Framework:** Flutter 3.x / Dart
- **State Management:** Riverpod 2.x
- **Navigation:** GoRouter
- **Database:** SQLite (`sqflite` + `path_provider`)
- **Machine Learning:** Google ML Kit Text Recognition (`google_mlkit_text_recognition`)
- **Media:** `image_picker`
- **Charts:** `CustomPainter` (thuần Flutter không phụ thuộc thư viện ngoài nặng nề)
- **UI:** Material 3, VKU Navy Seed Color

---

## 🚀 Hướng dẫn cài đặt & chạy ứng dụng

### Yêu cầu môi trường:
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode
- Thiết bị thật (để sử dụng tính năng Camera & OCR ML Kit)

### Các bước thực hiện:

```bash
# 1. Clone repository
git clone https://github.com/nguyenthanhlongg/vku-expense-ocr.git
cd vku-expense-ocr

# 2. Cài đặt dependencies
flutter pub get

# 3. Chạy ứng dụng trên thiết bị thật
flutter run
```

---

## 📂 Cấu trúc thư mục

```
vku_expense_ocr/
├── lib/
│   ├── core/              # Theme, router, constants, utils
│   ├── data/              # SQLite helper, repositories, models
│   ├── providers/         # Riverpod state providers
│   ├── services/          # ML Kit OCR service, parser logic
│   └── views/             # Screens: Home, Scan/Review, Details, Reports
├── test/                  # Unit tests & Widget tests
├── demo/                  # Bản web demo tương tác
├── docs/                  # Tài liệu đề bài & hướng dẫn
└── pubspec.yaml           # Cấu hình dự án & thư viện
```

---

## 👨‍💻 Tác giả
- **Sinh viên:** Nguyễn Thành Long
- **Trường:** Trường Đại học Công nghệ Thông tin và Truyền thông Việt - Hàn (VKU)

