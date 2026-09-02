# DJI 无人机 RTMP 直播搭建与排障指南（Windows）

> 环境：Windows + MediaMTX v1.20.1（本仓库 `server/mediamtx_v1.20.1_windows_amd64`）+ DJI Fly 遥控器。

## 一、启动

**推荐：双击根目录 `start_windows.bat`**。自动启动 MediaMTX（RTMP :1935 / WebRTC :8889 / HLS :8888）并托管观看页（:8080），控制台打印全部地址。

手动启动：

```powershell
powershell -ExecutionPolicy Bypass -File server\serve.ps1
```

## 二、遥控器（DJI Fly）配置

自定义 RTMP，**服务器地址与推流码分开填**：

| 栏目       | 填写                                        |
| ---------- | ------------------------------------------- |
| 服务器地址 | `rtmp://<电脑IP>/`（端口可选，默认 1935） |
| 推流码     | `livedji`                                 |

- 电脑 IP 选遥控器所在网络的那个（控制台已标注接口）
- 拼接结果等价 `rtmp://<电脑IP>:1935/livedji`
- 实际 path 以 MediaMTX 日志为准

**前置条件**：

- 需**接入麦克风**（Type-C 耳机 / 蓝牙耳机）才能开播
- 需**连接 / 起飞无人机**才有画面（否则仅音频，日志 `1 track (MPEG-4 Audio)`）

## 三、观看

| 方式                 | 地址                                        | 延迟                       |
| -------------------- | ------------------------------------------- | -------------------------- |
| 自定义观看页（推荐） | `http://<电脑IP>:8080/`                   | 低（含状态 / 时钟 / 署名） |
| WebRTC               | `http://<电脑IP>:8889/livedji`            | 最低                       |
| HLS                  | `http://<电脑IP>:8888/livedji/index.m3u8` | 最高                       |

- 本机可用 `127.0.0.1` 代替 `<电脑IP>`
- 其它设备：与电脑同一局域网，用电脑的局域网 IP（不能填 `127.0.0.1`）

### VLC 等播放器串流

VLC `Ctrl+N`（媒体 → 打开网络串流）粘贴地址：

| 场景   | RTMP（低延迟）                                   | HLS（更稳）                                        |
| ------ | ------------------------------------------------ | ------------------------------------------------- |
| 本机   | `rtmp://127.0.0.1:1935/livedji`                | `http://127.0.0.1:8888/livedji/index.m3u8`      |
| 局域网 | `rtmp://<电脑IP>:1935/livedji`                 | `http://<电脑IP>:8888/livedji/index.m3u8`       |

## 四、常见问题

1. **遥控器提示检查 RTMP 地址 / 推流码**

    - 防火墙放行 RTMP、观看页和 WebRTC 所需端口：
     ```powershell
     New-NetFirewallRule -DisplayName "MediaMTX RTMP" -Direction Inbound -Protocol TCP -LocalPort 1935 -Action Allow
       New-NetFirewallRule -DisplayName "DJI Live Web" -Direction Inbound -Protocol TCP -LocalPort 8080,8889 -Action Allow
       New-NetFirewallRule -DisplayName "MediaMTX WebRTC" -Direction Inbound -Protocol UDP -LocalPort 8189 -Action Allow
     ```
   - IP 选遥控器所在网络的网卡 IP
   - 看 MediaMTX 日志确认实际 path
2. **只有音频没视频**（日志 `1 track`）

   - 无人机未起飞 / 相机未激活；DJI 端建议编码 H.264
3. **VLC 无法打开**

   - 该路径无活动推流，先确认遥控器已开播
4. **延迟大**

   - 用 WebRTC / 自定义观看页；降低图传清晰度 / 码率

## 五、关键结论

1. MediaMTX 默认配置即可匿名接收推流，无需额外配置
2. 推流 path 以日志为准
3. 延迟：WebRTC < RTMP < HLS
