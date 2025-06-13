#!/bin/bash

# 脚本名称
SCRIPT_NAME="3x-ui-go"
SCRIPT_PATH="/opt/${SCRIPT_NAME}"
INSTALL_SCRIPT="bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 欢迎信息
echo -e "${GREEN}
#####################################################################
#                                                                   #
#          欢迎使用一键3X-UI安装与优化脚本                          #
#                                                                   #
#          项目地址：https://github.com/everett7623/3x-ui-go        #
#                                                                   #
#          特别鸣谢：mhsanaei/3x-ui                                 #
#                                                                   #
#####################################################################
${NC}"

# 检查root权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}错误: 此脚本需要root权限运行。${NC}"
        exit 1
    fi
}

# 检查系统
check_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
    else
        echo -e "${RED}错误: 无法检测操作系统。${NC}"
        exit 1
    fi

    if [[ "$OS" != "debian" && "$OS" != "ubuntu" && "$OS" != "centos" && "$OS" != "fedora" && "$OS" != "rhel" ]]; then
        echo -e "${RED}警告: 此脚本可能不支持您的操作系统 ($OS)。建议在 Debian/Ubuntu/CentOS 上运行。${NC}"
        read -p "是否继续？(y/N): " choice
        if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
            exit 1
        fi
    fi
}

# 安装依赖
install_dependencies() {
    echo -e "${GREEN}--- 1. 安装依赖 ---${NC}"
    if command -v apt &> /dev/null; then
        apt update && apt upgrade -y
        apt install sudo wget unzip curl -y
    elif command -v yum &> /dev/null; then
        yum update -y
        yum install sudo wget unzip curl -y
    elif command -v dnf &> /dev/null; then
        dnf update -y
        dnf install sudo wget unzip curl -y
    else
        echo -e "${RED}错误: 无法识别包管理器。请手动安装 sudo, wget, unzip, curl。${NC}"
        exit 1
    fi
    echo -e "${GREEN}依赖安装完成。${NC}"
}

# BBR加速
install_bbr() {
    echo -e "${GREEN}--- 2. 安装 BBR 加速 ---${NC}"
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
    sysctl -p
    sysctl --system
    echo -e "${GREEN}BBR 加速配置完成。${NC}"
    echo -e "${YELLOW}请重启VPS以确保BBR完全生效：reboot${NC}"
}

# 安装原版3x-ui
install_3x_ui() {
    echo -e "${GREEN}--- 3. 安装原版3x-ui ---${NC}"
    eval "$INSTALL_SCRIPT"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}原版3x-ui安装成功！${NC}"
    else
        echo -e "${RED}原版3x-ui安装失败，请检查网络或日志。${NC}"
    fi
}

# 清理一键3X-UI脚本相关文件
clean_script_files() {
    echo -e "${YELLOW}--- 清理一键3X-UI脚本相关文件 ---${NC}"
    if [ -f "$(basename "$0")" ]; then
        rm -f "$(basename "$0")"
        echo -e "${GREEN}脚本文件 $(basename "$0") 已删除。${NC}"
    else
        echo -e "${YELLOW}脚本文件 $(basename "$0") 不存在，跳过清理。${NC}"
    fi
}

# 卸载原版3x-ui
uninstall_3x_ui() {
    echo -e "${RED}--- 卸载原版3x-ui ---${NC}"
    echo -e "${YELLOW}警告: 卸载将删除所有3x-ui数据！${NC}"
    read -p "您确定要卸载3x-ui吗？(y/N): " confirm_uninstall
    if [[ "$confirm_uninstall" == "y" || "$confirm_uninstall" == "Y" ]]; then
        if command -v 3x-ui &> /dev/null; then
            3x-ui uninstall
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}原版3x-ui卸载成功！${NC}"
            else
                echo -e "${RED}原版3x-ui卸载失败。${NC}"
            fi
        else
            echo -e "${YELLOW}未检测到3x-ui安装，跳过卸载。${NC}"
        fi
    else
        echo -e "${YELLOW}取消卸载3x-ui。${NC}"
    fi
}

# 主菜单
show_menu() {
    echo -e "${YELLOW}
--- 菜单 ---
1. 一键3X-UI (安装依赖, BBR优化, 安装原版3x-ui)
2. 清理一键3X-UI脚本文件
3. 卸载原版3x-ui并清理脚本文件
4. 退出
${NC}"
    read -p "请选择一个选项 (1-4): " menu_choice
    case $menu_choice in
        1)
            check_root
            check_os
            install_dependencies
            install_bbr
            install_3x_ui
            echo -e "${GREEN}全部操作完成！请重启VPS以确保BBR完全生效。${NC}"
            ;;
        2)
            check_root
            clean_script_files
            echo -e "${GREEN}清理完成。${NC}"
            ;;
        3)
            check_root
            uninstall_3x_ui
            clean_script_files
            echo -e "${GREEN}清理并卸载完成。${NC}"
            ;;
        4)
            echo -e "${GREEN}退出脚本。${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选项，请重新选择。${NC}"
            show_menu
            ;;
    esac
}

# 运行菜单
show_menu
