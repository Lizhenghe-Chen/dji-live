# BunnyChen-DJI-RTPM

大疆（DJI）无人机通过 **RTMP 推流**到本机 [MediaMTX](https://github.com/bluenviron/mediamtx)，
实现低延迟本地直播观看的完整方案（含搭建与排障指南）。

```
无人机相机 → 遥控器(DJI Fly) → RTMP推流 → MediaMTX(本机 :1935) → 本地观看
                                                    ├─ RTMP  : rtmp://127.0.0.1:1935/livedji
                                                    ├─ HLS   : http://127.0.0.1:8888/livedji/index.m3u8
                                                    └─ WebRTC: http://127.0.0.1:8889/livedji  ← 延迟最低
```

---

## MediaMTX 简介

**MediaMTX** 是一个即开即用、零依赖的实时媒体服务器/媒体代理，支持通过
Media-over-QUIC、SRT、WebRTC、RTSP、RTMP、HLS、MPEG-TS、RTP 等协议进行流的
发布、读取、代理、录制与回放。它像一台“媒体路由器”，把多种协议互相转换，
单可执行文件，兼容 **Linux / Windows / macOS**，无需安装依赖。

- **官方网站**：https://mediamtx.org
- **GitHub 仓库**：https://github.com/bluenviron/mediamtx （MIT 协议，20k+ stars）
- **Releases 下载**：https://github.com/bluenviron/mediamtx/releases

### 本仓库所用可执行文件

| 平台 | 目录 / 文件 | 来源 |
|------|------------|------|
| Windows | `mediamtx_v1.20.1_windows_amd64\mediamtx.exe` | GitHub Releases v1.20.1 |
| macOS   | （待补充） | 见下方「后续规划」 |

可执行文件均来自 [bluenviron/mediamtx Releases](https://github.com/bluenviron/mediamtx/releases)，
该仓库提供 **Linux、Windows、macOS、ARM** 等多个平台版本，可按需选用。

---

## 快速开始（Windows）

```powershell
# 启动 MediaMTX
cd mediamtx_v1.20.1_windows_amd64
.\mediamtx.exe
```

启动成功标志：

```
[RTMP]   started with listener on :1935 (TCP/RTMP)
[HLS]    started with listener on :8888  (TCP/HTTP)
[WebRTC] started with listeners on :8889 (TCP/HTTP), :8189 (UDP/ICE)
```

默认端口：RTSP `8554`、RTMP `1935`、HLS `8888`、WebRTC `8889`、SRT `8890`。

---

## 文档

- 详细搭建与排障指南（Windows）：[DJI_RTMP直播搭建与排障指南_Windows版.md](./DJI_RTMP直播搭建与排障指南_Windows版.md)

---

## 后续规划

- [ ] 补充 **macOS** 版本（`mediamtx_darwin_*` 可执行文件）的搭建与排障说明
- [ ] macOS 与 Windows 的防火墙/权限配置差异说明

