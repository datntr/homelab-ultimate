# Hướng dẫn Chuyên sâu: ZeroTTS (AI Giọng nói Tiếng Việt Siêu Tốc)

**ZeroTTS** (phát triển bởi Zeroweight AI) là giải pháp **Text-to-Speech (Chuyển văn bản thành giọng nói)** tiếng Việt mã nguồn mở thế hệ mới, được tối ưu hóa đặc biệt bằng **ONNX Runtime trên CPU**. 

Khác với các hệ thống TTS truyền thống yêu cầu card đồ họa (GPU) rời đắt đỏ, ZeroTTS có thể chạy mượt mà ngay trên các máy chủ VPS giá rẻ chỉ từ **1 - 2 vCPU và 2GB RAM** với tốc độ tổng hợp giọng nói gần như tức thì (Real-time Streaming).

---

## 1. Điểm Khác Biệt Nổi Bật của ZeroTTS

- ⚡ **Tối ưu thuần CPU ONNX:** Chạy hoàn toàn bằng thư viện `onnxruntime`, không phụ thuộc PyTorch CUDA cồng kềnh, giảm 80% dung lượng container và mức tiêu thụ RAM.
- 🎙️ **8 Giọng đọc Preset Tiêu chuẩn:** Sở hữu bộ sưu tập giọng đọc tiếng Việt phong phú, tự nhiên, đa dạng vùng miền (Bắc, Trung, Nam) và giới tính (Nam/Nữ).
- 🌊 **Hỗ trợ Streaming Audio:** Phát âm thanh trực tiếp theo luồng ngay khi đang sinh câu thoại, loại bỏ thời gian chờ đợi đối với văn bản dài.
- 🚀 **REST API & WebUI Tích hợp:** Giao diện trực quan dựa trên Gradio kết hợp với backend FastAPI hiệu năng cao, sẵn sàng tích hợp vào N8N, OpenClaw, Home Assistant và Hermes Agent.
- 🛡️ **Bảo mật Gradio thông minh:** `homelab.sh` tích hợp sẵn cơ chế xác thực đăng nhập qua biến môi trường `.env`, cho phép bật/tắt mật khẩu hoặc đổi mật khẩu linh hoạt.

---

## 2. Kho 8 Giọng Preset Tiếng Việt

ZeroTTS đi kèm sẵn 8 giọng đọc chất lượng phòng thu:

| Tên Giọng | Mã (Voice ID) | Giới tính | Vùng miền / Phong cách |
| :--- | :--- | :--- | :--- |
| **Mai Chi** | `maichi` | Nữ | Giọng Bắc ngọt ngào, truyền cảm, thích hợp đọc truyện & tin tức |
| **Gia Huy** | `giahuy` | Nam | Giọng Bắc chuẩn, trầm ấm, chững chạc |
| **Bảo Trang** | `baotrang` | Nữ | Giọng Nam Bộ tươi vui, năng động |
| **Hữu Đức** | `huuduc` | Nam | Giọng Nam Bộ phong thái thuyết minh, tự tin |
| **Kim Oanh** | `kimoanh` | Nữ | Giọng Bắc nhẹ nhàng, thanh thoát |
| **Hà My** | `hamy` | Nữ | Giọng trẻ trung, hiện đại |
| **Quang Minh** | `quangminh` | Nam | Giọng nam lịch lãm, thích hợp làm trợ lý ảo |
| **Tiến Đạt** | `tiendat` | Nam | Giọng đọc hào sảng, rõ ràng, dứt khoát |

---

## 3. Cách Cài Đặt & Cấu Hình Trên Homelab

### Cài đặt qua Menu Kịch bản:
1. Chạy kịch bản `./homelab.sh`
2. Chọn **[3] Cửa hàng Ứng dụng (App Store)**.
3. Chọn **[8] Text-to-Speech (AI Giọng nói tiếng Việt)**.
4. Chọn **[2] ZeroTTS (TTS tiếng Việt ONNX siêu tốc)**.
5. Nhập Subdomain dự kiến kết nối Cloudflare Tunnel (VD: `zerotts.yourdomain.com`).
6. Kịch bản sẽ tự động kéo mã nguồn, đóng gói Image ONNX tối ưu và khởi động container trên cổng nội bộ **`7861`**.

---

## 4. Định tuyến qua Cloudflare Tunnel

Để truy cập WebUI ZeroTTS an toàn từ Internet qua HTTPS:

1. 🌐 Truy cập [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/).
2. 🛣️ Vào **Networks > Tunnels** > chọn Tunnel của máy chủ Homelab.
3. ➕ Bấm **Configure > Public Hostname > Add a public hostname**.
4. ⚙️ Điền thông số:
   - **Subdomain:** `zerotts` (hoặc tên tùy chọn)
   - **Domain:** chọn tên miền của bạn (`yourdomain.com`)
   - **Type:** `HTTP`
   - **URL:** `zerotts:7861` *(nếu dùng Cloudflare Docker)* hoặc `127.0.0.1:7861` *(nếu dùng Cloudflare Systemd service)*
5. 💾 Bấm **Save hostname**.

---

## 5. Quản Lý & Tiện Ích Mở Rộng (Menu Phím 6)

Khi truy cập vào **Menu 3 > Quản lý ZeroTTS > [6] Tiện ích mở rộng & Sửa lỗi**, bạn có các tùy chọn:

- 🛡️ **Bật / Tắt bảo vệ mật khẩu:**
  - *Mặc định:* ZeroTTS khởi chạy ở chế độ vào thẳng WebUI (không cần mật khẩu, tiện lợi cho mạng nội bộ).
  - *Bật bảo vệ:* Bấm phím **1** để nhập Username và Password mong muốn. Hệ thống sẽ tự động cấu hình xác thực vào Gradio mount và khởi động lại container an toàn.
  - *Tắt bảo vệ:* Sau khi đã bật, bạn có thể bấm lại phím **1** bất kỳ lúc nào để chuyển về chế độ truy cập trực tiếp không cần đăng nhập.
- 🔑 **Xem / Đổi Tài khoản & Mật khẩu:** Kiểm tra hoặc cập nhật thông tin đăng nhập bất kỳ lúc nào mà không làm gián đoạn dữ liệu.
- 📂 **Sửa lỗi phân quyền (Fix Permission Denied):** Tự động `chmod -R 777` cho thư mục cache model và audio output.
- 🧹 **Dọn dẹp bộ nhớ đệm (HF Cache):** Xóa sạch cache Hugging Face (`/data/hf_cache`) nếu bạn muốn giải phóng dung lượng ổ cứng.

---

## 6. So Sánh: ZeroTTS vs VieNeu-TTS

Homelab cung cấp cả hai công cụ TTS tiếng Việt hàng đầu để bạn linh hoạt sử dụng:

| Tiêu chí | ⚡ ZeroTTS | 🎭 VieNeu-TTS |
| :--- | :--- | :--- |
| **Công nghệ lõi** | ONNX Runtime CPU | PyTorch / NeuTTS Architecture |
| **Tài nguyên yêu cầu** | Siêu nhẹ (~1-2 vCPU, 2GB RAM) | Trung bình (2-4 vCPU, 4GB RAM) |
| **Tốc độ sinh âm thanh** | Cực nhanh, hỗ trợ Streaming tức thì | Trung bình, phù hợp render từng đoạn |
| **Kho giọng đọc có sẵn** | 8 giọng chất lượng cao cố định | 5+ giọng preset phong phú |
| **Clone giọng (Voice Cloning)** | Không hỗ trợ (tập trung tốc độ & độ ổn định) | **Rất mạnh** (clone qua file ghi âm 5-10 giây) |
| **Cổng WebUI mặc định** | `7861` | `7860` |
| **Mục đích khuyên dùng** | Trợ lý ảo phản hồi nhanh, đọc thông báo Home Assistant, chatbot giọng nói | Làm video Youtube/Tiktok, đọc truyện dài, giả lập giọng người thật |

---

## 7. Tích Hợp API (Dành cho Lập trình viên & Tự động hóa)

ZeroTTS cung cấp REST API chạy trên cùng cổng `7861`.

### API Streaming Audio (FastAPI Route):
```bash
curl -X POST "http://localhost:7861/stream" \
     -H "Content-Type: application/json" \
     --data '{
       "text": "Xin chào, đây là hệ thống tự động hóa nhà thông minh Homelab Ultimate!",
       "voice": "maichi",
       "speed": 1.0
     }' \
     --output speech.wav
```

### Tích hợp vào OpenClaw / Hermes Agent:
Bạn có thể trỏ tool Text-to-Speech trong OpenClaw hoặc Hermes Agent tới URL nội bộ:
- **TTS Provider:** `custom` / `local`
- **Endpoint:** `http://zerotts:7861/stream` (nằm chung mạng Docker `homelab_net`)
- **Voice:** `maichi` hoặc `giahuy`
