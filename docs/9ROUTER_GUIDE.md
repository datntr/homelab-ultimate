# 🚦 Hướng dẫn Ứng dụng: 9Router (Trạm trung chuyển AI)

9Router không phải là router định tuyến mạng Internet thông thường, mà là một **AI Router (Trạm trung chuyển API Trí tuệ Nhân tạo)**. Nó đóng vai trò làm cầu nối trung gian giữa các công cụ lập trình AI (như Cursor, Copilot, Antigravity, Claude Code) và hơn 60 nhà cung cấp mô hình AI khác nhau (OpenAI, Gemini, Anthropic, Qwen...).

---

## 🌟 1. Tính năng cốt lõi
- 🔀 **Định tuyến thông minh 3 lớp (3-Tier Auto Fallback):** Khi cấu hình tài khoản VIP của bạn hết hạn ngạch (Quota) hoặc bị lỗi rate-limit, 9Router sẽ tự động nhảy sang dùng các API giá rẻ dự phòng, và cuối cùng là nhảy sang các API hoàn toàn miễn phí. Đảm bảo bạn không bao giờ bị gián đoạn khi đang hăng say code.
- 🗜️ **Cơ chế Tiết kiệm Token (RTK & Caveman Mode):** Tự động nén dữ liệu đầu vào (ví dụ: nội dung file cực dài, output của git diff/grep) và ép AI trả lời siêu ngắn gọn. Tính năng này giúp tiết kiệm từ 20-65% dung lượng token mà chất lượng code không thay đổi.

---

## 🚀 2. Cách sử dụng (Cơ bản)
Sau khi cài đặt xong qua script `homelab.sh`:

1. Truy cập vào giao diện Web UI của 9Router thông qua Cloudflare Tunnel.
2. Đăng nhập bằng mật khẩu mặc định: `admin123` *(Trừ khi bạn đã đổi mật khẩu khác)*.
3. Tại giao diện **Providers**, hãy khai báo các API Key của bạn (OpenAI, Groq, Anthropic, Kimi, v.v...).
4. Mở IDE của bạn (Cursor, VSCode với Cline...) và trỏ cấu hình OpenAI-compatible API về địa chỉ của 9Router.
   - **Ví dụ:** `https://ai.yourdomain.com/v1` *(thay vì api.openai.com)*.

---

## 🔧 3. Các Tiện ích mở rộng trong homelab.sh
Trong menu quản lý 9Router, phần **Tiện ích mở rộng**, bạn có các quyền trợ giúp sau:

- 🔓 **Sửa lỗi quyền ghi Database:** Vì 9Router lưu trữ mọi thông tin API Keys vào Database SQLite ở ổ cứng ngoài (bind mount), đôi lúc lỗi phân quyền của Docker có thể khiến nó báo lỗi `Permission Denied`. Tiện ích này sẽ cấp quyền `chmod 777` để khắc phục triệt để lỗi không lưu được dữ liệu.
- 🔑 **Xem lại Mật khẩu khởi tạo:** Giúp bạn tra cứu nhanh mật khẩu mặc định (`admin123`) nếu bạn vô tình quên.

---

## 💡 4. Ghi chú về OmniRoute (Bản nâng cấp)
Trong kho ứng dụng (App Store) của `homelab.sh` còn có một ứng dụng anh em mang tên **OmniRoute**. 

> [!NOTE]
> OmniRoute thực chất là một phiên bản rẽ nhánh (fork) cấp độ cao hơn (Advanced) của 9Router, được viết bằng TypeScript. Nó có thêm các tính năng:
> - Hỗ trợ lưu bộ nhớ đệm (Semantic Cache) bằng Redis giúp trả lời tức thì những câu hỏi trùng lặp.
> - Tự động đánh giá chất lượng phản hồi của LLM.
> - Hỗ trợ xử lý âm thanh, hình ảnh và nhúng (multi-modal).

Bạn có thể cài đặt 1 trong 2 tùy thuộc vào nhu cầu: **9Router** thì gọn nhẹ, **OmniRoute** thì cồng kềnh hơn nhưng sở hữu nhiều tính năng chuẩn Enterprise.
