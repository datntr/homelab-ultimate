# 🌌 Hướng dẫn Cài đặt & Sử dụng OmniRoute (The Free AI Gateway)

## 🎯 1. OmniRoute là gì?
OmniRoute là một Cổng kết nối AI (AI Gateway) siêu mạnh mẽ. Nó đóng vai trò như một người "đứng giữa", nhận câu hỏi từ bạn (hoặc từ N8N) và tự động phân luồng gửi đến các nhà cung cấp AI.

Điểm "đáng sợ" nhất của OmniRoute là khả năng **Zero-Config (Không cần cấu hình)**. Nó được tích hợp sẵn hơn 350+ nhà cung cấp AI, trong đó có một kho API Key miễn phí (Free Tiers) cung cấp cho bạn khoảng **1.5 Tỉ Token miễn phí mỗi tháng**. Bạn không cần phải đau đầu đi tạo tài khoản hay nạp tiền ở bất cứ đâu!

---

## 🛠️ 2. Cài đặt OmniRoute qua Homelab Script

Script `homelab.sh` đã được tích hợp tự động hóa hoàn toàn việc cài đặt OmniRoute (kèm theo cả Redis để quản lý Rate Limit).

**Các bước cài đặt:**
1. Mở Terminal kết nối vào VPS, chạy script `homelab.sh`.
2. Truy cập **Menu 3 (Cửa hàng Ứng dụng - App Store)**.
3. Bấm **Phím 7** để Xóa sạch bản OmniRoute cũ (Nếu trước đó bạn cài bị lỗi).
4. Vẫn ở Menu 3, chọn phím số tương ứng với **OmniRoute** để cài đặt mới.
5. Khi hệ thống yêu cầu, hãy nhập một Subdomain (Tên miền phụ) mong muốn. VD: `ai.yourdomain.com`.
6. Chờ vài phút để hệ thống tải Docker Image và khởi động.

> [!NOTE]
> **Về thông báo "Đang chạy ở chế độ không cần cấu hình" (Zero-Config):**
> Kịch bản `homelab.sh` đã tự động đúc sẵn 2 khóa bảo mật siêu mạnh (JWT_SECRET và STORAGE_ENCRYPTION_KEY) và ghim vĩnh viễn vào tệp `docker-compose.yml` của bạn để bảo vệ dữ liệu. 
> Nếu bạn vẫn thấy thông báo màu vàng phàn nàn về việc này trên trang chủ OmniRoute, **hãy khởi động lại container** (hoặc chọn mục Khởi động lại trong Menu quản lý ứng dụng của kịch bản). Sau khi khởi động lại, OmniRoute sẽ nhận diện được khóa mới và thông báo sẽ biến mất hoàn toàn!

---

## 🌐 3. Đưa OmniRoute ra Internet bằng Cloudflare Tunnel
Vì OmniRoute chạy trong mạng ảo nội bộ (`homelab_net`), bạn cần phải cấu hình Cloudflare để có thể truy cập Dashboard từ bên ngoài.

1. Đăng nhập vào trang quản trị **Cloudflare Zero Trust**.
2. Chuyển đến mục **Networks > Tunnels**. Bấm vào Tunnel VPS của bạn.
3. Sang tab **Public Hostname**, bấm `Add a public hostname`.
4. Điền cấu hình như sau:
   - **Subdomain:** Tên miền phụ bạn vừa nhập ở trên (VD: `ai`).
   - **Domain:** Tên miền gốc của bạn (VD: `yourdomain.com`).
   - **Type:** Chọn `HTTP`.
   - **URL:** Gõ chính xác `omniroute:20128` (Đây là cổng gốc của Dashboard OmniRoute).
5. Bấm Save. Vậy là xong!

---

## 🤖 4. Hướng dẫn sử dụng trong N8N
Khi đã có OmniRoute, bạn không cần phải khai báo từng API Key rườm rà trong N8N nữa. Chỉ cần kết nối một lần duy nhất theo chuẩn OpenAI.

1. Mở Workflow của N8N, kéo thả một Node **OpenAI (Chat Model)**.
2. Tại phần **Credential**, tạo chứng chỉ mới kiểu **Custom API** (Hoặc OpenAI Custom API).
3. Điền cấu hình:
   - **Base URL:** `https://[Ten_Mien_OmniRoute]/v1` 
   *(Lưu ý: BẮT BUỘC phải có đuôi `/v1` ở cuối. VD: `https://ai.yourdomain.com/v1`)*.
   - **API Key:** Gõ bừa một chuỗi ký tự bất kỳ (VD: `sk-123456`). OmniRoute tự động che key này và dùng Key miễn phí nội bộ của nó.
4. Ở phần chọn **Model** trong Node N8N, thay vì chọn tên model cụ thể (như gpt-4), bạn hãy bấm vào biểu tượng "Bánh răng" (Expression) và gõ chữ: `auto`.
   
> [!TIP]
> 👉 **Giải thích tính năng `auto`:** Khi nhận được model `auto`, OmniRoute sẽ khởi động cỗ máy chấm điểm. Nó sẽ phân tích xem câu hỏi của bạn là gì, kiểm tra 350+ nhà cung cấp xem server nào đang rảnh, server nào trả lời Code tốt nhất, và đặc biệt là server nào đang MIỄN PHÍ. Sau đó nó tự động gửi yêu cầu đến server chiến thắng. Bạn luôn nhận được câu trả lời nhanh nhất và rẻ nhất (hoặc 0đ) mà không cần bận tâm ở đằng sau nó đang dùng AI của hãng nào!

---

## 📊 5. Bảng điều khiển (Dashboard)
Để theo dõi bạn đang tiết kiệm được bao nhiêu tiền và hệ thống `auto` đang chọn model nào, hãy truy cập vào bảng điều khiển bằng tên miền của bạn:

👉 **Truy cập:** `https://[Ten_Mien_OmniRoute]/dashboard`

Tại đây bạn có thể xem biểu đồ Request, Logs thời gian thực, cũng như tự tay cấu hình các Combo luân chuyển Model cực đỉnh của OmniRoute. Mọi thứ đã sẵn sàng!
