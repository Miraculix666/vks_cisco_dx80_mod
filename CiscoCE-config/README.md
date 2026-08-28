# CiscoCE-config 🛠️

This sub-project focuses on "unchaining" the Cisco DX80 running CE firmware (9.15+) and turning it into a modern, dual-purpose collaboration workstation.

## Features

- **SIP Ready**: Optimized settings for Sipgate, Telekom, and Fritzbox integration.
- **Microservice Shortcuts**: Custom UI buttons for **Microsoft Teams** and **Zoom** via the internal Web Engine.
- **Web Browser Unlocked**: URL bar enabled for unrestricted web navigation.
- **Advanced UI**: Global Dark Mode, Proximity (Wireless Sharing), and Standby optimizations.
- **Macros**: Custom JavaScript logic for UI interaction, system monitoring, and persistent USB camera access.

## Contents

- `Deploy-DX80-Final.ps1`: Unified deployment script for all CE configurations.
- `Push-*.ps1`: Modular scripts for specific features (SIP, Dark Theme, etc.).
- `*.js`: JavaScript macros for device automation.
- `DX80_Config.xml`: Base configuration template.

## Installation

1. Set your credentials using `Set-DX80Credentials.ps1`.
2. Run `Deploy-DX80-Final.ps1` to apply the full configuration suite.
3. Check `docs/WALKTHROUGH.md` for a visual guide.

---
*Part of the [Cisco DX80 Project](../README.md)*
