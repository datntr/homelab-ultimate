# 🚀 Homelab Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-Zero_Trust-orange.svg)](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

> **🎯 Script bash giúp bạn tự động hóa việc triển khai và quản lý một máy chủ cá nhân (Homelab) tập trung vào AI, Automation và IoT. Mọi kết nối đều được bảo mật qua Cloudflare Tunnel.**

---

## 📋 Mục lục

- [🎯 Dành cho ai?](#-dành-cho-ai)
- [✨ Tính năng chính](#-tính-năng-chính)
- [🔧 Yêu cầu hệ thống](#-yêu-cầu-hệ-thống-system-requirements)
- [🐧 Nền tảng hỗ trợ](#-nền-tảng-hỗ-trợ-supported-platforms)
- [💻 Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
- [📦 Danh sách Ứng dụng](#-danh-sách-ứng-dụng-tích-hợp)
- [📖 Tài liệu hướng dẫn](#-tài-liệu-hướng-dẫn-chi-tiết-docs)

---

## 🎯 Dành cho ai?

### ✅ **Bạn NÊN sử dụng script này nếu:**
- 🏠 **Muốn chơi Homelab/Nhà thông minh** nhưng lười gõ lệnh Docker thủ công.
- 🔄 **Làm Tự động hóa (Automation)** với N8N và cần nhúng thẳng thư viện ngoài vào.
- 🤖 **Thường xuyên dùng AI** và cần một AI Gateway nội bộ (để tiết kiệm token API).
- 🌐 **Quan tâm đến bảo mật**, không muốn mở port trực tiếp lên mạng Internet.
- 🧑‍💻 **Developer, Tweak thủ** cần một server (NodeJS) chạy 24/7 và Trợ lý AI cá nhân (OpenClaw).

### ❌ **KHÔNG phù hợp nếu:**
- ☁️ Bạn chỉ muốn dùng các dịch vụ Cloud trả phí (SaaS) mà không muốn tự quản trị máy chủ.
- 🔌 Máy tính/Server của bạn không có mạng ổn định.

---

## ✨ Tính năng chính

- ⚡ **Cài đặt nhanh gọn:** Tự động cài đặt Docker, cấu hình Network và quản lý các container thông qua giao diện menu Terminal tương tác.
- 🛡️ **Bảo mật không cần mở port:** Tích hợp sẵn Cloudflare Tunnel (Zero Trust). Bạn không cần NAT port trên modem mạng, tránh rủi ro bị quét IP hoặc tấn công từ bên ngoài.
- ⚙️ **Tùy biến N8N dễ dàng:** Script có sẵn tính năng "độ" lại N8N (cài thêm Python3, FFmpeg, yt-dlp, Puppeteer...) thẳng vào container chỉ bằng cách bấm phím.
- 🧠 **Quản lý AI Gateway:** Đi kèm OmniRoute và 9Router để làm cổng luân chuyển API, giúp tiết kiệm token khi dùng chung nhiều model AI.
- 💾 **Backup & Restore:** Có sẵn tính năng nén và mã hóa (AES-256) toàn bộ cấu hình, kèm theo Duplicati để tự động đồng bộ lên Google Drive.
- 📖 **Code Quality:** Script được viết theo chuẩn và tuân thủ [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html).

---

## 🔧 Yêu cầu hệ thống (System Requirements)

### 💻 **Phần cứng tối thiểu:**
- **CPU:** 1 Core (Khuyến nghị 2+ Cores nếu chạy N8N và AI).
- **RAM:** 2GB (Khuyến nghị 4GB+).
- **Ổ cứng:** Tối thiểu 15GB trống.

### 🌐 **Yêu cầu bắt buộc:**
- ☁️ **Tài khoản Cloudflare** (Miễn phí) để tạo bảo mật Tunnel Zero-Trust.
- 🌍 **Một Tên miền (Domain)** đã trỏ Nameserver về Cloudflare (Khuyên dùng tên miền thật như .vn, .com, không nên dùng domain free trôi nổi vì rất dễ lỗi).

---

## 🐧 Nền tảng hỗ trợ (Supported Platforms)

Vì script sử dụng trình quản lý gói `apt` để tự động cài đặt Docker ban đầu, mức độ hỗ trợ trên các HĐH sẽ khác nhau:

**✅ Hỗ trợ toàn diện (Cài tự động 100%):**
- Ubuntu 18.04+ (Primary)
- Debian 10+
- Raspberry Pi OS
- Windows 10/11 (Thông qua WSL2 cài Ubuntu)

**⚠️ Hỗ trợ một phần (Cần cài Docker thủ công trước):**
- CentOS 7+ / AlmaLinux / Rocky Linux
- Fedora 30+
- Arch Linux
- macOS 10.15+
*(Với các HĐH này, bạn cần tự cài đặt Docker và Docker Compose trước. Sau khi có Docker, script sẽ chạy bình thường để quản lý các app).*

---

## 💻 Hướng dẫn cài đặt

🐧 **Linux (Khuyến nghị)**

**Bước 1: Chuẩn bị hệ thống**

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y curl wget git

# CentOS/RHEL/Fedora
sudo yum install -y curl wget git
# hoặc
sudo dnf install -y curl wget git
```

**Bước 2: Tải và chạy script**

```bash
# Tải script và cấp quyền thực thi
wget -O homelab.sh "https://raw.githubusercontent.com/datntr/homelab-ultimate/master/homelab.sh?$(date +%s)" && chmod +x homelab.sh

# Hoặc dùng curl
curl -sFLo homelab.sh "https://raw.githubusercontent.com/datntr/homelab-ultimate/master/homelab.sh?$(date +%s)" && chmod +x homelab.sh

# Chạy script
sudo ./homelab.sh
```

**Bước 3: Chạy lại khi cần**

```bash
# Sau khi đã tải, chỉ cần chạy lại lệnh này từ thư mục chứa file
sudo ./homelab.sh
```

---

🪟 **Windows (Chỉ qua WSL2)**

**WSL2 Ubuntu (Duy nhất được hỗ trợ)**

1. **Cài đặt WSL2:**

```powershell
# Chạy PowerShell với quyền Admin
wsl --install
# Khởi động lại máy
```

2. **Cài đặt Ubuntu:**

```powershell
wsl --install -d Ubuntu
```

3. **Trong Ubuntu WSL:**

```bash
# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Tải và chạy script
wget -O homelab.sh "https://raw.githubusercontent.com/datntr/homelab-ultimate/master/homelab.sh?$(date +%s)" && chmod +x homelab.sh && sudo ./homelab.sh
```

> [!WARNING]
> **Lưu ý quan trọng:**
> - **Git Bash:** Không được hỗ trợ chính thức (thiếu `apt`, `systemctl`).
> - **PowerShell:** Không thể chạy trực tiếp bash script.
> - **Chỉ WSL2 Ubuntu** được khuyến nghị.

---

🍎 **macOS (Không hỗ trợ chính thức)**

> [!WARNING]
> **Hạn chế:**
> - Script sử dụng `apt` (Ubuntu/Debian package manager).
> - Script sử dụng `systemctl` (Linux systemd).
> - macOS không có các lệnh này.

**Giải pháp thay thế:**
1. Sử dụng Docker Desktop và cài đặt các dịch vụ thủ công bằng `docker-compose`.
2. Sử dụng Máy ảo (VM) Ubuntu trên macOS.

---

🍓 **Raspberry Pi**

```bash
# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Tải script
wget -O homelab.sh "https://raw.githubusercontent.com/datntr/homelab-ultimate/master/homelab.sh?$(date +%s)"
chmod +x homelab.sh

# Chạy script
sudo ./homelab.sh
```

---

## 🚀 Cách sử dụng

🎛️ **Menu tương tác**

```bash
sudo ./homelab.sh
```

Sẽ hiển thị menu chính để bạn dễ dàng lựa chọn các chức năng:

```text
================================================================
             🚀 QUẢN LÝ HOMELAB SERVER (NEXUS) 🚀
================================================================

[ Hệ thống Lõi ]
 1. 🚀 Quản lý Docker (Cài đặt / Kiểm tra)
 2. 🌐 Cấu hình Cloudflare Tunnel

[ Quản lý Ứng dụng ]
 3. 🛒 App Store (Cài mới, Cấu hình, Tiện ích mở rộng, Xóa App)
 4. 🔄 Bật / Tắt toàn bộ dịch vụ

[ Bảo trì & Vận hành ]
 5. ⚙️ Trạng thái hệ thống
 6. 💾 Quản lý Sao lưu & Phục hồi
 7. 🧹 Dọn dẹp rác hệ thống (Clear Cache)
 8. 📊 Phân tích dung lượng ổ cứng

 0. ❌ Thoát
================================================================
```

---

## 📦 Danh sách Ứng dụng tích hợp

Hiện tại script đang hỗ trợ triển khai nhanh các ứng dụng sau:

| Ứng dụng | Phân loại | Mô tả |
|----------|-----------|-------|
| **N8N** | Tự động hóa | Xây dựng workflow tự động (đã mod mở khóa tính năng). |
| **Home Assistant** | IoT | Nền tảng quản lý thiết bị nhà thông minh. |
| **OmniRoute / 9Router**| AI Gateway | Cổng định tuyến API AI giúp điều phối request. |
| **OpenClaw** | AI Assistant | Trợ lý AI cá nhân tự trị (Tích hợp Chat qua Telegram/WhatsApp). |
| **Hermes Agent** | Tác tử suy luận lõi | Phần mềm Agent gốc từ NousResearch chuyên xử lý logic chuyên sâu. |
| **Uptime Kuma** | Giám sát | Theo dõi uptime các dịch vụ, cảnh báo qua Telegram/Discord. |
| **NodeJS** | Web Server| Container chạy sẵn Express.js để code API/Webhook. |
| **Duplicati** | Sao lưu | Lập lịch nén và đẩy bản sao lưu lên Google Drive/OneDrive. |
| **Dozzle** | Logging | Giao diện web nhẹ nhàng giúp xem Log Docker theo thời gian thực. |
| **PostgreSQL** | Cơ sở dữ liệu | (Core) Shared Database tách biệt với N8N dành cho mọi ứng dụng. |
| **Redis** | Bộ đệm | (Core) Shared Cache & Message Broker tối ưu tốc độ xử lý. |
| **Portainer CE** | Quản lý | Bảng điều khiển trực quan để quản trị toàn bộ Docker trên máy. |

---

## 📖 Tài liệu hướng dẫn chi tiết (Docs)

Trong quá trình sử dụng, nếu bạn gặp vướng mắc về cách cấu hình chi tiết cho từng app, vui lòng tham khảo các tài liệu sau:

- 📘 [Hướng dẫn cấu hình Cloudflare Tunnel](docs/CLOUDFLARE_GUIDE.md)
- 🐘 [Kết nối Database (PostgreSQL) & Cache (Redis)](docs/CORE_SERVICES_GUIDE.md)
- 📗 [Hướng dẫn Nâng cao & Thêm thư viện cho N8N](docs/N8N_GUIDE.md)
- 📙 [Cài đặt HACS & Fix lỗi Cloudflare cho Home Assistant](docs/HOMEASSISTANT_GUIDE.md)
- 📕 [Cách sử dụng AI Gateway (9Router)](docs/9ROUTER_GUIDE.md)
- 🔀 [Cổng định tuyến AI Nâng cao (OmniRoute)](docs/OMNIROUTE_GUIDE.md)
- 💬 [Trợ lý ảo cá nhân AI (OpenClaw)](docs/OPENCLAW_GUIDE.md)
- 🧠 [Sức mạnh của Tác tử AI (Hermes Agent)](docs/HERMES_AGENT_GUIDE.md)
- 📓 [Lập lịch Backup với Duplicati](docs/DUPLICATI_GUIDE.md)
- 📓 [Sử dụng các tiện ích hệ thống (Portainer, Dozzle, Kuma)](docs/UTILITIES_GUIDE.md)

---

## 📜 Giấy phép (License)

Dự án này được phân phối dưới giấy phép **MIT License**. Bạn hoàn toàn có quyền sử dụng, sao chép, sửa đổi, gộp chung, xuất bản, phân phối, cấp phép phụ và/hoặc bán các bản sao của Phần mềm mà không bị hạn chế. Xem chi tiết tại [LICENSE](https://opensource.org/licenses/MIT).

---

## 🙏 Tác giả & Đóng góp (Credits)

- 👨‍💻 **Tác giả:** [datntr](https://github.com/datntr) - Xây dựng kịch bản cốt lõi và kiến trúc Homelab Modular.
- 📦 **Kho lưu trữ chính thức:** [https://github.com/datntr/homelab-ultimate](https://github.com/datntr/homelab-ultimate)

### 📬 Thông tin liên hệ
Nếu có bất kỳ thắc mắc, đóng góp mã nguồn hoặc phát hiện lỗi (bug) trong quá trình sử dụng, đừng ngần ngại liên hệ với tôi qua:
- 🌐 **Website:** [tieuca.me](https://tieuca.me)
- ✉️ **Email:** datntr.dev@gmail.com
- ✈️ **Telegram:** [@tieuca](https://t.me/tieuca)

🏆 *Chân thành cảm ơn các cộng đồng mã nguồn mở và những người phát triển các ứng dụng tuyệt vời như Docker, Cloudflare, N8N, Home Assistant... đã giúp hệ sinh thái Homelab trở nên phổ biến!*
