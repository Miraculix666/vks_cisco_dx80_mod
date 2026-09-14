# Cisco DX80 Firmware & Macro Mods — Help & Operations Guide

## Overview

The `vks_cisco_dx80_mod` repository provides custom xAPI JavaScript macros, UI extensions (XML), and Android OS / free operating system migration utilities for the Cisco DX80 endpoint.

---

## Macro Overview

| Macro Script | Description |
| :--- | :--- |
| `MeetingShortcuts.js` | One-touch meeting quick-dial buttons on the Cisco Touch 10 / DX80 screen. |
| `SystemMonitor.js` | Monitors CPU/Memory load, SIP registration, and camera link state. |
| `UsbWebcamPersistent.js` | Ensures external USB camera passthrough remains active across reboots. |

---

## Justfile Command Reference

```bash
# Display available automation recipes
just

# Run Node.js unit tests for xAPI macros
just test-unit

# Check JS macro syntax
just lint

# Check metafile completeness
just docs-audit
```
