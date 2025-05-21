# 3X-UI 一键安装脚本

本脚本旨在为用户提供一个简便、高效的方式来安装和配置 3X-UI 面板。它集成了系统优化、网络加速、安全防护等功能，适用于多种 Linux 发行版。

## 📌 功能概览

* 自动检测系统类型并安装必要依赖
* 配置系统时区为上海（Asia/Shanghai）
* 应用 BBR 拥塞控制算法，优化网络性能
* 设置 DNS，防止 DNS 污染
* 增加系统文件打开数限制，提升并发处理能力
* 安装并配置 3X-UI 面板，自动设置面板端口
* 安装并配置 Fail2ban，防止暴力破解
* 设置 3X-UI 面板开机自启

## ⚙️ 系统要求

* 操作系统：CentOS、Debian、Ubuntu（需具备 root 权限）

## 🚀 安装步骤

1. 以 root 用户登录您的服务器。
2. 运行以下命令开始安装：

   ```bash
   wget -O 3xuigo.sh https://raw.githubusercontent.com/everett7623/3x-ui-go/main/3xuigo.sh && chmod +x 3xuigo.sh && ./3xuigo.sh
   ```

3. 脚本将自动执行以下操作：

   * 更新系统并安装必要依赖（如 wget、curl、unzip、socat）
   * 配置系统时区为上海
   * 应用 BBR 拥塞控制算法
   * 设置 DNS，防止 DNS 污染
   * 增加系统文件打开数限制
   * 安装并配置 3X-UI 面板
   * 安装并配置 Fail2ban
   * 设置 3X-UI 面板开机自启

## 🔐 默认登录信息

* 面板地址：`http://your_server_ip:18888`
* 用户名和密码将在安装过程中随机生成，并在安装完成后显示。请务必记录。

## 🛠️ 常用命令

* 启动面板：`x-ui start`
* 停止面板：`x-ui stop`
* 重启面板：`x-ui restart`
* 查看面板状态：`x-ui status`
* 查看当前设置：`x-ui settings`
* 设置开机自启：`x-ui enable`
* 取消开机自启：`x-ui disable`
* 查看面板日志：`x-ui log`
* 查看 Fail2ban 封禁日志：`x-ui banlog`
* 更新面板：`x-ui update`
* 重新安装面板：`x-ui install`
* 卸载面板：`x-ui uninstall`

## 📄 注意事项

* 安装完成后，建议尽快修改默认的用户名和密码，以确保安全。

## 📬 联系与支持

如在使用过程中遇到问题，欢迎提交 [Issues](https://github.com/everett7623/3x-ui-go/issues) 或联系维护者获取支持。

---

感谢您使用本一键安装脚本，祝您使用愉快！

---
