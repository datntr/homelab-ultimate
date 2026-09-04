# 🐘 Hướng dẫn kết nối Database & Cache (Core Services)

Xin chúc mừng! Bạn đã tích hợp thành công bộ đôi **PostgreSQL (Database)** và **Redis (Cache)** vào Homelab của mình. 

> [!TIP]
> Việc tách riêng cơ sở dữ liệu dùng chung (Shared DB) giúp bạn xây dựng các ứng dụng như NodeJS, Python hoặc cài thêm các nền tảng khác một cách chuyên nghiệp mà không sợ xung đột dữ liệu với N8N hay Home Assistant.

Dưới đây là cách mà các ứng dụng của bạn có thể kết nối với chúng:

---

## 1. Kết nối đến PostgreSQL
Trong môi trường Docker của Homelab, các container giao tiếp với nhau bằng **Tên Container (Hostname)** chứ không phải địa chỉ IP.

Khi bạn lập trình ứng dụng (NodeJS, Python, PHP...) và đưa vào chạy trên hệ thống, chỉ cần cấu hình chuỗi kết nối Database như sau:

- **Host (Máy chủ):** `postgres-core` *(Tuyệt đối không dùng `localhost` hay `127.0.0.1`)*
- **Port (Cổng):** `5432`
- **Username:** `postgres`
- **Password:** *[Mật khẩu ngẫu nhiên đã được script cấp cho bạn lúc cài]*
- **Database:** `postgres` *(Khuyên dùng: Dùng NodeJS/DBeaver tự tạo thêm Database khác tùy ý để phân tách từng project)*

**Ví dụ chuỗi kết nối (Connection String) trong NodeJS (Prisma/TypeORM):**
```text
postgresql://postgres:MAT_KHAU_CUA_BAN@postgres-core:5432/postgres
```

---

## 2. Kết nối đến Redis
Tương tự như PostgreSQL, Redis cũng nằm vùng "tàng hình" trong mạng LAN ảo `homelab_net`. Dùng để làm Cache lưu trữ tốc độ cao hoặc Message Queue.

- **Host (Máy chủ):** `redis-core`
- **Port (Cổng):** `6379`
- **Password:** *[Mật khẩu ngẫu nhiên đã được script cấp cho bạn]*

**Ví dụ chuỗi kết nối (Connection String) thông dụng:**
```text
redis://:MAT_KHAU_CUA_BAN@redis-core:6379
```

> [!WARNING]
> **Vấn đề bảo mật:** Vì các port `5432` và `6379` chỉ mở ngầm ở trong mạng ảo `homelab_net` (Docker Network), không map ra ngoài hệ điều hành máy chủ VPS, nên hacker không thể dùng các phần mềm dò quét (Scan Port) Internet để tìm ra Database của bạn. Hệ thống an toàn ở mức tuyệt đối!

---

## 3. Nếu muốn thao tác từ bên ngoài VPS (Dành cho Dev)
Nếu bạn đang ngồi ở máy tính cá nhân (Desktop/Laptop) và muốn dùng phần mềm quản trị CSDL như **DBeaver, Navicat, hay PgAdmin** để kết nối trực tiếp vào xem data thì làm thế nào?

**Cách xử lý qua Portainer:**
1. Hãy cài **Portainer** (số 12 trong Menu). 
2. Vào giao diện Portainer (ví dụ: `http://ip-vps:9000`), mở phần cấu hình của container `postgres-core`.
3. Bấm **Duplicate/Edit**, kéo xuống mục *Network ports configuration*.
4. Bấm **Publish a new network port** và cấu hình map ra ngoài tạm thời (ví dụ map thành `host: 5432 -> container: 5432`). Bấm Deploy the container.
5. Bây giờ bạn có thể dùng DBeaver kết nối vào `IP_VPS_CUA_BAN:5432` để chỉnh sửa cấu trúc bảng.
6. **[RẤT QUAN TRỌNG]** Sau khi chỉnh sửa cấu trúc (schema) và data xong, nhớ vào lại Portainer xóa cái map port 5432 đi để đóng kín hệ thống, đảm bảo không ai có thể xâm nhập!
