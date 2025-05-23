#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检测系统
check_system() {
    print_info "正在检测系统..."
    
    if [[ -f /etc/redhat-release ]]; then
        OS="centos"
        print_error "此脚本仅支持Debian/Ubuntu系统"
        exit 1
    elif cat /etc/issue | grep -q -E -i "debian"; then
        OS="debian"
        print_success "检测到Debian系统"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        OS="ubuntu"
        print_success "检测到Ubuntu系统"
    else
        print_error "不支持的系统类型"
        exit 1
    fi
    
    # 检测是否为root用户
    if [[ $EUID -ne 0 ]]; then
        print_error "此脚本必须以root用户运行"
        exit 1
    fi
}

# 安装依赖
install_dependencies() {
    print_info "开始安装系统依赖..."
    
    # 更新系统并安装必要的依赖
    apt update && apt upgrade -y
    if [[ $? -ne 0 ]]; then
        print_error "系统更新失败"
        exit 1
    fi
    
    apt install sudo wget unzip curl -y
    if [[ $? -ne 0 ]]; then
        print_error "依赖安装失败"
        exit 1
    fi
    
    print_success "系统依赖安装完成"
}

# BBR检测和优化
optimize_bbr() {
    print_info "开始BBR优化..."
    
    # 检查当前是否已启用BBR
    current_cc=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}')
    if [[ "$current_cc" == "bbr" ]]; then
        print_warning "BBR已经启用"
    fi
    
    # 写入优化配置
    cat > /etc/sysctl.conf << EOF
fs.file-max = 6815744
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_moderate_rcvbuf=1
net.core.rmem_max=33554432
net.core.wmem_max=33554432
net.ipv4.tcp_rmem=4096 87380 33554432
net.ipv4.tcp_wmem=4096 16384 33554432
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.ipv4.ip_forward=1
net.ipv4.conf.all.route_localnet=1
net.ipv4.conf.all.forwarding=1
net.ipv4.conf.default.forwarding=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1
EOF

    # 应用配置
    sysctl -p && sysctl --system
    
    # 验证BBR是否启用
    current_cc=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}')
    if [[ "$current_cc" == "bbr" ]]; then
        print_success "BBR优化完成并已启用"
    else
        print_warning "BBR可能需要重启后才能生效"
    fi
}

# 内核优化
optimize_kernel() {
    print_info "开始内核参数优化..."
    
    # 检查并加载必要的内核模块
    modprobe tcp_bbr 2>/dev/null
    
    # 设置文件描述符限制
    cat >> /etc/security/limits.conf << EOF
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOF

    print_success "内核参数优化完成"
}

# 设置时区
set_timezone() {
    print_info "设置系统时区..."
    
    # 设置为上海时区
    timedatectl set-timezone Asia/Shanghai
    
    # 同步系统时间
    apt install -y chrony 2>/dev/null || apt install -y ntp 2>/dev/null
    
    print_success "时区设置完成: $(timedatectl | grep "Time zone" | awk '{print $3}')"
}

# 优化DNS
optimize_dns() {
    print_info "优化DNS设置..."
    
    # 备份原DNS配置
    cp /etc/resolv.conf /etc/resolv.conf.bak
    
    # 设置DNS服务器
    cat > /etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF

    # 防止DNS被覆盖
    chattr +i /etc/resolv.conf
    
    print_success "DNS优化完成"
}

# 安装3x-ui面板
install_3xui() {
    print_info "开始安装3x-ui面板..."
    
    # 下载并执行安装脚本
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    
    if [[ $? -eq 0 ]]; then
        print_success "3x-ui面板安装完成"
        
        # 获取面板信息
        print_info "3x-ui面板信息："
        print_info "默认端口: 54321"
        print_info "默认用户名: admin"
        print_info "默认密码: admin"
        print_warning "请立即登录面板修改默认用户名和密码！"
    else
        print_error "3x-ui面板安装失败"
        exit 1
    fi
}

# 清理脚本
cleanup() {
    print_info "清理临时文件..."
    
    # 清理apt缓存
    apt autoremove -y
    apt autoclean
    
    # 删除脚本自身
    rm -f $0
    
    print_success "清理完成"
}

# 显示系统信息
show_system_info() {
    echo ""
    echo "========================================"
    echo "系统优化信息："
    echo "========================================"
    echo "系统版本: $(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f 2)"
    echo "内核版本: $(uname -r)"
    echo "BBR状态: $(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')"
    echo "时区: $(timedatectl | grep "Time zone" | awk '{print $3}')"
    echo "========================================"
    echo ""
}

# 主函数
main() {
    clear
    echo "========================================"
    echo "    VPS优化及3x-ui一键安装脚本"
    echo "========================================"
    echo ""
    
    # 执行各步骤
    check_system
    install_dependencies
    optimize_bbr
    optimize_kernel
    set_timezone
    optimize_dns
    install_3xui
    
    # 显示系统信息
    show_system_info
    
    # 询问是否清理
    read -p "是否清理临时文件并删除本脚本？[y/N]: " clean_choice
    if [[ "$clean_choice" =~ ^[Yy]$ ]]; then
        cleanup
    fi
    
    print_success "所有操作完成！"
    print_warning "建议重启系统以确保所有优化生效"
    
    read -p "是否立即重启系统？[y/N]: " reboot_choice
    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        print_info "系统将在5秒后重启..."
        sleep 5
        reboot
    fi
}

# 捕获错误
trap 'print_error "脚本执行出错，退出..."; exit 1' ERR

# 执行主函数
main
