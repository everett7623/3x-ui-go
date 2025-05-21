# 优化版3x-ui一键安装脚本

这是一个经过优化的3x-ui面板安装脚本，主要特点包括：

- 支持全端口配置，包括80/443端口
- 优化的系统参数配置，应用BBR加速
- 安全的防火墙设置，允许灵活使用各种端口
- 安装Fail2ban防止暴力破解
- 自动配置国际DNS，避免DNS污染

## 使用方法

一键安装命令：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/everett7623/3x-ui-go/main/install.sh)
```
