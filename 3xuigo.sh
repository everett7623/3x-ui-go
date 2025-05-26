#!/bin/bash

# VPS优化及3x-ui一键安装脚本 - 优化版
# 版本: 2.0
# 作者: 优化版本

set -euo pipefail  # 严格模式：遇到错误立即退出，未定义变量报错，管道命令失败时退出

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# 全局变量
OS=""
LOG_FILE="/tmp/vps_setup_$(date +%Y%m%d_%H%M%S).log"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 打印带颜色的信息
print_info() {
    local msg="[INFO] $1"
    echo -e "${BLUE}${msg}${NC}"
    log "$msg"
}

print_success() {
    local msg="[SUCCESS] $1"
    echo -e "${GREEN}${msg}${NC}"
    log "$msg"
}

print_error() {
    local msg="[ERROR] $1"
    echo -e "${RED}${msg}${NC}" >&2
    log "$msg"
}

print_warning() {
    local msg="[WARNING] $1"
    echo -e "${YELLOW}${msg}${NC}"
    log "$msg"
}

# 错误处理函数
error_exit() {
    print_error "$1"
    print_error "详细日志请查看: $LOG_FILE"
    exit 1
}

# 检测系统
check_system() {
    print_info "正在检测系统..."
    
    # 检测是否为root用户
    if [[ $EUID -ne 0 ]]; then
        error_exit "此脚本必须以root用户运行，请使用 sudo 或切换到root用户"
    fi
    
    # 检测系统类型
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            "debian")
                OS="debian"
                print_success "检测到Debian系统 ($VERSION)"
                ;;
            "ubuntu")
                OS="ubuntu"
                print_success "检测到Ubuntu系统 ($VERSION)"
                ;;
            "centos"|"rhel"|"fedora")
                error_exit "此脚本仅支持Debian/Ubuntu系统，检测到: $PRETTY_NAME"
                ;;
            *)
                error_exit "不支持的系统类型: $PRETTY_NAME"
                ;;
        esac
    else
        error_exit "无法检测系统类型"
    fi
    
    # 检查网络连接
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        error_exit "网络连接异常，无法访问外网"
    fi
    
    print_success "系统检测完成"
}

# 安装依赖
install_dependencies() {
    print_info "开始安装系统依赖..."
    
    # 备份原始sources.list
    if [[ ! -f /etc/apt/sources.list.bak ]]; then
        cp /etc/apt/sources.list /etc/apt/sources.list.bak
        print_info "已备份原始软件源配置"
    fi
    
    # 更新系统
    print_info "更新软件包列表..."
    apt update || error_exit "软件包列表更新失败"
    
    print_info "升级系统软件包..."
    DEBIAN_FRONTEND=noninteractive apt upgrade -y || error_exit "系统升级失败"
    
    # 安装必要依赖
    local packages=(
        "sudo"
        "wget"
        "curl"
        "unzip"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "apt-transport-https"
        "software-properties-common"
    )
    
    print_info "安装必要依赖包..."
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            print_info "安装 $package..."
            DEBIAN_FRONTEND=noninteractive apt install -y "$package" || error_exit "$package 安装失败"
        else
            print_info "$package 已安装"
        fi
    done
    
    print_success "系统依赖安装完成"
}

# BBR检测和优化
optimize_bbr() {
    print_info "开始BBR优化..."
    
    # 检查内核版本
    local kernel_version
    kernel_version=$(uname -r | cut -d. -f1-2)
    local major_version
    major_version=$(echo "$kernel_version" | cut -d. -f1)
    local minor_version
    minor_version=$(echo "$kernel_version" | cut -d. -f2)
    
    if [[ $major_version -lt 4 ]] || [[ $major_version -eq 4 && $minor_version -lt 9 ]]; then
        print_warning "内核版本过低 ($kernel_version)，BBR需要4.9+版本"
        return 1
    fi
    
    # 检查当前拥塞控制算法
    local current_cc
    current_cc=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "unknown")
    if [[ "$current_cc" == "bbr" ]]; then
        print_warning "BBR已经启用"
        return 0
    fi
    
    # 加载BBR模块
    if ! lsmod | grep -q tcp_bbr; then
        modprobe tcp_bbr || print_warning "无法加载BBR模块"
    fi
    
    # 备份原始配置
    if [[ -f /etc/sysctl.conf && ! -f /etc/sysctl.conf.bak ]]; then
        cp /etc/sysctl.conf /etc/sysctl.conf.bak
        print_info "已备份原始sysctl配置"
    fi
    
    # 写入优化配置
    cat > /etc/sysctl.d/99-bbr-optimization.conf << 'EOF'
# BBR和网络优化配置
# 文件描述符限制
fs.file-max = 1048576

# TCP优化
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_frto = 0
net.ipv4.tcp_mtu_probing = 0
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = 1
net.ipv4.tcp_moderate_rcvbuf = 1

# 缓冲区优化
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 16384 33554432
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192

# IP转发
net.ipv4.ip_forward = 1
net.ipv4.conf.all.route_localnet = 1
net.ipv4.conf.all.forwarding = 1
net.ipv4.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.default.forwarding = 1

# BBR配置
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# 其他优化
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 10
EOF

    # 应用配置
    print_info "应用BBR配置..."
    sysctl -p /etc/sysctl.d/99-bbr-optimization.conf || error_exit "BBR配置应用失败"
    
    # 验证BBR是否启用
    sleep 1
    current_cc=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
    if [[ "$current_cc" == "bbr" ]]; then
        print_success "BBR优化完成并已启用"
    else
        print_warning "BBR配置已写入，重启后生效"
    fi
}

# 内核优化
optimize_kernel() {
    print_info "开始内核参数优化..."
    
    # 备份limits.conf
    if [[ ! -f /etc/security/limits.conf.bak ]]; then
        cp /etc/security/limits.conf /etc/security/limits.conf.bak
        print_info "已备份原始limits配置"
    fi
    
    # 设置文件描述符限制
    cat >> /etc/security/limits.conf << 'EOF'

# VPS优化 - 文件描述符限制
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 65535
* hard nproc 65535
root soft nofile 1048576
root hard nofile 1048576
EOF

    # 优化systemd服务限制
    if [[ -d /etc/systemd ]]; then
        mkdir -p /etc/systemd/system.conf.d
        cat > /etc/systemd/system.conf.d/limits.conf << 'EOF'
[Manager]
DefaultLimitNOFILE=1048576
DefaultLimitNPROC=65535
EOF
        systemctl daemon-reload
    fi

    print_success "内核参数优化完成"
}

# 设置时区和时间同步
set_timezone() {
    print_info "设置系统时区和时间同步..."
    
    # 设置为上海时区
    if timedatectl set-timezone Asia/Shanghai; then
        print_success "时区设置为Asia/Shanghai"
    else
        print_warning "时区设置失败"
    fi
    
    # 安装和配置时间同步
    if command -v chrony >/dev/null 2>&1; then
        print_info "chrony已安装"
    else
        print_info "安装chrony时间同步服务..."
        DEBIAN_FRONTEND=noninteractive apt install -y chrony || {
            print_warning "chrony安装失败，尝试安装ntp..."
            DEBIAN_FRONTEND=noninteractive apt install -y ntp || print_warning "时间同步服务安装失败"
        }
    fi
    
    # 启用时间同步
    if command -v chrony >/dev/null 2>&1; then
        systemctl enable --now chrony || print_warning "chrony服务启动失败"
    elif command -v ntp >/dev/null 2>&1; then
        systemctl enable --now ntp || print_warning "ntp服务启动失败"
    fi
    
    # 显示当前时间信息
    local current_time
    current_time=$(timedatectl 2>/dev/null | grep "Local time" | awk -F': ' '{print $2}' || date)
    print_success "时间设置完成: $current_time"
}

# 安装3x-ui面板
install_3xui() {
    print_info "开始安装3x-ui面板..."
    
    # 检查是否已安装
    if systemctl is-active --quiet x-ui 2>/dev/null; then
        print_warning "检测到3x-ui已在运行"
        read -p "是否重新安装？[y/N]: " reinstall_choice
        if [[ ! "$reinstall_choice" =~ ^[Yy]$ ]]; then
            print_info "跳过3x-ui安装"
            return 0
        fi
    fi
    
    # 下载并执行安装脚本
    print_info "下载3x-ui安装脚本..."
    local install_script="/tmp/3xui_install.sh"
    
    if wget -O "$install_script" "https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh"; then
        chmod +x "$install_script"
        print_info "开始执行3x-ui安装..."
        bash "$install_script" || error_exit "3x-ui安装失败"
        rm -f "$install_script"
        print_success "3x-ui面板安装完成"
    else
        error_exit "3x-ui安装脚本下载失败"
    fi
}

# 防火墙配置
configure_firewall() {
    print_info "配置防火墙..."
    
    # 安装ufw如果不存在
    if ! command -v ufw >/dev/null 2>&1; then
        print_info "安装ufw防火墙..."
        DEBIAN_FRONTEND=noninteractive apt install -y ufw || print_warning "ufw安装失败"
    fi
    
    if command -v ufw >/dev/null 2>&1; then
        # 重置防火墙规则
        ufw --force reset >/dev/null 2>&1
        
        # 设置默认策略
        ufw default deny incoming >/dev/null 2>&1
        ufw default allow outgoing >/dev/null 2>&1
        
        # 允许SSH
        ufw allow ssh >/dev/null 2>&1
        
        # 允许常用端口
        local common_ports=(80 443 2053 2083 2087 2096 8080 8443)
        for port in "${common_ports[@]}"; do
            ufw allow "$port" >/dev/null 2>&1
        done
        
        # 启用防火墙
        ufw --force enable >/dev/null 2>&1
        print_success "防火墙配置完成"
    else
        print_warning "防火墙配置跳过"
    fi
}

# 清理系统
cleanup_system() {
    print_info "清理系统..."
    
    # 清理apt缓存
    apt autoremove -y >/dev/null 2>&1
    apt autoclean >/dev/null 2>&1
    
    # 清理日志文件
    if [[ -d /var/log ]]; then
        find /var/log -type f -name "*.log" -size +100M -exec truncate -s 0 {} \; 2>/dev/null || true
    fi
    
    # 清理临时文件
    rm -rf /tmp/* 2>/dev/null || true
    
    print_success "系统清理完成"
}

# 显示系统信息
show_system_info() {
    echo ""
    echo "========================================"
    echo "         系统优化完成信息"
    echo "========================================"
    
    # 基本系统信息
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "系统版本: $PRETTY_NAME"
    fi
    
    echo "内核版本: $(uname -r)"
    echo "当前时区: $(timedatectl show --property=Timezone --value 2>/dev/null || echo "未知")"
    echo "系统时间: $(date)"
    echo ""
    
    # 网络优化信息
    echo "网络优化信息："
    echo "----------------------------------------"
    local current_cc
    current_cc=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "未知")
    echo "拥塞控制算法: $current_cc"
    
    local current_qdisc
    current_qdisc=$(sysctl -n net.core.default_qdisc 2>/dev/null || echo "未知")
    echo "队列调度算法: $current_qdisc"
    echo ""
    
    # 服务状态
    echo "服务状态："
    echo "----------------------------------------"
    if systemctl is-active --quiet x-ui 2>/dev/null; then
        echo "3x-ui面板: 运行中"
    else
        echo "3x-ui面板: 未运行"
    fi
    
    if systemctl is-active --quiet ufw 2>/dev/null; then
        echo "防火墙: 已启用"
    else
        echo "防火墙: 未启用"
    fi
    
    echo "========================================"
    echo "日志文件: $LOG_FILE"
    echo "========================================"
    echo ""
}

# 交互式菜单
interactive_menu() {
    while true; do
        echo ""
        echo "========================================"
        echo "     VPS优化脚本 - 交互式菜单"
        echo "========================================"
        echo "1. 完整安装 (推荐)"
        echo "2. 仅系统优化"
        echo "3. 仅安装3x-ui"
        echo "4. 系统信息"
        echo "5. 退出"
        echo "========================================"
        
        read -p "请选择操作 [1-5]: " choice
        
        case $choice in
            1)
                return 0  # 执行完整安装
                ;;
            2)
                install_dependencies
                optimize_bbr
                optimize_kernel
                set_timezone
                configure_firewall
                cleanup_system
                show_system_info
                ;;
            3)
                install_3xui
                show_system_info
                ;;
            4)
                show_system_info
                ;;
            5)
                print_info "退出脚本"
                exit 0
                ;;
            *)
                print_error "无效选择，请重新输入"
                ;;
        esac
    done
}

# 主函数
main() {
    # 初始化
    clear
    echo "========================================"
    echo "    VPS优化及3x-ui一键安装脚本 v2.0"
    echo "    支持Ubuntu/Debian系统"
    echo "========================================"
    echo ""
    
    print_info "脚本开始执行，日志文件: $LOG_FILE"
    
    # 检查参数
    if [[ $# -gt 0 ]]; then
        case "$1" in
            "--auto"|"-a")
                print_info "自动模式，执行完整安装"
                ;;
            "--menu"|"-m")
                check_system
                interactive_menu
                ;;
            "--help"|"-h")
                echo "使用方法:"
                echo "  $0           # 交互式安装"
                echo "  $0 --auto    # 自动完整安装"
                echo "  $0 --menu    # 显示菜单"
                echo "  $0 --help    # 显示帮助"
                exit 0
                ;;
            *)
                error_exit "未知参数: $1，使用 --help 查看帮助"
                ;;
        esac
    else
        # 默认显示菜单
        check_system
        interactive_menu
    fi
    
    # 执行完整安装流程
    print_info "开始完整安装流程..."
    
    check_system
    install_dependencies
    optimize_bbr
    optimize_kernel
    set_timezone
    configure_firewall
    install_3xui
    cleanup_system
    
    # 显示系统信息
    show_system_info
    
    # 询问是否清理脚本
    echo ""
    read -p "是否删除安装脚本？[y/N]: " clean_choice
    if [[ "$clean_choice" =~ ^[Yy]$ ]]; then
        print_info "删除安装脚本..."
        rm -f "$0" 2>/dev/null || print_warning "脚本删除失败"
    fi
    
    print_success "所有操作完成！"
    print_warning "建议重启系统以确保所有优化生效"
    
    # 询问是否重启
    echo ""
    read -p "是否立即重启系统？[y/N]: " reboot_choice
    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        print_info "系统将在5秒后重启..."
        sleep 5
        reboot
    else
        print_info "请手动重启系统以使所有优化生效"
    fi
}

# 信号处理
cleanup_on_exit() {
    print_info "脚本被中断，正在清理..."
    # 这里可以添加清理代码
    exit 1
}

# 设置信号处理
trap cleanup_on_exit INT TERM

# 执行主函数
main "$@"
