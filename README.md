# 3x-ui-go

<div align="center">
  <img src="https://img.shields.io/github/stars/everett7623/3x-ui-go?style=for-the-badge" alt="GitHub stars">
  <img src="https://img.shields.io/github/forks/everett7623/3x-ui-go?style=for-the-badge" alt="GitHub forks">
  <img src="https://img.shields.io/github/license/everett7623/3x-ui-go?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Go-1.21+-00ADD8?style=for-the-badge&logo=go" alt="Go Version">
  <img src="https://img.shields.io/github/release/everett7623/3x-ui-go?style=for-the-badge" alt="Release">
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

### 💻 系统要求

| 项目 | 要求 |
|------|------|
| **操作系统** | Ubuntu 18+ / Debian 9+ / CentOS 7+ |
| **架构** | x86_64 / aarch64 |
| **内存** | 最小 256MB，推荐 512MB+ |
| **存储** | 最小 10GB 可用空间 |

### ⚡ 一键原版3xui+bbr

```bash
bash <(curl -Ls https://raw.githubusercontent.com/everett7623/3x-ui-go/main/3xuigo.sh)
```

### 🎯 安装过程

--- 菜单 ---
1. 一键3X-UI (安装依赖, BBR优化, 安装原版3x-ui)
2. 清理一键3X-UI脚本文件
3. 卸载原版3X-UI并清理脚本文件
4. 退出



### 🔑 登录信息

安装完成后，您将看到面板的登录信息：



> **⚠️ 安全提醒**: 请立即修改默认的用户名和密码！

### 🧹 清理安装文件

安装完成后，您可以安全删除安装脚本：



```bash
# 删除安装脚本
rm -f 3xuigo.sh
```

## 🛠️ 管理命令

```bash
# 查看面板状态
systemctl status 3x-ui-go

# 启动面板
systemctl start 3x-ui-go

# 停止面板
systemctl stop 3x-ui-go

# 重启面板
systemctl restart 3x-ui-go

# 查看面板日志
journalctl -u 3x-ui-go -f
```

## 📱 客户端配置

### 🔗 推荐客户端

| 平台 | 客户端 | 下载链接 | 特点 |
|------|--------|----------|------|
| **Windows** | v2rayN | [GitHub](https://github.com/2dust/v2rayN) | 功能全面，界面友好 |
| **macOS** | Karing | [GitHub](https://github.com/koroshkorosh1/Karing/releases) | 开源免费，界面现代 |
| **Linux** | Hiddify | [GitHub](https://github.com/hiddify/hiddify-app/releases) | 跨平台支持 |
| **Android** | v2rayNG | [GitHub](https://github.com/2dust/v2rayNG) | 轻量高效 |
| **iOS** | Shadowrocket | [购买链接](https://s.y8o.de/xiaohuojian) | 功能强大 |

### 📋 配置导入步骤

1. **创建用户** - 在面板中创建新用户配置
2. **获取配置** - 复制订阅链接或扫描二维码
3. **导入客户端** - 在客户端中导入配置
4. **连接测试** - 选择节点并测试连接

## 🔧 配置说明

### 🌐 访问面板

```
# 默认访问地址
http://your-server-ip:2053（根据自定义）

# 使用域名（推荐）
https://your-domain.com:2053（根据自定义）
```

### 🔒 SSL 证书配置

面板支持以下 SSL 证书配置方式：

1. **Let's Encrypt 自动申请**
2. **自有证书上传**
3. **Cloudflare 托管证书**

### 🛡️ 安全建议

- ✅ 修改默认登录凭据
- ✅ 启用双因素认证（如果支持）
- ✅ 使用 HTTPS 访问面板
- ✅ 定期备份配置数据
- ✅ 监控系统资源使用情况

## 🆘 常见问题

<details>
<summary><strong>Q: 安装失败怎么办？</strong></summary>

**A**: 请检查以下几点：
- 系统是否满足最低要求
- 网络连接是否正常
- 是否有足够的权限（建议使用 root 用户）
- 查看安装日志中的错误信息
</details>

<details>
<summary><strong>Q: 面板无法访问？</strong></summary>

**A**: 请检查：
- 服务是否正常运行：`systemctl status 3x-ui-go`
- 防火墙是否开放相应端口
- 服务器安全组设置是否正确
</details>

<details>
<summary><strong>Q: 如何备份数据？</strong></summary>

**A**: 重要数据通常位于：
- 配置文件：`/etc/3x-ui-go/`
- 数据库文件：`/etc/3x-ui-go/db/`
- 定期备份这些目录即可
</details>

## 🤝 贡献指南

我们欢迎各种形式的贡献！

### 💡 如何贡献

1. **Fork** 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 **Pull Request**

### 📝 代码规范

- 遵循 Go 官方代码规范
- 添加必要的注释和文档
- 确保所有测试通过
- 保持代码简洁和可读性

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源许可证发布。

## 🙏 致谢

特别感谢以下项目和贡献者：

- [Project X](https://github.com/XTLS/Xray-core) - 提供强大的 Xray 核心
- [3x-ui](https://github.com/MHSanaei/3x-ui) - 原始项目灵感来源
- 所有贡献者和社区支持者 ❤️

## 📞 获取支持

遇到问题？我们提供多种支持方式：

- 🐛 **问题反馈**: [GitHub Issues](https://github.com/everett7623/3x-ui-go/issues)
- 📚 **项目文档**: [Wiki](https://github.com/everett7623/3x-ui-go/wiki)
- 💬 **社区讨论**: [Discussions](https://github.com/everett7623/3x-ui-go/discussions)

## 📈 项目统计

### ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=everett7623/3x-ui-go&type=Date)](https://star-history.com/#everett7623/3x-ui-go&Date)

### 📊 贡献统计

![贡献者](https://contrib.rocks/image?repo=everett7623/3x-ui-go)

---

<div align="center">
  <p>如果这个项目对您有帮助，请考虑给个 ⭐ Star！</p>
  <p>Made with ❤️ by <a href="https://github.com/everett7623">everett7623</a></p>
  
  **🌟 让我们一起构建更好的代理管理工具！🌟**
</div>
