# 🏠 Hướng dẫn Ứng dụng: Home Assistant (Nhà thông minh)

Home Assistant (HA) là nền tảng quản lý nhà thông minh mã nguồn mở mạnh mẽ nhất hiện nay, cho phép kết nối hàng ngàn thiết bị IoT từ nhiều hãng khác nhau về một chuẩn chung duy nhất.

Trong quá trình sử dụng Home Assistant trên hệ thống Homelab thông qua Cloudflare Tunnels, có một số vấn đề bảo mật đặc thù mà người dùng thường gặp phải. Kịch bản `homelab.sh` đã tích hợp sẵn các công cụ (Tiện ích mở rộng) để giải quyết triệt để các rào cản này.

---

## 🚫 1. Sửa lỗi 400 Bad Request (Lỗi Cloudflare)
Khi chạy HA qua Cloudflare Tunnels, hệ thống kết nối từ máy chủ Cloudflare thường bị HA coi là một IP Proxy giả mạo. Do cơ chế bảo mật nội bộ khắt khe của HA, nó sẽ từ chối kết nối và hiển thị màn hình trắng với dòng chữ `400 Bad Request` trên trình duyệt.

- **Cách khắc phục:** 
Trong Menu quản lý Home Assistant của `homelab.sh`, bạn chọn Tiện ích số 1: **"Sửa lỗi 400 Bad Request"**. 
Kịch bản sẽ tự động quét dải mạng LAN Docker nội bộ và chèn nó vào danh sách `trusted_proxies` trong file cấu hình `configuration.yaml` của HA. Cuối cùng, HA sẽ tự khởi động lại và bạn sẽ truy cập được bình thường.

---

## 🛒 2. Cài đặt kho ứng dụng HACS (Home Assistant Community Store)
HACS là chợ ứng dụng bên thứ 3 khổng lồ do cộng đồng đóng góp. Nơi đây cung cấp vô số các giao diện (themes), thẻ (cards), và các Tích hợp (Integration) độc quyền từ các thiết bị nội địa (như Tuya, Xiaomi, Broadlink) mà bản cài gốc của HA không hề có.

Việc cài đặt HACS thủ công thông thường yêu cầu bạn phải chui vào bash của container và chạy hàng loạt các lệnh rườm rà.

- **Cách khắc phục nhanh:** 
Chỉ cần chọn Tiện ích số 2: **"Cài đặt HACS"** trong menu quản lý HA của `homelab.sh`. Kịch bản sẽ tự động chạy script cài đặt HACS chính thức và nhúng nó vào Container của bạn trong vòng vài giây.

> [!IMPORTANT]
> Sau khi cài đặt HACS thành công qua script, HACS vẫn chưa hiển thị ngay ở menu bên trái. Bạn cần làm thêm một bước xác thực thủ công:
> 1. Đăng nhập vào Web UI của Home Assistant.
> 2. Truy cập mục **Cài đặt (Settings)** -> **Thiết bị & Dịch vụ (Devices & Services)**.
> 3. Bấm **Thêm Tích hợp (Add Integration)** ở góc dưới cùng bên phải.
> 4. Tìm kiếm từ khóa `HACS`.
> 5. Làm theo hướng dẫn trên màn hình, copy mã xác thực và đăng nhập vào tài khoản GitHub của bạn để liên kết (link) ứng dụng HACS.
