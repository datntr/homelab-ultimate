# 🧰 Hướng dẫn Ứng dụng: Các Tiện ích Hệ thống (Portainer, Dozzle, Uptime Kuma)

Hệ thống Homelab được trang bị sẵn bộ 3 công cụ vận hành cực kỳ mạnh mẽ giúp bạn quản lý, theo dõi lỗi và giám sát máy chủ như một chuyên gia System Admin.

---

## 🐳 1. Portainer CE (Quản lý Docker Trực quan)
Portainer là một giao diện Web cho phép bạn quản lý mọi vùng chứa (container), volumes, và logs của Docker mà không cần phải gõ bất kỳ một dòng lệnh CLI nào trên VPS.

> [!WARNING]
> **Cảnh báo bảo mật 5 phút:** Portainer có cơ chế tự vệ rất khắt khe. Ngay sau khi bạn cài đặt xong bằng `homelab.sh`, bạn có **chính xác 5 phút** để truy cập vào Web UI của Portainer (thông qua IP VPS port 9000 hoặc qua Cloudflare Tunnel) để thiết lập Mật khẩu Admin ban đầu.
> 
> ⏳ Nếu quá 5 phút mà bạn chưa tạo tài khoản, Portainer sẽ khóa chặt giao diện Web lại để chống hacker tự động dò mật khẩu.

**Cách mở khóa Portainer:** 
🔓 Nếu bạn lỡ để quá thời gian bị khóa, hãy chạy script `homelab.sh` -> Quản lý Portainer -> Bấm phím **Khởi động lại (Restart)**. Việc này sẽ reset đồng hồ và cấp cho bạn thêm 5 phút nữa để vào tạo tài khoản.

---

## 📜 2. Dozzle (Xem Log thời gian thực)
Thay vì gõ lệnh `docker logs` rườm rà, **Dozzle** cung cấp giao diện Web mượt mà để xem log toàn bộ ứng dụng theo thời gian thực (Real-time).

> [!TIP]
> **Bảo mật:** Script `homelab.sh` tự động sinh tài khoản ngẫu nhiên lưu tại `$HOMELAB_DIR/dozzle/.env`.
> Khi cài xong, Username (mặc định là `admin`) và Password sẽ in to rõ ra màn hình Terminal. Hãy lưu lại ngay!

---

## 📈 3. Uptime Kuma (Giám sát cảnh báo hệ thống)
Phiên bản tự lưu trữ của UptimeRobot, chuyên giám sát hệ thống 24/7:

- 🔔 **Cảnh báo tức thì:** "Bắn ping" mỗi phút. Nếu app sập (`502`), lập tức gửi tin nhắn qua Telegram, Discord, Email...
- 🔗 **Kết nối Docker Socket:** Được cấp quyền đọc `/var/run/docker.sock`.
- ✅ **Chính xác tuyệt đối:** Thay vì Ping URL ảo, Kuma giám sát thẳng vào lõi Docker để biết chính xác app đang `Running` (xanh) hay `Exited` (đỏ).
