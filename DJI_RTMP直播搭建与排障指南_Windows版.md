# DJI 无人机 RTMP 直播 → MediaMTX → 本地观看 教程（Windows 版）

> 目标：大疆无人机通过 RTMP 推流到本机 MediaMTX，在电脑上低延迟观看直播。
> 环境：**Windows + MediaMTX v1.20.1（windows/amd64 版）** + 大疆 DJI Fly（带屏遥控器）+ VLC / 浏览器。
> ⚠️ 本文档所有命令、路径、防火墙操作均针对 **Windows 平台**（PowerShell），Linux/macOS 环境不适用。

---

## 一、关于 MediaMTX

**MediaMTX** 是一个即开即用、零依赖的实时媒体服务器/媒体代理，支持通过
Media-over-QUIC、SRT、WebRTC、RTSP、RTMP、HLS、MPEG-TS、RTP 等协议进行流的
发布、读取、代理、录制与回放。它像一台“媒体路由器”，把多种协议互相转换，
单可执行文件，兼容 Linux / Windows / macOS，无需安装依赖。

- **官方网站**：https://mediamtx.org
- **GitHub 仓库**：https://github.com/bluenviron/mediamtx （MIT 协议，20k+ stars）
- **本文所用**：`mediamtx_v1.20.1_windows_amd64\mediamtx.exe`
  - 下载地址（Releases）：https://github.com/bluenviron/mediamtx/releases （v1.20.1 为当前 Latest）
  - 本仓库还提供 **Linux、macOS、ARM** 等多个平台的可执行文件，可按需选用。

> 📌 文档目前记录 **Windows 版本**；后续如需新增 **macOS 版**，只需更换对应平台的
> 可执行文件（`mediamtx`），启动与使用方式相同，但**防火墙/权限命令不同**（macOS 用 `pfctl`/应用放行设置），届时再补充相应章节。

---

## 二、架构

```
无人机相机 → 遥控器(DJI Fly) → RTMP推流 → MediaMTX(本机 :1935) → 本地观看
                                                    ├─ RTMP  : rtmp://127.0.0.1:1935/livedji
                                                    ├─ HLS   : http://127.0.0.1:8888/livedji/index.m3u8
                                                    └─ WebRTC: http://127.0.0.1:8889/livedji  ← 延迟最低
```

---

## 三、启动 MediaMTX（Windows）

> 本文使用的是官方 **Windows amd64 版本**（`mediamtx_v1.20.1_windows_amd64`），
> 文件为 `mediamtx.exe`，启动命令、防火墙放行、端口绑定行为均以 Windows 为准。

```powershell
# 进入 mediamtx 目录后执行
cd .\mediamtx_v1.20.1_windows_amd64\ 
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

## 四、大疆遥控器（DJI Fly）侧配置

界面的 **「地址」和「推流码」两栏** 填写：

| 栏目   | 填写内容                       |
| ------ | ------------------------------ |
| 地址   | `rtmp://<电脑IP>:1935/live/` |
| 推流码 | `dji`                        |

- 电脑 IP：使用电脑**当前连接的网络**（WiFi 或以太网）的 IPv4，用 `ipconfig` 确认。
- 拼接结果：`rtmp://<电脑IP>:1935/live/dji`
- ⚠️ **注意**：DJI 会把地址与推流码**直接拼接、可能吃掉斜杠**，最终实际路径可能是 `livedji`（无斜杠）。以 **MediaMTX 日志里显示的 path 为准**（见「常见问题与排查」）。

### 前置条件

- **需要接入麦克风**：DJI 遥控器开启直播需接入**支持 Type-C 的有线耳机**或**蓝牙耳机**，否则无法开始直播。
- **必须连接无人机才有画面**：未连接/未起飞无人机时，推流可能**只有声音或串流失败**
  （MediaMTX 日志表现为纯音频 `1 track (MPEG-4 Audio)`）。请先连接/起飞无人机，
  确认遥控器已显示相机画面再开始直播。

---

## 五、本地观看（按延迟从低到高）

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

## 六、让其它设备（手机/其它电脑）通过浏览器访问

MediaMTX **默认就绑定所有接口（0.0.0.0）**，且防火墙已放行，**局域网内其它设备无需任何额外配置**即可访问。

需要满足的条件：

- 其它设备与 MediaMTX 电脑**在同一个局域网/网段**（如 `192.168.3.x`）。
- 其它设备访问时**必须用电脑的局域网 IP**（如 `192.168.3.5`），**不能填 `127.0.0.1`**（那是各设备自己的回环地址）。

访问地址对照表（path 见「大疆遥控器配置」，如 `livedji`）：

| 访问方式           | 本机访问                                     | 局域网其它设备                                 |
| ------------------ | -------------------------------------------- | ---------------------------------------------- |
| WebRTC（最低延迟） | `http://127.0.0.1:8889/livedji`            | `http://192.168.3.5:8889/livedji`            |
| HLS                | `http://127.0.0.1:8888/livedji/index.m3u8` | `http://192.168.3.5:8888/livedji/index.m3u8` |
| RTMP（VLC）        | `rtmp://127.0.0.1:1935/livedji`            | `rtmp://192.168.3.5:1935/livedji`            |

> 💡 电脑 IP 会因 DHCP 变化，长期使用建议给电脑设置**静态/固定 IP**。

---

## 六·五、自定义观看页面（水印 / 时钟 / 标题）

MediaMTX 自带的 WebRTC 页面（`http://<IP>:8889/livedji`）只有纯视频画面。
仓库提供了 **`watch.html`** —— 一个自定义观看页面，可在画面上叠加：

- **水印**（文字、位置、大小、透明度、旋转角度均可调）
- **实时时钟**（顶部 + 水印内）
- **标题 / 直播状态**（顶部信息栏）
- **延迟估算**、静音、全屏等控制

### 快速使用

```powershell
# 1. 启动静态服务器（托管 watch.html）
.\start-watch-server.ps1          # 默认端口 8890

# 2. 浏览器打开（同一 WiFi / 热点下，手机也能看）
http://<电脑IP>:8890/watch.html?server=<电脑IP>:8889&path=livedji&wm=BunnyChen&title=DJI直播
```

### URL 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `server` | MediaMTX 地址（IP:端口） | `127.0.0.1:8889` |
| `path` | 流路径 | `livedji` |
| `title` | 顶部标题 | `DJI 直播` |
| `wm` | 水印文字 | `BunnyChen` |
| `wmpos` | 水印位置 `tl/tr/bl/br/c` | `br`（右下） |
| `wmsize` | 水印字号 | `48` |
| `wmopacity` | 水印透明度 `0~1` | `0.35` |
| `clock` | 显示时钟 `1/0` | `1` |

> 💡 页面右下角「⚙ 设置」面板可**实时调整**水印文字、位置、大小、透明度、旋转，
> 无需改 URL。设置仅保存在当前页面，刷新后恢复 URL 参数值。

> 💡 也可直接双击 `watch.html` 用浏览器打开（file:// 方式），
> 但仅本机可用；局域网共享需用上面的静态服务器方式。

### watch.html 完整源码

将以下内容保存为 `watch.html`（与 `mediamtx.exe` 同目录或任意目录均可）：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>DJI 直播监控</title>
<style>
  :root {
    --accent: #00e5a0;
    --danger: #ff5252;
    --bg: #0d1117;
    --panel: rgba(13, 17, 23, 0.72);
    --text: #e6edf3;
    --muted: #8b949e;
  }

  * { margin: 0; padding: 0; box-sizing: border-box; }

  html, body {
    width: 100%;
    height: 100%;
    overflow: hidden;
    background: var(--bg);
    font-family: "Segoe UI", "Microsoft YaHei", Arial, sans-serif;
    color: var(--text);
  }

  /* ---------- 视频 ---------- */
  #video {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    object-fit: contain;
    background: #000;
  }

  /* ---------- 顶部信息栏 ---------- */
  #topbar {
    position: absolute;
    top: 0; left: 0; right: 0;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    padding: 14px 18px;
    pointer-events: none;
    background: linear-gradient(180deg, rgba(0,0,0,.55), transparent);
  }
  #title-box { display: flex; align-items: center; gap: 10px; }
  #dot {
    width: 10px; height: 10px;
    border-radius: 50%;
    background: var(--danger);
    box-shadow: 0 0 8px var(--danger);
    animation: pulse 1.6s infinite;
  }
  #dot.live { background: var(--accent); box-shadow: 0 0 8px var(--accent); }
  @keyframes pulse { 0%,100% { opacity: 1; } 50% { opacity: .35; } }
  #title { font-size: 17px; font-weight: 600; letter-spacing: .5px; text-shadow: 0 1px 4px #000; }
  #subtitle { font-size: 12px; color: var(--muted); text-shadow: 0 1px 3px #000; margin-top: 2px; }

  #clock-box { text-align: right; text-shadow: 0 1px 4px #000; }
  #clock { font-size: 26px; font-weight: 700; font-variant-numeric: tabular-nums; }
  #date { font-size: 12px; color: var(--muted); }

  /* ---------- 水印 ---------- */
  #watermark {
    position: absolute;
    font-weight: 700;
    letter-spacing: 2px;
    color: #fff;
    text-shadow: 0 0 6px rgba(0,0,0,.8), 0 2px 4px rgba(0,0,0,.6);
    user-select: none;
    pointer-events: none;
    white-space: nowrap;
    opacity: .35;
  }
  #watermark .wm-time { display: block; font-size: .55em; font-weight: 400; letter-spacing: 1px; text-align: center; margin-top: 4px; opacity: .85; }

  /* ---------- 状态提示 ---------- */
  #status {
    position: absolute;
    left: 50%; top: 50%;
    transform: translate(-50%, -50%);
    text-align: center;
    color: var(--muted);
    font-size: 15px;
    pointer-events: none;
    display: none;
    text-shadow: 0 1px 4px #000;
  }
  #status .spinner {
    width: 34px; height: 34px;
    margin: 0 auto 14px;
    border: 3px solid rgba(255,255,255,.15);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }
  @keyframes spin { to { transform: rotate(360deg); } }

  /* ---------- 底部控制栏 ---------- */
  #controls {
    position: absolute;
    bottom: 0; left: 0; right: 0;
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px 16px;
    background: linear-gradient(0deg, rgba(0,0,0,.6), transparent);
    opacity: 0;
    transition: opacity .25s;
  }
  body:hover #controls { opacity: 1; }
  .btn {
    background: var(--panel);
    border: 1px solid rgba(255,255,255,.12);
    color: var(--text);
    border-radius: 8px;
    padding: 7px 14px;
    font-size: 13px;
    cursor: pointer;
    transition: background .15s, border-color .15s;
    user-select: none;
  }
  .btn:hover { background: rgba(255,255,255,.12); border-color: rgba(255,255,255,.3); }
  .btn.active { border-color: var(--accent); color: var(--accent); }
  #controls .spacer { flex: 1; }
  #latency { font-size: 12px; color: var(--muted); font-variant-numeric: tabular-nums; }

  /* ---------- 设置面板 ---------- */
  #settings {
    position: absolute;
    right: 16px; bottom: 60px;
    width: 300px;
    background: var(--panel);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255,255,255,.12);
    border-radius: 12px;
    padding: 16px;
    display: none;
    z-index: 10;
  }
  #settings.open { display: block; }
  #settings h3 { font-size: 14px; margin-bottom: 12px; color: var(--accent); }
  .field { margin-bottom: 12px; }
  .field label { display: block; font-size: 12px; color: var(--muted); margin-bottom: 4px; }
  .field input[type="text"], .field select {
    width: 100%;
    background: rgba(255,255,255,.06);
    border: 1px solid rgba(255,255,255,.15);
    color: var(--text);
    border-radius: 6px;
    padding: 6px 8px;
    font-size: 13px;
    outline: none;
  }
  .field input[type="text"]:focus, .field select:focus { border-color: var(--accent); }
  .field input[type="range"] { width: 100%; accent-color: var(--accent); }
  .field .row { display: flex; justify-content: space-between; font-size: 12px; color: var(--muted); }
  .field .row b { color: var(--text); font-variant-numeric: tabular-nums; }
  .btn-row { display: flex; gap: 8px; margin-top: 4px; }
  .btn-row .btn { flex: 1; }
</style>
</head>
<body>

<video id="video" autoplay playsinline></video>

<!-- 顶部信息栏 -->
<div id="topbar">
  <div id="title-box">
    <div id="dot"></div>
    <div>
      <div id="title">DJI 直播</div>
      <div id="subtitle">连接中…</div>
    </div>
  </div>
  <div id="clock-box">
    <div id="clock">--:--:--</div>
    <div id="date">----/--/--</div>
  </div>
</div>

<!-- 水印 -->
<div id="watermark">
  <span id="wm-text">BunnyChen</span>
  <span class="wm-time" id="wm-time"></span>
</div>

<!-- 状态提示 -->
<div id="status">
  <div class="spinner"></div>
  <div id="status-text">正在连接直播流…</div>
</div>

<!-- 底部控制栏 -->
<div id="controls">
  <button class="btn" id="btn-settings">⚙ 设置</button>
  <button class="btn" id="btn-mute">🔊 静音</button>
  <button class="btn" id="btn-fullscreen">⛶ 全屏</button>
  <div class="spacer"></div>
  <span id="latency"></span>
</div>

<!-- 设置面板 -->
<div id="settings">
  <h3>⚙ 显示设置</h3>
  <div class="field">
    <label>水印文字</label>
    <input type="text" id="set-wm-text" placeholder="BunnyChen">
  </div>
  <div class="field">
    <label>水印位置</label>
    <select id="set-wm-pos">
      <option value="tl">左上</option>
      <option value="tr">右上</option>
      <option value="bl">左下</option>
      <option value="br" selected>右下</option>
      <option value="c">居中</option>
    </select>
  </div>
  <div class="field">
    <div class="row"><span>水印大小</span><b id="val-size">48</b></div>
    <input type="range" id="set-wm-size" min="16" max="120" value="48">
  </div>
  <div class="field">
    <div class="row"><span>水印透明度</span><b id="val-opacity">35%</b></div>
    <input type="range" id="set-wm-opacity" min="5" max="100" value="35">
  </div>
  <div class="field">
    <div class="row"><span>水印旋转</span><b id="val-rotate">0°</b></div>
    <input type="range" id="set-wm-rotate" min="-45" max="45" value="0">
  </div>
  <div class="field">
    <label>显示时钟</label>
    <select id="set-clock">
      <option value="1" selected>显示</option>
      <option value="0">隐藏</option>
    </select>
  </div>
  <div class="btn-row">
    <button class="btn" id="btn-apply">应用</button>
    <button class="btn" id="btn-reset">重置</button>
  </div>
</div>

<script>
// ============================================================
// 参数解析（URL 查询参数）
//   server   MediaMTX 地址，默认 127.0.0.1:8889
//   path     流路径，默认 livedji
//   title    页面标题
//   wm       水印文字
//   wmpos    水印位置 tl/tr/bl/br/c
//   wmsize   水印字号
//   wmopacity 水印透明度 0-1
//   clock    是否显示时钟 1/0
// 示例：
//   watch.html?server=192.168.43.12:8889&path=livedji&wm=BunnyChen&wmpos=tl
// ============================================================
const params = new URLSearchParams(location.search);
const CFG = {
  server:   params.get('server')   || '127.0.0.1:8889',
  path:     params.get('path')     || 'livedji',
  title:    params.get('title')    || 'DJI 直播',
  wm:       params.get('wm')       || 'BunnyChen',
  wmpos:    params.get('wmpos')    || 'br',
  wmsize:   parseInt(params.get('wmsize') || '48', 10),
  wmopacity: parseFloat(params.get('wmopacity') || '0.35'),
  clock:    params.get('clock')    !== '0',
};

const video = document.getElementById('video');
const dot = document.getElementById('dot');
const titleEl = document.getElementById('title');
const subtitleEl = document.getElementById('subtitle');
const clockEl = document.getElementById('clock');
const dateEl = document.getElementById('date');
const wmEl = document.getElementById('watermark');
const wmTextEl = document.getElementById('wm-text');
const wmTimeEl = document.getElementById('wm-time');
const statusEl = document.getElementById('status');
const statusTextEl = document.getElementById('status-text');
const latencyEl = document.getElementById('latency');

titleEl.textContent = CFG.title;

// ---------- 时钟 ----------
function tickClock() {
  const now = new Date();
  const p = n => String(n).padStart(2, '0');
  clockEl.textContent = `${p(now.getHours())}:${p(now.getMinutes())}:${p(now.getSeconds())}`;
  dateEl.textContent = `${now.getFullYear()}/${p(now.getMonth()+1)}/${p(now.getDate())}`;
  wmTimeEl.textContent = `${p(now.getHours())}:${p(now.getMinutes())}:${p(now.getSeconds())}`;
}
tickClock();
setInterval(tickClock, 1000);

// ---------- 水印 ----------
const POS_MAP = {
  tl: { top: '70px',  left: '18px' },
  tr: { top: '70px',  right: '18px' },
  bl: { bottom: '60px', left: '18px' },
  br: { bottom: '60px', right: '18px' },
  c:  { top: '50%', left: '50%', transform: 'translate(-50%,-50%)' },
};
function applyWatermark() {
  wmTextEl.textContent = CFG.wm;
  wmEl.style.fontSize = CFG.wmsize + 'px';
  wmEl.style.opacity = CFG.wmopacity;
  const pos = POS_MAP[CFG.wmpos] || POS_MAP.br;
  Object.assign(wmEl.style, pos);
  wmEl.style.transform = pos.transform || `rotate(${CFG.wmRotate || 0}deg)`;
  wmEl.style.display = CFG.wm ? 'block' : 'none';
  clockEl.parentElement.style.display = CFG.clock ? 'block' : 'none';
}
CFG.wmRotate = 0;
applyWatermark();

// ---------- 状态 ----------
function setStatus(text, show) {
  statusTextEl.textContent = text;
  statusEl.style.display = show ? 'block' : 'none';
}
function setLive(live) {
  dot.classList.toggle('live', live);
  subtitleEl.textContent = live ? `● 直播中 · ${CFG.path}` : '连接中…';
}

// ---------- 加载 MediaMTX 播放器 ----------
function loadReader() {
  return new Promise((resolve, reject) => {
    if (window.MediaMTXWebRTCReader) return resolve();
    const s = document.createElement('script');
    s.src = `http://${CFG.server}/reader.js`;
    s.onload = () => resolve();
    s.onerror = () => reject(new Error('无法加载 reader.js，请检查 server 参数'));
    document.head.appendChild(s);
  });
}

let reader = null;
let lastTs = null;

async function connect() {
  setStatus('正在连接直播流…', true);
  setLive(false);
  if (reader) { try { reader.close(); } catch (e) {} reader = null; }

  try {
    await loadReader();
    reader = new MediaMTXWebRTCReader({
      url: `http://${CFG.server}/${CFG.path}/whep`,
      onError: (err) => {
        setStatus('连接失败：' + err, true);
        setLive(false);
      },
      onTrack: (evt) => {
        video.srcObject = evt.streams[0];
        setStatus('', false);
        setLive(true);
        lastTs = performance.now();
      },
    });
  } catch (err) {
    setStatus(err.message, true);
  }
}

// 延迟估算（基于视频时间戳）
video.addEventListener('timeupdate', () => {
  if (lastTs && video.currentTime > 0) {
    const drift = (performance.now() - lastTs) / 1000 - video.currentTime;
    latencyEl.textContent = `延迟 ≈ ${Math.max(0, drift).toFixed(1)}s`;
  }
});

// ---------- 控制栏 ----------
const btnMute = document.getElementById('btn-mute');
btnMute.addEventListener('click', () => {
  video.muted = !video.muted;
  btnMute.textContent = video.muted ? '🔇 取消静音' : '🔊 静音';
});

document.getElementById('btn-fullscreen').addEventListener('click', () => {
  if (document.fullscreenElement) document.exitFullscreen();
  else document.documentElement.requestFullscreen();
});

const settingsEl = document.getElementById('settings');
document.getElementById('btn-settings').addEventListener('click', () => {
  settingsEl.classList.toggle('open');
  if (settingsEl.classList.contains('open')) syncSettingsUI();
});

// ---------- 设置面板 ----------
const $ = id => document.getElementById(id);
function syncSettingsUI() {
  $('set-wm-text').value = CFG.wm;
  $('set-wm-pos').value = CFG.wmpos;
  $('set-wm-size').value = CFG.wmsize;
  $('val-size').textContent = CFG.wmsize;
  $('set-wm-opacity').value = Math.round(CFG.wmopacity * 100);
  $('val-opacity').textContent = Math.round(CFG.wmopacity * 100) + '%';
  $('set-wm-rotate').value = CFG.wmRotate;
  $('val-rotate').textContent = CFG.wmRotate + '°';
  $('set-clock').value = CFG.clock ? '1' : '0';
}
$('set-wm-size').addEventListener('input', e => $('val-size').textContent = e.target.value);
$('set-wm-opacity').addEventListener('input', e => $('val-opacity').textContent = e.target.value + '%');
$('set-wm-rotate').addEventListener('input', e => $('val-rotate').textContent = e.target.value + '°');

$('btn-apply').addEventListener('click', () => {
  CFG.wm = $('set-wm-text').value.trim();
  CFG.wmpos = $('set-wm-pos').value;
  CFG.wmsize = parseInt($('set-wm-size').value, 10);
  CFG.wmopacity = parseInt($('set-wm-opacity').value, 10) / 100;
  CFG.wmRotate = parseInt($('set-wm-rotate').value, 10);
  CFG.clock = $('set-clock').value === '1';
  applyWatermark();
  settingsEl.classList.remove('open');
});
$('btn-reset').addEventListener('click', () => {
  CFG.wm = 'BunnyChen'; CFG.wmpos = 'br'; CFG.wmsize = 48;
  CFG.wmopacity = 0.35; CFG.wmRotate = 0; CFG.clock = true;
  applyWatermark(); syncSettingsUI();
});

// 点击视频切换控制栏
video.addEventListener('click', () => {
  document.getElementById('controls').style.opacity = 1;
  setTimeout(() => { document.getElementById('controls').style.opacity = 0; }, 2500);
});

// ---------- 启动 ----------
connect();
</script>
</body>
</html>
```

---

## 七、常见问题与排查

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

- VLC 加低延迟参数（见「本地观看」章节②）。
- 换用 **WebRTC** 观看（延迟最低）。
- 大疆侧降低图传清晰度/码率。

---

## 八、关键结论回顾

1. MediaMTX 默认配置（`authMethod: internal` + `any` 用户）即可匿名接收推流，无需额外权限配置。
2. 大疆实际推流路径可能是 `livedji`（无斜杠），一切以 **MediaMTX 日志中的 path** 为准。
3. 若只有音频没有视频 → 检查无人机起飞/相机激活状态，及 DJI 端编码（建议 H.264）。
4. 观看延迟：**WebRTC < RTMP < HLS**。
