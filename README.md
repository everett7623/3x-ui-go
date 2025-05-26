# 3x-ui-go

<div align="center">
  <img src="https://img.shields.io/github/stars/everett7623/3x-ui-go?style=for-the-badge" alt="GitHub stars">
  <img src="https://img.shields.io/github/forks/everett7623/3x-ui-go?style=for-the-badge" alt="GitHub forks">
  <img src="https://img.shields.io/github/license/everett7623/3x-ui-go?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Go-1.21+-00ADD8?style=for-the-badge&logo=go" alt="Go Version">
</div>

<div align="center">
  <h3>🚀 基于 Go 语言的现代化 Xray 管理面板</h3>
  <p>支持多种协议、多用户管理、流量控制和 IP 限制的高性能代理服务管理系统</p>
</div>

---

## ✨ 特性

### 🔐 协议支持
- **VMess** - V2Ray 原生协议，支持动态端口
- **VLESS** - 轻量级协议，性能更优
- **Trojan** - 伪装 HTTPS 流量
- **ShadowSocks** - 经典代理协议
- **WireGuard** - 现代 VPN 协议

### 🛡️ 安全特性
- **Reality** - 最新抗审查技术
- **TLS/XTLS** - 端到端加密
- **双因素认证** - 增强安全性
- **IP 白名单** - 访问控制
- **SSL 证书** - 自动申请与续期

### 📊 管理功能
- **多用户管理** - 支持批量操作
- **流量统计** - 实时监控与历史记录
- **到期时间** - 灵活的用户期限设置
- **流量限制** - 精确的流量控制
- **IP 限制** - 单用户连接数控制

### 🌐 界面特性
- **现代化 UI** - 响应式设计
- **多语言支持** - 中文、英文、波斯语等
- **深色模式** - 护眼界面
- **移动端适配** - 完美支持移动设备

## 🚀 快速开始

### 系统要求

- **操作系统**: Ubuntu 18+ / Debian 9+ / CentOS 7+
- **架构**: x86_64 / aarch64
- **内存**: 最小 256MB，推荐 512MB+
- **存储**: 最小 10GB 可用空间

### 一键安装

```bash
# 基础安装
wget -O 3xuigo.sh https://raw.githubusercontent.com/everett7623/3x-ui-go/main/3xuigo.sh && chmod +x 3xuigo.sh && ./3xuigo.sh
```


### 手动编译

```bash
# 克隆仓库
git clone https://github.com/everett7623/3x-ui-go.git
cd 3x-ui-go

# 安装依赖
go mod tidy

# 编译
go build -ldflags="-s -w" -o 3x-ui-go main.go

# 运行
./3x-ui-go
```

## 🛠️ 配置

### 首次配置

1. 安装完成后访问面板：`http://your-server-ip:2053`
2. 默认登录信息：
   - 用户名：`admin`
   - 密码：`admin`
3. **请立即修改默认密码**

### SSL 证书配置

```bash
# 使用管理脚本
./3x-ui-go cert

# 或使用 Let's Encrypt
./3x-ui-go cert --provider letsencrypt --domain your-domain.com --email your-email@example.com
```

### 防火墙配置

```bash
# Ubuntu/Debian
ufw allow 2053
ufw allow 443
ufw allow 80

# CentOS/RHEL
firewall-cmd --permanent --add-port=2053/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
```

## 📋 管理命令

```bash
# 查看状态
./3x-ui-go status

# 启动服务
./3x-ui-go start

# 停止服务
./3x-ui-go stop

# 重启服务
./3x-ui-go restart

# 查看日志
./3x-ui-go logs

# 备份数据
./3x-ui-go backup

# 恢复数据
./3x-ui-go restore backup.tar.gz

# 更新面板
./3x-ui-go update

# 卸载
./3x-ui-go uninstall
```

## 🔧 高级配置

### 配置文件

主配置文件位于：`/etc/3x-ui-go/config.yaml`

```yaml
# 面板配置
panel:
  port: 2053
  path: /
  ssl: false
  cert_file: ""
  key_file: ""

# 数据库配置
database:
  type: sqlite3
  path: /etc/3x-ui-go/3x-ui-go.db

# 日志配置
log:
  level: info
  file: /var/log/3x-ui-go/3x-ui-go.log
  max_size: 10
  max_days: 7

# Xray 配置
xray:
  bin_path: /usr/local/bin/xray
  config_path: /etc/3x-ui-go/xray.json
  log_level: warning
```

### 环境变量

```bash
# 面板端口
export XUI_PORT=2053

# 数据库路径
export XUI_DB_PATH=/etc/3x-ui-go/3x-ui-go.db

# 日志级别
export XUI_LOG_LEVEL=info

# SSL 配置
export XUI_SSL_CERT=/path/to/cert.pem
export XUI_SSL_KEY=/path/to/key.pem
```

## 📱 客户端配置

### 推荐客户端

| 平台 | 客户端 | 下载链接 |
|------|--------|----------|
| Windows | v2rayN / Clash | [v2rayN](https://github.com/2dust/v2rayN) |
| macOS | ClashX / v2rayU | [ClashX](https://github.com/yichengchen/clashX) |
| Linux | v2ray-core / Clash | [v2ray-core](https://github.com/v2fly/v2ray-core) |
| Android | v2rayNG / Clash | [v2rayNG](https://github.com/2dust/v2rayNG) |
| iOS | Shadowrocket / Quantumult | App Store |

### 配置导入

1. 在面板中创建用户配置
2. 复制订阅链接或扫描二维码
3. 在客户端中导入配置
4. 选择节点并连接

## 🔒 安全建议

### 基础安全

- ✅ 修改默认管理员密码
- ✅ 使用强密码策略
- ✅ 启用双因素认证
- ✅ 定期更新系统和面板
- ✅ 配置防火墙规则

### 高级安全

- 🔐 使用非标准端口
- 🔐 配置 Nginx 反向代理
- 🔐 使用 Cloudflare CDN
- 🔐 启用访问日志审计
- 🔐 配置 fail2ban 防护

## 📊 监控与维护

### 系统监控

```bash
# 查看服务状态
systemctl status 3x-ui-go

# 查看资源使用
htop
df -h
free -h

# 查看网络连接
netstat -tulpn | grep 2053
```

### 日志分析

```bash
# 查看面板日志
tail -f /var/log/3x-ui-go/3x-ui-go.log

# 查看 Xray 日志
tail -f /var/log/xray/access.log

# 查看错误日志
tail -f /var/log/xray/error.log
```

## 🔄 备份与恢复

### 自动备份

```bash
# 设置定时备份
crontab -e

# 每天凌晨2点备份
0 2 * * * /usr/local/bin/3x-ui-go backup
```

### 手动备份

```bash
# 创建备份
./3x-ui-go backup

# 恢复备份
./3x-ui-go restore backup-20231201-020000.tar.gz
```

## 🆙 更新升级

### 自动更新

```bash
# 检查更新
./3x-ui-go check-update

# 自动更新
./3x-ui-go update
```

### 手动更新

```bash
# 下载最新版本
wget https://github.com/everett7623/3x-ui-go/releases/latest/download/3x-ui-go-linux-amd64.tar.gz

# 解压并替换
tar -xzf 3x-ui-go-linux-amd64.tar.gz
systemctl stop 3x-ui-go
cp 3x-ui-go /usr/local/bin/
systemctl start 3x-ui-go
```

## 🤝 贡献指南

我们欢迎各种形式的贡献！

### 如何贡献

1. **Fork** 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的修改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 **Pull Request**

### 代码规范

- 遵循 Go 官方代码规范
- 添加必要的注释和文档
- 确保测试通过
- 保持代码简洁和可读性

## 📄 许可证

本项目采用 [MIT License](LICENSE) 许可证。

## 🙏 致谢

- [Project X](https://github.com/XTLS/Xray-core) - Xray 核心
- [3x-ui](https://github.com/MHSanaei/3x-ui) - 原始项目灵感
- 所有贡献者和支持者

## 📞 支持

- 📧 **Email**: support@everett7623.dev
- 💬 **Telegram**: [@everett7623](https://t.me/everett7623)
- 🐛 **Issues**: [GitHub Issues](https://github.com/everett7623/3x-ui-go/issues)
- 📖 **文档**: [Wiki](https://github.com/everett7623/3x-ui-go/wiki)

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=everett7623/3x-ui-go&type=Date)](https://star-history.com/#everett7623/3x-ui-go&Date)

---

<div align="center">
  <p>如果这个项目对你有帮助，请考虑给个 ⭐ Star！</p>
  <p>Made with ❤️ by <a href="https://github.com/everett7623">everett7623</a></p>
</div>
