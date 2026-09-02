# DJI 无人机 RTMP 直播搭建与排障指南（Windows）

> 环境：Windows + MediaMTX v1.20.1（本仓库 `server/mediamtx_v1.20.1_windows_amd64`）+ DJI Fly 遥控器。
> ✅ Windows 版 MediaMTX 已随仓库内置，**无需下载**，开箱即用。

> 通用准备（硬件设备 / 推流软件 / 网络：同一 Wi-Fi 或热点）统一见根目录 [README](../README.md)。

## 一、启动

**推荐：双击根目录 `start_windows.bat`**。自动启动 MediaMTX（RTMP :1935 / WebRTC :8889 / HLS :8888）并托管观看页（:8080），控制台打印全部地址。

手动启动：

```powershell
powershell -ExecutionPolicy Bypass -File server\serve.ps1
```

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
   - 看 MediaMTX 日志确认实际 path
