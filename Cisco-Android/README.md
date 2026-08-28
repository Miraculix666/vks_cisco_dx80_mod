# Cisco-Android 🤖

Focuses on downgrading the Cisco DX80 from CE firmware back to the last available Cisco Android-based firmware.

## Why Downgrade?
- Access to native Android apps (Teams, Zoom, etc.).
- More flexible OS environment for certain use cases.
- Foundation for further Android-based modding.

## Contents
- `Rescue-DX80.ps1`: Initial recovery script.
- `Rescue-DX80-V2.ps1`: Enhanced recovery and downgrade automation.

## Procedure
> [!WARNING]
> Downgrading firmware can be risky. Ensure you have a stable network connection and serial console access for monitoring.

1. Prepare the Android firmware image (not included in this repo).
2. Use the provided PowerShell scripts to trigger the TFTP/HTTP boot process.
3. Monitor progress via the serial console (see `docs/Serial-Console-Guide.md`).

---
*Part of the [Cisco DX80 Project](../README.md)*
