# DJI 无人机 RTMP 直播搭建与排障指南（macOS）

> 适用环境：macOS、MediaMTX v1.20.1（`server/mediamtx_v1.20.1_darwin_{arm64,amd64}`）和安装 DJI Fly 的遥控器。
> 已验证启动脚本、MediaMTX 端口与观看页托管；真机推流仍需在实际设备上确认。

macOS 使用系统自带的 `nc`（netcat）托管观看页，不需要额外安装 Python、Node.js、npm 或 Docker。

## 一、准备 MediaMTX

> 通用准备（硬件设备 / 推流软件 / 网络：同一 Wi-Fi 或热点）统一见根目录 [README](../README.md)。

MediaMTX 就位情况：

| 芯片 | 状态 | 说明 |
| --- | --- | --- |
| Apple Silicon（M1-M4） | 已内置 | `server/mediamtx_v1.20.1_darwin_arm64/` |
| Intel | ⬇️ 按需下载 | 下载后放入 `server/mediamtx_v1.20.1_darwin_amd64/` |

仅 **Intel Mac** 需要下载：

1. 前往 [官方 Releases](https://github.com/bluenviron/mediamtx/releases) 下载 v1.20.1 的 `mediamtx_v1.20.1_darwin_amd64.tar.gz`
2. 解压，将整个目录放到 `server/mediamtx_v1.20.1_darwin_amd64/`
3. 启动脚本会自动识别芯片架构

### 首次运行前

```bash
chmod +x start_macos.command
```

- 被 **Gatekeeper** 拦截时：`xattr -dr com.apple.quarantine start_macos.command server/mediamtx_v1.20.1_darwin_arm64/mediamtx`
- **防火墙**：首次运行弹窗点「允许」；或 系统设置 → 网络 → 防火墙 → 允许 mediamtx 接受传入连接

## 二、启动

双击 `start_macos.command`，或在终端运行 `./start_macos.command`。脚本会：

1. 根据芯片架构选择对应的 mediamtx
2. 启动 MediaMTX（RTMP :1935 / WebRTC :8889 / HLS :8888）
3. 用 macOS 自带的 `nc`（netcat）托管观看页（:8080）
4. 打印全部地址（标注接口，en0 通常为 Wi-Fi）

启动窗口会在直播期间保持打开。关闭窗口或按 `Ctrl+C` 会同时停止 MediaMTX 与观看页；排障日志位于 `server/mediamtx.log`。

## 三、配置 DJI Fly

配置方法与通用步骤见 [README](../README.md)「DJI Fly 配置」；本平台无特殊差异。

## 四、macOS 排障

观看方式 / VLC / 通用问题（只有音频没视频、VLC 无法打开、延迟大）见 [README](../README.md)。

1. **遥控器提示检查 RTMP 地址 / 推流码**

   - 防火墙允许 mediamtx 接受传入连接（系统设置 → 网络 → 防火墙）
   - IP 选遥控器所在网络的网卡 IP
   - 看 MediaMTX 日志确认实际 path（`server/mediamtx.log`）
