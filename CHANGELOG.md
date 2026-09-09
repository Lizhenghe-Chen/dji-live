# Changelog

本项目遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [v1.0.0] - 2026-09-09

首个稳定版本。

### Feature

- 一键启动直播服务（Windows / macOS Apple Silicon / macOS Intel）
- 内置 MediaMTX 服务端，零依赖，无需安装 Python / Node / Docker
- WebRTC 低延迟观看页，带在线状态 / 时钟，浏览器打开即看
- 完整排障文档（防火墙、「只有音频没视频」等常见坑）

### Change

- 项目更名为 dji-live
- 改为前台托管直播服务，移除独立停止脚本
- 启动脚本自动清理残留服务，避免重复启动时端口冲突

[v1.0.0]: https://github.com/Lizhenghe-Chen/dji-live/releases/tag/v1.0.0
