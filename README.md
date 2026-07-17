# nvm-desk

#### 介绍
NVM 的图形桌面壳，双击换版本，零依赖拿走即用

# nvm-desk

> A minimal GUI wrapper for NVM-Windows — view, list, and switch Node.js versions at a glance.

## Why

`nvm use <version>` is easy to forget when you only touch Node.js once in a while. nvm-desk gives you a single window: all installed versions in one list, the current one highlighted, and a one-click switch button. No terminal, no memorizing commands.

## Features

- **Zero dependencies** — built with PowerShell + Windows Forms, runs on Windows out of the box
- **Single executable** — icon embedded, double-click and go; no installation
- **Portable** — the entire folder can be copied, shared, or put on a USB stick; works anywhere
- **One-click switch** — pick a version, click, confirm UAC, done
- **Lightweight** — ~24 KB exe

## Quick Start

1. Download the latest `nvm-desk.zip` from [Releases]((https://github.com/MY0279/nvm-desk.git))
2. Extract to anywhere
3. Double-click `nvm-desk.exe`

> Requires [NVM-Windows](https://github.com/coreybutler/nvm-windows) installed and configured.

## Screenshot

> (add a screenshot here)

## Folder Structure

```
nvm-desk/
├── nvm-desk.exe       # Launcher (embedded icon, relative path)
├── nvm_manager.ps1    # GUI script
└── nvm_icon.ico       # Icon source
```

## Disclaimer

**For learning purposes only.** This is a personal project built to explore PowerShell GUI programming.

## Author
rrfhecong@163.com

