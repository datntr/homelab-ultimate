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

### Bước 2: Vượt qua Lớp 2 (Phê duyệt thiết bị & Nút)
Sau khi bấm Kết nối, màn hình sẽ hiển thị yêu cầu phê duyệt:

#### 2a. Đối với Trình duyệt Web (Device Pairing):
Thông báo: **"Cần ghép đôi thiết bị (Trình duyệt này cần phê duyệt một lần...)"**.
Trên màn hình sẽ có dòng lệnh: `openclaw devices approve <Device_ID>`

#### 2b. Đối với App trên Điện thoại (Node Access):
Sau khi đăng nhập, App sẽ hiện thông báo: **"Phê duyệt quyền truy cập nút"**.
Trên màn hình điện thoại có dòng lệnh: `openclaw nodes approve <Node_UUID>`

#### 👉 Cách phê duyệt tự động bằng Script:
1. Copy toàn bộ dòng lệnh hiển thị trên màn hình (hoặc copy riêng chuỗi mã ID).
2. Mở kịch bản `homelab.sh` -> Đi tới **Quản lý OpenClaw** -> **Phím 6 (Tiện ích)** -> **Phím 3 (Phê duyệt thiết bị / Nút)**.
3. Dán nguyên đoạn vừa copy vào và nhấn **Enter**. Script sẽ **tự động nhận diện** thông minh (dù là lệnh Device hay Node) và phê duyệt tức thì!
4. Quay lại thiết bị bấm **Kết nối** hoặc **"Tôi đã phê duyệt"** để vào giao diện chính.

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
- **Cách 1 (Nhanh nhất qua Script):**
  1. Mở `homelab.sh` -> Quản lý OpenClaw -> **Phím 6 (Tiện ích)** -> **Phím 6 (Đổi / Reset Mật khẩu Gateway)**.
  2. Nhập mật khẩu mới và ấn Enter. Script sẽ tự động cập nhật cả file `docker-compose.yml`, `openclaw.json` và nạp lại container cho bạn!
- **Cách 2 (Thủ công):**
  1. Mở `homelab.sh` -> Quản lý OpenClaw -> **Phím 5 (Chỉnh sửa cấu hình)**.
  2. Tìm đến dòng `OPENCLAW_GATEWAY_PASSWORD=admin123` và sửa `admin123` thành mật khẩu mới.
  3. Bấm `Ctrl+X`, `Y`, `Enter` để lưu lại.
  4. Quay ra bấm **Phím 4 (Cập nhật / Nạp lại cấu hình)**.

---

## ⚡ 6. Tối ưu Hàng đợi & Trị lỗi Bot "Văng lỗi rồi Im bặt" (Queue & Debounce)

### ⚠️ Hiện tượng & Nguyên nhân:
- **Dấu hiệu:** Khi bạn nhắn nhiều câu ngắn dồn dập (hoặc trong nhóm chat có nhiều người/bot cùng nhắn), Telegram văng thông báo `⚠️ Agent couldn't generate a response`, sau đó bot "im bặt" không trả lời tiếp.
- **Nguyên nhân:**
  1. Hàng đợi mặc định là `queueMode: "steer"` (chế độ ngắt ngang). Khi tin 2 đến lúc bot đang suy nghĩ tin 1, tiến trình cũ bị hủy đột ngột làm đứt gãy context.
  2. Không có thời gian chờ gom tin (Debounce), mỗi câu chat ngắn đều kích hoạt 1 lần gọi AI riêng biệt gây nghẽn.
  3. Trong nhóm chat, chế độ `requireMention` đang tắt (`false`), bot tự kích hoạt với mọi tin nhắn trong nhóm dẫn đến quá tải.

---

### 🛠️ Hướng dẫn Khắc phục Chi tiết:

#### Cách 1: Cấu hình qua Giao diện Web Control UI (Khuyên dùng - Cực dễ) 🌐
1. Truy cập vào trang Web Control UI của OpenClaw (VD: `https://claw.yourdomain.com`).
2. Bấm vào biểu tượng **bánh răng (Settings / Cài đặt)**.
3. Tìm đến mục **Messages** (hoặc dùng ô tìm kiếm `debounce` / `queue`):
   - **Inbound Debounce (ms):** Nhập `2000` *(đợi 2 giây để gom các câu chat dồn dập thành 1 lần xử lý)*.
   - **Queue Mode:** Chuyển từ `steer` sang **`followup`** *(xử lý tuần tự từng tin, không ngắt ngang)*.
4. Chuyển sang tab **Channels** -> chọn **Telegram**:
   - Ở mục **Groups**, tìm tùy chọn **Require Mention** ➔ Gạt sang **Bật (ON / true)** *(chỉ khi tag `@bot` hoặc reply thì bot mới trả lời, tránh nghe trộm và quá tải trong nhóm chat)*.
5. Bấm nút **Save** để lưu lại. Cấu hình sẽ có hiệu lực ngay lập tức!

#### Cách 2: Cấu hình trực tiếp vào file `openclaw.json` (Dành cho Quản trị viên) 💻
Mở file cấu hình trên VPS:
```bash
nano /opt/homelab/openclaw/data/openclaw.json
```
Thêm khối cấu hình `messages` và bật `requireMention: true`:
```json
  "messages": {
    "inbound": {
      "debounceMs": 2000
    },
    "queue": {
      "mode": "followup"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "groups": {
        "*": {
          "requireMention": true
        }
      }
    }
  }
```
Lưu lại (`Ctrl+O`, `Enter`, `Ctrl+X`) rồi khởi động lại OpenClaw:
```bash
docker restart openclaw
```
*(Hoặc dùng lệnh CLI: `docker exec -it openclaw openclaw config set messages.inbound.debounceMs 2000` và `docker exec -it openclaw openclaw config set messages.queue.mode followup`)*.

---

## 🎙️ 7. Hướng dẫn Cấu hình Live Voice & Mở Toàn bộ Quyền Truy xuất trên OpenClaw

Tài liệu hướng dẫn chi tiết từng bước để thiết lập **Đàm thoại giọng nói hai chiều thời gian thực (Realtime Live Voice / Talk Mode)** trên OpenClaw, tối ưu phản hồi không độ trễ, và mở khóa toàn bộ quyền điều khiển Smarthome (Home Assistant), máy chủ Homelab và gửi tin nhắn Telegram trực tiếp từ giọng nói mà không bị hỏi xin quyền hay chặn lại.

---

### 🔑 7.1. Phân chia 2 Tầng Xử lý: Tầng Suy luận (OmiRoute) vs Tầng Âm thanh (Google Live Voice)

Trong kiến trúc của OpenClaw, hệ thống phân định rõ ràng 2 tầng độc lập:

1. **Tầng Não bộ / Suy luận chính (Brain & Reasoning):**
   - 👉 **Chạy qua OmiRoute / OneAPI / LiteLLM Proxy 100%!**
   - Model chính (như `gemini-2.5-pro`, `gemini-3.7-flash` trỏ về cổng Proxy AI nội bộ `https://ai.yourdomain.com/v1`).
   - Mọi tác vụ suy nghĩ, lập trình, tính toán logic, chạy script điều khiển Smarthome đều chạy qua Proxy rất mượt mà và tận dụng được tính năng Load Balancing nhiều API Key.

2. **Tầng Âm thanh Thời gian thực (Realtime Voice Live Stream):**
   - 👉 **Bắt buộc kết nối trực tiếp bằng Google API Key (Không đi qua Proxy thông thường được).**

#### ❓ Vì sao tầng Voice chưa thể định tuyến qua Proxy (OmiRoute / OneAPI)?
- **Khác biệt về giao thức truyền tải:**
  + **Proxy (OmiRoute, OneAPI, LiteLLM):** Là cổng định tuyến chuẩn **HTTP REST / Chat Completions** (gửi prompt text/ảnh -> nhận về stream text).
  + **Voice Live (`talk.realtime`):** Sử dụng kết nối **WebSocket / WebRTC song công hai chiều (Full-Duplex Audio Stream)** của Google Gemini Multimodal Live API. Giao thức này truyền nhận trực tiếp các gói tin âm thanh nhị phân (PCM audio chunks) theo thời gian thực với độ trễ siêu thấp (<300ms). Các proxy chuẩn OpenAI hiện nay chưa hỗ trợ luồng WebSocket/WebRTC đặc thù này của Google.
- **Cơ chế cấu hình của OpenClaw:**
  + Trong Schema của OpenClaw, mục `talk.realtime.providers.google` chỉ nhận trực tiếp chuỗi `apiKey` đơn lẻ của Google và tự động thiết lập kết nối WebSocket thẳng tới máy chủ Google (`generativelanguage.googleapis.com`), hoàn toàn không có trường tùy biến `baseUrl` cho luồng Voice.

---

### 🛠️ 7.2. Quy trình Cấu hình Chi tiết (5 Bước Chuẩn xác)

#### Bước 1: Nạp API Key cho Google Gemini Live Voice

##### 📌 Nguyên tắc quan trọng:
SDK Google Multimodal Live (`@google/genai`) nhúng trong OpenClaw **chỉ đọc API Key trực tiếp từ biến môi trường của hệ thống**. Việc điền trường `"apiKey"` thủ công trong file `openclaw.json` sẽ bị luồng socket bỏ qua hoặc bị mã hóa thành `***`.

##### ⚙️ Cách cấu hình:
1. Truy cập [Google AI Studio](https://aistudio.google.com/app/apikey) để tạo một **API Key** mới (miễn phí, hạn mức cao).
2. Thêm biến `GEMINI_API_KEY` vào file `/opt/homelab/openclaw/docker-compose.yml`:

```yaml
services:
  openclaw:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw
    environment:
      - TZ=Asia/Ho_Chi_Minh
      - OPENCLAW_GATEWAY_PASSWORD=*** (mật khẩu Gateway của bạn)
      - GEMINI_API_KEY=AIzaSy...your_gemini_api_key...
    volumes:
      - /opt/homelab/openclaw/data:/home/node/.openclaw
    restart: unless-stopped
```

---

#### Bước 2: Tái tạo Container trên Menu homelab.sh để nhận biến môi trường

> [!IMPORTANT]
> **Lưu ý sống còn:** Sau khi sửa `docker-compose.yml` để thêm `GEMINI_API_KEY`, việc chọn **Phím 1 (Restart mềm)** trong script sẽ **KHÔNG nhận biến mới** vì Docker giữ nguyên container cũ. Bắt buộc phải thực hiện **Tái tạo lại (Force Recreate)**!

Bạn có thể làm theo 1 trong 2 cách:
* **Cách 1 (Ngay trên menu `homelab.sh` - Khuyên dùng):**
  1. Mở script: `sudo ./homelab.sh` ➔ Chọn **`3. App Store`** ➔ Chọn **`OpenClaw`**.
  2. Bắt buộc chọn **Phím 2: ⚠ Khởi tạo lại (Hard Reset - Tái tạo nguyên bản)** *(hoặc Phím 4: Cập nhật / Nạp lại cấu hình)*.
  3. Nhấn **`Y`** để xác nhận. Script sẽ tự động chạy lệnh tái tạo và nạp biến môi trường mới vào container ngay lập tức.
* **Cách 2 (Bằng dòng lệnh Terminal):**
  ```bash
  cd /opt/homelab/openclaw && docker compose up -d --force-recreate
  ```

---

#### Bước 3: Cấu hình Chế độ Đàm thoại Live & Tối ưu Độ trễ (`talk`)

Mở file `/opt/homelab/openclaw/data/openclaw.json` (hoặc vào **Control UI** -> **Settings** -> **Config**), cấu hình khối `"talk"` ở cấp gốc (root):

```json
{
  "talk": {
    "speechLocale": "vi-VN",
    "interruptOnSpeech": true,
    "realtime": {
      "provider": "google",
      "consultRouting": "provider-direct",
      "vadThreshold": 0.2,
      "silenceDurationMs": 300,
      "instructions": "Bạn là giao diện giọng nói cho trợ lý AI trên HomeLab. Luôn xưng hô tự nhiên, chu đáo, ấm áp và dứt khoát. Khi người dùng yêu cầu điều khiển thiết bị smarthome, bật/tắt thiết bị, kiểm tra thời tiết, nhà thông minh hoặc gửi lệnh tới Home Assistant/Telegram, hãy luôn gọi công cụ openclaw_agent_consult để Agent trực tiếp xử lý."
    }
  }
}
```

> [!WARNING]
> **Lưu ý an toàn Schema:**
> - **KHÔNG** thêm `"enabled": true` vào mục `talk` hoặc `realtime` (vì sai Schema Zod của OpenClaw sẽ kích hoạt cơ chế bảo vệ và gây crash container lúc khởi động).
> - Khi đã khai báo `GEMINI_API_KEY` ở `docker-compose.yml`, không cần điền `apiKey` thủ công vào `openclaw.json` nữa.

##### 🔍 Bảng giải thích chi tiết các thông số then chốt:
| Thông số | Giá trị | Ý nghĩa thực tế & Tối ưu hiệu năng |
| :--- | :--- | :--- |
| `speechLocale` | `"vi-VN"` | Định tuyến nhận diện giọng nói tiếng Việt chuẩn xác, phát âm tự nhiên. |
| `consultRouting` | `"provider-direct"` | **Bắt buộc để đàm thoại Live liên tục**. Giữ kết nối mở (Duplex Live), bấm mic 1 lần là trò chuyện hai chiều liên tục, không bị ngắt cuộc gọi sau mỗi câu. |
| `interruptOnSpeech` | `true` | Cho phép nói chen ngang (barge-in) khi AI đang nói. |
| `vadThreshold` | `0.2` | Tăng độ nhạy bắt giọng nói của micro (ngưỡng 0.2 giúp micro phát hiện tiếng nói ngay cả khi loa ngoài đang phát âm thanh). |
| `silenceDurationMs` | `300` | Thời gian chờ im lặng trước khi chốt câu (0.3s giúp phản xạ trả lời gần như tức thì, giảm tối đa độ trễ). |
| `instructions` | `String` | Hướng dẫn cốt lõi để mô hình giọng nói biết tự động kích hoạt công cụ `openclaw_agent_consult` chuyển tiếp lệnh Smarthome và Telegram về cho Agent xử lý ngầm. |

---

#### Bước 4: Mở Toàn quyền Thực thi & Gửi tin nhắn Chéo kênh (`tools`)

Thêm/sửa khối `"tools"` trong file `/opt/homelab/openclaw/data/openclaw.json`:

```json
{
  "tools": {
    "exec": {
      "ask": "off",
      "security": "full"
    },
    "message": {
      "crossContext": {
        "allowAcrossProviders": true
      }
    }
  }
}
```

##### 🔍 Giải thích các thông số:
- `"tools.exec.ask": "off"`: Tắt hoàn toàn việc hỏi xin phép phê duyệt `/approve` khi chạy lệnh hệ thống hoặc gọi API Smarthome.
- `"tools.exec.security": "full"`: Cấp toàn quyền thực thi các tập lệnh mạng và script can thiệp hệ thống nội bộ.
- `"tools.message.crossContext.allowAcrossProviders": true`: Cho phép chuyển tiếp tin nhắn từ Web/Voice sang các nền tảng chat khác (như bot Telegram).

---

#### Bước 5: Cơ chế Bảo vệ Voice Safety Gate & Cách Mở khóa Toàn bộ (Bypass)

##### 📌 1. Vì sao OpenClaw Mặc định lại Sinh ra Cơ chế này?
Trong thiết kế gốc của OpenClaw, khi đàm thoại giọng nói thời gian thực (Live Voice), hệ thống tự động phân loại các yêu cầu thành 2 nhóm:
- **Hành động chỉ đọc (Safe Read-Only):** Tra cứu thời tiết, tìm kiếm web, đọc file, kiểm tra trạng thái thiết bị Smarthome ➔ **Thực thi ngay lập tức, không bao giờ hỏi.**
- **Hành động có tác động ra ngoài (High-Impact Action):** Gửi tin nhắn Telegram/Discord, chạy lệnh shell hệ thống (`exec`), xóa sửa cấu hình ➔ OpenClaw thiết kế cơ chế **xác nhận 2 bước bằng giọng nói (2-Step Voice Confirmation)** nhằm bảo vệ hệ thống, ngăn chặn triệt để trường hợp micro vô tình bắt trúng tiếng ồn ngoài môi trường (TV, người khác nói chuyện) rồi tự động gửi nhầm tin nhắn ra ngoài.

---

##### 🎙️ 2. Luồng Hoạt động Chuẩn gốc (Nếu KHÔNG Patch file mã nguồn):
Nếu bạn muốn giữ nguyên cơ chế bảo mật an toàn mặc định của OpenClaw, quy trình ra lệnh bằng giọng nói sẽ diễn ra như sau:
1. **Người dùng ra lệnh:**
   - *"Gửi tin nhắn lên nhóm chat: Tôi đang trên đường về nhà."*
2. **AI phản hồi hỏi xác nhận:**
   - *"Bạn có chắc chắn muốn gửi tin nhắn này lên nhóm chat không?"*
3. **Người dùng xác nhận bằng từ khóa chuẩn (Explicit Affirmation):**
   Bạn chỉ cần nói một trong các câu/từ khóa hợp lệ sau:
   - **Tiếng Việt:** *"Xác nhận"*, *"Đồng ý"*, *"Gửi đi"*, *"Làm luôn đi"*
   - **Tiếng Anh:** *"Yes"*, *"Confirm"*, *"Do it"*, *"Send it"*
   ➔ Ngay lập tức, hệ thống cấp phát token xác nhận (`confirmationId`) và gửi tin nhắn đi tức thì.

---

##### 📂 3. Vị trí Lưu trữ Mã nguồn & Tác động khi Recreate Container:
Nếu bạn thấy việc phải xác nhận 2 bước là rườm rà và muốn **nói 1 câu là gửi ngay lập tức (Bypass 100%)**, bạn cần can thiệp vào file worker lõi:
- **Vị trí file:**
  1. `/app/dist/worker/worker.mjs`
  2. `/app/dist/agent-tools.before-tool-call-*.mjs`
- **Bản chất lưu trữ trong Docker (Disk vs RAM):**
  + **Đã ghi thẳng vào Ổ cứng (Overlay layer của Container):** Khi chạy lệnh Patch, file code trong container đã được lưu trực tiếp xuống ổ cứng vật lý của máy chủ (trong lớp ghi của container Docker), hoàn toàn **KHÔNG PHẢI chỉ lưu tạm trên RAM**.
  + **Lệnh Restart (`docker restart`):** Chỉ là thao tác để tiến trình Node.js đọc lại file mới từ ổ cứng nạp vào bộ nhớ RAM đang chạy.
  + **Tuy nhiên, hai file này KHÔNG nằm trong thư mục mount dữ liệu `/home/node/.openclaw`:** Do đó, chúng gắn liền với vòng đời của container hiện tại.

###### 🔍 Bảng tra cứu các tình huống thực tế trong quá trình vận hành:

| Tình huống thực tế | Trạng thái bản Patch | Có cần Patch lại không? |
| :--- | :--- | :--- |
| **Mất điện đột ngột / Server sập nguồn** | 🟢 **VẪN CÒN NGUYÊN** | ❌ **Không cần** (File đã nằm trên ổ cứng, bật máy lên Docker tự nạp lại). |
| **Khởi động lại máy chủ (Reboot VPS)** | 🟢 **VẪN CÒN NGUYÊN** | ❌ **Không cần** (Docker tự chạy lại container với file đã sửa). |
| **Restart container (`docker restart openclaw`)** | 🟢 **VẪN CÒN NGUYÊN** | ❌ **Không cần**. |
| **`docker compose stop` / `docker compose start`** | 🟢 **VẪN CÒN NGUYÊN** | ❌ **Không cần**. |
| **`docker compose down` rồi `up -d` (Recreate container)** | 🔴 **BỊ MẤT** | ⚠️ **Cần Patch lại** (Vì container cũ bị hủy, container mới tạo lại từ Image gốc). |
| **Cập nhật phiên bản mới (`docker pull` / Update Image)** | 🔴 **BỊ MẤT** | ⚠️ **Cần Patch lại** (Vì kéo Image mới về thay thế). |

> [!NOTE]
> **Tóm tắt quy tắc cốt lõi:**
> - **Sử dụng bình thường, tắt máy, khởi động lại VPS, mất điện:** 👉 **Không bao giờ mất bản vá!** Bật máy lên là tiếp tục sử dụng bình thường.
> - **Chỉ khi nào chủ động:** Xóa container (`down`), bấm **Force Recreate** hoặc **Cập nhật Image OpenClaw mới** thì container mới quay về bản gốc chưa patch *(trừ khi bạn cấu hình Mount Volume vĩnh viễn ở Cách 1 dưới đây)*.

---

###### ⚠️ Phân biệt rõ 3 loại thay đổi trong OpenClaw:

| Thao tác | Cách áp dụng hiệu lực | Có làm mất bản vá mã nguồn không? |
| :--- | :--- | :--- |
| **Sửa cấu hình (`openclaw.json` / Prompt)** | Chỉ cần **Restart Gateway** (`docker restart openclaw` hoặc nút Restart trên Web UI) | 🟢 **KHÔNG mất** (File nằm ở thư mục mount ngoài ổ cứng host `/opt/homelab/openclaw/data`). |
| **Sửa biến môi trường (`docker-compose.yml`)** *(Ví dụ: thêm `GEMINI_API_KEY`)* | Cần **Tái tạo Container** (`docker compose up -d --force-recreate`) | 🔴 **SẼ MẤT** bản vá `/app/dist/...` vì Docker khởi tạo lại container từ Image gốc (nếu không mount đè từ ngoài). |
| **Sửa mã nguồn lõi (`/app/dist/...`)** | Chạy lệnh patch + restart container | Bị hoàn nguyên nếu Recreate container. |

---

##### 🛠️ 4. Hướng dẫn Mở khóa Toàn bộ (Bypass 2-Step) & Giữ Bản vá Vĩnh viễn:
Dành cho người dùng muốn **bỏ qua bước hỏi xác nhận, ra lệnh giọng nói là AI thực thi ngay lập tức**:

---

##### ⚡ Cách 1: Chuyển đổi 1-Click Tự động Phát hiện Trạng thái trên `homelab.sh` (Khuyên dùng)
Tính năng này đã được tích hợp cơ chế **tự động phát hiện trạng thái thông minh** vào script quản trị:
1. Mở script trên VPS: `sudo ./homelab.sh`
2. Chọn **`3. Cửa hàng ứng dụng (App Store)`** ➔ Chọn **`OpenClaw`** *(hoặc vào `2. Quản lý ứng dụng` ➔ chọn `OpenClaw`)*.
3. Chọn **`Phím 6: 🛠️ Tiện ích mở rộng & Sửa lỗi (Advanced Tools)`**.
4. Script sẽ **tự động kiểm tra hệ thống** và hiển thị trạng thái thực tế của Voice Gate ngay trên Menu:
   - Nếu đang ở Bản Gốc: Menu hiển thị `7. 🎙️ Voice Safety Gate: [BẢN GỐC AN TOÀN] ➔ Bấm để Kích hoạt Mở khóa Tự động`.
     ➔ Khi bấm **`Phím 7`**: Script tự động tạo bản sao lưu `docker-compose.yml.bak_YYYYMMDD_HHMMSS`, tạo `auto_patch.sh` trong data và kích hoạt mở khóa vĩnh viễn qua `entrypoint`.
   - Nếu đã Mở Khóa: Menu tự động chuyển sang `7. 🎙️ Voice Safety Gate: [ĐÃ MỞ KHÓA VĨNH VIỄN] ➔ Bấm để Đảo ngược về Bản Gốc`.
     ➔ Khi bấm **`Phím 7`** (hoặc Phím 8): Script tự động tạo bản sao lưu `docker-compose.yml.bak_before_revert_YYYYMMDD_HHMMSS`, gỡ bỏ `entrypoint`, xóa sạch file `auto_patch.sh` và chạy `docker compose up -d --force-recreate` để Docker tự động khôi phục container nguyên bản gốc 100% từ Docker Image!

---

##### 🛠️ Cách 2: Thiết lập Thủ công bằng tay (Dành cho Quản trị viên)

**Bước 1: Tạo file script tự động `auto_patch.sh` trong thư mục data**
*(File này nằm trong thư mục `/opt/homelab/openclaw/data/` nên được lưu vĩnh viễn trên ổ cứng máy chủ):*

```bash
nano /opt/homelab/openclaw/data/auto_patch.sh
```

Dán nội dung sau vào:
```bash
#!/bin/sh
# Tự động gỡ bỏ Voice Safety Gate cho OpenClaw trước khi khởi động
node -e '
const fs = require("fs");
try {
  // 1. Patch worker.mjs
  const wp = "/app/dist/worker/worker.mjs";
  if (fs.existsSync(wp)) {
    let wt = fs.readFileSync(wp, "utf8");
    wt = wt.replaceAll(/\{allowed:!1,reason:`VOICE_CONFIRMATION_REQUIRED:[^`]+`\}/g, "{allowed:!0}");
    fs.writeFileSync(wp, wt);
  }
  // 2. Patch các file agent-tools
  fs.readdirSync("/app/dist").filter(f => f.includes("agent-tools.before-tool-call") && f.endsWith(".mjs")).forEach(f => {
    let p = "/app/dist/" + f;
    let t = fs.readFileSync(p, "utf8");
    t = t.replaceAll(/\{allowed:!1,reason:`VOICE_CONFIRMATION_REQUIRED:[^`]+`\}/g, "{allowed:!0}");
    t = t.replace("function resolveClientVoiceToolConfirmationPolicy(params, consume) {", "function resolveClientVoiceToolConfirmationPolicy(params, consume) {\n\treturn { allowed: true };");
    fs.writeFileSync(p, t);
  });
  console.log("[Auto-Patch] Da mo khoa toan bo Voice Gate thanh cong!");
} catch (e) {
  console.error("[Auto-Patch] Loi:", e);
}
'
```

Cấp quyền thực thi:
```bash
chmod +x /opt/homelab/openclaw/data/auto_patch.sh
```

**Bước 2: Sao lưu và Cập nhật dòng `entrypoint` trong `docker-compose.yml`**
```bash
# Sao lưu file compose kèm mốc thời gian
cp /opt/homelab/openclaw/docker-compose.yml /opt/homelab/openclaw/docker-compose.yml.bak_$(date +%Y%m%d_%H%M%S)
```

Thêm khai báo `entrypoint` vào file `/opt/homelab/openclaw/docker-compose.yml`:

```yaml
services:
  openclaw:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw
    environment:
      - TZ=Asia/Ho_Chi_Minh
      - OPENCLAW_GATEWAY_PASSWORD=admin123
      - GEMINI_API_KEY=AIzaSy...your_gemini_api_key...
    volumes:
      - /opt/homelab/openclaw/data:/home/node/.openclaw
    # Dòng entrypoint tự động kích hoạt bản vá khi container khởi động:
    entrypoint: ["/bin/sh", "-c", "if [ -f /home/node/.openclaw/auto_patch.sh ]; then /bin/sh /home/node/.openclaw/auto_patch.sh; fi && exec tini -s -- node openclaw.mjs gateway"]
    restart: unless-stopped
```

**Bước 3: Nạp lại cấu hình container:**
```bash
cd /opt/homelab/openclaw && docker compose up -d
```
> [!TIP]
> Toàn bộ quy trình hoàn toàn tự động 100%. Dù mất điện, reboot server, Recreate container hay cập nhật Image mới, OpenClaw luôn tự động mở khóa Voice Gate ngay khi vừa khởi động!

---

### 📱 7.3. Cách Sử dụng & Danh mục Lệnh Mẫu trên App Mobile & Web

1. Mở App **OpenClaw** trên điện thoại (đảm bảo đã cấp quyền **Microphone** trong Cài đặt ứng dụng).
2. Khi Gateway nhận diện được Key, dòng chữ cảnh báo sẽ tự động biến mất.
3. Chạm vào nút **Micro màu cam/đỏ** ở thanh dưới để bắt đầu đàm thoại trực tiếp hai chiều.

#### 🎙️ Danh mục các khẩu lệnh điều khiển mẫu đã kích hoạt:
* **Điều khiển Smarthome (Home Assistant):**
  - *"Bật / Tắt máy tính"*
  - *"Kiểm tra trạng thái thiết bị trong nhà"*
  - *"Phát loa thông báo trên Google Home Speaker"*
* **Kênh Telegram / Đa tác vụ (Multi-Agent):**
  - *"Gửi tin nhắn lên nhóm chat"*
  - *"Nhắn tin trên Telegram bảo chuẩn bị báo cáo"*
  - *"Gửi thông báo riêng cho tôi trên Telegram"*
* **Trợ lý thông tin & Vận hành máy chủ:**
  - *"Thời tiết hôm nay thế nào?"*
  - *"Kiểm tra trạng thái máy chủ Homelab"*


