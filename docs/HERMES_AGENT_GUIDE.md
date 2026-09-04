# Hướng dẫn Chuyên sâu: Hermes Agent

**Hermes Agent** (được phát triển bởi NousResearch) không chỉ đơn thuần là một chatbot, mà là một **Tác tử AI (AI Agent) có khả năng tự tiến hóa**. Nó được thiết kế để kết hợp sức mạnh của các mô hình ngôn ngữ lớn (LLM) với khả năng thực thi luồng công việc phức tạp thông qua **Function Calling** và kho công cụ (Tools) đồ sộ.

Trong hệ sinh thái Homelab, Hermes Agent đóng vai trò là **"Bộ não phân tích chuyên sâu"**, có thể chạy ngầm trên VPS để tự động hóa các tác vụ phức tạp nhất mà không cần bạn phải mở laptop.

---

## 1. Các Tính Năng Độc Quyền (Sự khác biệt của Hermes Agent)

Theo tài liệu chính thức từ NousResearch, Hermes Agent sở hữu những khả năng vượt trội:

- 🧠 **Vòng lặp tự học (Closed Learning Loop):** Tự tạo kỹ năng mới, có bộ nhớ dài hạn (FTS5) và tự động xây dựng hồ sơ người dùng.
- 🕒 **Tự động hóa theo lịch trình (Scheduled Automations):** Ra lệnh bằng ngôn ngữ tự nhiên (VD: *"Backup mỗi đêm"*) để chạy ngầm tự động qua `cron`.
- 👥 **Phân quyền & Chạy song song:** Sinh ra các "Agent con" xử lý đa luồng hoặc gọi script Python trực tiếp.
- 🌍 **Sống ở mọi nơi (Lives where you do):** Tích hợp Telegram, Discord, Slack, WhatsApp... hỗ trợ nhận diện giọng nói.
- 💻 **Giao diện Terminal đỉnh cao:** Giao diện TUI hỗ trợ đa dòng, gợi ý lệnh (`/`) và stream dữ liệu thời gian thực.

---

## 2. Cách Truy cập Giao diện Quản trị (Dashboard)

Vì yếu tố bảo mật, `homelab.sh` triển khai Hermes Agent hoàn toàn **nội bộ (không mở port ra ngoài Internet)**. Để truy cập, bạn bắt buộc phải dùng **Cloudflare Tunnel**.

### Thiết lập Cloudflare Tunnel:
1. 🌐 Truy cập trang quản trị [Cloudflare Zero Trust](https://one.dash.cloudflare.com/).
2. 🛣️ Đi đến **Networks > Tunnels** và chọn Tunnel đang chạy trên máy chủ.
3. ➕ Bấm **Configure > Public Hostname > Add a public hostname**.
4. ⚙️ Cấu hình định tuyến:
   - 🏷️ **Subdomain:** `hermes` (tạo thành `hermes.yourdomain.com`).
   - 🌍 **Domain:** Chọn domain của bạn (`yourdomain.com`).
   - 🔌 **Type:** `HTTP`
   - 🔗 **URL:** `hermes:9119` *(Tên mạng nội bộ Docker và Port của giao diện Dashboard)*.
5. 💾 Bấm **Save hostname**. Sau đó truy cập `https://hermes.yourdomain.com` để vào Dashboard.

---

## 3. Thiết lập Lần Đầu (Initial Setup)

> [!IMPORTANT]
> Giao diện Web của Hermes sẽ bị **lỗi đỏ (agent init failed)** nếu nó chưa được cấp API Key (LLM). Bạn **không thể** cài đặt qua Web!

Hãy chạy kịch bản `homelab.sh` > **Quản lý Ứng dụng** > **Hermes Agent** > Chọn **[1] Cấu hình AI (API Key / Model)**. Màn hình cài đặt (TUI) sẽ hiện ra.

### Lựa chọn 1: Dùng chung với 9Router / OmniRoute (Khuyên dùng)
Tận dụng AI miễn phí từ AI Gateway có sẵn trong hệ thống:
- **Provider:** Chọn `OpenAI`
- **Custom Endpoint (URL):** `http://<IP_VPS_CỦA_BẠN>:8000/v1` (Port 8000 là của 9Router/OmniRoute).
- **API Key:** Nhập bừa (VD: `sk-homelab`).
- **Tên Model:** Nhập tên model đã gán trong Gateway (VD: `gpt-4o`).

### Lựa chọn 2: Dùng Nous Portal hoặc API trực tiếp
- **Nous Portal:** Tích hợp sẵn Tool Gateway (Firecrawl, FAL, TTS) không cần cấu hình lắt nhắt.
- **API Khác:** Chọn thẳng OpenAI, OpenRouter, Anthropic và dán API Key thật của bạn. Mọi lúc muốn đổi model, chỉ cần chạy lại Phím [1] trong `homelab.sh`.

---

## 4. Ứng Dụng Thực Tế (Use Cases)

### A. Thư ký Telegram đa năng
- Gửi đoạn ghi âm (Voice memo) vào Telegram lúc đang lái xe.
- Hermes sẽ tự dịch ra văn bản, tra cứu lịch trình hoặc gửi email thay bạn.

### B. Kỹ sư chạy ngầm (Cron)
- Yêu cầu: *"2h sáng mỗi ngày kiểm tra ổ cứng, vẽ biểu đồ gửi vào Discord"*.
- Hermes sẽ tự tạo cron job và thực thi mỗi đêm không cần bạn code.

### C. Khi nào dùng OpenClaw, Khi nào dùng Hermes?
- **OpenClaw:** Hỏi-đáp cá nhân, chat nhanh, trợ lý cơ bản.
- **Hermes Agent:** Tác vụ phức tạp (Cào web, code Python), cần **tự học** sau khi sai, hoặc chạy nền (Cron/Subagents). Móc nối 2 hệ thống qua API nội bộ (`homelab_net`) là tối ưu nhất!
