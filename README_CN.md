# nvm-desk

> 一个极简的 NVM-Windows 图形界面工具 — 不用开终端，就能切换、安装、管理 Node.js 版本。

## 为什么做这个

偶尔碰一下 Node.js 的时候，`nvm use <version>` 这条命令总得现查。nvm-desk 给你一个清爽的双标签窗口：已安装的版本一键切换/删除，还能在线浏览所有 Node.js 发行版并一键安装。告别终端，告别死记命令。

## 功能

- **双标签布局** — 已安装版本（切换 & 删除）+ 在线版本（一键安装）
- **自动镜像** — 读取 nvm `settings.txt` 中的 `node_mirror`，国内 npmmirror 开箱即用
- **窗口可缩放** — 拖拽边缘或最大化，布局通过 Anchor 自适应
- **便携** — 仅 `nvm-desk.exe` + `nvm_manager.ps1` 两个文件，拷到哪都能跑
- **零依赖** — 基于 PowerShell + Windows Forms，Windows 自带，无需安装任何运行时
- **轻量** — exe ~24 KB + 脚本 ~24 KB

## 快速开始

1. 从 [Releases](https://gitee.com/code-ape-hc/nvm-desk/releases) 下载最新 `nvm-desk.zip`
2. 解压到任意目录
3. 双击 `nvm-desk.exe`

> 需要已安装并配置 [NVM-Windows](https://github.com/coreybutler/nvm-windows)。

## 截图

>（在此处添加截图）

## 目录结构

```
nvm-desk/
├── nvm-desk.exe       # C# 启动器（相对路径调用 nvm_manager.ps1）
├── nvm_manager.ps1    # GUI 脚本（PowerShell + Windows Forms）
└── nvm_icon.ico       # 图标源文件（构建时嵌入 exe）
```

## 声明

**仅供学习交流。** 这是个人为探索 PowerShell GUI 编程而构建的项目。

## 作者
rrfhecong@163.com
