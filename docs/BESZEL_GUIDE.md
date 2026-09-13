# 📊 Hướng dẫn Toàn diện: Beszel (Giám sát Phần cứng & Docker Siêu Nhẹ)

**Beszel** là giải pháp giám sát máy chủ và container Docker hiện đại, siêu nhẹ, tiêu tốn cực ít tài nguyên (chỉ vài chục MB RAM) nhưng sở hữu giao diện trực quan, biểu đồ thời gian thực đẹp mắt và hệ thống cảnh báo mạnh mẽ.

Trong hệ sinh thái **Homelab Ultimate**, Beszel được thiết lập trọn gói cả **Hub (Trung tâm hiển thị)** và **Agent (Trình thu thập chỉ số)** chạy song song, giao tiếp nội bộ siêu tốc qua **Unix Domain Socket** mà không cần mở bất kỳ cổng mạng trung gian nào.

---

## 🌟 1. Tính Năng Nổi Bật

- ⚡ **Siêu nhẹ & Hiệu năng cao:** Viết bằng Go và PocketBase, tiêu thụ CPU/RAM gần như bằng 0, nhẹ hơn đáng kể so với Netdata, Prometheus hay Grafana.
- 🐳 **Thống kê Container Docker theo thời gian thực:** Tự động theo dõi CPU, RAM, Network I/O của toàn bộ các container đang chạy trên hệ thống.
- 🔒 **Bảo mật tuyệt đối qua ED25519:** Xác thực giữa Hub và Agent thông qua cặp khóa mã hóa SSH Ed25519, không dùng mật khẩu thô.
- ⚡ **Giao tiếp Unix Socket nội bộ:** Hub và Agent nói chuyện trực tiếp qua file socket chia sẻ (`/beszel_socket/beszel.sock`), miễn nhiễm 100% với việc bị tường lửa UFW/iptables hay Docker Bridge chặn port.
- 🔔 **Hệ thống Cảnh báo đa kênh:** Hỗ trợ cảnh báo qua Telegram, Discord, Email, Pushover, Webhook khi CPU, RAM, Dung lượng ổ cứng vượt ngưỡng.

---

## 🚀 2. Hướng Dẫn Sử Dụng Sau Khi Cài Đặt (Máy Chủ Chính)

### Bước 1: Đăng nhập WebUI
- Sau khi cài đặt từ menu `homelab.sh` (Mục 10 trong App Store), truy cập vào tên miền bạn đã cấu hình (ví dụ: `https://beszel.yourdomain.com`) hoặc `http://IP_MAY_CHU:8090`.
- Đăng nhập bằng tài khoản được script khởi tạo tự động:
  - **Email:** `admin@homelab.local`
  - **Mật khẩu:** `admin123` *(Bạn có thể đổi mật khẩu bất kỳ lúc nào)*

### Bước 2: Thêm Máy chủ Homelab vào Giám sát
Khi vào WebUI lần đầu, danh sách máy chủ sẽ trống (chỉ hiện thanh menu trên cùng). Bạn thêm máy chủ nội bộ chỉ trong 10 giây:

1. Bấm nút **`+ Thêm Hệ thống`** (hoặc `+ Add System`) ở góc trên bên phải màn hình.
2. Điền các trường thông tin:
   - **Tên (Name):** `HomeLab` *(hoặc đặt tên tùy ý)*.
   - **Máy chủ / IP (Host / IP):** Điền chính xác đường dẫn socket nội bộ:
     ```text
     /beszel_socket/beszel.sock
     ```
   - **Cổng (Port):** Để mặc định hoặc để trống (dùng Unix socket thì không cần quan tâm cổng).
   - **Khóa (Public Key):** Giữ nguyên khóa mặc định được sinh sẵn.
3. Bấm nút màu trắng **Thêm Hệ thống** (Save) ở góc dưới bên phải.
4. 🎉 **Kết quả:** Trạng thái hệ thống sẽ lập tức đổi sang màu **Xanh lá (Connected)** và bảng điều khiển bung ra đầy đủ biểu đồ CPU, RAM, Disk, Docker Stats.

---

## 🌐 3. Cách Kết Nối Thêm Các Máy Chủ Khác (Remote Server)

Một Hub Beszel duy nhất có thể quản lý hàng chục máy chủ khác nhau (VPS mua ngoài, server phụ, máy tính tại nhà...). 

> [!NOTE]
> **Máy chủ khác KHÔNG CẦN cài đặt lại Hub!**
> Bạn chỉ cần cài duy nhất trình thu thập **Beszel Agent** (chỉ tốn ~10MB RAM) theo các bước dưới đây.

---

### 🟢 TRƯỜNG HỢP A: Máy chủ từ xa có IP Public (VPS, Cloud Server)

Đây là phương thức chuẩn và phổ biến nhất (kết nối trực tiếp qua SSH port 45876).

#### Bước 1: Khai báo trên WebUI (Hub chính)
1. Mở WebUI Beszel trên máy chính > Bấm **`+ Thêm Hệ thống`**.
2. Điền thông tin máy từ xa:
   - **Tên:** Đặt tên gợi nhớ (VD: `GreenVPS`, `VPS-Singapore`...).
   - **Máy chủ / IP:** Nhập **IP Public** của máy kia (VD: `103.xxx.xxx.xxx`).
   - **Cổng:** `45876` (giữ nguyên mặc định).
   - **Khóa & Token:** Hệ thống tự động điền sẵn khóa của Hub.

#### Bước 2: Lấy lệnh cài đặt Agent
Ở góc dưới bên trái hộp thoại, có nút **`Sao chép docker compose`** và một mũi tên chỉ xuống `v`:
- 👉 Bấm vào mũi tên `v` đó và chọn **`Sao chép docker run`** *(để lấy lệnh chạy nhanh 1 dòng duy nhất, không cần mất công tạo file compose trên VPS kia)*.

#### Bước 3: Chạy lệnh trên máy chủ từ xa
1. Mở SSH vào máy chủ từ xa với quyền **`root`** (hoặc dùng `sudo`).
2. Bạn có thể đứng ở **bất kỳ thư mục nào** (ở ngay `/root`, `/home`... đều được vì Docker container chạy nền độc lập với thư mục).
3. **Dán (Paste)** dòng lệnh vừa sao chép vào Terminal và bấm Enter:
   ```bash
   docker run -d \
     --name beszel-agent \
     --network host \
     --restart unless-stopped \
     -v /var/run/docker.sock:/var/run/docker.sock:ro \
     -e KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..." \
     henrygd/beszel-agent:latest
   ```
4. **Mở cổng tường lửa trên máy kia (Rất quan trọng):**
   - Nếu máy từ xa dùng Ubuntu/Debian (UFW):
     ```bash
     sudo ufw allow 45876/tcp
     ```
   - Nếu dùng CentOS/RHEL/AlmaLinux (Firewalld):
     ```bash
     sudo firewall-cmd --permanent --add-port=45876/tcp && sudo firewall-cmd --reload
     ```
5. Kiểm tra container đã chạy:
   ```bash
   docker ps
   # Thấy container "beszel-agent" có trạng thái "Up" là thành công!
   ```

#### Bước 4: Hoàn tất
Quay lại WebUI máy chính, bấm nút màu trắng **`Thêm Hệ thống`** ở góc dưới bên phải. Sau vài giây, máy chủ mới sẽ **sáng đèn Xanh lá** và bắt đầu truyền số liệu về!

> [!WARNING]
> ### ⚠️ Nếu bạn từng chạy Agent trước đó hoặc xóa trên Hub rồi thêm lại:
> Trên máy chủ từ xa / máy con, nếu bạn đã từng chạy lệnh `docker run` trước đó thì container `beszel-agent` đã tồn tại. Nếu bạn xóa máy trên WebUI rồi thêm lại và dán tiếp lệnh mới, Docker sẽ báo lỗi xung đột:
> ```text
> docker: Error response from daemon: Conflict. The container name "/beszel-agent" is already in use by container "..."
> ```
> **Cách xử lý:** Trước khi chạy lệnh mới, bạn chỉ cần gỡ bỏ container cũ bằng một lệnh duy nhất:
> ```bash
> docker rm -f beszel-agent
> ```
> Sau đó dán lại lệnh `docker run` mới là sẽ chạy mượt mà ngay lập tức!

---

### 🔵 TRƯỜNG HỢP B: Máy chủ KHÔNG CÓ IP Public (Máy tính ở nhà, Raspberry Pi sau mạng NAT/CGNAT)

Nếu máy kia đặt ở gia đình không có IP tĩnh/IP Public, hoặc bạn không muốn mở cổng 45876, hãy sử dụng chế độ **WebSocket** (Agent sẽ chủ động gửi dữ liệu về Hub qua Domain Cloudflare):

1. Trên WebUI Hub, bấm vào biểu tượng ⚙️ **Cài đặt (Settings)** > Mục **Tokens** > Tạo một Token mới.
2. Trên máy tính ở nhà, mở Terminal lên và chạy lệnh sau:
   ```bash
   docker run -d \
     --name beszel-agent \
     --network host \
     --restart unless-stopped \
     -v /var/run/docker.sock:/var/run/docker.sock:ro \
     -e KEY="<PUBLIC_KEY_CỦA_HUB>" \
     -e HUB_URL="https://beszel.yourdomain.com" \
     -e TOKEN="<TOKEN_VỪA_TẠO>" \
     henrygd/beszel-agent:latest
   ```
   *(Thay `https://beszel.yourdomain.com` bằng tên miền Beszel của bạn)*
3. **Kết quả:** Agent sẽ tự động vượt tường lửa gia đình kết nối thẳng về Hub mà bạn **không cần mở bất kỳ cổng nào trên modem nhà**!

---

## 🛠️ 4. Tiện Ích Mở Rộng Trong `homelab.sh`

Mọi lúc cần quản trị, trên máy chủ chính bạn chỉ cần gõ:
```bash
sudo ./homelab.sh
```
Chọn **Quản lý Ứng dụng** > **Beszel** > Chọn **[6] Tiện ích mở rộng**:

- 🔑 **[1] Xem Tài khoản & Mật khẩu:** Tra cứu nhanh Email và Mật khẩu đăng nhập WebUI (được lưu trong `.env`).
- 🔄 **[2] Đổi Mật khẩu:** Đổi mật khẩu tài khoản tự động 100% từ terminal (Script tự động gọi PocketBase API can thiệp vào SQLite database và cập nhật lại file `.env`).
- 🛡️ **[3] Xem Public Key của Agent:** Hiển thị khóa SSH Ed25519 dùng khi bạn muốn cấu hình Agent thủ công trên máy khác.
- 📖 **[4] Hướng dẫn Kết nối Máy chủ:** Xem nhanh hướng dẫn điền socket Host `/beszel_socket/beszel.sock`.

*(Để khởi động lại ứng dụng, bạn chỉ cần dùng chức năng số `[1] Khởi động lại` ngay tại menu chính của Beszel).*

---

## 🔐 5. Hướng Dẫn Đổi Mật Khẩu & Cơ Chế Xác Thực

Beszel được xây dựng trên nền tảng **PocketBase (Go + SQLite)**. Cơ chế tài khoản có 2 điểm đặc biệt bạn cần nắm rõ:

> [!IMPORTANT]
> 1. **Giao diện WebUI chính của Beszel HOÀN TOÀN KHÔNG CÓ nút Đổi mật khẩu.** (Tác giả thiết kế giao diện chính chỉ thuần túy để xem biểu đồ thống kê).
> 2. **File `.env` CHỈ có tác dụng ở lần đầu tiên cài đặt.** Sau khi database SQLite đã được tạo (`data.db`), việc sửa `USER_PASSWORD` trong `.env` rồi restart Docker sẽ **KHÔNG làm thay đổi mật khẩu trong database**.

### 👉 2 Cách Đổi Mật Khẩu Chuẩn Xác:

#### Cách 1: Dùng tính năng Đổi mật khẩu tự động trong `homelab.sh` (Khuyên dùng - Nhanh nhất)
1. Mở script trên máy chủ: `sudo ./homelab.sh`
2. Vào **Quản lý Ứng dụng** > **Beszel** > Chọn **[6] Tiện ích mở rộng** > Chọn **[2] Đổi mật khẩu**.
3. Nhập mật khẩu mới bạn muốn đặt.
4. 🎉 **Xong ngay:** Script sẽ tự động gọi PocketBase API cập nhật trực tiếp vào cơ sở dữ liệu SQLite và đồng bộ vào file `.env`. Bạn có thể đăng nhập WebUI bằng mật khẩu mới ngay lập tức mà không cần làm gì thêm!

#### Cách 2: Đổi thủ công qua Trang quản trị ngầm PocketBase (`/_/`)
Nếu bạn muốn tự tay quản lý trong cơ sở dữ liệu:
1. Mở SSH trên máy chủ chính, tạo tài khoản Superuser quản trị database:
   ```bash
   docker exec -it beszel /beszel superuser upsert admin@homelab.local MatKhauMoi123
   ```
2. Mở trình duyệt truy cập vào đường dẫn quản trị database (bắt buộc có đuôi `/_/`):
   ```text
   https://beszel.yourdomain.com/_/
   ```
3. Đăng nhập bằng email `admin@homelab.local` và mật khẩu `MatKhauMoi123` vừa tạo.
4. Ở cột bên trái, chọn bảng **`users`** > Nhấp vào dòng tài khoản của bạn > Cuộn xuống trường **Password** và **Password Confirm**, nhập mật khẩu mới và bấm **Save changes**.

---

## ❓ 6. Xử Lý Sự Cố Thường Gặp (Troubleshooting)

### 🔴 Đã đổi mật khẩu thành công trong .env nhưng đăng nhập báo "Nỗ lực đăng nhập thất bại"
- **Nguyên nhân:** File `.env` đã nhận mật khẩu mới nhưng cơ sở dữ liệu SQLite của Beszel vẫn đang lưu mật khẩu cũ (`admin123`), và WebUI chính của Beszel không có nút đổi mật khẩu.
- **Khắc phục:** 
  - **Cách nhanh nhất:** Chạy `sudo ./homelab.sh` > Beszel > Tiện ích mở rộng > Chọn **[2] Đổi mật khẩu** để script tự động ghi đè mật khẩu mới vào database SQLite.
  - **Hoặc đăng nhập tạm:** Hãy gõ mật khẩu cũ (**`admin123`**) vào ô đăng nhập để vào xem biểu đồ bình thường.

### 🔴 Máy chủ Homelab nội bộ báo đỏ (Offline)
- **Nguyên nhân:** Điền `localhost`, `127.0.0.1` hay `host.docker.internal` khiến Docker Bridge Network chặn kết nối giữa 2 container.
- **Giải pháp:** Chỉnh sửa Host/IP thành đúng đường dẫn:
  ```text
  /beszel_socket/beszel.sock
  ```

### 🔴 Máy chủ từ xa báo đỏ (Offline)
1. **Kiểm tra cổng 45876:** Máy từ xa đã chạy `sudo ufw allow 45876/tcp` chưa? Nếu thuê VPS trên AWS, Oracle, Google Cloud thì phải mở thêm Security Group / Firewall Rules trên trang quản trị nhà mạng.
2. **Kiểm tra Public Key:** Đảm bảo chuỗi `KEY="..."` khi chạy container trên máy từ xa khớp chính xác với Public Key của Hub (Xem lại ở Phím 3 Tiện ích mở rộng).

### 🐳 Không hiển thị danh sách Docker Containers
- Đảm bảo tham số `-v /var/run/docker.sock:/var/run/docker.sock:ro` có trong lệnh chạy agent.
- Đợi 30 giây đến 1 phút để Agent hoàn tất chu kỳ ping lấy chỉ số đầu tiên.
