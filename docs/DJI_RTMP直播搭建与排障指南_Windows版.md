# DJI 无人机 RTMP 直播搭建与排障指南（Windows）

> 适用环境：Windows、MediaMTX v1.20.1（本仓库 `server/mediamtx_v1.20.1_windows_amd64`）和安装 DJI Fly 的遥控器。
> Windows 版 MediaMTX 已随仓库提供，无需单独下载。

Windows 使用系统自带的 PowerShell / .NET 托管观看页，不需要额外安装 Python、Node.js、npm 或 Docker。

> 通用准备（硬件设备 / 推流软件 / 网络：同一 Wi-Fi 或热点）统一见根目录 [README](../README.md)。

## 一、启动

双击根目录的 `start_windows.bat`。脚本会启动 MediaMTX（RTMP :1935 / WebRTC :8889 / HLS :8888）和观看页（:8080），然后打印可用地址。

手动启动：

```powershell
powershell -ExecutionPolicy Bypass -File server\serve.ps1
```

> 启动窗口会在直播期间保持打开。关闭窗口或按 `Ctrl+C` 会同时停止 MediaMTX 与观看页；日志在 `server/mediamtx.log`。

## 二、Windows 排障

DJI Fly 配置 / 观看方式 / VLC / 通用问题（只有音频没视频、VLC 无法打开、延迟大）见 [README](../README.md)。

1. **遥控器提示检查 RTMP 地址 / 推流码**

   - 防火墙放行 RTMP、观看页和 WebRTC 所需端口：
     ```powershell
     New-NetFirewallRule -DisplayName "MediaMTX RTMP" -Direction Inbound -Protocol TCP -LocalPort 1935 -Action Allow
     New-NetFirewallRule -DisplayName "DJI Live Web" -Direction Inbound -Protocol TCP -LocalPort 8080,8889 -Action Allow
     New-NetFirewallRule -DisplayName "MediaMTX WebRTC" -Direction Inbound -Protocol UDP -LocalPort 8189 -Action Allow
     ```
   - IP 选遥控器所在网络的网卡 IP
   - 看 MediaMTX 日志确认实际 path（`server\mediamtx.log`）
