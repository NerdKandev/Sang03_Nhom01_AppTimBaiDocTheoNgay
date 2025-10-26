# 📖 BIBLE APP - ỨNG DỤNG ĐỌC KINH THÁNH

## 🎯 Tổng quan dự án

Ứng dụng đọc Kinh Thánh hàng ngày với các tính năng:
- 📚 **66 sách Kinh Thánh** (Cựu Ước + Tân Ước)
- 📖 **Bài đọc hàng ngày** được sắp xếp theo lịch
- 👤 **Hệ thống người dùng** với đăng ký/đăng nhập
- ❤️ **Yêu thích & Bookmark** các bài đọc
- 📝 **Ghi chú cá nhân** cho từng bài đọc
- 📊 **Theo dõi tiến độ** đọc Kinh Thánh
- 🔄 **Backup/Restore** dữ liệu
- 👨‍💼 **Admin Panel** quản lý nội dung

## 🏗️ Kiến trúc hệ thống

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Layer      │    │  Service Layer  │    │ Database Layer  │
│                 │    │                 │    │                 │
│ - Widgets       │───▶│ - AuthService   │───▶│ - SQLite        │
│ - Screens       │    │ - AdminService  │    │ - Models        │
│ - Controllers   │    │ - UserFeatures  │    │ - Migrations    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Tính năng đã hoàn thành

### ✅ **UI/Theme (Người 2)**
 HomePage – Danh sách bài Kinh nổi bật / danh mục chính (JSON demo)
 SearchPage – Tìm theo tên, tác giả, thể loại (lọc trong JSON)
 ReadPage – Giao diện đọc Kinh, hỗ trợ Dark/Light mode
 AudioPage / Widget – Nút Phát / Tạm dừng, liên kết bài Kinh
 Navigation – BottomBar / Drawer giữa Home, Search, Favorites, Settings
 SettingsPage – Chuyển đổi Dark/Light mode, lưu trạng thái bằng SharedPreferences
 ThemeProvider – Quản lý chủ đề & lưu trạng thái theme
 X chua lam duoc JSON Loader – Đọc dữ liệu từ assets/sutras.json
 Reusable Widgets – SutraCard, AudioPlayerWidget, SearchBar

### 🔄 **Đang phát triển**
- [ ] **Admin Panel (Người 3)** - Quản lý nội dung
- [ ] **User Features (Người 4)** - Tính năng cá nhân
- [ ] **TTS/Schedule (Người 5)** - Đọc tự động & lịch

## 📁 Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── bible_book.dart
│   ├── daily_reading.dart
│   └── user.dart
├── services/                 # Business logic
│   ├── database_service.dart
│   ├── auth_service.dart
│   ├── admin_service.dart
│   ├── user_features_service.dart
│   └── test_*.dart
├── utils/                    # Utilities
│   └── data_utils.dart
└── migrations/              # Database migrations
    ├── 001_create_tables.sql
    ├── 002_seed_bible_books.sql
    └── 003_seed_daily_readings.sql

docs/                        # Documentation
├── DATABASE_SCHEMA.md
├── API_DOCUMENTATION.md
├── SETUP_GUIDE.md
└── AUTHENTICATION_GUIDE.md
```

## 🛠️ Cài đặt và chạy

### **1. Clone repository:**
```bash
git clone <repository-url>
cd Sang03_Nhom01_AppTimBaiDocTheoNgay
```

### **2. Cài đặt dependencies:**
```bash
flutter pub get
```

### **3. Chạy ứng dụng:**
```bash
flutter run
```

### **Cấu trúc branch:**
- `main` - Code ổn định
- `dev` - Tổng hợp code mới
- `feature/ui-theme` - Giao diện
- `feature/auth-offline` - Authentication
- `feature/admin-crud` - Admin panel
- `feature/user-progress` - User features
- `feature/tts-schedule` - TTS & Schedule

### **Quy trình cơ bản:**
1. **Clone project:** `git clone <repo-url>`
2. **Tạo branch:** `git checkout -b feature/<tên_chức_năng>`
3. **Commit code:** `git add . && git commit -m "Mô tả"`
4. **Push code:** `git push origin feature/<tên_chức_năng>`
5. **Tạo PR:** GitHub → Compare & pull request

### **Cập nhật code:**
```bash
git checkout dev
git pull origin dev
git checkout feature/<tên_chức_năng>
git merge dev
```

## 🚨 Lưu ý quan trọng

### **Files không commit:**
- Database files: `*.db`, `*.sqlite`
- Audio files: `*.wav`, `*.mp3`
- Model files: `*.tflite`, `*.onnx`, `*.h5`
- Cache files: `build/`, `.dart_tool/`

### **Kiểm tra trước commit:**
```bash
git status
git rm --cached <file_name>  # Xóa file khỏi repo
```

## 📊 Trạng thái dự án

| Thành viên | Nhiệm vụ | Trạng thái | Tiến độ |
|------------|----------|------------|---------|
| **Người 1** | Backend Logic | ✅ Hoàn thành | 100% |
| **Người 2** | UI/Theme |  ✅ Hoàn thành | 100% 
| **Người 3** | Admin Panel | 🔄 Đang làm | 0% |
| **Người 4** | User Features | 🔄 Đang làm | 0% |
| **Người 5** | TTS/Schedule | 🔄 Đang làm | 0% |

## 🎯 Mục tiêu tiếp theo

1. **Phát triển Admin Panel** - Quản lý nội dung
2. **Tích hợp User Features** - Tính năng cá nhân
3. **Implement TTS/Schedule** - Đọc tự động
4. **Testing & Deployment** - Kiểm thử và triển khai

## 📞 Liên hệ

- **Repository:** [GitHub Link]
- **Documentation:** [docs/](docs/)
- **Issues:** [GitHub Issues]
- **Discussions:** [GitHub Discussions]
