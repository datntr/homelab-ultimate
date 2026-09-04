# ☁️ Hướng dẫn Cấu hình: Cloudflare Tunnel (Zero-Trust)

Homelab này được thiết kế theo kiến trúc **Zero-Port Exposure** (Không mở port ra Internet). Điều này có nghĩa là mọi kết nối từ bên ngoài Internet đi vào các dịch vụ (N8N, Home Assistant, OpenClaw...) đều phải đi qua một đường hầm bảo mật gọi là **Cloudflare Tunnel**.

> [!TIP]
> Đây là phương pháp bảo mật an toàn nhất hiện nay, giúp ẩn hoàn toàn địa chỉ IP thật của VPS và tận dụng được tường lửa (WAF) cực mạnh của Cloudflare.

---

## 🛠️ 1. Yêu cầu chuẩn bị
- 🌍 Một tên miền (Domain) đã được trỏ Nameserver về Cloudflare.
- ☁️ Tài khoản Cloudflare (hoàn toàn miễn phí).
- 💻 Một VPS (đã cài đặt kịch bản `homelab.sh` và thiết lập Docker).

---

## 🚀 2. Cách thiết lập Cloudflare Tunnel
1. 🔑 Đăng nhập vào trang quản trị Cloudflare -> Chọn **Zero Trust** ở cột bên trái.
2. 🧭 Điều hướng tới **Networks** -> **Tunnels** -> Chọn **Add a tunnel**.
3. ☁️ Chọn loại **Cloudflared** -> Bấm Next và đặt tên cho Tunnel (ví dụ: `MyHomelab`).
4. 💻 Ở màn hình "Install and run a connector", bạn hãy kéo xuống mục **Docker**. Bạn sẽ thấy một dòng lệnh có chứa `token`.
   - 📌 Lệnh có dạng: `docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJ...`
   - 📋 Hãy **copy** chuỗi token dài bắt đầu bằng `eyJ...`.

5. 🔙 Quay lại VPS của bạn, mở kịch bản `homelab.sh` -> Chọn Menu số **2 (Cấu hình Cloudflare Tunnel)**.
6. 🪄 Dán chuỗi Token vừa copy vào. Script sẽ tự động thiết lập và chạy một container ngầm để đào hầm kết nối từ VPS của bạn tới máy chủ Cloudflare.

---

## 🌐 3. Định tuyến Tên miền (Public Hostname)
Sau khi Tunnel báo trạng thái **Healthy (Màu xanh)** trên trang web Cloudflare, bạn có thể bắt đầu tạo tên miền phụ cho các dịch vụ.

Tại trang quản lý Tunnel, chuyển qua tab **Public Hostname** -> **Add a public hostname**.

- **Subdomain:** Nhập tên dịch vụ (ví dụ: `n8n`, `ha`, `ai`).
- **Domain:** Chọn tên miền của bạn.
- **Service Type:** `HTTP`
- **URL:** Tên của Container nội bộ và Port của nó.

### 📋 Bảng URL nội bộ (Tham chiếu)
| Ứng dụng | URL định tuyến |
|----------|---------------|
| **N8N** | `n8n:5678` |
| **Home Assistant**| `homeassistant:8123` |
| **9Router** | `9router:20128` |
| **OpenClaw** | `openclaw:18789` |
| **Portainer** | `portainer:9000` |
| **Uptime Kuma** | `uptimekuma:3001` |
| **Dozzle** | `dozzle:8080` |
| **NodeJS** | `nodejs:3000` |

> [!NOTE]
> Chỉ cần gõ đúng cấu trúc `tên_container:cổng`. Do Cloudflare Tunnel nằm cùng mạng `homelab_net` với các container khác, nó sẽ tự động nhận diện dịch vụ thông qua DNS nội bộ của Docker mà không cần IP cụ thể.

---

## 🛡️ 4. Bảo vệ dịch vụ bằng Cloudflare Access (Nâng cao)
Đối với các dịch vụ không có màn hình đăng nhập, hoặc bạn muốn thiết lập lớp bảo mật 2 lớp (2FA), hãy sử dụng **Cloudflare Access** (Tạo lớp khiên chắn yêu cầu Email OTP trước khi vào web).

1. 🛡️ Trong màn hình Zero Trust, chọn **Access** -> **Applications** -> **Add an application**.
2. 🏠 Chọn **Self-hosted**.
3. 🏷️ Đặt tên ứng dụng và điền đúng Tên miền (Subdomain) đã gán ở bước 3.
4. 🔐 Ở tab **Policies**, tạo một Policy yêu cầu người truy cập phải nhập mã OTP gửi qua Email của bạn (chọn Action `Allow` và rule `Include -> Emails`).
5. ✅ Hoàn tất. Bất kỳ ai truy cập vào link web đó sẽ thấy màn hình chặn của Cloudflare.

> [!WARNING]
> Không nên áp dụng Access cho các API endpoint (như OpenClaw hoặc 9Router) nếu bạn định dùng chúng qua Code, vì code không thể tự nhập mã OTP. Chỉ nên dùng Access cho giao diện Web UI (như Dozzle, Portainer).
