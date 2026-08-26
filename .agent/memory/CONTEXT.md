# 🧠 Project Context

> **FILE:** `.agent/memory/CONTEXT.md`
> **PURPOSE:** Live, running context of project state — updated every agent session
> **DEPENDS ON:** `MASTER_INSTRUCTIONS.md`
> **DEPENDED ON BY:** All agents on session start
> **LAST MODIFIED:** See git log
> **FORMAT:** Newest entries at top. Update, don't just append.

---

## 📊 Current Project State

| Field | Value |
|---|---|
| **Project Version** | 1.0.0 |
| **Active Branch** | `dev` |
| **Last Release** | v1.0.0 — Initial framework |
| **Current Sprint/Focus** | Framework initialisation |
| **Open Issues** | None |
| **Pending PRs** | None |
| **Dump Inbox Status** | 🟢 Empty |
| **Health Check Status** | 🟢 All systems nominal |
| **Sessions Since Last Consolidation Review** | 0 |
| **Next Consolidation Review Due** | After session 5 |

---

## 🏃 Active Agent Sessions

| Agent ID | Role | Branch | Files | Started | Last Ping |
|---|---|---|---|---|---|

*Update this table on session start and end.*

---

## 📋 Recent Work Log

> Summarise what was done in each session. Newest first.

### 2026-06-16 — repo-cleanup-scrub
- ✅ Reorganized general scripts in `Skripts-and-tools` under category folders (AD, System, User, Network) and resolved naming to PascalCase.
- ✅ Cleaned up all root duplicates in `scripts-and-tools-pol` and moved obsolete `setup.ps1` to `archive/`.
- ✅ Consolidated L-Kennung query scripts into `Get-LKennungUser.ps1`.
- ✅ Consolidated L-Kennung report/table scripts into `New-LKennungReport.ps1`.
- ✅ Consolidated DNS setup and repair scripts into `Setup-DnsServer.ps1`.
- ✅ Moved `win11-hardening` to `Skripts-and-tools` and established a Windows Directory Junction back in `opsi_scripts`.
- ✅ Extracted and migrated `extract_opsi.ps1` to `opsi_scripts\tools\Extract-OpsiData.ps1`.
- ✅ Implemented `Import-Environment.ps1` config loader and `environment.json.example` configuration template.
- ✅ Systematically scrubbed all AI/agent references and `Miraculix666` usernames, replacing them with standard systems administration headers.
- ✅ Generated `README.md` and `CHANGELOG.md` files at the root level and in all category subdirectories for all three repositories.
- ✅ Ran full syntax audits and verified directory junctions and JSON credentials loader functionality.

### 2026-02-23 — system-init
- ✅ Framework scaffolding created
- ✅ All core `.agent/` files generated
- ✅ Hard locks registered for governance files
- ✅ CI workflows created
- ✅ Scripts created
- ✅ Documentation structure established
- ✅ Initial `release` and `dev` branch strategy defined
- 🔵 Next: Human review of MASTER_INSTRUCTIONS.md, then first feature work

---

## 🎯 Current Objectives

1. 🔵 Human review and approval of initial framework
2. ⚪ First real project code to be scaffolded under `src/`
3. ⚪ CI pipeline validated against real repository
4. ⚪ First `dev → release` PR executed

---

## ⚠️ Known Issues / Blockers

*None at this time.*

---

## 📝 How to Update This File

On session start, add your agent to the Active Sessions table.
On session end:
1. Remove from Active Sessions
2. Add summary to Recent Work Log
3. Update Current Project State fields as needed
4. Update Current Objectives if completed

---

*This file is the living heartbeat of the project. Keep it accurate.*

## 2026-07-12
- Added optional counter entity input to Tibber automations (`tibber_smart_device.yaml`, `tibber_pool_pump.yaml`, `tibber_pool_pump_emergency.yaml`).
## 2026-07-04
- Addressed issue with tibber price fetching automation and related scripts.
- Updated `tibber_smart_device.yaml` to use modern `action:` syntax.
- Updated `universal_notification.yaml` to use modern `notify.send_message` action instead of deprecated `notify.*` services.
- Removed hardcoded personal device entity_id `notify.mobile_app_marius_mi_15t_pro` from `blueprints/scripts/universal_notification.yaml`.

