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
- **Provider:** Chọn `custom` (Hermes nhận diện custom endpoint qua provider `custom` hoặc cấu hình base_url).
- **Custom Endpoint (URL):** `http://9router:20128/v1` (Port 20128 nội bộ Docker) hoặc `http://<IP_VPS>:20128/v1`.
- **API Key:** Nhập API Key từ 9Router/OmniRoute (VD: `sk-ad333ff94f...`).
- **Tên Model:** Nhập tên model đã gán trong Gateway (VD: `gemini-3.8-flash`).

### Lựa chọn 2: Dùng Nous Portal hoặc API trực tiếp
- **Nous Portal:** Tích hợp sẵn Tool Gateway (Firecrawl, FAL, TTS) không cần cấu hình lắt nhắt.
- **API Khác:** Chọn thẳng OpenAI, OpenRouter, Anthropic và dán API Key thật của bạn. Mọi lúc muốn đổi model, chỉ cần chạy lại Phím [1] trong `homelab.sh`.

---

## 4. Các Tiện Ích Mở Rộng & Quản Trị (Menu Phím 6)

Kịch bản `homelab.sh` tích hợp sẵn bộ công cụ quản lý toàn diện cho Hermes Agent (vào **Quản lý Hermes Agent -> Phím 6: Tiện ích mở rộng**):

| Phím | Tên tiện ích | Chức năng chi tiết |
| :--- | :--- | :--- |
| **1** | **🧠 Cấu hình AI** | Đổi nhanh Base URL, API Key, Model AI (9Router, OmniRoute, OpenAI, Nous Portal). |
| **2** | **🔑 Xem Mật khẩu** | Hiển thị thông báo trạng thái bảo mật tài khoản Dashboard. |
| **3** | **🔄 Đổi Mật khẩu** | Tự động băm (hash) mật khẩu mới bằng thuật toán **`scrypt`** chuẩn của Hermes, xóa trường lộ chữ và khởi động lại an toàn. |
| **4** | **⚡ Chuyển đổi Chế độ** | Chuyển đổi linh hoạt giữa **All-in-one** và **Dedicated** mà không làm mất cấu hình hoặc biến môi trường khác. |
| **5** | **🚀 Bật / Khởi động lại Gateway** | Kích hoạt Messaging Gateway (Telegram / Home Assistant) với user `hermes` và cờ `--no-supervise` nếu bị gián đoạn. |

---

## 5. Hai Chế Độ Hoạt Động Của Hermes (Dedicated vs All-in-one)

Hermes trong Docker hỗ trợ 2 mô hình triển khai:

1. 🖥️ **Mô hình Dedicated (Mặc định khi cài đặt - Khuyên dùng):**
   - **Cách hoạt động:** Chỉ khởi chạy riêng giao diện Web Dashboard, tắt hoàn toàn tiến trình Messaging Gateway.
   - **Cấu hình trong Compose:** Khai báo `command: dashboard --host 0.0.0.0`.
   - **Ưu điểm:** Tiết kiệm tài nguyên RAM/CPU tối đa, ổn định tuyệt đối khi bạn chỉ muốn chat và quản lý qua trình duyệt Web.

2. 🌐 **Mô hình All-in-one (Chạy song song cả Gateway Telegram/HA + Web):**
   - **Cách hoạt động:** Container tự động chạy song song cả **Messaging Gateway** (kết nối Telegram, Home Assistant) lẫn **Web Dashboard** (cổng 9119).
   - **Cấu hình trong Compose:** Khai báo lệnh chạy gateway và biến bật Dashboard:
     ```yaml
     command: gateway run
     environment:
       - HERMES_DASHBOARD=true
       - HERMES_DASHBOARD_HOST=0.0.0.0
     ```
   - **Ưu điểm:** Mỗi khi restart container hoặc khởi động lại máy chủ, bot Telegram và HA luôn tự động online cùng lúc với Web Dashboard.

> [!TIP]
> Bạn có thể chuyển đổi qua lại giữa 2 chế độ này bất cứ lúc nào bằng **Phím 4** trong menu Tiện ích của `homelab.sh`. Script sẽ tự động sao lưu file `docker-compose.yml.bak` trước khi thực hiện.

---

## 6. Lệnh Thủ Công Hữu Ích (Dành cho Quản Trị Viên)

Nếu bạn thao tác qua SSH Terminal từ máy chủ Host:

- **Bật Gateway nền:**
  ```bash
  docker exec -u hermes -e HERMES_HOME=/opt/data -e HOME=/opt/data/home -d hermes /opt/hermes/.venv/bin/hermes gateway run --no-supervise
  ```
- **Kiểm tra trạng thái Gateway:**
  ```bash
  docker exec -u hermes -e HERMES_HOME=/opt/data -e HOME=/opt/data/home hermes /opt/hermes/.venv/bin/hermes gateway status
  ```
- **Xem danh sách Profile:**
  ```bash
  docker exec -it hermes hermes profile list
  ```

---

## 7. Ứng Dụng Thực Tế (Use Cases)

### A. Thư ký Telegram đa năng
- Gửi đoạn ghi âm (Voice memo) vào Telegram lúc đang lái xe.
- Hermes sẽ tự dịch ra văn bản, tra cứu lịch trình hoặc gửi email thay bạn.

### B. Kỹ sư chạy ngầm (Cron)
- Yêu cầu: *"2h sáng mỗi ngày kiểm tra ổ cứng, vẽ biểu đồ gửi vào Discord"*.
- Hermes sẽ tự tạo cron job và thực thi mỗi đêm không cần bạn code.

### C. Khi nào dùng OpenClaw, Khi nào dùng Hermes?
- **OpenClaw:** Hỏi-đáp cá nhân, chat nhanh, trợ lý cơ bản.
- **Hermes Agent:** Tác vụ phức tạp (Cào web, code Python), cần **tự học** sau khi sai, hoặc chạy nền (Cron/Subagents). Móc nối 2 hệ thống qua API nội bộ (`homelab_net`) là tối ưu nhất!
