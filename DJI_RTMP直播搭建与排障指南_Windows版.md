# DJI 无人机 RTMP 直播 → MediaMTX → 本地观看 教程（Windows 版）

> 目标：大疆无人机通过 RTMP 推流到本机 MediaMTX，在电脑上低延迟观看直播。
> 环境：**Windows + MediaMTX v1.20.1（windows/amd64 版）** + 大疆 DJI Fly（带屏遥控器）+ VLC / 浏览器。
> ⚠️ 本文档所有命令、路径、防火墙操作均针对 **Windows 平台**（PowerShell），Linux/macOS 环境不适用。

---

## 一、架构

```
无人机相机 → 遥控器(DJI Fly) → RTMP推流 → MediaMTX(本机 :1935) → 本地观看
                                                    ├─ RTMP  : rtmp://127.0.0.1:1935/livedji
                                                    ├─ HLS   : http://127.0.0.1:8888/livedji/index.m3u8
                                                    └─ WebRTC: http://127.0.0.1:8889/livedji  ← 延迟最低
```

---

## 二、启动 MediaMTX（Windows）

> 本文使用的是官方 **Windows amd64 版本**（`mediamtx_v1.20.1_windows_amd64`），
> 文件为 `mediamtx.exe`，启动命令、防火墙放行、端口绑定行为均以 Windows 为准。

```powershell
# 进入 mediamtx 目录后执行
.\mediamtx.exe
```

启动成功标志（日志应出现）：

```
[RTMP] started with listener on :1935 (TCP/RTMP)
[HLS]  started with listener on :8888  (TCP/HTTP)
[WebRTC] started with listeners on :8889 (TCP/HTTP), :8189 (UDP/ICE)
```

默认端口：

| 服务   | 端口 |
| ------ | ---- |
| RTSP   | 8554 |
| RTMP   | 1935 |
| HLS    | 8888 |
| WebRTC | 8889 |
| SRT    | 8890 |

---

## 三、大疆遥控器（DJI Fly）侧配置

界面的 **「地址」和「推流码」两栏** 填写：

| 栏目   | 填写内容                       |
| ------ | ------------------------------ |
| 地址   | `rtmp://<电脑IP>:1935/live/` |
| 推流码 | `dji`                        |

- 电脑 IP：使用电脑**当前连接的网络**（WiFi 或以太网）的 IPv4，用 `ipconfig` 确认。
- 拼接结果：`rtmp://<电脑IP>:1935/live/dji`
- ⚠️ **注意**：DJI 会把地址与推流码**直接拼接、可能吃掉斜杠**，最终实际路径可能是 `livedji`（无斜杠）。以 **MediaMTX 日志里显示的 path 为准**（见第五节排查）。

---

## 四、本地观看（按延迟从低到高）

### ① WebRTC（延迟最低，亚秒级，推荐）

用 Chrome / Edge 浏览器打开：

```
http://127.0.0.1:8889/livedji
```

### ② RTMP（延迟较低）

VLC 打开网络流，**低延迟参数**：

```powershell
Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe" -ArgumentList `
  '--network-caching=100 --clock-jitter=0 --clock-synchro=-1 --live-caching=100 "rtmp://127.0.0.1:1935/livedji"'
```

或 VLC 图形界面：媒体 → 打开网络串流，输入 `rtmp://127.0.0.1:1935/livedji`。

### ③ HLS（延迟最高，兼容性最好）

浏览器或 VLC 播放：

```
http://127.0.0.1:8888/livedji/index.m3u8
```

---

## 四.5、让其它设备（手机/其它电脑）通过浏览器访问

MediaMTX **默认就绑定所有接口（0.0.0.0）**，且防火墙已放行，**局域网内其它设备无需任何额外配置**即可访问。

需要满足的条件：

- 其它设备与 MediaMTX 电脑**在同一个局域网/网段**（如 `192.168.3.x`）。
- 其它设备访问时**必须用电脑的局域网 IP**（如 `192.168.3.5`），**不能填 `127.0.0.1`**（那是各设备自己的回环地址）。

访问地址对照表（path 见第三节，如 `livedji`）：

| 访问方式           | 本机访问                                     | 局域网其它设备                                 |
| ------------------ | -------------------------------------------- | ---------------------------------------------- |
| WebRTC（最低延迟） | `http://127.0.0.1:8889/livedji`            | `http://192.168.3.5:8889/livedji`            |
| HLS                | `http://127.0.0.1:8888/livedji/index.m3u8` | `http://192.168.3.5:8888/livedji/index.m3u8` |
| RTMP（VLC）        | `rtmp://127.0.0.1:1935/livedji`            | `rtmp://192.168.3.5:1935/livedji`            |

> 💡 电脑 IP 会因 DHCP 变化，长期使用建议给电脑设置**静态/固定 IP**。

---

## 五、常见问题与排查

### 1. 遥控器提示「请检查 RTMP 地址与推流码」

- **防火墙入站拦截**（⚠️ 仅 Windows，使用 Windows 防火墙 cmdlet）：确认 1935 端口已放行，且你的网络 Profile（Private/Public）在放行范围内。检查：

  ```powershell
  Get-NetFirewallRule -Direction Inbound | Where-Object {$_.DisplayName -match "mediamtx|1935"}
  ```

  需要时放行（管理员 PowerShell）：
  ```powershell
  New-NetFirewallRule -DisplayName "MediaMTX RTMP" -Direction Inbound -Protocol TCP -LocalPort 1935 -Action Allow -Profile Private,Domain
  ```
- **IP 填错网卡**：大疆连 WiFi，就填电脑 WiFi 的 IP，别填以太网 IP。
- **路径拼接不对**：看 MediaMTX 日志确认实际 path。

### 2. 看 MediaMTX 日志确认连接状态

正常推流时日志类似：

```
[RTMP] [conn 192.168.3.25:xxxx] is publishing to path 'livedji'
[path livedji] stream is available and online, 2 tracks (H264, MPEG-4 Audio)
```

- `2 tracks (H264, MPEG-4 Audio)` = 视频+音频正常
- `1 track (MPEG-4 Audio)` = **只有音频没视频** → 无人机未起飞/相机未激活，或需在 DJI Fly 改编码为 H.264。

### 3. VLC 提示「无法打开 MRL」

说明该路径当前**没有活动推流**。先确认大疆已开始直播，再打开 VLC。

### 4. 延迟大

- VLC 加低延迟参数（见第四节②）。
- 换用 **WebRTC** 观看（延迟最低）。
- 大疆侧降低图传清晰度/码率。

---

## 六、关键结论回顾

1. MediaMTX 默认配置（`authMethod: internal` + `any` 用户）即可匿名接收推流，无需额外权限配置。
2. 大疆实际推流路径可能是 `livedji`（无斜杠），一切以 **MediaMTX 日志中的 path** 为准。
3. 若只有音频没有视频 → 检查无人机起飞/相机激活状态，及 DJI 端编码（建议 H.264）。
4. 观看延迟：**WebRTC < RTMP < HLS**。
