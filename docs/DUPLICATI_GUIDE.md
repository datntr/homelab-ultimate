# ☁️ Hướng dẫn Ứng dụng: Duplicati (Sao lưu Đám mây Tự động)

Duplicati là một ứng dụng sao lưu (backup) miễn phí, mã nguồn mở chuyên dùng để mã hóa và đồng bộ dữ liệu của bạn lên các dịch vụ đám mây (Cloud Storage) như Google Drive, OneDrive, Dropbox, S3, v.v.

Trong hệ thống Homelab của chúng ta, toàn bộ dữ liệu cấu hình, cơ sở dữ liệu của tất cả các ứng dụng (N8N, Home Assistant, 9Router, OpenClaw...) đều được tập trung tại một nơi duy nhất: thư mục `/opt/homelab`. Do đó, Duplicati đóng vai trò là "chiếc phao cứu sinh" chống mất dữ liệu nếu VPS của bạn bị hỏng hoặc lỗi ổ cứng.

---

## 🔑 1. Lưu ý về Mật khẩu đăng nhập
Theo bản cập nhật mới nhất, Duplicati bắt buộc phải có mật khẩu để truy cập Web UI. Kịch bản `homelab.sh` đã tự động thiết lập mật khẩu mặc định là:
- **Username:** (Trống không cần điền)
- **Password:** `admin123`

*(Bạn có thể vào mục Settings của Duplicati trên giao diện Web để đổi lại mật khẩu này).*

---

## 🔄 2. Cách thiết lập Backup tự động lên Google Drive
Sau khi cài đặt và truy cập vào Web UI của Duplicati:

1. **Thêm lịch sao lưu mới (Add backup):** Chọn *Configure a new backup*.
2. **Cài đặt chung (General):** Đặt tên cho lịch backup (VD: `Homelab Daily Backup`). 
   > [!CAUTION]
   > Bạn nên đặt mật khẩu mã hóa (Passphrase) cực kỳ cẩn thận ở bước này. Nếu bạn làm mất Passphrase này, bản backup tải lên mây sẽ biến thành đống rác vì không thể giải mã được!
3. **Nơi lưu trữ (Destination):**
   - Chọn Storage type: `Google Drive`.
   - Chọn đường dẫn thư mục lưu trên Drive (VD: `Homelab_Backups`).
   - Bấm nút **AuthID** để đăng nhập vào tài khoản Google của bạn và cấp quyền cho Duplicati.
4. **Dữ liệu cần sao lưu (Source Data):**
   - Mở cây thư mục, tìm đến đường dẫn `/source`.
   - Đánh dấu tick vào toàn bộ thư mục `/source` *(Đây chính là thư mục `/opt/homelab` đã được map từ hệ điều hành máy chủ vào thẳng trong vùng chứa Docker của Duplicati)*.
5. **Lịch trình (Schedule):** Đặt lịch tự động chạy, ví dụ: 2:00 sáng mỗi ngày.
6. **Lưu lại:** Bấm Save. Cuối cùng, bạn có thể bấm "Run now" để kích hoạt bản backup đầu tiên ngay lập tức!

---

## ♻️ 3. Cách phục hồi dữ liệu (Restore)
Nếu VPS của bạn bị sập hoàn toàn và bạn phải mua một con VPS mới:

1. Chạy lại script `homelab.sh` trên VPS mới để cài lại hệ thống Docker và chọn cài đặt app Duplicati.
2. Truy cập vào Web UI của Duplicati mới, chọn **Restore** -> **Direct restore from backup files**.
3. Khai báo lại thông tin Google Drive và **nhập đúng Mật khẩu mã hóa (Passphrase)** mà bạn đã đặt lúc backup.
4. Chọn bản backup gần nhất và phục hồi thẳng về thư mục gốc `/source` (tức là `/opt/homelab`).
5. Dùng script `homelab.sh` cài lại các app khác, chúng sẽ nhận diện cấu hình cũ tự động và chạy như chưa hề có chuyện gì xảy ra!

---

> [!NOTE]
> **Phân biệt với tính năng Backup nội bộ của `homelab.sh`:**
> Trong Menu chính của `homelab.sh` cũng có chức năng **[Phím 6] Quản lý Sao lưu & Phục hồi**. Chức năng đó là để nén (tar) và mã hóa (AES-256) dữ liệu nội bộ trên ngay trên ổ cứng VPS để bạn tải file `.enc` về máy tính (hoặc làm checkpoint trước khi nghịch code). Còn **Duplicati** là công cụ tự động hóa quá trình đẩy file lên thẳng Google Drive hằng ngày mà bạn không cần động tay vào.
