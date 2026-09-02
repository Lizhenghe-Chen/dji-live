# DJI 无人机 RTMP 直播搭建与排障指南（macOS）

> 环境：macOS + MediaMTX v1.20.1（`server/mediamtx_v1.20.1_darwin_{arm64,amd64}`）+ DJI Fly 遥控器。
> ✅ 启动脚本与服务端已实现并验证通过（MediaMTX 三端口 / 观看页托管）；**真机推流（无人机）待实测**。

## 一、准备

1. 下载 macOS 版 MediaMTX：[Releases](https://github.com/bluenviron/mediamtx/releases) v1.20.1
   - Apple Silicon（M1/M2/M3/M4）：`mediamtx_v1.20.1_darwin_arm64.tar.gz`（本仓库已内置）
   - Intel：`mediamtx_v1.20.1_darwin_amd64.tar.gz`
   Intel Mac 解压后，将整个目录放到 `server/mediamtx_v1.20.1_darwin_amd64/`。

2. 首次运行前：

   ```bash
   chmod +x start_macos.command
   ```

   - 被 **Gatekeeper** 拦截时：`xattr -dr com.apple.quarantine start_macos.command server/mediamtx_v1.20.1_darwin_arm64/mediamtx`
   - **防火墙**：首次运行弹窗点「允许」；或 系统设置 → 网络 → 防火墙 → 允许 mediamtx / python3 接受传入连接

## 二、启动

**双击 `start_macos.command`**（或终端 `./start_macos.command`）。脚本自动：

1. 识别芯片（`uname -m`：arm64 / amd64）选对应 mediamtx
2. 启动 MediaMTX（RTMP :1935 / WebRTC :8889 / HLS :8888）
3. 用 macOS 自带 python3 托管观看页（:8080），零安装
4. 打印全部地址（标注接口，en0 通常为 Wi-Fi）

关闭窗口后服务仍在后台运行。

## 三、遥控器（DJI Fly）配置

与 Windows 相同，自定义 RTMP，**服务器地址与推流码分开填**：

| 栏目       | 填写                                        |
| ---------- | ------------------------------------------- |
| 服务器地址 | `rtmp://<电脑IP>/`（**默认不带端口号**，不填即用默认 1935） |
| 推流码     | `livedji`                                 |

- 电脑 IP 选遥控器所在网络的那个（`start_macos.command` 输出已标注接口）
- 实际 path 以 MediaMTX 日志为准

**前置条件**：

- 需**接入麦克风**（Type-C 耳机 / 蓝牙耳机）才能开播
- 需**连接 / 起飞无人机**才有画面（否则仅音频，日志 `1 track (MPEG-4 Audio)`）

## 四、观看

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

## 五、常见问题

1. **遥控器提示检查 RTMP 地址 / 推流码**

   - 防火墙允许 mediamtx / python3 接受传入连接（系统设置 → 网络 → 防火墙）
   - IP 选遥控器所在网络的网卡 IP
   - 看 MediaMTX 日志确认实际 path
2. **只有音频没视频**（日志 `1 track`）

   - 无人机未起飞 / 相机未激活；DJI 端建议编码 H.264
3. **VLC 无法打开**

   - 该路径无活动推流，先确认遥控器已开播
4. **延迟大**

   - 用 WebRTC / 自定义观看页；降低图传清晰度 / 码率

## 六、关键结论

1. MediaMTX 默认配置即可匿名接收推流，无需额外配置
2. 推流 path 以日志为准
3. 延迟：WebRTC < RTMP < HLS
