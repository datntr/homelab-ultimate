#!/bin/bash

# ============================================================
# HomeLab App Manager - Modular Architecture
# ============================================================

# === Check if running as root ===
if [ "$(id -u)" -ne 0 ]; then
   echo -e "\033[0;31m✗ Lỗi: Vui lòng chạy script bằng quyền root (sudo bash $0)\033[0m" >&2
   exit 1
fi

# === Configuration ===
HOMELAB_DIR="/opt/homelab"
BACKUP_DIR="/opt/homelab_backups"
CONFIG_FILE="$HOMELAB_DIR/.homelab_config"
KEY_FILE="$HOMELAB_DIR/.backup_key"

# Colors for output
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[36m'     # Đổi sang Cyan để nổi bật hơn trên nền đen
MAGENTA='\e[35m'
NC='\e[0m' # No Color

set -e
set -o pipefail

# Đảm bảo thư mục gốc tồn tại
mkdir -p "$HOMELAB_DIR"
touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

# === Helper Functions ===
print_section() { echo -e "\n${BLUE}>>> $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }

# Đọc cấu hình vào biến
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
}
# Ghi cấu hình (key value)
save_config() {
    local key=$1
    local val=$2
    if grep -q "^${key}=" "$CONFIG_FILE"; then
        sed -i "s|^${key}=.*|${key}=\"${val}\"|" "$CONFIG_FILE"
    else
        echo "${key}=\"${val}\"" >> "$CONFIG_FILE"
    fi
    chmod 600 "$CONFIG_FILE"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker chưa được cài đặt!"
        read -p "Bạn có muốn tự động cài đặt Docker ngay bây giờ không? (Y/n): " choice
        if [[ ! "$choice" =~ ^[Nn]$ ]]; then
            manage_docker_install
            if command -v docker &> /dev/null; then
                if ! docker network inspect homelab_net &>/dev/null; then
                    docker network create homelab_net >/dev/null 2>&1
                fi
                return 0
            fi
        fi
        return 1
    fi
    
    # Đảm bảo mạng ảo luôn tồn tại để tránh lỗi khi gỡ/cài lại Docker
    if ! docker network inspect homelab_net &>/dev/null; then
        docker network create homelab_net >/dev/null 2>&1
    fi
    
    return 0
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        print_error "Không thể xác định hệ điều hành"
        exit 1
    fi
}

# ============================================================
# TÍNH NĂNG 1: QUẢN LÝ DOCKER
# ============================================================
manage_docker_install() {
    print_section "Cài đặt / Cập nhật Docker"
    echo "Tiến hành xử lý hệ thống..."
    detect_os
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        apt-get update
        apt-get install -y ca-certificates curl openssl
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/$OS/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$OS $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif [ "$OS" = "almalinux" ] || [ "$OS" = "centos" ] || [ "$OS" = "rocky" ]; then
        dnf install -y dnf-plugins-core openssl
        dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        print_error "Hệ điều hành $OS chưa được hỗ trợ cài tự động."
        return 1
    fi
    systemctl enable --now docker
    print_success "Thao tác cài đặt/cập nhật Docker thành công!"
}

docker_menu() {
    while true; do
        print_section "🐳 Quản lý Hệ thống Docker"
        
        # Kiểm tra nhanh không in ra màn hình lỗi
        if docker --version >/dev/null 2>&1; then
            echo -e "Trạng thái: ${GREEN}Đang hoạt động${NC}"
            echo -e "Phiên bản: $(docker --version | awk '{print $3}' | tr -d ',')"
        else
            echo -e "Trạng thái: ${RED}CHƯA CÀI ĐẶT${NC}"
            echo -e "\n${GREEN} 1.${NC} Cài đặt Docker & Docker Compose"
            if [ -d "/var/lib/docker" ]; then
                echo -e "${RED} 2.${NC} Dọn sạch tàn dư (Xóa dữ liệu Docker cũ)"
            fi
            echo -e "${YELLOW} 0.${NC} Quay lại Menu chính"
            echo ""
            read -p "Nhập lựa chọn của bạn: " d_choice
            if [ "$d_choice" == "1" ]; then
                manage_docker_install
            elif [ "$d_choice" == "2" ] && [ -d "/var/lib/docker" ]; then
                echo -e "\n${RED}CẢNH BÁO: Hành động này sẽ xóa vĩnh viễn toàn bộ dữ liệu Docker cũ.${NC}"
                read -p "Xác nhận xóa sạch? (y/N): " conf
                if [[ "$conf" =~ ^[Yy]$ ]]; then
                    rm -rf /var/lib/docker /var/lib/containerd
                    print_success "Đã xóa sạch tàn dư Docker!"
                fi
            elif [ "$d_choice" == "0" ]; then
                break
            else
                print_error "Lựa chọn không hợp lệ!"
            fi
            echo ""; read -p "Nhấn Enter để tiếp tục..."
            clear
            continue
        fi

        echo -e "\n${GREEN} 1.${NC} Xem dung lượng đĩa Docker đang chiếm"
        echo -e "${GREEN} 2.${NC} Dọn dẹp rác hệ thống (Xóa Image/Container thừa)"
        echo -e "${GREEN} 3.${NC} Khởi động lại dịch vụ Docker (Restart Daemon)"
        echo -e "${GREEN} 4.${NC} Cập nhật Docker lên bản mới nhất"
        echo -e "${RED} 5.${NC} Gỡ cài đặt Docker (Kèm tùy chọn Xóa sạch dữ liệu)"
        echo -e "${YELLOW} 0.${NC} Quay lại Menu chính"
        echo ""
        read -p "Nhập lựa chọn của bạn: " d_choice
        
        case $d_choice in
            1)
                print_section "Dung lượng đĩa Docker"
                docker system df
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            2)
                read -p "$(echo -e "\n${RED}⚠ CẢNH BÁO: Xóa toàn bộ Container đã tắt, Cache cũ và Image thừa? (y/N): ${NC}")" conf
                if [[ "$conf" =~ ^[Yy]$ ]]; then
                    echo "Đang dọn dẹp hệ thống Docker..."
                    docker system prune -a -f --volumes
                    print_success "Đã dọn dẹp xong!"
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            3)
                echo "Đang khởi động lại Docker Daemon..."
                systemctl restart docker
                print_success "Đã khởi động lại thành công!"
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            4)
                manage_docker_install
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            5)
                read -p "$(echo -e "\n${RED}⚠ Bạn có chắc chắn muốn GỠ CÀI ĐẶT phần mềm Docker? (y/N): ${NC}")" conf1
                if [[ "$conf1" =~ ^[Yy]$ ]]; then
                    echo "Đang gỡ cài đặt phần mềm Docker..."
                    apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
                    print_success "Đã gỡ xong phần mềm Docker."
                    
                    if [ -d "/var/lib/docker" ]; then
                        echo -e "\n${YELLOW}Dữ liệu của bạn (Container, Image, Database) vẫn an toàn trong /var/lib/docker.${NC}"
                        read -p "$(echo -e "${RED}⚠ Bạn có muốn dọn dẹp XÓA SẠCH toàn bộ dữ liệu cũ này không? (y/N): ${NC}")" conf2
                        if [[ "$conf2" =~ ^[Yy]$ ]]; then
                            read -p "$(echo -e "${RED}⚠ Vui lòng gõ chữ 'XOA' (viết hoa) để xác nhận hành động nguy hiểm này: ${NC}")" conf3
                            if [ "$conf3" == "XOA" ]; then
                                echo "Đang dọn dẹp dữ liệu..."
                                rm -rf /var/lib/docker /var/lib/containerd
                                print_success "Đã dọn sạch toàn bộ dữ liệu Docker!"
                            else
                                print_warning "Hủy xóa dữ liệu do sai mã xác nhận."
                            fi
                        else
                            print_success "Đã giữ lại dữ liệu Docker cũ."
                        fi
                    fi
                else
                    print_warning "Đã hủy thao tác gỡ cài đặt."
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            0) break ;;
            *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
        esac
        clear
    done
}

# ============================================================
# TÍNH NĂNG 2: CLOUDFLARE TUNNEL
# ============================================================
manage_cloudflare_install() {
    print_section "Cài đặt / Đổi Token Cloudflare Tunnel"
    if ! check_docker; then return 0; fi
    
    load_config
    if [ -n "$CF_TOKEN" ]; then
        echo -e "Token hiện tại đã được cấu hình."
        read -p "Bạn có muốn thay đổi Token không? (y/N): " choice
        if [[ "$choice" =~ ^[Nn]$ ]] || [[ -z "$choice" ]]; then return 0; fi
    else
        read -p "Bạn có muốn tiến hành cài đặt Cloudflare Tunnel? (Y/n): " choice
        if [[ "$choice" =~ ^[Nn]$ ]]; then return 0; fi
    fi

    echo "Lưu ý: Bạn lấy Token tại trang Cloudflare Zero Trust > Networks > Tunnels"
    read -p "🔑 Nhập Cloudflare Tunnel Token mới (Bỏ trống và nhấn Enter để hủy): " NEW_TOKEN
    if [ -z "$NEW_TOKEN" ]; then
        print_warning "Đã hủy thao tác cài đặt Cloudflare Tunnel."
        return 0
    fi
    
    # Đảm bảo có mạng chung
    if ! docker network inspect homelab_net &>/dev/null; then
        docker network create homelab_net
        print_success "Tạo mạng ảo homelab_net thành công"
    fi

    save_config "CF_TOKEN" "$NEW_TOKEN"
    
    mkdir -p $HOMELAB_DIR/cloudflared
    cat << EOF > $HOMELAB_DIR/cloudflared/docker-compose.yml
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel run
    environment:
      - TUNNEL_TOKEN=$NEW_TOKEN
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF

    echo "Đang tải bản mới nhất (nếu có) và khởi động Cloudflare Tunnel..."
    cd "$HOMELAB_DIR/cloudflared"
    docker compose pull
    docker compose up -d
    print_success "Cài đặt Cloudflare Tunnel thành công!"
}

cloudflare_menu() {
    if ! check_docker; then return 0; fi
    while true; do
        local cf_status="[Chưa cài]"
        if [ -d "$HOMELAB_DIR/cloudflared" ]; then
            local is_running=$(docker inspect -f '{{.State.Running}}' cloudflared 2>/dev/null || echo "false")
            if [ "$is_running" == "true" ]; then
                local cf_logs=$(docker logs --tail 20 cloudflared 2>&1)
                if echo "$cf_logs" | grep -qi "invalid token"; then
                    cf_status="[${RED}Lỗi Token 🔴${NC}]"
                elif echo "$cf_logs" | grep -q "Registered tunnel connection"; then
                    cf_status="[${GREEN}Đã kết nối 🟢${NC}]"
                else
                    cf_status="[${GREEN}Đang chạy 🟢${NC}]"
                fi
            else
                cf_status="[${RED}Đã dừng 🔴${NC}]"
            fi
        fi

        print_section "🌐 Quản lý Cloudflare Tunnel $cf_status"
        echo -e "${GREEN} 1.${NC} Cài đặt mới / Thay đổi Token"
        
        if [ -d "$HOMELAB_DIR/cloudflared" ]; then
            echo -e "${GREEN} 2.${NC} Xem Log chi tiết"
            echo -e "${GREEN} 3.${NC} Xem Token hiện tại"
            if [ "$is_running" == "true" ]; then
                echo -e "${YELLOW} 4.${NC} Dừng Tunnel (Stop)"
            else
                echo -e "${GREEN} 4.${NC} Bật Tunnel (Start)"
            fi
            echo -e "${GREEN} 5.${NC} Khởi động lại (Restart Tunnel)"
            echo -e "${RED} 6.${NC} Gỡ bỏ Cloudflare Tunnel"
        fi
        
        echo -e "${YELLOW} 0.${NC} Quay lại Menu chính"
        echo ""
        read -p "Nhập lựa chọn của bạn: " cf_choice
        
        case $cf_choice in
            1)
                manage_cloudflare_install
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            2)
                print_section "Log chi tiết Cloudflare Tunnel"
                if [ -d "$HOMELAB_DIR/cloudflared" ]; then
                    echo -e "${YELLOW}Đang xuất 30 dòng Log gần nhất...${NC}\n"
                    docker logs --tail 30 cloudflared
                else
                    print_error "Cloudflare Tunnel chưa được cài đặt!"
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            3)
                load_config
                if [ -n "$CF_TOKEN" ]; then
                    local first_chars="${CF_TOKEN:0:15}"
                    local last_chars="${CF_TOKEN: -15}"
                    echo -e "\n${GREEN}Token hiện tại đang lưu là:${NC}"
                    echo -e "${first_chars}******************************${last_chars}"
                    echo -e "${YELLOW}(Đã che bớt nội dung để bảo mật. Hãy so sánh đoạn đầu/cuối với trang Cloudflare)${NC}"
                else
                    print_error "Chưa có Token nào được lưu trong hệ thống!"
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            4)
                if [ -d "$HOMELAB_DIR/cloudflared" ]; then
                    if [ "$is_running" == "true" ]; then
                        echo "Đang dừng Cloudflare Tunnel..."
                        cd "$HOMELAB_DIR/cloudflared" && docker compose stop
                        print_success "Đã dừng thành công!"
                    else
                        echo "Đang bật Cloudflare Tunnel..."
                        cd "$HOMELAB_DIR/cloudflared" && docker compose up -d
                        print_success "Đã bật thành công!"
                    fi
                else
                    print_error "Cloudflare Tunnel chưa được cài đặt!"
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            5)
                if [ -d "$HOMELAB_DIR/cloudflared" ]; then
                    echo "Đang khởi động lại Cloudflare Tunnel..."
                    cd "$HOMELAB_DIR/cloudflared" && docker compose up -d --force-recreate
                    print_success "Đã khởi động lại thành công!"
                else
                    print_error "Cloudflare Tunnel chưa được cài đặt!"
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            6)
                if [ -d "$HOMELAB_DIR/cloudflared" ]; then
                    read -p "$(echo -e "\n${RED}⚠ CẢNH BÁO: Xóa toàn bộ Cloudflare Tunnel? (y/N): ${NC}")" conf
                    if [[ "$conf" =~ ^[Yy]$ ]]; then
                        cd "$HOMELAB_DIR/cloudflared" && docker compose down -v || true
                        cd /
                        rm -rf "$HOMELAB_DIR/cloudflared"
                        sed -i '/^CF_TOKEN=/d' "$CONFIG_FILE"
                        print_success "Đã xóa hoàn toàn Cloudflare Tunnel!"
                    fi
                else
                    print_error "Cloudflare Tunnel chưa được cài đặt!"
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            0) break ;;
            *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
        esac
        clear
    done
}

# ============================================================
# TÍNH NĂNG 3: APP STORE
# ============================================================

init_openclaw_config() {
    local domain=$1
    echo "Đang tạo cấu hình mặc định cho OpenClaw..."
    mkdir -p "$HOMELAB_DIR/openclaw/data"
    
    local origins="\"http://localhost:18789\",\"http://127.0.0.1:18789\""
    if [ -n "$domain" ]; then
        origins="$origins,\"https://$domain\",\"http://$domain\""
    fi

    cat << EOF_CONF > "$HOMELAB_DIR/openclaw/data/openclaw.json"
{
  "gateway": {
    "mode": "local",
    "bind": "lan",
    "trustedProxies": [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
      "127.0.0.0/8",
      "fd00::/8",
      "::1/128"
    ],
    "controlUi": {
      "allowedOrigins": [$origins]
    }
  }
}
EOF_CONF
    chmod 777 "$HOMELAB_DIR/openclaw/data/openclaw.json" 2>/dev/null || true
}

install_app() {
    local app_name=$1
    local port=$2
    local compose_content=$3
    
    print_section "Cài đặt $app_name"
    if ! check_docker; then return 0; fi
    
    read -p "Bạn có chắc chắn muốn cài đặt ứng dụng $app_name? (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        print_warning "Đã hủy thao tác cài đặt."
        echo ""
        read -p "Nhấn Enter để tiếp tục..."
        return 0
    fi
    
    # Tạo thư mục
    mkdir -p "$HOMELAB_DIR/$app_name"
    
    if [ "$port" != "none" ] && [ "$port" != "host" ]; then
        read -p "🌐 Nhập Subdomain dự kiến cho $app_name (VD: $app_name.domain.com): " domain
        local app_upper=$(echo "$app_name" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
        save_config "DOMAIN_${app_upper}" "$domain"
        
        touch "$HOMELAB_DIR/$app_name/.env"
        if grep -q "^DOMAIN=" "$HOMELAB_DIR/$app_name/.env"; then
            sed -i "s|^DOMAIN=.*|DOMAIN=$domain|" "$HOMELAB_DIR/$app_name/.env"
        else
            echo "DOMAIN=$domain" >> "$HOMELAB_DIR/$app_name/.env"
        fi
    fi

    # Sinh file compose
    echo "$compose_content" > "$HOMELAB_DIR/$app_name/docker-compose.yml"
    
    if [ "$port" != "none" ] && [ "$port" != "host" ]; then
        # Tự động đục lỗ an toàn ra 127.0.0.1 cho app chính để tương thích Cloudflare Systemd và aaPanel
        sed -i "/container_name: $app_name/a \\    ports:\n      - \"127.0.0.1:$port:$port\"" "$HOMELAB_DIR/$app_name/docker-compose.yml"
    fi
    
    # Xử lý đặc biệt cho Home Assistant
    if [ "$app_name" == "homeassistant" ]; then
        mkdir -p "$HOMELAB_DIR/homeassistant/config"
        if [ ! -f "$HOMELAB_DIR/homeassistant/config/configuration.yaml" ]; then
            cat << 'EOF_HA' > "$HOMELAB_DIR/homeassistant/config/configuration.yaml"
# Loads default set of integrations. Do not remove.
default_config:

# Load frontend themes from the themes folder
frontend:
  themes: !include_dir_merge_named themes

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.16.0.0/12
    - 192.168.0.0/16
    - 10.0.0.0/8
EOF_HA
            touch "$HOMELAB_DIR/homeassistant/config/automations.yaml"
            touch "$HOMELAB_DIR/homeassistant/config/scripts.yaml"
            touch "$HOMELAB_DIR/homeassistant/config/scenes.yaml"
        fi
    fi
    
    if [ "$app_name" == "openclaw" ]; then
        init_openclaw_config "$domain"
    fi
    
    if [ "$app_name" == "dozzle" ]; then
        mkdir -p "$HOMELAB_DIR/dozzle/data"
        local dozzle_user="admin"
        local dozzle_pass="admin123"
        if [ ! -f "$HOMELAB_DIR/dozzle/data/users.yml" ]; then
            echo "Đang khởi tạo tài khoản Dozzle..."
            docker run --rm amir20/dozzle:latest generate "$dozzle_user" --password "$dozzle_pass" > "$HOMELAB_DIR/dozzle/data/users.yml" 2>/dev/null
            echo "DOZZLE_USERNAME=$dozzle_user" > "$HOMELAB_DIR/dozzle/.env"
            echo "DOZZLE_PASSWORD=$dozzle_pass" >> "$HOMELAB_DIR/dozzle/.env"
        fi
    fi

    if [ "$app_name" == "hermes" ]; then
        mkdir -p "$HOMELAB_DIR/hermes/data"
    fi
    
    if [ "$app_name" == "cliproxy" ]; then
        mkdir -p "$HOMELAB_DIR/cliproxy/auth-data"
        if [ ! -f "$HOMELAB_DIR/cliproxy/config.yaml" ]; then
            local mgmt_key=$(openssl rand -hex 16)
            cat << EOF_CLI > "$HOMELAB_DIR/cliproxy/config.yaml"
# Auto-generated by Homelab Ultimate
port: 8317
remote-management:
  allow-remote: true
  secret-key: "$mgmt_key"
EOF_CLI
        fi
    fi
    
    # Bật app
    echo "Đang khởi tạo $app_name (Kéo bản mới nhất)..."
    cd "$HOMELAB_DIR/$app_name"
    docker compose pull

    # Hermes Agent: Tạo config SAU KHI image đã tải xong (cần dùng chính image đó để hash mật khẩu)
    if [ "$app_name" == "hermes" ]; then
        if [ ! -f "$HOMELAB_DIR/hermes/data/config.yaml" ]; then
            echo "Đang khởi tạo tài khoản mặc định cho Hermes Agent..."
            docker run --rm --entrypoint python3 -v "$HOMELAB_DIR/hermes/data:/opt/data" nousresearch/hermes-agent:latest -c '
try:
    from plugins.dashboard_auth.basic import hash_password
    h = hash_password("admin123")
except:
    import bcrypt
    h = bcrypt.hashpw(b"admin123", bcrypt.gensalt()).decode()
with open("/opt/data/config.yaml", "w") as f:
    f.write("_config_version: 12\ndashboard:\n  basic_auth:\n    username: admin\n    password_hash: \"" + h + "\"\n")
' 2>/dev/null
            if [ ! -f "$HOMELAB_DIR/hermes/data/config.yaml" ]; then
                echo -e "${RED}Lỗi khi khởi tạo mật khẩu. Hermes Dashboard có thể không khởi động được!${NC}"
            fi
        fi
    fi

    docker compose up -d
    
    # Xử lý tự động phân quyền (Fix Permission Denied) ngay sau khi cài
    echo "Đang tự động xử lý quyền thư mục..."
    chmod -R 777 "$HOMELAB_DIR/$app_name" 2>/dev/null || true
    # Thử gọi lệnh chmod 777 bên trong container (nhắm tới các path phổ biến)
    docker exec --user root "$app_name" chmod -R 777 /app/data /home/node/.openclaw 2>/dev/null || true
    docker exec --user root "$app_name" chown -R 1000:1000 /app/data /home/node/.openclaw 2>/dev/null || true

    print_success "Cài đặt $app_name thành công!"
    if [ "$port" != "none" ] && [ "$port" != "host" ]; then
        echo -e "⚠ Nhớ lên trang Cloudflare Tunnel và thêm Public Hostname:"
        echo -e "   Domain: ${YELLOW}$domain${NC}"
        
        # Nhận diện thông minh môi trường Cloudflare
        if docker ps -a --format '{{.Names}}' | grep -Eq "^cloudflared$"; then
            echo -e "   Service: ${YELLOW}http://$app_name:$port${NC}"
        else
            echo -e "   Service: ${YELLOW}http://127.0.0.1:$port${NC}"
        fi
    fi
    if [ "$app_name" == "portainer" ]; then
        echo -e "⚠ CẢNH BÁO BẢO MẬT: Portainer có bộ đếm giờ tự vệ!"
        echo -e "Bạn có ${RED}CHÍNH XÁC 5 PHÚT${NC} để truy cập Web và tạo mật khẩu Admin."
        echo "Nếu quá 5 phút mà chưa tạo, Portainer sẽ khóa chặt cửa."
        echo "Khi đó, bạn hãy vào lại Script -> Menu 3 -> Quản lý Portainer -> Khởi động lại (Phím 2) để được cấp thêm 5 phút nhé!"
    fi
    if [ "$app_name" == "dozzle" ]; then
        if [ -f "$HOMELAB_DIR/dozzle/.env" ]; then
            local d_user=$(grep "DOZZLE_USERNAME=" "$HOMELAB_DIR/dozzle/.env" | cut -d '=' -f2)
            local d_pass=$(grep "DOZZLE_PASSWORD=" "$HOMELAB_DIR/dozzle/.env" | cut -d '=' -f2)
            echo -e "🔐 ${GREEN}Tài khoản đăng nhập Dozzle của bạn:${NC}"
            echo -e "   - Username: ${YELLOW}$d_user${NC}"
            echo -e "   - Password: ${YELLOW}$d_pass${NC}"
            echo "Hãy lưu lại thông tin này nhé!"
        fi
    fi
    if [[ "$app_name" == "9router" || "$app_name" == "openclaw" || "$app_name" == "duplicati" || "$app_name" == "hermes" ]]; then
        echo -e "\n🔐 ${GREEN}Tài khoản đăng nhập mặc định của $app_name:${NC}"
        if [ "$app_name" == "hermes" ]; then
            echo -e "   - Username: ${CYAN}admin${NC}"
        fi
        echo -e "   - Password: ${CYAN}admin123${NC}"
        echo -e "${YELLOW}Vui lòng đổi mật khẩu sau khi đăng nhập thành công!${NC}"
    fi
    if [ "$app_name" == "cliproxy" ]; then
        if [ -f "$HOMELAB_DIR/cliproxy/config.yaml" ]; then
            local m_key=$(grep "secret-key:" "$HOMELAB_DIR/cliproxy/config.yaml" | cut -d '"' -f2)
            echo -e "\n🔐 ${GREEN}Khóa quản trị (Management Key) của bạn là:${NC}"
            echo -e "   - Key: ${YELLOW}$m_key${NC}"
            echo -e "Hãy lưu lại đoạn mã này! Ứng dụng sẽ tự động mã hóa nó thành chuỗi Hash (\$2a...) ngay sau khi chạy."
        fi
    fi
    if [[ "$app_name" == "postgres-core" || "$app_name" == "redis-core" ]]; then
        if [ -f "$HOMELAB_DIR/$app_name/.env" ]; then
            local core_pass=""
            if [ "$app_name" == "postgres-core" ]; then
                core_pass=$(grep "POSTGRES_PASSWORD=" "$HOMELAB_DIR/$app_name/.env" | cut -d '=' -f2)
                echo -e "\n${YELLOW}⚠ LƯU Ý QUAN TRỌNG: ⚠${NC}"
                echo -e "Đây là thông tin kết nối Database của bạn:"
                echo -e " - Host: ${GREEN}$app_name${NC} (Trong cùng mạng Docker)"
                echo -e " - Port: ${GREEN}5432${NC}"
                echo -e " - User: ${GREEN}postgres${NC}"
                echo -e " - Password: ${GREEN}$core_pass${NC}"
            else
                core_pass=$(grep "REDIS_PASSWORD=" "$HOMELAB_DIR/$app_name/.env" | cut -d '=' -f2)
                echo -e "\n${YELLOW}⚠ LƯU Ý QUAN TRỌNG: ⚠${NC}"
                echo -e "Đây là thông tin kết nối Redis của bạn:"
                echo -e " - Host: ${GREEN}$app_name${NC} (Trong cùng mạng Docker)"
                echo -e " - Port: ${GREEN}6379${NC}"
                echo -e " - Password: ${GREEN}$core_pass${NC}"
            fi
            echo -e "Vui lòng lưu lại mật khẩu này! Mật khẩu cũng được lưu trong file .env"
        fi
    fi
    echo ""
    read -p "Nhấn Enter để tiếp tục..."
}

advanced_tools_menu() {
    local app_name=$1
    while true; do
        clear
        print_section "Tiện ích mở rộng & Sửa lỗi: $app_name"
        
        case $app_name in
            "n8n")
                echo -e "${CYAN} 1.${NC} 🔓 Mở khóa Node 'Execute Command' & Cho phép dùng thư viện NPM"
                echo -e "${MAGENTA} 2.${NC} 📦 Cài đặt thư viện NPM (Dành cho Node Code)"
                echo -e "${RED} 3.${NC} 🔑 Khôi phục Mật khẩu Chủ (Reset Password)"
                echo -e "${GREEN} 4.${NC} ⚙️ Tích hợp gói bổ sung (Python, FFmpeg, yt-dlp)"
                echo -e "${YELLOW} 5.${NC} 🔄 Khôi phục bản Gốc (Gỡ bỏ mọi tích hợp)"
                echo -e "${CYAN} 6.${NC} 📂 Sửa lỗi quyền ghi file (Fix Permission Denied)"
                ;;
            "homeassistant")
                echo -e "${CYAN} 1.${NC} 🛠️ Sửa lỗi 400 Bad Request (Fix lỗi Cloudflare)"
                echo -e "${MAGENTA} 2.${NC} 🎁 Cài đặt HACS (Kho ứng dụng cộng đồng)"
                ;;
            "omiroute")
                echo -e "${CYAN} 1.${NC} 📂 Sửa lỗi quyền ghi Database (Fix Permission Denied)"
                ;;
            "cliproxy")
                echo -e "${CYAN} 1.${NC} 📂 Sửa lỗi quyền ghi Database (Fix Permission Denied)"
                echo -e "${RED} 2.${NC} 🔑 Đổi / Reset Management Key (Vì key tự bị mã hoá)"
                ;;
            "openclaw")
                echo -e "${CYAN} 1.${NC} 📂 Sửa lỗi quyền ghi Database (Fix Permission Denied)"
                echo -e "${MAGENTA} 2.${NC} ⚙️ Khởi tạo Cấu hình (Fix Missing Config)"
                echo -e "${GREEN} 3.${NC} 📱 Phê duyệt thiết bị (Approve Device)"
                echo -e "${YELLOW} 4.${NC} 🤖 Liên kết Chatbot mạng xã hội (Telegram, Discord, WhatsApp)"
                echo -e "${CYAN} 5.${NC} 🔑 Xem Mật khẩu"
                ;;
            "9router")
                echo -e "${CYAN} 1.${NC} 📂 Sửa lỗi quyền ghi Database (Fix Permission Denied)"
                echo -e "${CYAN} 2.${NC} 🔑 Xem Mật khẩu"
                ;;
            "dozzle")
                echo -e "${CYAN} 1.${NC} 🔑 Xem Mật khẩu"
                echo -e "${MAGENTA} 2.${NC} 🔄 Đổi Mật khẩu"
                ;;
            "hermes")
                echo -e "${YELLOW} 1.${NC} 🧠 Cấu hình AI (API Key / Model)"
                echo -e "${CYAN} 2.${NC} 🔑 Xem Mật khẩu"
                echo -e "${MAGENTA} 3.${NC} 🔄 Đổi Mật khẩu"
                ;;
            "duplicati")
                echo -e "${CYAN} 1.${NC} 🔑 Xem Mật khẩu"
                echo -e "${MAGENTA} 2.${NC} 🔄 Đổi Mật khẩu"
                ;;
            "postgres-core")
                echo -e "${CYAN} 1.${NC} 🔑 Xem thông tin kết nối Database"
                echo -e "${MAGENTA} 2.${NC} 🔄 Đổi Mật khẩu Database"
                ;;
            "redis-core")
                echo -e "${CYAN} 1.${NC} 🔑 Xem thông tin kết nối Redis"
                echo -e "${MAGENTA} 2.${NC} 🔄 Đổi Mật khẩu Redis"
                ;;
            *)
                echo -e "Không có tiện ích mở rộng nào cho ứng dụng này."
                ;;
        esac
        
        echo -e "${YELLOW} 0.${NC} Quay lại"
        echo ""
        read -p "Nhập lựa chọn của bạn: " adv_choice
        
        if [ "$adv_choice" == "0" ]; then break; fi
        
        case $app_name in
            "n8n")
                case $adv_choice in
                    1)
                        echo "Đang cấu hình mở khóa cho N8N..."
                        cd "$HOMELAB_DIR/n8n"
                        if ! grep -q "NODES_EXCLUDE" docker-compose.yml; then
                            sed -i '/environment:/a \      - NODES_EXCLUDE=[]' docker-compose.yml
                        fi
                        if ! grep -q "NODE_FUNCTION_ALLOW_EXTERNAL" docker-compose.yml; then
                            sed -i '/environment:/a \      - NODE_FUNCTION_ALLOW_EXTERNAL=*' docker-compose.yml
                            sed -i '/environment:/a \      - NODE_FUNCTION_ALLOW_BUILTIN=*' docker-compose.yml
                        fi
                        docker compose up -d
                        print_success "Đã mở khóa thành công! Hãy tải lại (F5) trang N8N."
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    2)
                        read -p "Nhập tên thư viện NPM muốn cài (VD: moment, axios, crypto): " npm_pkg
                        if [ -n "$npm_pkg" ]; then
                            echo "Đang cài đặt $npm_pkg vào N8N..."
                            if docker exec --user root n8n npm install -g "$npm_pkg"; then
                                print_success "Cài đặt $npm_pkg thành công! Bạn có thể import thư viện này trong Node Code."
                            else
                                print_error "Cài đặt thất bại! Hãy kiểm tra lại tên thư viện."
                            fi
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    3)
                        echo "Đang khôi phục mật khẩu N8N..."
                        if docker exec --user node n8n n8n user-management:reset; then
                            docker restart n8n
                            print_success "Đã Reset tài khoản thành công!"
                            echo "Hãy mở trang web N8N bằng trình duyệt Ẩn danh (Incognito) để thiết lập lại mật khẩu mới nhé."
                        else
                            print_error "Khôi phục thất bại!"
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    4)
                        echo -e "${YELLOW}Trình hướng dẫn Nâng cấp N8N (Custom Build)${NC}"
                        read -p "$(echo -e "Bạn có muốn cài Python3 & Pip không? (Y/n): ")" p_py
                        read -p "$(echo -e "Bạn có muốn cài FFmpeg không? (Y/n): ")" p_ff
                        read -p "$(echo -e "Bạn có muốn cài yt-dlp không? (Y/n): ")" p_yt
                        read -p "$(echo -e "Bạn có muốn cài Trình duyệt ẩn danh (Chromium & Puppeteer) không? (Y/n): ")" p_pup
                        read -p "$(echo -e "Bạn có muốn cài Xử lý ảnh (GraphicsMagick) không? (Y/n): ")" p_gm
                        read -p "$(echo -e "Bạn có muốn cài Đọc PDF (Poppler-utils) không? (Y/n): ")" p_pop
                        read -p "$(echo -e "Bạn có muốn cài Quét chữ OCR (Tesseract + Gói Tiếng Việt) không? (Y/n): ")" p_tes
                        
                        pkgs=""
                        if [[ ! "$p_py" =~ ^[Nn]$ ]]; then pkgs="$pkgs python3 py3-pip"; fi
                        if [[ ! "$p_ff" =~ ^[Nn]$ ]]; then pkgs="$pkgs ffmpeg"; fi
                        if [[ ! "$p_pup" =~ ^[Nn]$ ]]; then pkgs="$pkgs chromium nss freetype harfbuzz pango ttf-freefont"; fi
                        if [[ ! "$p_gm" =~ ^[Nn]$ ]]; then pkgs="$pkgs graphicsmagick"; fi
                        if [[ ! "$p_pop" =~ ^[Nn]$ ]]; then pkgs="$pkgs poppler-utils"; fi
                        if [[ ! "$p_tes" =~ ^[Nn]$ ]]; then pkgs="$pkgs tesseract-ocr tesseract-ocr-data-eng tesseract-ocr-data-vie"; fi
                        
                        if [ -z "$pkgs" ] && [[ "$p_yt" =~ ^[Nn]$ ]]; then
                            print_warning "Bạn không chọn gói nào. Hủy nâng cấp."
                            echo ""; read -p "Nhấn Enter để tiếp tục..."
                            continue
                        fi

                        echo "Đang khởi tạo Dockerfile..."
                        cd "$HOMELAB_DIR/n8n"
                        cat << 'EOF_DOCKER' > Dockerfile
# Dùng bản alpine tạm thời để mượn package manager (apk)
FROM alpine:latest AS alpine

# Kế thừa bản N8N chính thức (distroless)
FROM n8nio/n8n:latest
USER root

# Bơm apk vào n8n distroless
COPY --from=alpine /sbin/apk /sbin/apk
COPY --from=alpine /usr/lib/libapk.so* /usr/lib/
EOF_DOCKER
                        if [ -n "$pkgs" ]; then
                            echo "RUN apk add --no-cache $pkgs" >> Dockerfile
                        fi
                        if [[ ! "$p_yt" =~ ^[Nn]$ ]]; then
                            if [[ ! "$p_py" =~ ^[Nn]$ ]]; then
                                echo "RUN pip3 install yt-dlp --break-system-packages" >> Dockerfile
                            else
                                echo "RUN apk add --no-cache python3 py3-pip && pip3 install yt-dlp --break-system-packages" >> Dockerfile
                            fi
                        fi
                        if [[ ! "$p_pup" =~ ^[Nn]$ ]]; then
                            echo "ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \\" >> Dockerfile
                            echo "    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser" >> Dockerfile
                            echo "RUN npm install -g puppeteer" >> Dockerfile
                            # Cấp quyền cho node external command nếu cần (không bắt buộc nhưng tốt)
                        fi
                        echo "USER node" >> Dockerfile
                        echo "WORKDIR /home/node" >> Dockerfile

                        echo "Đang cấu hình lại docker-compose..."
                        sed -i 's|^.*image:.*n8n.*|    build: .|g' docker-compose.yml
                        if ! grep -q "/downloads:/downloads" docker-compose.yml; then
                            sed -i '/volumes:/a \      - ./downloads:/downloads' docker-compose.yml
                        fi
                        
                        echo "Đang tiến hành Build (Vui lòng đợi 3-5 phút)..."
                        docker builder prune -f
                        docker compose build --no-cache
                        docker compose up -d
                        
                        print_success "Nâng cấp hoàn tất!"
                        if [[ ! "$p_yt" =~ ^[Nn]$ ]]; then
                            echo "Phiên bản yt-dlp: $(docker exec n8n yt-dlp --version 2>/dev/null || echo "Lỗi")"
                        fi
                        if [[ ! "$p_ff" =~ ^[Nn]$ ]]; then
                            echo "Phiên bản FFmpeg: $(docker exec n8n sh -c 'ffmpeg -version | head -n 1' 2>/dev/null || echo "Lỗi")"
                        fi
                        if [[ ! "$p_pup" =~ ^[Nn]$ ]]; then
                            echo "Phiên bản Puppeteer: $(docker exec n8n sh -c 'npm list -g puppeteer --depth=0 2>/dev/null | grep puppeteer' || echo "Lỗi")"
                        fi
                        if [[ ! "$p_gm" =~ ^[Nn]$ ]]; then
                            echo "Phiên bản GraphicsMagick: $(docker exec n8n sh -c 'gm -version | head -n 1' 2>/dev/null || echo "Lỗi")"
                        fi
                        if [[ ! "$p_pop" =~ ^[Nn]$ ]]; then
                            echo "Phiên bản Poppler: $(docker exec n8n sh -c 'pdftotext -v 2>&1 | head -n 1' 2>/dev/null || echo "Lỗi")"
                        fi
                        if [[ ! "$p_tes" =~ ^[Nn]$ ]]; then
                            echo "Phiên bản Tesseract: $(docker exec n8n sh -c 'tesseract --version | head -n 1' 2>/dev/null || echo "Lỗi")"
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    5)
                        echo "Đang khôi phục N8N về nguyên bản (Gỡ bỏ mọi tích hợp)..."
                        cd "$HOMELAB_DIR/n8n"
                        if [ -f Dockerfile ]; then rm -f Dockerfile; fi
                        sed -i 's|^.*build: \..*|    image: n8nio/n8n:latest|g' docker-compose.yml
                        sed -i '/\/downloads:\/downloads/d' docker-compose.yml
                        
                        docker compose up -d
                        print_success "Đã khôi phục N8N về bản chuẩn cực nhẹ!"
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    6)
                        echo "Đang sửa lỗi phân quyền (chmod 777) cho N8N..."
                        docker exec --user root n8n chmod -R 777 /home/node/.n8n
                        if docker exec --user root n8n test -d /downloads; then
                            docker exec --user root n8n chmod -R 777 /downloads
                        fi
                        print_success "Đã mở quyền ghi tối đa thành công!"
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            "homeassistant")
                case $adv_choice in
                    1)
                        echo "Đang tự động tiêm mã bẻ khóa Proxy vào Home Assistant..."
                        mkdir -p "$HOMELAB_DIR/homeassistant/config"
                        cat << 'EOF_HA' > "$HOMELAB_DIR/homeassistant/config/configuration.yaml"
# Loads default set of integrations. Do not remove.
default_config:

# Load frontend themes from the themes folder
frontend:
  themes: !include_dir_merge_named themes

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.16.0.0/12
    - 192.168.0.0/16
    - 10.0.0.0/8
EOF_HA
                        touch "$HOMELAB_DIR/homeassistant/config/automations.yaml"
                        touch "$HOMELAB_DIR/homeassistant/config/scripts.yaml"
                        touch "$HOMELAB_DIR/homeassistant/config/scenes.yaml"
                        cd "$HOMELAB_DIR/$app_name" && docker compose restart
                        print_success "Đã nạp xong cấu hình chống chặn Cloudflare!"
                        echo "Bạn hãy tải lại (F5) trang Home Assistant nhé."
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    2)
                        echo "Đang cài đặt HACS (Home Assistant Community Store)..."
                        if docker exec homeassistant bash -c "wget -O - https://get.hacs.xyz | bash -"; then
                            print_success "Cài đặt HACS thành công! Hãy quay lại menu quản lý và Khởi động lại (Phím 2) để áp dụng."
                        else
                            print_error "Cài đặt HACS thất bại. Hãy kiểm tra lại kết nối mạng hoặc trạng thái container."
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            "omiroute")
                case $adv_choice in
                    1)
                        echo "Đang sửa lỗi phân quyền (chmod 777) cho OmniRoute..."
                        chmod -R 777 "$HOMELAB_DIR/omiroute/data" 2>/dev/null || true
                        docker exec --user root omiroute chmod -R 777 /app/data 2>/dev/null || true
                        print_success "Đã mở quyền ghi tối đa thành công!"
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            "cliproxy")
                case $adv_choice in
                    1)
                        echo "Đang sửa lỗi phân quyền (chmod 777) cho CLI Proxy API..."
                        chmod -R 777 "$HOMELAB_DIR/cliproxy/auth-data" 2>/dev/null || true
                        docker exec --user root cliproxy chmod -R 777 /root/.cli-proxy-api 2>/dev/null || true
                        print_success "Đã mở quyền ghi tối đa thành công!"
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    2)
                        if [ -f "$HOMELAB_DIR/cliproxy/config.yaml" ]; then
                            echo -e "Lưu ý: CLI Proxy API tự động mã hóa (hash) Management Key sau khi khởi động."
                            echo -e "Do đó, bạn không thể xem lại Key gốc mà chỉ có thể tạo Key mới."
                            read -p "🔑 Nhập Management Key mới (Để trống sẽ tự động tạo ngẫu nhiên): " new_mgmt_key
                            if [ -z "$new_mgmt_key" ]; then
                                new_mgmt_key=$(openssl rand -hex 16)
                            fi
                            sed -i 's/^[[:space:]]*secret-key:.*$/  secret-key: "'"$new_mgmt_key"'"/' "$HOMELAB_DIR/cliproxy/config.yaml"
                            print_success "Đã cập nhật Management Key mới!"
                            echo -e "🔐 Key mới của bạn là: ${YELLOW}$new_mgmt_key${NC}"
                            echo "Đang khởi động lại CLI Proxy API để áp dụng..."
                            cd "$HOMELAB_DIR/cliproxy" && docker compose restart 2>/dev/null
                        else
                            print_error "Không tìm thấy file config.yaml!"
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            "openclaw")
                case $adv_choice in
                    1)
                        echo "Đang sửa lỗi phân quyền (chmod 777) cho OpenClaw..."
                        chmod -R 777 "$HOMELAB_DIR/openclaw/data" 2>/dev/null || true
                        docker exec --user root openclaw chmod -R 777 /home/node/.openclaw 2>/dev/null || true
                        docker exec --user root openclaw chown -R 1000:1000 /home/node/.openclaw 2>/dev/null || true
                        print_success "Đã mở quyền ghi tối đa thành công!"
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    2)
                        # Lấy domain nếu có
                        local d=""
                        if [ -f "$HOMELAB_DIR/openclaw/.env" ]; then
                            d=$(grep "^DOMAIN=" "$HOMELAB_DIR/openclaw/.env" | cut -d '=' -f2)
                        fi
                        init_openclaw_config "$d"
                        print_success "Đã tạo cấu hình thành công! Hãy Khởi động lại (Restart) OpenClaw."
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    3)
                        echo "Danh sách các thiết bị đang chờ phê duyệt:"
                        docker exec openclaw openclaw devices list || true
                        echo ""
                        read -p "Nhập mã thiết bị (Device ID) cần phê duyệt (hoặc dán nguyên cả lệnh): " dev_id
                        if [ -n "$dev_id" ]; then
                            dev_id=$(echo "$dev_id" | awk '{print $NF}')
                            docker exec openclaw openclaw devices approve "$dev_id"
                            print_success "Đã phê duyệt thiết bị thành công!"
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    4)
                        echo -e "Bạn muốn liên kết OpenClaw với kênh nào?"
                        echo "1. Telegram"
                        echo "2. Discord"
                        echo "3. WhatsApp (Quét mã QR)"
                        read -p "Chọn (1-3): " ch_choice
                        case $ch_choice in
                            1)
                                read -p "Nhập Bot Token của Telegram (Lấy từ @BotFather): " t_token
                                if [ -n "$t_token" ]; then
                                    docker exec openclaw openclaw channels add --channel telegram --token "$t_token"
                                    print_success "Đã gửi lệnh liên kết Telegram!"
                                fi
                                ;;
                            2)
                                read -p "Nhập Bot Token của Discord: " d_token
                                if [ -n "$d_token" ]; then
                                    docker exec openclaw openclaw channels add --channel discord --token "$d_token"
                                    print_success "Đã gửi lệnh liên kết Discord!"
                                fi
                                ;;
                            3)
                                echo "Đang lấy mã QR đăng nhập WhatsApp..."
                                docker exec -it openclaw openclaw channels login
                                ;;
                            *) print_error "Hủy thao tác." ;;
                        esac
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    5)
                        echo -e "🔑 Mật khẩu mặc định của OpenClaw là: ${YELLOW}admin123${NC}"
                        echo -e "${RED}Hiện tại OpenClaw không hỗ trợ đổi mật khẩu qua script.${NC}"
                        echo -e "${RED}Vui lòng đổi mật khẩu trực tiếp trên giao diện Web của OpenClaw.${NC}"
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            "9router")
                case $adv_choice in
                    1)
                        echo "Đang sửa lỗi phân quyền (chmod 777) cho 9Router..."
                        chmod -R 777 "$HOMELAB_DIR/9router/data" 2>/dev/null || true
                        docker exec --user root 9router chmod -R 777 /app/data 2>/dev/null || true
                        print_success "Đã mở quyền ghi tối đa thành công!"
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    2)
                        echo -e "🔑 Mật khẩu mặc định của 9Router là: ${YELLOW}admin123${NC}"
                        echo -e "Tài khoản đăng nhập thường là ${YELLOW}admin${NC} hoặc không cần username."
                        echo -e "${RED}Hiện tại 9Router không hỗ trợ đổi mật khẩu qua script.${NC}"
                        echo -e "${RED}Vui lòng đổi mật khẩu trực tiếp trên giao diện quản trị của 9Router.${NC}"
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            "dozzle")
                case $adv_choice in
                    1)
                        if [ -f "$HOMELAB_DIR/dozzle/.env" ]; then
                            local d_user=$(grep "DOZZLE_USERNAME=" "$HOMELAB_DIR/dozzle/.env" | cut -d '=' -f2)
                            local d_pass=$(grep "DOZZLE_PASSWORD=" "$HOMELAB_DIR/dozzle/.env" | cut -d '=' -f2)
                            echo -e "🔐 ${GREEN}Tài khoản Dozzle:${NC}"
                            echo -e "   - Username: ${YELLOW}$d_user${NC}"
                            echo -e "   - Password: ${YELLOW}$d_pass${NC}"
                        else
                            print_error "Không tìm thấy file .env của Dozzle."
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    2)
                        echo -e "🔄 ${CYAN}Đổi mật khẩu Dozzle${NC}"
                        read -p "Nhập mật khẩu mới: " new_pass
                        if [ -n "$new_pass" ]; then
                            local d_user=$(grep "DOZZLE_USERNAME=" "$HOMELAB_DIR/dozzle/.env" | cut -d '=' -f2)
                            if [ -z "$d_user" ]; then d_user="admin"; fi
                            echo "Đang tạo mã băm..."
                            docker run --rm amir20/dozzle:latest generate "$d_user" --password "$new_pass" > "$HOMELAB_DIR/dozzle/data/users.yml" 2>/dev/null
                            sed -i "s/^DOZZLE_PASSWORD=.*/DOZZLE_PASSWORD=$new_pass/" "$HOMELAB_DIR/dozzle/.env"
                            echo "Đang khởi động lại Dozzle..."
                            cd "$HOMELAB_DIR/dozzle" && docker compose restart
                            print_success "Đã đổi mật khẩu thành công!"
                        else
                            print_error "Mật khẩu không được để trống!"
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            "hermes")
                case $adv_choice in
                    1)
                        echo -e "🧠 ${CYAN}Cấu hình Provider và Model cho Hermes Agent${NC}"
                        echo "Bạn muốn cấu hình theo cách nào?"
                        echo -e "   ${YELLOW}1.${NC} Khai báo API tùy chỉnh (Dùng cho 9Router / OmniRoute)"
                        echo -e "   ${YELLOW}2.${NC} Cài đặt qua giao diện của Hermes (Dùng cho Nous Portal / OpenAI gốc)"
                        read -p "Chọn (1/2): " ai_setup_choice
                        
                        if [ "$ai_setup_choice" == "1" ]; then
                            echo "Lưu ý: Bỏ trống nếu bạn muốn dùng giá trị mặc định của API."
                            read -p "Nhập Base URL (VD: http://10.10.10.10:8000/v1 để dùng chung 9Router): " api_url
                            read -p "Nhập API Key (Nếu dùng 9Router nội bộ thì nhập bừa 'sk-homelab'): " api_key
                            
                            echo "Đang lưu cấu hình..."
                            touch "$HOMELAB_DIR/hermes/.env"
                            # Cập nhật hoặc thêm mới các biến
                            grep -q "^OPENAI_BASE_URL=" "$HOMELAB_DIR/hermes/.env" && sed -i "s|^OPENAI_BASE_URL=.*|OPENAI_BASE_URL=$api_url|" "$HOMELAB_DIR/hermes/.env" || echo "OPENAI_BASE_URL=$api_url" >> "$HOMELAB_DIR/hermes/.env"
                            grep -q "^OPENAI_API_KEY=" "$HOMELAB_DIR/hermes/.env" && sed -i "s|^OPENAI_API_KEY=.*|OPENAI_API_KEY=$api_key|" "$HOMELAB_DIR/hermes/.env" || echo "OPENAI_API_KEY=$api_key" >> "$HOMELAB_DIR/hermes/.env"
                            
                            # Set default provider to openai if URL is provided
                            if [ -n "$api_url" ]; then
                                grep -q "^ACTIVE_PROVIDER=" "$HOMELAB_DIR/hermes/.env" && sed -i "s|^ACTIVE_PROVIDER=.*|ACTIVE_PROVIDER=openai|" "$HOMELAB_DIR/hermes/.env" || echo "ACTIVE_PROVIDER=openai" >> "$HOMELAB_DIR/hermes/.env"
                            fi

                            echo "Đang khởi động lại Hermes Agent để áp dụng cấu hình..."
                            cd "$HOMELAB_DIR/hermes" && docker compose down && docker compose up -d
                            print_success "Hoàn tất cấu hình! Hãy tải lại (F5) trang Web UI để sử dụng."
                        elif [ "$ai_setup_choice" == "2" ]; then
                            echo "Lưu ý: Bạn sắp bước vào giao diện cài đặt của Hermes."
                            echo ""; read -p "Nhấn Enter để bắt đầu..."
                            docker exec -it hermes hermes model
                            echo "Đang khởi động lại Hermes Agent để áp dụng cấu hình..."
                            cd "$HOMELAB_DIR/hermes" && docker compose restart
                            print_success "Hoàn tất cấu hình! Hãy tải lại (F5) trang Web UI để sử dụng."
                        else
                            print_error "Lựa chọn không hợp lệ!"
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    2)
                        echo -e "🔑 Mật khẩu của Hermes Agent đã được mã hóa an toàn (Bcrypt)."
                        echo "Bạn không thể xem lại dạng văn bản rõ. Hãy dùng tùy chọn 3 để thiết lập mật khẩu mới."
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    3)
                        echo -e "🔄 ${CYAN}Đổi mật khẩu Hermes Agent${NC}"
                        read -p "Nhập mật khẩu mới: " new_pass
                        if [ -n "$new_pass" ]; then
                            echo "Đang tạo mã băm an toàn..."
                            docker run --rm --entrypoint python3 -v "$HOMELAB_DIR/hermes/data:/opt/data" nousresearch/hermes-agent:latest -c "
try:
    from plugins.dashboard_auth.basic import hash_password
    h = hash_password('$new_pass')
except:
    import bcrypt
    h = bcrypt.hashpw(b'$new_pass', bcrypt.gensalt()).decode()
with open('/opt/data/config.yaml', 'r') as f:
    content = f.read()
import re
new_content = re.sub(r'password_hash:\s*\".*?\"', f'password_hash: \"{h}\"', content)
with open('/opt/data/config.yaml', 'w') as f:
    f.write(new_content)
" 2>/dev/null
                            echo "Đang khởi động lại Hermes Agent..."
                            cd "$HOMELAB_DIR/hermes" && docker compose restart
                            print_success "Đã đổi mật khẩu thành công!"
                        else
                            print_error "Mật khẩu không được để trống!"
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            "duplicati")
                case $adv_choice in
                    1)
                        if [ -f "$HOMELAB_DIR/duplicati/docker-compose.yml" ]; then
                            local dup_pass=$(grep "DUPLICATI__WEBSERVICE_PASSWORD" "$HOMELAB_DIR/duplicati/docker-compose.yml" | cut -d '=' -f2)
                            echo -e "🔐 ${GREEN}Mật khẩu Duplicati:${NC} ${YELLOW}$dup_pass${NC}"
                        else
                            print_error "Không tìm thấy cấu hình Duplicati."
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    2)
                        echo -e "🔄 ${CYAN}Đổi mật khẩu Duplicati${NC}"
                        read -p "Nhập mật khẩu mới: " new_pass
                        if [ -n "$new_pass" ]; then
                            sed -i "s/DUPLICATI__WEBSERVICE_PASSWORD=.*/DUPLICATI__WEBSERVICE_PASSWORD=$new_pass/" "$HOMELAB_DIR/duplicati/docker-compose.yml"
                            echo "Đang khởi động lại Duplicati để cập nhật cấu hình..."
                            cd "$HOMELAB_DIR/duplicati" && docker compose up -d
                            print_success "Đã đổi mật khẩu thành công!"
                        else
                            print_error "Mật khẩu không được để trống!"
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            "postgres-core")
                case $adv_choice in
                    1)
                        if [ -f "$HOMELAB_DIR/postgres-core/.env" ]; then
                            local pg_pass=$(grep "POSTGRES_PASSWORD=" "$HOMELAB_DIR/postgres-core/.env" | cut -d '=' -f2)
                            echo -e "🔐 ${GREEN}Thông tin kết nối PostgreSQL:${NC}"
                            echo -e "   - Host: ${YELLOW}postgres-core${NC} (Mạng nội bộ Docker)"
                            echo -e "   - Username: ${YELLOW}postgres${NC}"
                            echo -e "   - Password: ${YELLOW}$pg_pass${NC}"
                        else
                            print_error "Không tìm thấy cấu hình PostgreSQL."
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    2)
                        echo -e "🔄 ${CYAN}Đổi mật khẩu PostgreSQL${NC}"
                        read -p "Nhập mật khẩu mới: " new_pass
                        if [ -n "$new_pass" ]; then
                            echo "Đang cập nhật mật khẩu trong Database..."
                            docker exec postgres-core psql -U postgres -c "ALTER USER postgres PASSWORD '$new_pass';" >/dev/null 2>&1
                            if [ $? -eq 0 ]; then
                                sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$new_pass/" "$HOMELAB_DIR/postgres-core/.env"
                                echo "Đang khởi động lại PostgreSQL..."
                                cd "$HOMELAB_DIR/postgres-core" && docker compose restart
                                print_success "Đã đổi mật khẩu thành công!"
                            else
                                print_error "Không thể kết nối vào Database để đổi mật khẩu. Đảm bảo container đang chạy."
                            fi
                        else
                            print_error "Mật khẩu không được để trống!"
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            "redis-core")
                case $adv_choice in
                    1)
                        if [ -f "$HOMELAB_DIR/redis-core/.env" ]; then
                            local rd_pass=$(grep "REDIS_PASSWORD=" "$HOMELAB_DIR/redis-core/.env" | cut -d '=' -f2)
                            echo -e "🔐 ${GREEN}Thông tin kết nối Redis:${NC}"
                            echo -e "   - Host: ${YELLOW}redis-core${NC} (Mạng nội bộ Docker)"
                            echo -e "   - Password: ${YELLOW}$rd_pass${NC}"
                        else
                            print_error "Không tìm thấy cấu hình Redis."
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    2)
                        echo -e "🔄 ${CYAN}Đổi mật khẩu Redis${NC}"
                        read -p "Nhập mật khẩu mới: " new_pass
                        if [ -n "$new_pass" ]; then
                            sed -i "s/^REDIS_PASSWORD=.*/REDIS_PASSWORD=$new_pass/" "$HOMELAB_DIR/redis-core/.env"
                            echo "Đang khởi động lại Redis để áp dụng mật khẩu mới..."
                            cd "$HOMELAB_DIR/redis-core" && docker compose down && docker compose up -d
                            print_success "Đã đổi mật khẩu thành công!"
                        else
                            print_error "Mật khẩu không được để trống!"
                        fi
                        echo ""; read -p "Nhấn Enter để tiếp tục..."
                        ;;
                    *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
                esac
                ;;
            *)
                print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
        esac
    done
}

manage_single_app() {
    local app_name=$1
    while true; do
        clear
        local display_name=""
        case "$app_name" in
            "n8n") display_name="N8N" ;;
            "homeassistant") display_name="Home Assistant" ;;
            "omiroute") display_name="OmniRoute" ;;
            "9router") display_name="9Router" ;;
            "openclaw") display_name="OpenClaw" ;;
            "hermes") display_name="Hermes Agent" ;;
            "uptimekuma") display_name="Uptime Kuma" ;;
            "nodejs") display_name="NodeJS" ;;
            "duplicati") display_name="Duplicati" ;;
            "dozzle") display_name="Dozzle" ;;
            "portainer") display_name="Portainer CE" ;;
            "cliproxy") display_name="CLI Proxy API" ;;
            *) display_name="$app_name" ;;
        esac

        local ver=""
        if [ -f "$HOMELAB_DIR/$app_name/docker-compose.yml" ]; then
            if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$app_name"; then
                ver=$(docker inspect -f '{{ index .Config.Labels "org.opencontainers.image.version"}}' "$app_name" 2>/dev/null)
                if [ -z "$ver" ] || [ "$ver" == "<no value>" ]; then
                    ver=$(docker inspect -f '{{ index .Config.Labels "version"}}' "$app_name" 2>/dev/null)
                fi
                if [ -z "$ver" ] || [ "$ver" == "<no value>" ]; then
                    ver=$(grep "image:" "$HOMELAB_DIR/$app_name/docker-compose.yml" | head -n 1 | awk -F':' '{print $NF}' | tr -d '"' | tr -d ' ' | tr -d '\r')
                fi
                if [ -n "$ver" ]; then
                    ver=" - v$ver"
                fi
            fi
        fi

        print_section "Quản lý Ứng dụng: ${display_name}${ver}"
        
        # Lấy trạng thái
        local status="Unknown"
        if [ -d "$HOMELAB_DIR/$app_name" ]; then
            cd "$HOMELAB_DIR/$app_name" 2>/dev/null
            status=$(docker ps -q -f "name=^${app_name}$" -f "status=running" 2>/dev/null | wc -l)
            if [ "$status" -gt 0 ]; then
                echo -e "Trạng thái: ${GREEN}Đang hoạt động ($status container)${NC}"
            else
                echo -e "Trạng thái: ${RED}Đã dừng${NC}"
            fi
        fi

        echo -e "\n${GREEN} 1.${NC} 📜 Xem Logs (Lịch sử hoạt động)"
        echo -e "${GREEN} 2.${NC} 🔄 Khởi động lại (Restart)"
        
        if [ "$status" -gt 0 ]; then
            echo -e "${YELLOW} 3.${NC} ⏹️ Dừng ứng dụng (Stop)"
        else
            echo -e "${GREEN} 3.${NC} ▶️ Bật ứng dụng (Start)"
        fi
        
        echo -e "${GREEN} 4.${NC} 🚀 Cập nhật / Nạp lại cấu hình (Pull & Up)"
        echo -e "${YELLOW} 5.${NC} ⚙️ Chỉnh sửa Cấu hình / Đổi tên miền"
        
        echo -e "${CYAN} 6.${NC} 🛠️ Tiện ích mở rộng & Sửa lỗi (Advanced Tools)"
        
        echo -e "${RED} 7.${NC} 🗑 Xóa ứng dụng (Gỡ cài đặt)"
        echo -e "${YELLOW} 0.${NC} Quay lại"
        echo ""
        read -p "Nhập lựa chọn của bạn: " act_choice
        
        case $act_choice in
            1)
                echo "Đang hiển thị 50 dòng log gần nhất của $app_name..."
                cd "$HOMELAB_DIR/$app_name" && docker compose logs --tail 50
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            2)
                echo "Đang khởi động lại $app_name..."
                cd "$HOMELAB_DIR/$app_name" && docker compose up -d --force-recreate
                print_success "Đã khởi động lại xong!"
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            3)
                if [ "$status" -gt 0 ]; then
                    echo "Đang dừng $app_name..."
                    cd "$HOMELAB_DIR/$app_name" && docker compose stop
                    print_success "Đã dừng ứng dụng."
                else
                    echo "Đang bật $app_name..."
                    cd "$HOMELAB_DIR/$app_name" && docker compose up -d
                    print_success "Đã bật ứng dụng."
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            4)
                echo "Đang tải bản cập nhật và nạp lại cấu hình cho $app_name..."
                cd "$HOMELAB_DIR/$app_name"
                docker compose pull
                docker compose up -d
                print_success "Đã xử lý xong!"
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            5)
                echo -e "Bạn muốn chỉnh sửa file cấu hình nào?"
                echo -e " 1. File docker-compose.yml (Cấu hình container lõi)"
                if [ -f "$HOMELAB_DIR/$app_name/.env" ]; then
                    echo -e " 2. File .env (Chứa Tên miền và các biến môi trường)"
                fi
                echo -e " 0. Hủy bỏ"
                read -p "Chọn (0-2): " edit_choice
                if [ "$edit_choice" == "1" ]; then
                    nano "$HOMELAB_DIR/$app_name/docker-compose.yml"
                    print_success "Đã lưu! Hãy chọn mục số 4 (Nạp lại cấu hình) để áp dụng ngay."
                elif [ "$edit_choice" == "2" ] && [ -f "$HOMELAB_DIR/$app_name/.env" ]; then
                    nano "$HOMELAB_DIR/$app_name/.env"
                    print_success "Đã lưu! Hãy chọn mục số 4 (Nạp lại cấu hình) để áp dụng ngay."
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            6)
                advanced_tools_menu "$app_name"
                ;;
            7)
                read -p "$(echo -e "\n${RED}⚠ CẢNH BÁO: Xóa toàn bộ dữ liệu của '$app_name'? (y/N): ${NC}")" conf
                if [[ "$conf" =~ ^[Yy]$ ]]; then
                    cd "$HOMELAB_DIR/$app_name" && docker compose down -v || true
                    cd /
                    rm -rf "$HOMELAB_DIR/$app_name"
                    local safe_app_upper=$(echo "$app_name" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
                    sed -i "/^DOMAIN_${safe_app_upper}=/d" "$CONFIG_FILE"
                    print_success "Đã xóa sạch ứng dụng $app_name"
                    echo ""; read -p "Nhấn Enter để tiếp tục..."
                    return
                fi
                ;;
            0) return ;;
            *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
        esac
    done
}

manage_apps_menu() {
    while true; do
        clear
        print_section "Quản lý Ứng dụng đang chạy"
        local apps=()
        if [ -d "$HOMELAB_DIR" ]; then
            for dir in "$HOMELAB_DIR"/*/; do
                if [ -d "$dir" ]; then
                    local name=$(basename "$dir")
                    if [ "$name" != "cloudflared" ]; then
                        apps+=("$name")
                    fi
                fi
            done
        fi
        
        if [ ${#apps[@]} -eq 0 ]; then
            print_warning "Chưa có ứng dụng nào được cài đặt."
            echo ""; read -p "Nhấn Enter để tiếp tục..."
            return
        fi
        
        local i=1
        for app in "${apps[@]}"; do
            echo -e "${GREEN} $i.${NC} $app"
            ((i++))
        done
        echo -e "${YELLOW} 0.${NC} Quay lại"
        echo ""
        
        read -p "Chọn ứng dụng để quản lý (0-${#apps[@]}): " app_idx
        
        if [ "$app_idx" == "0" ] || [ -z "$app_idx" ]; then
            return
        elif [[ "$app_idx" =~ ^[0-9]+$ ]] && [ "$app_idx" -ge 1 ] && [ "$app_idx" -le ${#apps[@]} ]; then
            local selected_app="${apps[$((app_idx-1))]}"
            manage_single_app "$selected_app"
        else
            print_error "Lựa chọn không hợp lệ."
            echo ""; read -p "Nhấn Enter để tiếp tục..."
        fi
    done
}

app_store_menu() {
    while true; do
        local running_containers=$(docker ps --format '{{.Names}}' 2>/dev/null || echo "")
        
        get_status() {
            local app=$1
            if [ -f "$HOMELAB_DIR/$app/docker-compose.yml" ]; then
                if echo "$running_containers" | grep -qx "$app"; then
                    local ver=$(docker inspect -f '{{ index .Config.Labels "org.opencontainers.image.version"}}' "$app" 2>/dev/null)
                    if [ -z "$ver" ] || [ "$ver" == "<no value>" ]; then
                        ver=$(docker inspect -f '{{ index .Config.Labels "version"}}' "$app" 2>/dev/null)
                    fi
                    if [ -z "$ver" ] || [ "$ver" == "<no value>" ]; then
                        ver=$(grep "image:" "$HOMELAB_DIR/$app/docker-compose.yml" | head -n 1 | awk -F':' '{print $NF}' | tr -d '"' | tr -d ' ' | tr -d '
')
                    fi
                    echo "[${GREEN}Đang chạy - v$ver${NC}]"
                else
                    echo "[${RED}Đã dừng${NC}]"
                fi
            else
                echo "[Chưa cài]"
            fi
        }

        local st1=$(get_status "n8n")
        local st2=$(get_status "homeassistant")
        local st3=$(get_status "omiroute")
        local st4=$(get_status "9router")
        local st5=$(get_status "cliproxy")
        local st6=$(get_status "openclaw")
        local st7=$(get_status "hermes")
        local st8=$(get_status "uptimekuma")
        local st9=$(get_status "nodejs")
        local st10=$(get_status "duplicati")
        local st11=$(get_status "dozzle")
        local st12=$(get_status "postgres-core")
        local st13=$(get_status "redis-core")
        local st14=$(get_status "portainer")

        print_section "📦 CỬA HÀNG ỨNG DỤNG (APP STORE)"
        
        echo -e "${BLUE} --- Nhóm Tự động hóa & Nhà thông minh ---${NC}"
        echo -e "${GREEN} 1.${NC} N8N (Tự động hóa workflow) $st1"
        echo -e "${GREEN} 2.${NC} Home Assistant (Nhà thông minh) $st2"
        
        echo -e "${BLUE} --- Nhóm Trí tuệ Nhân tạo (AI & LLMs) ---${NC}"
        echo -e "${GREEN} 3.${NC} OmniRoute (AI Gateway Router) $st3"
        echo -e "${GREEN} 4.${NC} 9Router (AI Gateway Alternative) $st4"
        echo -e "${GREEN} 5.${NC} CLI Proxy API (Trạm trung chuyển & Quản lý API) $st5"
        echo -e "${GREEN} 6.${NC} OpenClaw (Trợ lý AI tự trị) $st6"
        echo -e "${GREEN} 7.${NC} Hermes Agent (Tác tử suy luận lõi) $st7"
        
        echo -e "${BLUE} --- Nhóm Tiện ích & Quản trị Hệ thống ---${NC}"
        echo -e "${GREEN} 8.${NC} Uptime Kuma (Giám sát hệ thống) $st8"
        echo -e "${GREEN} 9.${NC} NodeJS (Môi trường Web Backend) $st9"
        echo -e "${GREEN} 10.${NC} Duplicati (Sao lưu Cloud Google Drive) $st10"
        echo -e "${GREEN} 11.${NC} Dozzle (Xem Log Docker Thời gian thực) $st11"
        
        echo -e "${BLUE} --- Nhóm Dịch vụ Lõi (Core Services) ---${NC}"
        echo -e "${GREEN} 12.${NC} PostgreSQL (Database dùng chung) $st12"
        echo -e "${GREEN} 13.${NC} Redis (Cache & Message Broker) $st13"
        
        echo -e "${BLUE} --- Tùy chọn Nâng cao ---${NC}"
        echo -e "${GREEN} 14.${NC} Portainer CE (Quản lý Docker UI) $st14"
        echo -e "${GREEN} 15.${NC} Quản lý các ứng dụng khác (Tự động quét)"
        echo -e "${YELLOW} 0.${NC} Quay lại Menu chính"
        echo ""
        read -p "Nhập lựa chọn của bạn: " app_choice

        case $app_choice in
            1)
                if [ -f "$HOMELAB_DIR/n8n/docker-compose.yml" ]; then manage_single_app "n8n"; continue; fi
                
                # Khởi tạo DB Password nếu chưa có
                mkdir -p "$HOMELAB_DIR/n8n"
                local db_pass=""
                if [ -f "$HOMELAB_DIR/n8n/.env" ] && grep -q "DB_PASSWORD=" "$HOMELAB_DIR/n8n/.env"; then
                    db_pass=$(grep "DB_PASSWORD=" "$HOMELAB_DIR/n8n/.env" | cut -d '=' -f2)
                else
                    db_pass=$(openssl rand -hex 16)
                    echo "DB_PASSWORD=$db_pass" >> "$HOMELAB_DIR/n8n/.env"
                fi

                read -r -d '' compose << 'EOF' || true
services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres-n8n
    restart: unless-stopped
    environment:
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=n8n
    volumes:
      - ./db_data:/var/lib/postgresql/data
    networks:
      - homelab_net

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    user: "root"
    environment:
      - N8N_HOST=${DOMAIN}
      - WEBHOOK_URL=https://${DOMAIN}/
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
      - NODES_EXCLUDE=[]
      - NODE_FUNCTION_ALLOW_EXTERNAL=*
      - NODE_FUNCTION_ALLOW_BUILTIN=*
      # Cấu hình Postgres
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=${DB_PASSWORD}
    depends_on:
      - postgres
    volumes:
      - ./data:/home/node/.n8n
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "n8n" "5678" "$compose"
                ;;
            2)
                if [ -f "$HOMELAB_DIR/homeassistant/docker-compose.yml" ]; then manage_single_app "homeassistant"; continue; fi
                read -r -d '' compose << 'EOF' || true
services:
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:stable
    container_name: homeassistant
    restart: unless-stopped
    privileged: true
    volumes:
      - ./config:/config
      - /etc/localtime:/etc/localtime:ro
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "homeassistant" "8123" "$compose"
                ;;
            3)
                if [ -f "$HOMELAB_DIR/omiroute/docker-compose.yml" ]; then manage_single_app "omiroute"; continue; fi
                
                mkdir -p "$HOMELAB_DIR/omiroute"
                local jwt_secret=$(openssl rand -hex 32)
                local storage_key=$(openssl rand -hex 32)

                read -r -d '' compose << EOF || true
services:
  omiroute:
    image: diegosouzapw/omniroute:latest
    container_name: omiroute
    restart: unless-stopped
    environment:
      - REDIS_URL=redis://omiroute-redis:6379
      - JWT_SECRET=$jwt_secret
      - STORAGE_ENCRYPTION_KEY=$storage_key
    volumes:
      - ./data:/app/data
    depends_on:
      - omiroute-redis
    networks:
      - homelab_net

  omiroute-redis:
    image: redis:7-alpine
    container_name: omiroute-redis
    restart: unless-stopped
    volumes:
      - ./redis-data:/data
    command: redis-server --save 60 1 --loglevel warning
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "omiroute" "20128" "$compose"
                ;;
            4)
                if [ -f "$HOMELAB_DIR/9router/docker-compose.yml" ]; then manage_single_app "9router"; continue; fi
                read -r -d '' compose << 'EOF' || true
services:
  9router:
    image: decolua/9router:latest
    container_name: 9router
    restart: unless-stopped
    environment:
      - INITIAL_PASSWORD=admin123
    volumes:
      - ./data:/app/data
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "9router" "20128" "$compose"
                ;;
            5)
                if [ -f "$HOMELAB_DIR/cliproxy/docker-compose.yml" ]; then manage_single_app "cliproxy"; continue; fi
                
                read -r -d '' compose << 'EOF' || true
services:
  cliproxy:
    image: eceasy/cli-proxy-api:latest
    container_name: cliproxy
    restart: unless-stopped
    volumes:
      - ./config.yaml:/CLIProxyAPI/config.yaml
      - ./auth-data:/root/.cli-proxy-api
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "cliproxy" "8317" "$compose"
                ;;
            6)
                if [ -f "$HOMELAB_DIR/openclaw/docker-compose.yml" ]; then manage_single_app "openclaw"; continue; fi
                
                read -r -d '' compose << 'EOF' || true
services:
  openclaw:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw
    restart: unless-stopped
    environment:
      - OPENCLAW_GATEWAY_PASSWORD=admin123
    volumes:
      - ./data:/home/node/.openclaw
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "openclaw" "18789" "$compose"
                ;;
            7)
                if [ -f "$HOMELAB_DIR/hermes/docker-compose.yml" ]; then manage_single_app "hermes"; continue; fi
                
                read -r -d '' compose << 'EOF' || true
services:
  hermes:
    image: nousresearch/hermes-agent:latest
    container_name: hermes
    restart: unless-stopped
    command: dashboard --host 0.0.0.0
    env_file:
      - .env
    volumes:
      - ./data:/opt/data
      - ./.env:/root/.hermes/.env
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "hermes" "9119" "$compose"
                ;;

            8)
                if [ -f "$HOMELAB_DIR/uptimekuma/docker-compose.yml" ]; then manage_single_app "uptimekuma"; continue; fi
                read -r -d '' compose << 'EOF' || true
services:
  uptimekuma:
    image: louislam/uptime-kuma:2
    container_name: uptimekuma
    user: root
    restart: unless-stopped
    volumes:
      - ./data:/app/data
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "uptimekuma" "3001" "$compose"
                ;;
            9)
                if [ -f "$HOMELAB_DIR/nodejs/docker-compose.yml" ]; then manage_single_app "nodejs"; continue; fi
                read -r -d '' compose << 'EOF' || true
services:
  nodejs:
    image: node:20-alpine
    container_name: nodejs
    restart: unless-stopped
    working_dir: /usr/src/app
    command:
      - sh
      - -c
      - |
        npm init -y
        npm install express
        cat << 'EOF_JS' > index.js
        const express = require('express');
        const app = express();
        const html = `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>NodeJS Homelab Backend</title>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    font-family: 'Inter', sans-serif;
                    background: linear-gradient(135deg, #0f2027, #203a43, #2c5364);
                    color: white;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    overflow: hidden;
                }
                .container {
                    text-align: center;
                    background: rgba(255, 255, 255, 0.1);
                    padding: 3rem 4rem;
                    border-radius: 20px;
                    backdrop-filter: blur(10px);
                    border: 1px solid rgba(255, 255, 255, 0.2);
                    box-shadow: 0 25px 45px rgba(0, 0, 0, 0.2);
                    animation: float 6s ease-in-out infinite;
                }
                h1 {
                    font-size: 2.5rem;
                    margin-bottom: 10px;
                    background: -webkit-linear-gradient(#00d2ff, #3a7bd5);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                }
                p {
                    font-size: 1.2rem;
                    color: #d1d1d1;
                    line-height: 1.6;
                }
                .status {
                    display: inline-block;
                    margin-top: 20px;
                    padding: 10px 20px;
                    background: rgba(0, 255, 136, 0.2);
                    color: #00ff88;
                    border-radius: 50px;
                    font-weight: bold;
                    border: 1px solid #00ff88;
                }
                @keyframes float {
                    0% { transform: translateY(0px); }
                    50% { transform: translateY(-20px); }
                    100% { transform: translateY(0px); }
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🚀 NodeJS Backend Ready</h1>
                <p>Môi trường Backend của bạn đã được khởi tạo thành công<br>và đang kết nối an toàn qua Cloudflare Tunnel!</p>
                <div class="status">● Server is running on Port 3000</div>
            </div>
        </body>
        </html>
        `;
        app.get('/', (req, res) => res.send(html));
        app.listen(3000, () => console.log('Server is running on port 3000'));
        EOF_JS
        node index.js
    volumes:
      - ./app:/usr/src/app
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "nodejs" "3000" "$compose"
                ;;
            10)
                if [ -f "$HOMELAB_DIR/duplicati/docker-compose.yml" ]; then manage_single_app "duplicati"; continue; fi
                
                # Khởi tạo Encryption Key cho Duplicati nếu chưa có
                mkdir -p "$HOMELAB_DIR/duplicati"
                local dup_key=""
                if [ -f "$HOMELAB_DIR/duplicati/.env" ] && grep -q "SETTINGS_ENCRYPTION_KEY=" "$HOMELAB_DIR/duplicati/.env"; then
                    dup_key=$(grep "SETTINGS_ENCRYPTION_KEY=" "$HOMELAB_DIR/duplicati/.env" | cut -d '=' -f2)
                else
                    dup_key=$(openssl rand -hex 16)
                    echo "SETTINGS_ENCRYPTION_KEY=$dup_key" >> "$HOMELAB_DIR/duplicati/.env"
                fi

                read -r -d '' compose << 'EOF' || true
services:
  duplicati:
    image: lscr.io/linuxserver/duplicati:latest
    container_name: duplicati
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Ho_Chi_Minh
      - SETTINGS_ENCRYPTION_KEY=${SETTINGS_ENCRYPTION_KEY}
      - DUPLICATI__WEBSERVICE_PASSWORD=admin123
    volumes:
      - ./config:/config
      - ./backups:/backups
      - /opt/homelab:/source
    restart: unless-stopped
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "duplicati" "8200" "$compose"
                ;;
            11)
                if [ -f "$HOMELAB_DIR/dozzle/docker-compose.yml" ]; then manage_single_app "dozzle"; continue; fi
                
                read -r -d '' compose << 'EOF' || true
services:
  dozzle:
    image: amir20/dozzle:latest
    container_name: dozzle
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./data:/data
    environment:
      - DOZZLE_AUTH_PROVIDER=simple
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "dozzle" "8080" "$compose"
                ;;
            12)
                if [ -f "$HOMELAB_DIR/postgres-core/docker-compose.yml" ]; then manage_single_app "postgres-core"; continue; fi
                
                # Khởi tạo DB Password ngẫu nhiên bảo mật
                mkdir -p "$HOMELAB_DIR/postgres-core"
                local db_pass=$(openssl rand -hex 16)
                echo "POSTGRES_USER=postgres" > "$HOMELAB_DIR/postgres-core/.env"
                echo "POSTGRES_PASSWORD=$db_pass" >> "$HOMELAB_DIR/postgres-core/.env"

                read -r -d '' compose << 'EOF' || true
services:
  postgres-core:
    image: postgres:16-alpine
    container_name: postgres-core
    restart: unless-stopped
    env_file: .env
    volumes:
      - ./data:/var/lib/postgresql/data
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "postgres-core" "none" "$compose"
                ;;
            13)
                if [ -f "$HOMELAB_DIR/redis-core/docker-compose.yml" ]; then manage_single_app "redis-core"; continue; fi
                
                mkdir -p "$HOMELAB_DIR/redis-core"
                local redis_pass=$(openssl rand -hex 16)
                echo "REDIS_PASSWORD=$redis_pass" > "$HOMELAB_DIR/redis-core/.env"

                read -r -d '' compose << 'EOF' || true
services:
  redis-core:
    image: redis:7-alpine
    container_name: redis-core
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD}
    env_file: .env
    volumes:
      - ./data:/data
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "redis-core" "none" "$compose"
                ;;
            14)
                if [ -f "$HOMELAB_DIR/portainer/docker-compose.yml" ]; then manage_single_app "portainer"; continue; fi
                read -r -d '' compose << 'EOF' || true
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    command: --no-setup-token
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./data:/data
    networks:
      - homelab_net
networks:
  homelab_net:
    external: true
EOF
                install_app "portainer" "9000" "$compose"
                ;;

            15)
                manage_apps_menu
                ;;
            0) break ;;
            *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
        esac
        clear
    done
}

# ============================================================
# TÍNH NĂNG 4 & 5: DỪNG, BẬT, TRẠNG THÁI
# ============================================================
toggle_services() {
    print_section "Bật/Tắt Toàn bộ Dịch vụ"
    if ! check_docker; then return 0; fi
    read -p "Bạn muốn Bật (b) hay Tắt (t) tất cả dịch vụ? [b/t]: " act
    for app in $(ls -1 $HOMELAB_DIR); do
        if [ -f "$HOMELAB_DIR/$app/docker-compose.yml" ]; then
            if [[ "$act" =~ ^[Bb]$ ]]; then
                echo -e "🚀 Bật $app..."
                cd "$HOMELAB_DIR/$app" && docker compose up -d
            elif [[ "$act" =~ ^[Tt]$ ]]; then
                echo -e "⏹️ Dừng $app..."
                cd "$HOMELAB_DIR/$app" && docker compose down
            fi
        fi
    done
    print_success "Đã hoàn tất thao tác."
}

status_check() {
    print_section "Trạng thái Hệ thống"
    if ! check_docker; then return 0; fi
    echo -e "OS Uptime: $(uptime -p)"
    echo -e "Memory: $(free -h | awk 'NR==2{print $3 "/" $2}')"
    echo ""
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.enc 2>/dev/null | wc -l || echo "0")
    echo -e "📦 Số lượng bản backup: $BACKUP_COUNT bản"
}

# ============================================================
# TÍNH NĂNG 6 & 7: BACKUP & RESTORE
# ============================================================
backup_menu() {
    while true; do
        print_section "💾 Quản lý Sao lưu & Phục hồi"
        BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.enc 2>/dev/null | wc -l || echo "0")
        echo -e "Trạng thái: Đang có ${GREEN}$BACKUP_COUNT${NC} bản sao lưu"
        
        echo -e "\n${GREEN} 1.${NC} Tạo bản sao lưu (Backup)"
        echo -e "${GREEN} 2.${NC} Khôi phục từ bản sao lưu (Restore)"
        echo -e "${GREEN} 3.${NC} Xem danh sách bản sao lưu"
        echo -e "${RED} 4.${NC} Xóa bản sao lưu"
        echo -e "${YELLOW} 0.${NC} Quay lại Menu chính"
        echo ""
        read -p "Nhập lựa chọn của bạn: " bk_opt
        
        case $bk_opt in
            1)
                do_backup
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            2)
                do_restore
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            3)
                print_section "Danh sách Bản sao lưu"
                if [ -z "$(ls -A "$BACKUP_DIR"/*.enc 2>/dev/null)" ]; then
                    print_warning "Chưa có bản backup nào."
                else
                    # Hiển thị dung lượng và tên file (Sắp xếp mới nhất lên đầu)
                    for file in $(ls -t "$BACKUP_DIR"/*.enc); do
                        size=$(ls -lh "$file" | awk '{print $5}')
                        [[ $size =~ ^[0-9]+$ ]] && size="${size}B"
                        name=$(basename "$file")
                        echo -e "[$size] \t $name"
                    done | nl
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            4)
                if [ -z "$(ls -A "$BACKUP_DIR"/*.enc 2>/dev/null)" ]; then
                    print_warning "Không có bản backup nào để xóa."
                else
                    echo "Các bản backup hiện có (Mới nhất xếp trên cùng):"
                    for file in $(ls -t "$BACKUP_DIR"/*.enc); do
                        size=$(ls -lh "$file" | awk '{print $5}')
                        [[ $size =~ ^[0-9]+$ ]] && size="${size}B"
                        name=$(basename "$file")
                        echo -e "[$size] \t $name"
                    done | nl
                    
                    echo ""
                    read -p "Nhập số thứ tự file cần XÓA (hoặc Enter để hủy): " del_choice
                    if [ -n "$del_choice" ]; then
                        SELECTED=$(ls -t "$BACKUP_DIR"/*.enc 2>/dev/null | sed -n "${del_choice}p")
                        if [ -n "$SELECTED" ]; then
                            rm -f "$SELECTED"
                            print_success "Đã xóa bản sao lưu: $(basename "$SELECTED")"
                        else
                            print_error "Lựa chọn không hợp lệ."
                        fi
                    fi
                fi
                echo ""; read -p "Nhấn Enter để tiếp tục..."
                ;;
            0) break ;;
            *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
        esac
        clear
    done
}

do_backup() {
    print_section "Tiến hành Backup (Mã hóa AES-256)"
    mkdir -p $BACKUP_DIR
    if ! check_docker; then return 0; fi
    
    echo "Chọn chế độ Backup:"
    echo -e "${GREEN} 1.${NC} Toàn bộ hệ thống (Tất cả Apps + Config)"
    echo -e "${GREEN} 2.${NC} Một ứng dụng cụ thể (Chỉ 1 App)"
    echo -e "${YELLOW} 0.${NC} Hủy bỏ"
    read -p "Nhập lựa chọn (0-2): " bk_choice
    
    if [ "$bk_choice" == "0" ] || [ -z "$bk_choice" ]; then return 0; fi
    
    local target_dir=""
    local bk_prefix="homelab_all"
    
    if [ "$bk_choice" == "1" ]; then
        target_dir="$HOMELAB_DIR"
    elif [ "$bk_choice" == "2" ]; then
        local app_count=$(find "$HOMELAB_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
        if [ "$app_count" -eq 0 ]; then
            print_warning "Chưa có ứng dụng nào được cài đặt để backup!"
            return 0
        fi
        echo "Các ứng dụng hiện có:"
        ls -1 $HOMELAB_DIR
        read -p "Nhập chính xác tên ứng dụng muốn backup: " app_target
        if [ -z "$app_target" ] || [ ! -d "$HOMELAB_DIR/$app_target" ]; then
            print_error "Không tìm thấy ứng dụng '$app_target'!"
            return 0
        fi
        target_dir="$HOMELAB_DIR/$app_target"
        bk_prefix="homelab_app_${app_target}"
    else
        print_error "Lựa chọn không hợp lệ!"
        return 0
    fi
    
    if [ ! -f "$KEY_FILE" ]; then
        openssl rand -base64 32 > "$KEY_FILE"
        chmod 400 "$KEY_FILE"
        print_warning "Vừa tạo mới Chìa khóa Backup. Hãy lưu kỹ chuỗi này: $(cat $KEY_FILE)"
    fi
    PASSWORD=$(cat "$KEY_FILE")
    DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/${bk_prefix}_${DATE}.tar.gz.enc"

    echo "1. Tạm dừng container..."
    if [ "$bk_choice" == "1" ]; then
        for app in $(ls -1 $HOMELAB_DIR); do
            if [ -f "$HOMELAB_DIR/$app/docker-compose.yml" ]; then cd "$HOMELAB_DIR/$app" && docker compose stop; fi
        done
    else
        if [ -f "$target_dir/docker-compose.yml" ]; then cd "$target_dir" && docker compose stop; fi
    fi

    echo "2. Nén và mã hóa..."
    tar --exclude=".backup_key" -cz -C $(dirname "$target_dir") $(basename "$target_dir") | openssl enc -aes-256-cbc -pbkdf2 -salt -pass pass:"$PASSWORD" -out "$BACKUP_FILE"

    echo "3. Bật lại container..."
    if [ "$bk_choice" == "1" ]; then
        for app in $(ls -1 $HOMELAB_DIR); do
            if [ -f "$HOMELAB_DIR/$app/docker-compose.yml" ]; then cd "$HOMELAB_DIR/$app" && docker compose start; fi
        done
    else
        if [ -f "$target_dir/docker-compose.yml" ]; then cd "$target_dir" && docker compose start; fi
    fi

    # Giữ 10 bản gần nhất
    ls -t "$BACKUP_DIR"/*.tar.gz.enc 2>/dev/null | tail -n +11 | xargs -I {} rm -- {} 2>/dev/null || true

    print_success "Backup thành công: $BACKUP_FILE"
}

do_restore() {
    print_section "Khôi phục Hệ thống / Ứng dụng"
    if ! check_docker; then return 0; fi
    if [ -z "$(ls -A "$BACKUP_DIR"/*.enc 2>/dev/null)" ]; then
        print_error "Không có bản backup nào trong $BACKUP_DIR"
        return 1
    fi

    echo "Các bản backup hiện có (Mới nhất xếp trên cùng):"
    for file in $(ls -t "$BACKUP_DIR"/*.enc); do
        size=$(ls -lh "$file" | awk '{print $5}')
        [[ $size =~ ^[0-9]+$ ]] && size="${size}B"
        name=$(basename "$file")
        echo -e "[$size] \t $name"
    done | nl
    echo ""
    read -p "Nhập số thứ tự file cần khôi phục (hoặc Enter để hủy): " choice
    if [ -z "$choice" ]; then return 0; fi

    SELECTED=$(ls -t "$BACKUP_DIR"/*.enc | sed -n "${choice}p")
    if [ -z "$SELECTED" ]; then
        print_error "Lựa chọn không hợp lệ"
        return 1
    fi
    
    local is_full=true
    local extract_dir=$(dirname $HOMELAB_DIR) # default for full backup is /opt
    if [[ $(basename "$SELECTED") == homelab_app_* ]]; then
        is_full=false
        extract_dir=$HOMELAB_DIR # target for app backup is /opt/homelab
        print_warning "Bạn đang khôi phục MỘT ỨNG DỤNG LẺ."
    else
        print_warning "Bạn đang khôi phục TOÀN BỘ HỆ THỐNG."
    fi

    read -p "🔑 Nhập chìa khóa giải mã (AES-256): " INPUT_KEY

    echo "1. Dừng hệ thống hiện tại..."
    if [ "$is_full" = true ]; then
        for app in $(ls -1 $HOMELAB_DIR); do
            if [ -f "$HOMELAB_DIR/$app/docker-compose.yml" ]; then cd "$HOMELAB_DIR/$app" && docker compose down; fi
        done
    else
        # Extract app name from filename (homelab_app_appname_date.tar.gz.enc)
        local app_name=$(basename "$SELECTED" | awk -F'_' '{print $3}')
        if [ -f "$HOMELAB_DIR/$app_name/docker-compose.yml" ]; then cd "$HOMELAB_DIR/$app_name" && docker compose down; fi
    fi

    echo "2. Đang giải mã và ghi đè..."
    if openssl enc -d -aes-256-cbc -pbkdf2 -salt -pass pass:"$INPUT_KEY" -in "$SELECTED" | tar -xz -C "$extract_dir"; then
        print_success "Giải nén thành công!"
    else
        print_error "Sai chìa khóa hoặc file lỗi!"
        return 1
    fi

    echo "3. Khởi động lại hệ thống..."
    if [ "$is_full" = true ]; then
        for app in $(ls -1 $HOMELAB_DIR); do
            if [ -f "$HOMELAB_DIR/$app/docker-compose.yml" ]; then cd "$HOMELAB_DIR/$app" && docker compose up -d; fi
        done
    else
        local app_name=$(basename "$SELECTED" | awk -F'_' '{print $3}')
        if [ -f "$HOMELAB_DIR/$app_name/docker-compose.yml" ]; then cd "$HOMELAB_DIR/$app_name" && docker compose up -d; fi
    fi
    print_success "Khôi phục hoàn tất!"
}

# ============================================================
# MAIN MENU
# ============================================================
clear_system_cache() {
    print_section "Dọn dẹp rác hệ thống (Clear Docker Cache)"
    echo -e "${YELLOW}Thao tác này sẽ xóa:${NC}"
    echo -e "- Các bản cập nhật cũ (Dangling images) còn thừa sau khi Pull"
    echo -e "- Bộ nhớ đệm Build Cache"
    echo -e "- Các Network rác không còn sử dụng"
    echo -e "${RED}Lưu ý: Không làm mất dữ liệu hay ảnh hưởng tới các app đang chạy!${NC}"
    echo ""
    read -p "$(echo -e "Bạn có chắc chắn muốn dọn dẹp hệ thống không? (Y/n): ")" conf
    if [[ "$conf" =~ ^[Nn]$ ]]; then
        print_warning "Đã hủy thao tác dọn dẹp."
    else
        echo "Đang dọn dẹp rác hệ thống..."
        echo -e "${CYAN}------------------- CHI TIẾT -------------------${NC}"
        docker image prune -a -f
        docker builder prune -f
        docker network prune -f
        echo -e "${CYAN}------------------------------------------------${NC}"
        print_success "Đã dọn dẹp xong! Hãy xem chi tiết không gian (Total reclaimed space) vừa được giải phóng ở bảng trên."
    fi
}

show_system_info() {
    local os_name="Unknown"
    if [ -f /etc/os-release ]; then
        os_name=$(awk -F= '/^PRETTY_NAME/{print $2}' /etc/os-release | tr -d '"')
    fi
    local ram_usage=$(free -h | awk 'NR==2{print $3 "/" $2}')
    local disk_usage=$(df -h / | awk '$NF=="/"{print $5 " (" $3 "/" $2 ")"}')
    local cpu_model=$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^[ \t]*//')
    local cpu_cores=$(nproc 2>/dev/null || echo "1")
    local ip_addr=$(curl -s -m 2 ifconfig.me || echo "Unknown")
    local uptime_val=$(uptime -p | sed 's/up //')
    local docker_stat="${RED}Chưa cài đặt${NC}"
    if command -v docker &> /dev/null; then
        docker_stat="${GREEN}$(docker --version | awk '{print $3}' | tr -d ',')${NC}"
    fi
    
    echo -e " ${GREEN}🖥️ OS:${NC} $os_name | ${GREEN}⏱️ Uptime:${NC} $uptime_val"
    echo -e " ${GREEN}🧠 CPU:${NC} $cpu_cores Cores - $cpu_model"
    echo -e " ${GREEN}⚙️ RAM:${NC} $ram_usage | ${GREEN}💾 Disk:${NC} $disk_usage"
    echo -e " ${GREEN}🌐 IP:${NC} $ip_addr | ${GREEN}🐳 Docker:${NC} $docker_stat"
    echo -e "${BLUE}================================================${NC}"
}

disk_analysis() {
    print_section "📊 Phân tích Dung lượng Ổ cứng"
    echo -e "\n${YELLOW}── Tổng quan ổ cứng ──${NC}"
    df -h / 2>/dev/null | tail -1 | awk '{printf "   Tổng: %s | Đã dùng: %s (%s) | Còn trống: %s\n", $2, $3, $5, $4}'
    
    echo -e "\n${YELLOW}── Top 10 thư mục chiếm nhiều nhất trong /opt/homelab ──${NC}"
    if [ -d "$HOMELAB_DIR" ]; then
        du -sh "$HOMELAB_DIR"/*/ 2>/dev/null | sort -rh | head -10 | awk '{printf "   %-8s  %s\n", $1, $2}'
    else
        echo "   (Chưa có thư mục $HOMELAB_DIR)"
    fi

    echo -e "\n${YELLOW}── Top 10 thư mục chiếm nhiều nhất toàn hệ thống ──${NC}"
    du -sh /var/lib/docker /var/log /tmp /root /opt /home /usr /var/cache 2>/dev/null | sort -rh | head -10 | awk '{printf "   %-8s  %s\n", $1, $2}'

    echo -e "\n${YELLOW}── Top 10 Docker Image nặng nhất ──${NC}"
    docker images --format "{{.Size}}\t{{.Repository}}:{{.Tag}}" 2>/dev/null | sort -rh | head -10 | awk -F'\t' '{printf "   %-8s  %s\n", $1, $2}'

    echo -e "\n${YELLOW}── Dung lượng Docker Volume ──${NC}"
    local vol_data=$(docker system df -v 2>/dev/null | grep -A 1000 "^VOLUME NAME" | sed '/^Build cache/,$d' | tail -n +2 | grep -Ev "^\s*$" | awk '{print $3 " " $1}' | sort -rh | head -10 | awk '{printf "   %-8s  %s\n", $1, $2}' || true)
    if [ -n "$vol_data" ]; then
        echo "$vol_data"
    else
        echo "   (Chưa có Docker Volume nào hoặc không đọc được dữ liệu)"
    fi

    echo ""; read -p "Nhấn Enter để tiếp tục..."
}

show_main_menu() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${MAGENTA}    🏠 HOMELAB ULTIMATE - v1.0.0${NC}"
    echo -e "${BLUE}================================================${NC}"
    show_system_info
    echo -e "${YELLOW}[Hệ thống Lõi]${NC}"
    echo -e "${GREEN} 1.${NC} 🚀 Quản lý Docker (Cài đặt / Kiểm tra)"
    echo -e "${GREEN} 2.${NC} 🌐 Cấu hình Cloudflare Tunnel"
    echo -e "${YELLOW}[Quản lý Ứng dụng]${NC}"
    echo -e "${GREEN} 3.${NC} 🛒 App Store (Cài mới, Cấu hình, Xóa App)"
    echo -e "${GREEN} 4.${NC} 🔄 Bật / Tắt toàn bộ dịch vụ"
    echo -e "${YELLOW}[Bảo trì & Vận hành]${NC}"
    echo -e "${GREEN} 5.${NC} ⚙️ Trạng thái hệ thống"
    echo -e "${GREEN} 6.${NC} 💾 Quản lý Sao lưu & Phục hồi"
    echo -e "${GREEN} 7.${NC} 🧹 Dọn dẹp rác hệ thống (Clear Cache)"
    echo -e "${MAGENTA} 8.${NC} 📊 Phân tích dung lượng ổ cứng"
    echo -e "${RED} 0.${NC} ❌ Thoát"
    echo ""
    read -p "Nhập lựa chọn (0-8): " choice

    case $choice in
        1) clear; docker_menu ;;
        2) clear; cloudflare_menu ;;
        3) clear; app_store_menu ;;
        4) toggle_services; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
        5) status_check; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
        6) clear; backup_menu ;;
        7) clear; clear_system_cache; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
        8) clear; disk_analysis ;;
        0) print_success "Cảm ơn bạn đã sử dụng Homelab Manager!"; exit 0 ;;
        *) print_error "Lựa chọn không hợp lệ!"; echo ""; read -p "Nhấn Enter để tiếp tục..." ;;
    esac
}

while true; do
    clear
    show_main_menu
done
