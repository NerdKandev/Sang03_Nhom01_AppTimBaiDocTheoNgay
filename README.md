HƯỚNG DẪN SỬ DỤNG GIT LÀM VIỆC NHÓM
I. Cấu trúc làm việc nhóm

- Mỗi thành viên sẽ làm việc trên một nhánh (branch) riêng để tránh xung đột.
- Tất cả code hợp nhất thông qua Pull Request (PR) lên branch `main`.
- Nhóm gồm 5 người sẽ có cấu trúc branch như sau:
  + main (nhánh chính, code ổn định)
  + dev (nhánh tổng hợp code mới)
  + feature/ui-theme
  + feature/auth-offline
  + feature/admin-crud
  + feature/user-progress
  + feature/tts-schedule

II. Quy trình làm việc Git cơ bản

1️⃣ **Clone project về máy lần đầu:**
    git clone <link_repo_github>

2️⃣ **Tạo branch riêng để làm việc:**
    git checkout -b feature/<tên_chức_năng>

3️⃣ **Làm việc và commit code:**
    git add .
    git commit -m "Mô tả ngắn gọn chức năng đã làm"

4️⃣ **Đẩy code lên GitHub:**
    git push origin feature/<tên_chức_năng>

5️⃣ **Tạo Pull Request (PR):**
    - Vào GitHub → Chọn nhánh của bạn → “Compare & pull request”
    - Thêm mô tả chi tiết chức năng, người review.
    - Chờ leader review và merge vào `dev`.

III. Cập nhật code mới nhất từ nhóm

1️⃣ Chuyển sang branch dev:
    git checkout dev

2️⃣ Kéo code mới nhất về:
    git pull origin dev

3️⃣ Quay lại branch của bạn và merge code dev:
    git checkout feature/<tên_chức_năng>
    git merge dev

4️⃣ Giải quyết xung đột (nếu có), sau đó commit lại:
    git add .
    git commit -m "Fix conflict với dev"


2️⃣ Lưu ý các file tránh commit
    # Không commit dữ liệu người dùng: 
    ví dụ các file có đuôi: *.db, *.hive, *.sqlite
    # File Cache / Audio
    ví dụ các file có duôi: *.wav, *.mp3, *.tflite, *.onnx ,*.h5

3️⃣ Kiểm tra xem file có đang bị commit hay không:
    git status

4️⃣ Nếu đã commit nhầm → xóa khỏi repo:
    git rm --cached <tên_file>
