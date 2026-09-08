# 🤖 Hướng dẫn Ứng dụng: N8N (Tự động hóa Workflow)

N8N là trái tim của hệ thống tự động hóa. Nó cho phép bạn kéo-thả để kết nối các dịch vụ, API, và tự động hóa quy trình làm việc giống như Zapier hay Make, nhưng hoàn toàn miễn phí và không giới hạn.

Tuy nhiên, phiên bản gốc của N8N mặc định khóa rất nhiều tính năng hệ thống để đảm bảo bảo mật. Nếu bạn là một "Power User", kịch bản `homelab.sh` đã cung cấp sẵn các **Tiện ích mở rộng** (Phím 6 trong Menu Quản lý của N8N) để bạn "độ" lại N8N thành một cỗ máy mạnh mẽ hơn:

---

## 🔓 1. Mở khóa Node 'Execute Command' & NPM
Mặc định N8N cấm chạy lệnh hệ thống và import thư viện ngoài.
- 🚀 **Cách mở khóa:** Chạy Tiện ích số 1. Nó tự động chèn `NODE_FUNCTION_ALLOW_EXTERNAL=*`, cho phép bạn code JavaScript không giới hạn.

---

## 📦 2. Cài đặt thư viện NPM
Bạn cần dùng `axios`, `crypto`, `moment`...?
- ⚡ **Giải pháp:** Chạy Tiện ích số 2 -> gõ tên thư viện. Script sẽ tự chui vào container và chạy `npm install` ngay lập tức, không cần build lại Image.

---

## 🔑 3. Khôi phục Mật khẩu Chủ
Lỡ quên mật khẩu admin?
- 🔄 **Giải pháp:** Chạy Tiện ích số 3. Gọi lệnh CLI `n8n user-management:reset` để reset tài khoản tức thì.

---

## 🐍 4. Tích hợp Python, FFmpeg, yt-dlp
Chạy Tiện ích số 4 để biến N8N thành siêu cỗ máy xử lý dữ liệu:
- 🐍 **Python3 & pip:** Chạy script Python ngay trong Node Execute Command.
- 🎬 **FFmpeg:** Nén, cắt ghép video/audio trực tiếp.
- 📥 **yt-dlp:** Tải video từ YouTube, Facebook, Tiktok cực nhanh.

> [!WARNING]
> Các gói cài thêm này nằm trong Container. Nếu bạn cập nhật bản N8N mới (Pull image), chúng sẽ bị mất và bạn cần chạy lại Tiện ích 4 & 2 để cài lại.

---

## 🔄 5. Khôi phục bản Gốc (Gỡ bỏ mọi tích hợp)
Nếu bản build tùy chỉnh gặp lỗi hoặc bạn muốn quay về trạng thái ban đầu của N8N:
- ⚡ **Giải pháp:** Chạy Tiện ích số 5. Script sẽ gỡ bỏ cấu hình build tùy chỉnh, xóa Dockerfile/compose build và kéo lại Image gốc từ nhà phát hành.

---

## 📂 6. Sửa lỗi quyền ghi file (Fix Permission Denied)
Nếu Node Write File hoặc N8N báo lỗi không ghi được vào thư mục data (`EACCES: permission denied`):
- 🛠️ **Giải pháp:** Chạy Tiện ích số 6. Script sẽ tự động cấp quyền `chmod -R 777` và phân quyền sở hữu `chown -R 1000:1000` cho thư mục lưu trữ của N8N.
