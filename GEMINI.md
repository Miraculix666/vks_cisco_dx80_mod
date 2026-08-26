# 🤖 Agent Directives & Repository Matrix (Antigravity & Jules)

Welcome AI Agent (Antigravity, Jules, Claude Code, Gemini CLI, Hermes, OpenJarvis).
This file defines the mandatory architecture, repository cross-references, and placement boundaries for `C:\GitHub\`.

---

## 🧭 Navigation & Cross-Reference Map
Always refer to [REPOSITORY_MAP.md](file:///C:/GitHub/REPOSITORY_MAP.md) and [agents_and_prompts/SYSTEM_WIDE_STANDARD.md](file:///C:/GitHub/agents_and_prompts/SYSTEM_WIDE_STANDARD.md) for complete rules.

### 📌 Quick Boundary Rules
1. **Core vs Config Separation**:
   * **`*_core` / `*_infra` / `*_packages`**: Put ONLY reusable code, scripts, Docker/LXC templates. NEVER hardcode live IPs, private passwords, domain tokens, or user secrets.
   * **`*_config`**: Put live host configurations (`/hosts/{hostname}_config.yaml`), private tokens, and GitOps parameters here.
   * **`*_backup*`**: READ-ONLY. Never mutate backup repositories.
2. **Public vs. Police/Internal Sysadmin**:
   * Put generic, open-source-safe tools in [`scripts-and-tools`](file:///C:/GitHub/scripts-and-tools).
   * Put police-specific, internal AD management tools (L-Kennung, FINDUS, IGVP) in [`scripts-and-tools-pol`](file:///C:/GitHub/scripts-and-tools-pol).
3. **Workspace Groups**:
   * Homelab, Home Assistant & LLM: [`ha-stack.code-workspace`](file:///C:/GitHub/ha-stack.code-workspace)
   * School Deployment & OPSI: [`opsi-stack.code-workspace`](file:///C:/GitHub/opsi-stack.code-workspace)
   * Kiosk & Cisco Video: [`vks.code-workspace`](file:///C:/GitHub/vks.code-workspace)
   * SysAdmin Tools: [`scripts-and-tools.code-workspace`](file:///C:/GitHub/scripts-and-tools.code-workspace)
   * Master (All Repos): [`all.code-workspace`](file:///C:/GitHub/all.code-workspace)

---

## 🔗 Key Cross-References by Domain
* **LLM Stack:** [`llm_stack_core`](file:///C:/GitHub/llm_stack_core) ⟷ [`llm_stack_config`](file:///C:/GitHub/llm_stack_config) ⟷ [`llm_stack_backup`](file:///C:/GitHub/llm_stack_backup)
* **Home Assistant:** [`ha_core`](file:///C:/GitHub/ha_core) ⟷ [`ha_config`](file:///C:/GitHub/ha_config) ⟷ [`ha_extensions`](file:///C:/GitHub/ha_extensions)
* **OPSI:** [`opsi_scripts`](file:///C:/GitHub/opsi_scripts) ⟷ [`opsi_packages`](file:///C:/GitHub/opsi_packages) ⟷ [`opsi_config`](file:///C:/GitHub/opsi_config) ⟷ [`opsi_infra`](file:///C:/GitHub/opsi_infra)
* **Cisco/Kiosk:** [`vks_kiosk`](file:///C:/GitHub/vks_kiosk) ⟷ [`vks_cisco_dx80_mod`](file:///C:/GitHub/vks_cisco_dx80_mod) ⟷ [`vks_cisco_dx80_base`](file:///C:/GitHub/vks_cisco_dx80_base)
* **SysAdmin:** [`configs`](file:///C:/GitHub/configs) ⟷ [`scripts-and-tools`](file:///C:/GitHub/scripts-and-tools) ⟷ [`scripts-and-tools-pol`](file:///C:/GitHub/scripts-and-tools-pol)


