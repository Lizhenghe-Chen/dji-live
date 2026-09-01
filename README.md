# BunnyChen-DJI-RTPM

大疆无人机 RTMP 低延迟直播：**一键启动即可开播、观看**（Windows / macOS）。

## 快速开始

1. **启动**：Windows 双击 `start.bat`；macOS 双击 `start.command`（首次先 `chmod +x start.command`）
2. 控制台打印所有地址（标注网络接口）：
   - `WATCH` → 打开观看直播
   - `SERVER` + `STREAM KEY` → 填入 DJI Fly
3. DJI Fly → 自定义 RTMP：`SERVER` 填 `rtmp://<电脑IP>/`，`STREAM KEY` 填 `livedji`
4. 任意设备浏览器打开 `WATCH` 地址观看

> 具体地址以控制台输出为准（每个 IP 标注了对应网络接口）。

## 前置条件

- DJI 遥控器需**接入麦克风**（Type-C 耳机 / 蓝牙耳机）才能开播
- 需**连接 / 起飞无人机**才有画面（否则仅音频或推流失败）
- 遥控器与电脑需**同一局域网**（同一 WiFi / 手机热点）

## 文件结构

```
RTPM/
├── start.bat          ← Windows 一键启动（双击）
├── start.command      ← macOS 一键启动（双击）
├── README.md / LICENSE
├── server/            ← 服务端（脚本自动管理）
│   ├── serve.ps1      ← Windows 启动逻辑
│   ├── serve.py       ← macOS 页面托管（系统自带 python3）
│   ├── index.html     ← 观看页（状态 / 时钟 / 署名，自动隐藏）
│   ├── mediamtx_v1.20.1_windows_amd64/
│   └── mediamtx_v1.20.1_darwin_{arm64,amd64}/   ← macOS（自行下载）
└── docs/
    ├── DJI_RTMP直播搭建与排障指南_Windows版.md
    └── DJI_RTMP直播搭建与排障指南_macOS版.md   ← 待测试
```

## VLC 等播放器

VLC `Ctrl+N` → 打开网络串流，粘贴地址：

- RTMP（低延迟）：`rtmp://<电脑IP>:1935/livedji`
- HLS（更稳）：`http://<电脑IP>:8888/livedji/index.m3u8`

本机用 `127.0.0.1`；其它设备用电脑局域网 IP（以控制台标注为准）。

## 文档

- 详细搭建与排障（Windows）：[docs/DJI_RTMP直播搭建与排障指南_Windows版.md](./docs/DJI_RTMP直播搭建与排障指南_Windows版.md)
- 详细搭建与排障（macOS，待测试）：[docs/DJI_RTMP直播搭建与排障指南_macOS版.md](./docs/DJI_RTMP直播搭建与排障指南_macOS版.md)
