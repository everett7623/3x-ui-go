#!/bin/bash

# 颜色设置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PLAIN='\033[0m'

# 检查是否为root用户
[[ $EUID -ne 0 ]] && echo -e "${RED}错误: ${PLAIN}必须使用root用户运行此脚本！\n" && exit 1

# 系统检测
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${RED}未检测到系统版本，请联系脚本作者！${PLAIN}\n" && exit 1
fi

echo -e "${GREEN}开始执行一键安装脚本...${PLAIN}"

# 1. 先安装依赖（优先执行以确保后续命令可用）
echo -e "${YELLOW}[步骤1] 更新系统并安装依赖${PLAIN}"
if [[ "${release}" == "centos" ]]; then
    yum update -y && yum install wget curl unzip sudo socat -y
else
    apt update && apt upgrade -y && apt install wget curl unzip sudo socat -y
fi

# 3. 设置系统时区为上海
echo -e "${YELLOW}[优化] 设置系统时区${PLAIN}"
timedatectl set-timezone Asia/Shanghai

# 4. 优化系统参数，应用BBR及网络调优
echo -e "${YELLOW}[步骤2] 优化系统参数，应用BBR加速${PLAIN}"
# 专为科学上网优化的内核参数
echo -e "${YELLOW}[优化] 应用专为科学上网优化的内核参数${PLAIN}"
cat > /etc/sysctl.conf << EOF
# 提高整体系统文件句柄数量上限
fs.file-max = 6815744

# 提高网络设备队列长度
net.core.netdev_max_backlog = 500000

# 提高套接字读/写缓冲区大小上限
net.core.optmem_max = 25165824
net.core.rmem_default = 31457280
net.core.rmem_max = 67108864
net.core.wmem_default = 31457280
net.core.wmem_max = 67108864

# 增加最大并发连接数
net.core.somaxconn = 65535

# 启用TCP SYN Cookie保护
net.ipv4.tcp_syncookies = 1

# 启用TIME-WAIT状态sockets重用，提高TCP连接关闭后端口复用速度
net.ipv4.tcp_tw_reuse = 1

# 减少TCP连接的FIN-WAIT-2状态时间，加快连接回收
net.ipv4.tcp_fin_timeout = 15

# 减少TCP keepalive探测时间，加快对断开连接的检测
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

# 提高SYN队列长度，应对高并发连接请求
net.ipv4.tcp_max_syn_backlog = 16384

# 提高TIME-WAIT上限，防止高并发时资源耗尽
net.ipv4.tcp_max_tw_buckets = 10000

# 提高TCP缓冲区范围
net.ipv4.tcp_mem = 65536 131072 262144
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384

# 开启TCP Fast Open，减少TCP握手延时
net.ipv4.tcp_fastopen = 3

# 开启IP转发，必须打开以允许流量转发
net.ipv4.ip_forward = 1
net.ipv4.conf.all.route_localnet = 1
net.ipv4.conf.all.forwarding = 1
net.ipv4.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.default.forwarding = 1

# 禁用一些可能影响VPN连接的功能
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_frto = 0
net.ipv4.tcp_mtu_probing = 0

# 启用有利于加速的TCP功能
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = 1
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_rfc1337 = 1

# 防止ICMP攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# 开启BBR拥塞控制算法，显著提升科学上网速度
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# 增加端口范围，提高并发连接能力
net.ipv4.ip_local_port_range = 1024 65535
EOF
sysctl -p && sysctl --system

# 5. 设置DNS - 修复防止resolv.conf被修改的问题
echo -e "${YELLOW}[优化] 设置防DNS污染的DNS服务器${PLAIN}"

# 检查系统是否使用systemd-resolved
if systemctl status systemd-resolved &>/dev/null; then
    echo -e "${YELLOW}检测到systemd-resolved服务，正在配置...${PLAIN}"
    
    # 创建自定义DNS配置
    cat > /etc/systemd/resolved.conf << EOF
[Resolve]
DNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 208.67.222.222 208.67.220.220 9.9.9.9
FallbackDNS=8.8.8.8 8.8.4.4
DNSSEC=yes
DNSOverTLS=yes
Cache=yes
EOF
    
    # 重启systemd-resolved服务
    systemctl restart systemd-resolved
    
    echo -e "${GREEN}已通过systemd-resolved配置DNS服务器${PLAIN}"
else
    # 传统方式修改resolv.conf
    echo -e "${YELLOW}使用传统方式配置DNS...${PLAIN}"
    
    # 备份原始resolv.conf
    cp /etc/resolv.conf /etc/resolv.conf.bak
    
    # 写入新的DNS配置
    cat > /etc/resolv.conf << EOF
# Cloudflare DNS
nameserver 1.1.1.1
nameserver 1.0.0.1
# Google DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
# OpenDNS
nameserver 208.67.222.222
nameserver 208.67.220.220
# Quad9 DNS
nameserver 9.9.9.9
options edns0 trust-ad
EOF
    
    # 尝试设置resolv.conf为不可修改，但增加错误处理
    echo -e "${YELLOW}尝试保护resolv.conf不被修改...${PLAIN}"
    if ! chattr +i /etc/resolv.conf 2>/dev/null; then
        echo -e "${YELLOW}警告: 无法设置resolv.conf为不可修改，这在某些系统上是正常的${PLAIN}"
        echo -e "${YELLOW}将尝试替代方案来保护DNS设置...${PLAIN}"
        
        # NetworkManager配置 (适用于使用NetworkManager的系统)
        if command -v nmcli &>/dev/null; then
            echo -e "${YELLOW}检测到NetworkManager，配置其使用自定义DNS...${PLAIN}"
            
            mkdir -p /etc/NetworkManager/conf.d/
            cat > /etc/NetworkManager/conf.d/dns-servers.conf << EOF
[main]
dns=none
EOF
            
            systemctl restart NetworkManager 2>/dev/null || true
            echo -e "${GREEN}已配置NetworkManager不覆盖DNS设置${PLAIN}"
        fi
        
        # dhclient配置 (适用于使用dhclient的系统)
        if [ -d /etc/dhcp/ ]; then
            echo -e "${YELLOW}配置dhclient不覆盖DNS设置...${PLAIN}"
            
            cat > /etc/dhcp/dhclient.conf << EOF
supersede domain-name-servers 1.1.1.1, 8.8.8.8, 208.67.222.222, 9.9.9.9;
EOF
            echo -e "${GREEN}已配置dhclient不覆盖DNS设置${PLAIN}"
        fi
    else
        echo -e "${GREEN}已成功保护resolv.conf不被修改${PLAIN}"
    fi
fi

# 6. 调整系统打开文件数限制（对高并发连接至关重要）
echo -e "${YELLOW}[优化] 增加系统文件打开数限制${PLAIN}"
cat > /etc/security/limits.conf << EOF
* soft nofile 1000000
* hard nofile 1000000
* soft nproc 1000000
* hard nproc 1000000
root soft nofile 1000000
root hard nofile 1000000
root soft nproc 1000000
root hard nproc 1000000
EOF

# 确保系统加载这些限制
if [ -d /etc/security/limits.d ]; then
    echo -e "${YELLOW}确保限制在所有配置文件中一致${PLAIN}"
    echo "* soft nofile 1000000" > /etc/security/limits.d/99-ulimit.conf
    echo "* hard nofile 1000000" >> /etc/security/limits.d/99-ulimit.conf
    echo "* soft nproc 1000000" >> /etc/security/limits.d/99-ulimit.conf
    echo "* hard nproc 1000000" >> /etc/security/limits.d/99-ulimit.conf
fi

# 确保PAM加载limits模块
if [ -f /etc/pam.d/common-session ]; then
    grep -q "session required pam_limits.so" /etc/pam.d/common-session || echo "session required pam_limits.so" >> /etc/pam.d/common-session
fi

# 检查是否安装expect
echo -e "${YELLOW}检查expect是否安装...${PLAIN}"
if ! command -v expect &> /dev/null; then
    echo -e "${YELLOW}安装expect以实现自动交互${PLAIN}"
    if [[ "${release}" == "centos" ]]; then
        yum install -y expect
    else
        apt install -y expect
    fi
fi

# 7. 安装X-UI，使用expect自动确认并设置面板端口
echo -e "${YELLOW}[步骤3] 安装3x-ui面板${PLAIN}"
echo -e "${GREEN}将自动设置面板端口为18888并捕获随机生成的登录凭据${PLAIN}"

# 使用expect进行自动交互安装，设置端口为18888
echo -e "${YELLOW}正在安装3x-ui，将自动设置端口并捕获登录凭据...${PLAIN}"

TMP_INFO_FILE=$(mktemp)

# 使用expect进行自动交互并保存输出
expect -c "
set timeout 300
spawn bash -c {curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh | bash}
expect {
    \"*customize the Panel Port*\" {
        send \"y\r\"
        expect \"*set up the panel port:*\"
        send \"18888\r\"
        exp_continue
    }
    \"*Access URL:*\" {
        # 捕获包含登录信息的行
        log_file -noappend $TMP_INFO_FILE
        expect \"*x-ui uninstall*\"
        log_file
        exp_continue
    }
    eof
}
"

# 提取关键登录信息并保存到变量
LOGIN_INFO=$(grep -A5 -B3 "Access URL:" $TMP_INFO_FILE | grep -E "Username:|Password:|Port:|WebBasePath:|Access URL:")

# 提取URL以便后续显示
ACCESS_URL=$(echo "$LOGIN_INFO" | grep "Access URL:" | awk '{print $3}')

# 8. 安装并配置Fail2ban防止暴力破解
echo -e "${YELLOW}[安全优化] 安装Fail2ban防止暴力破解${PLAIN}"
if [[ "${release}" == "centos" ]]; then
    yum install -y fail2ban
else
    apt install -y fail2ban
fi

# 配置Fail2ban保护SSH和面板
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5

[x-ui-panel]
enabled = true
port = 18888
filter = x-ui-panel
logpath = /var/log/auth.log
maxretry = 5
EOF

# 创建面板的过滤器
cat > /etc/fail2ban/filter.d/x-ui-panel.conf << EOF
[Definition]
failregex = .*Failed login from <HOST>.*
ignoreregex =
EOF

# 启动Fail2ban
systemctl enable fail2ban
systemctl restart fail2ban

echo -e "${GREEN}已配置Fail2ban防止SSH和面板被暴力破解${PLAIN}"

# 9. 设置开机自启
echo -e "${YELLOW}[优化] 设置3x-ui开机自启${PLAIN}"
systemctl enable x-ui

# 10. 显示安装结果和使用信息
echo -e "\n${GREEN}==================================${PLAIN}"
echo -e "${RED}3x-ui 安装完成！登录信息:${PLAIN}"
echo -e "$LOGIN_INFO"
echo -e "${GREEN}==================================${PLAIN}"
echo -e "${YELLOW}如需管理面板，可使用以下命令:${PLAIN}"
echo -e "${GREEN}x-ui start${PLAIN}    - 启动x-ui面板"
echo -e "${GREEN}x-ui stop${PLAIN}     - 停止x-ui面板"
echo -e "${GREEN}x-ui restart${PLAIN}  - 重启x-ui面板"
echo -e "${GREEN}x-ui status${PLAIN}   - 查看x-ui状态"
echo -e "${GREEN}x-ui settings${PLAIN} - 查看当前设置"
echo -e "${GREEN}x-ui enable${PLAIN}   - 设置x-ui开机自启"
echo -e "${GREEN}x-ui disable${PLAIN}  - 取消x-ui开机自启"
echo -e "${GREEN}x-ui log${PLAIN}      - 查看x-ui日志"
echo -e "${GREEN}x-ui banlog${PLAIN}   - 查看Fail2ban封禁日志"
echo -e "${GREEN}x-ui update${PLAIN}   - 更新x-ui面板"
echo -e "${GREEN}x-ui legacy${PLAIN}   - 旧版本"
echo -e "${GREEN}x-ui install${PLAIN}  - 重新安装x-ui面板"
echo -e "${GREEN}x-ui uninstall${PLAIN} - 卸载x-ui面板"
echo -e "${GREEN}==================================${PLAIN}"

# 清理临时文件
rm -f $TMP_INFO_FILE

echo -e "${GREEN}优化脚本执行完毕！${PLAIN}"
