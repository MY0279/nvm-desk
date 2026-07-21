# nvm-desk

> A minimal GUI wrapper for NVM-Windows — switch, install, and manage Node.js versions without opening a terminal.

## Why

`nvm use <version>` is easy to forget when you only touch Node.js once in a while. nvm-desk gives you a clean window with two tabs: all your installed versions with one-click switch/delete, plus a live catalog of every Node.js release you can install. No terminal, no memorizing commands.

## Features

- **Two-tab layout** — Installed versions with Switch & Delete; Available Online with one-click Install
- **Auto mirror** — reads `node_mirror` from nvm's `settings.txt`, works out of the box with npmmirror
- **Resizable window** — drag edges or maximize, layout adapts via anchor-based scaling
- **Portable** — just `nvm-desk.exe` + `nvm_manager.ps1`, copy the folder anywhere and run
- **Zero dependencies** — built with PowerShell + Windows Forms, ships with Windows
- **Lightweight** — ~24 KB exe + 24 KB script

## Quick Start

1. Download the latest `nvm-desk.zip` from [Releases](https://gitee.com/code-ape-hc/nvm-desk/releases)
2. Extract to anywhere
3. Double-click `nvm-desk.exe`

> Requires [NVM-Windows](https://github.com/coreybutler/nvm-windows) installed and configured.

## Screenshot

<img width="1144" height="1132" alt="0331c453f35b6c33c4618a08fa155cc5" src="https://github.com/user-attachments/assets/0d7d1fe5-4053-41e3-b8d7-b9d05925dbe8" />
<img width="1378" height="1180" alt="f62f77a646fd4ca1faabcaa90cf767d1" src="https://github.com/user-attachments/assets/b3b2673b-fa6d-4978-9895-9b14b97c39cf" />


## Folder Structure

```
nvm-desk/
├── nvm-desk.exe       # C# launcher (relative path to nvm_manager.ps1)
├── nvm_manager.ps1    # GUI script (PowerShell + Windows Forms)
└── nvm_icon.ico       # Icon source (embedded into exe at build time)
```

## Disclaimer

**For learning purposes only.** This is a personal project built to explore PowerShell GUI programming.

## Author
rrfhecong@163.com
