# 🦞 Hướng dẫn sử dụng & Vận hành OpenClaw (Homelab)

Tài liệu này hướng dẫn chi tiết cách kết nối, vận hành, và xử lý các lớp bảo mật khắt khe của ứng dụng **OpenClaw** được cài đặt thông qua kịch bản `homelab.sh`.

---

## 🔒 1. Cơ chế Bảo mật Kép của OpenClaw
OpenClaw là một AI Gateway cực kỳ chú trọng bảo mật. Để có thể truy cập và sử dụng Web UI của OpenClaw từ một trình duyệt lạ, bạn bắt buộc phải vượt qua **2 lớp bảo mật**:

1. **Lớp 1 (Xác thực Mật khẩu):** Yêu cầu nhập đúng `Mật khẩu Gateway`.
2. **Lớp 2 (Phê duyệt Thiết bị - Device Pairing):** Yêu cầu chủ hệ thống (người cầm quyền truy cập máy chủ VPS) phải chạy lệnh xác nhận thiết bị thì trình duyệt đó mới được phép đi vào.

> [!TIP]
> Nhờ kịch bản `homelab.sh`, quá trình vượt rào phức tạp này đã được tự động hóa và đơn giản hóa tối đa.

---

## 🔗 2. Hướng dẫn Kết nối và Phê duyệt Thiết bị (Lần đầu)
Sau khi cài đặt xong OpenClaw qua App Store, bạn làm theo các bước sau để kết nối:

### Bước 1: Vượt qua Lớp 1 (Mật khẩu)
Khi truy cập vào tên miền của OpenClaw (ví dụ: `https://openclaw.yourdomain.com`), bạn sẽ thấy màn hình yêu cầu xác thực.
- **URL WebSocket:** Giữ nguyên mặc định.
- **Token Gateway:** Bỏ trống.
- **Mật khẩu (không được lưu):** Điền `admin123` *(Đây là mật khẩu được `homelab.sh` thiết lập tự động)*.
- Nhấn **Kết nối (Connect)**.

### Bước 2: Vượt qua Lớp 2 (Phê duyệt thiết bị)
Sau khi bấm Kết nối, màn hình sẽ chuyển sang thông báo: **"Cần ghép đôi thiết bị (Trình duyệt này cần phê duyệt một lần...)"**.
Trên màn hình sẽ hiển thị một dòng lệnh có chứa mã thiết bị (Device ID) của bạn, dạng như sau:
`openclaw devices approve e28cfebc-03e1-4391-8fd6-17864fb118f6`

1. Quét khối (bôi đen) và **Copy toàn bộ dòng lệnh đó** (hoặc chỉ copy chuỗi mã ID dài).
2. Mở kịch bản `homelab.sh` trên máy chủ VPS của bạn.
3. Đi tới **Quản lý OpenClaw** -> Chọn **Phím 6 (Tiện ích mở rộng)** -> Chọn **Phím 3 (Phê duyệt thiết bị)**.
4. Dán nguyên đoạn mã vừa copy vào và nhấn Enter. Script sẽ tự động trích xuất ID và phê duyệt nó trên server.

Sau khi Terminal báo thành công, hãy quay lại trình duyệt và bấm **Kết nối** một lần nữa. Bạn sẽ được đưa thẳng vào giao diện điều khiển (Control UI) xanh lá cây tuyệt đẹp!

---

## ⚡ 3. Các Tiện ích Tự động của homelab.sh
Phiên bản `homelab.sh` hiện tại đã được tự động hóa hoàn toàn quy trình cài đặt hóc búa của OpenClaw:

1. ⚙️ **Tự động tạo cấu hình gốc (`openclaw.json`):** Ngay khi chọn cài đặt, Script sẽ mồi sẵn cấu hình, giúp OpenClaw khởi chạy mượt mà không bị treo ở lỗi `Missing config`.
2. 🌐 **Tự động vượt Proxy & CORS:** Script tự động đọc Tên miền (Domain), sau đó đưa các dải IP nội bộ vào `trustedProxies` và tên miền của bạn vào `allowedOrigins`. Nhờ vậy, OpenClaw hoạt động hoàn hảo phía sau Cloudflare Tunnels *(Không còn bị lỗi Proxy Attribution Required)*.
3. 🔑 **Tự động chèn Mật khẩu:** Cung cấp biến môi trường để OpenClaw đồng ý mở cổng ra mạng LAN.
4. 📂 **Tự động sửa lỗi phân quyền:** Tự động can thiệp sửa lỗi quyền ghi *(Fix `EACCES: permission denied`)* ngay khi ứng dụng vừa tải xong.

---

## 💬 4. Quản lý Mạng xã hội (Channels)
OpenClaw cung cấp 2 cách để tích hợp Bot AI vào mạng xã hội (như Telegram, Discord, WhatsApp):

### Cách 1: Sử dụng Giao diện Web (Khuyên dùng)
Trên Bảng điều khiển Gateway (Web UI), bạn chuyển sang tab **Kênh (Channels)**. Tại đây có đầy đủ giao diện đồ họa trực quan, hướng dẫn từng bước và hỗ trợ quét mã QR cực kỳ tiện lợi cho hàng loạt nền tảng (Zalo, Slack, Signal, v.v.).

### Cách 2: Cấu hình qua Script hoặc Terminal (Dành cho Coder)
Nếu bạn đang thao tác trực tiếp trên máy chủ và không muốn mở trình duyệt, bạn có thể:
1. Mở `homelab.sh` -> Quản lý OpenClaw -> **Phím 6 (Tiện ích)** -> **Phím 4 (Liên kết Chatbot)** để nhập Token nhanh.
2. Hoặc gõ lệnh trực tiếp:
```bash
docker exec -it openclaw openclaw channels add --channel telegram --token "<MÃ_TOKEN>"
```

---

## 🚑 5. Cẩm nang Xử lý Sự cố

> [!WARNING]
> Hầu hết các lỗi đã được `homelab.sh` xử lý triệt để lúc cài đặt. Nhưng nếu bạn táy máy hoặc cấu hình sai, dưới đây là cách cấp cứu:

### ❌ 5.1. Không thể kết nối WebSocket (Lỗi Proxy / CORS)
- **Dấu hiệu:** Màn hình trắng xóa hoặc hiển thị lỗi chữ đỏ `proxy_attribution_required`. Thường xảy ra nếu bạn vừa đổi sang tên miền mới.
- **Cách khắc phục:**
  1. Mở `homelab.sh` -> Quản lý OpenClaw -> **Phím 6 (Tiện ích)** -> **Phím 2 (Khởi tạo Cấu hình)**.
  2. Quay lại Menu, bấm **Phím 2 (Khởi động lại)**.

### ❌ 5.2. Lỗi EACCES hoặc EPERM (Không thể lưu cài đặt, đổi tên Agent)
- **Dấu hiệu:** Xem log báo lỗi `EACCES: permission denied` hoặc trên giao diện web báo lỗi đỏ `Error: EPERM: operation not permitted, fchmod` khi bạn cố gắng đổi tên, đổi avatar hoặc lưu cài đặt Agent.
- **Cách khắc phục:**
  1. Mở `homelab.sh` -> Quản lý OpenClaw -> **Phím 6 (Tiện ích)** -> **Phím 1 (Sửa lỗi quyền ghi Database)**. Kịch bản sẽ tự động chown và phân quyền lại toàn bộ thư mục.
  2. Quay lại web và bấm Lưu lại lần nữa, lỗi sẽ hoàn toàn biến mất.

### 🔑 5.3. Cách đổi mật khẩu Gateway
1. Mở `homelab.sh` -> Quản lý OpenClaw -> **Phím 5 (Chỉnh sửa cấu hình)**.
2. Tìm đến dòng `OPENCLAW_GATEWAY_PASSWORD=admin123` và sửa `admin123` thành mật khẩu siêu khó của bạn.
3. Bấm `Ctrl+X`, `Y`, `Enter` để lưu lại.
4. Quay ra bấm **Phím 4 (Cập nhật / Nạp lại cấu hình)** để OpenClaw nhận mật khẩu mới.
