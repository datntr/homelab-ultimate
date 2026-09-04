# 📝 Lịch sử Cập nhật (Changelog)

Tất cả những thay đổi nổi bật của dự án **Homelab Ultimate** sẽ được ghi chép lại tại đây.

---

## [v1.0.0] - Bản phát hành Đầu tiên (Initial Release)

### 🌟 Tính năng cốt lõi (Core Features)
- Ra mắt kịch bản cài đặt tự động `homelab.sh` với Menu tương tác (TUI) bằng tiếng Việt hoàn chỉnh.
- Quản lý các nhóm ứng dụng theo kiến trúc Modular:
  - **Core Services:** PostgreSQL, Redis (tạo tài khoản siêu bảo mật tự động).
  - **Tự động hóa:** N8N, Home Assistant.
  - **Tiện ích hệ thống:** Portainer CE (Quản lý Docker), Dozzle (Đọc Log), Uptime Kuma (Giám sát cảnh báo), Duplicati (Sao lưu).
- **Tính năng Mạng:** Hỗ trợ thiết lập Cloudflare Tunnel nội bộ không cần mở Port.
- **Bảo mật:** Tự động sinh ngẫu nhiên các loại mật khẩu và mã hóa Bcrypt. Hỗ trợ tính năng Xem và Đổi Mật Khẩu tự động cho từng ứng dụng ngay trong giao diện Menu.
- Tích hợp công cụ **"Phân tích dung lượng ổ đĩa"** để dọn dẹp Docker Volume tự động, chống tràn ổ cứng.

### 🌟 Tích hợp Hệ sinh thái AI (AI Apps)
- **OmniRoute / 9Router:** Cổng định tuyến AI Gateway giúp quản lý API Key tập trung, cung cấp API tương thích chuẩn OpenAI cho toàn mạng nội bộ.
- **OpenClaw:** Trợ lý ảo AI cá nhân tối giản, siêu nhẹ.
- **Hermes Agent:** Tác tử AI (Agent) có khả năng tự học, gọi hàm (Tool Calling) và chạy ngầm qua lịch trình.
- Bổ sung cấu hình AI tự động cho Hermes Agent vào menu quản lý.
