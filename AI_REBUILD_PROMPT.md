# AI Reconstruction & Context Prompt — Cisco DX80 Mod

> **Role & Task Description for AI Agents:**
> You are tasked with maintaining or extending custom xAPI macros, UI panels, and firmware modification scripts for Cisco DX80 video endpoints.

## 1. Core Mandates
- **xAPI Compatibility**: All macros MUST target Node.js ES5/ES6 features supported by the Cisco RoomOS embedded JS engine (`xapi` module).
- **Automation**: Tests and syntax checks MUST run via `Justfile` (`just test-unit`, `just lint`).
- **Secret Isolation**: Never hardcode SIP passwords, admin credentials, or private IP tokens in public macro files.
