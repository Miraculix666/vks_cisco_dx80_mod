# âš¡ MASTER INSTRUCTIONS â€” Universal Agent Framework

> **âš ï¸ MANDATORY READ:** Any agent, LLM, or automated system MUST read this file completely
> before performing ANY action in this repository. This file is the multi-agent startup protocol.
> For full agent identity, rules, and code standards, see [`Agent.md`](Agent.md).

---

## ðŸ“‹ Meta

| Field | Value |
|---|---|
| **Version** | 2.1.0 |
| **Last Updated** | 2026-03-02 |
| **Maintained By** | All agents (auto-update required on each session) |
| **Branch** | Applies to ALL branches |
| **Compatibility** | Any LLM / agent system (language-agnostic instructions) |

---

## ðŸŽ¯ Framework Mission

This framework provides a **universal, language-agnostic, multi-agent-ready project scaffold** that:

- Works with any agent system or LLM (no vendor lock-in)
- Enforces consistent documentation, locking, and version control
- Provides reusable prompt patterns (see [`config/prompts.config.md`](config/prompts.config.md))
- Supports safe concurrent multi-agent collaboration
- Maintains full auditability and rollback capability via Git

---

## ðŸ”— Workspace Integration & Deployment

- **No Repository Crossing Links:** Repositories must remain completely independent. Do not use directory junctions or symbolic links to share code, scripts, or configurations between repositories.
- **Auto-Clone neuer Repos:** Sobald ein neues Repository remote erstellt wurde, soll es umgehend lokal geklont werden, damit die lokale Workspace-Struktur lÃ¼ckenlos bleibt.
- **Workspace-Dateien:** Jedes Repository MUSS in den globalen Workspace `all.code-workspace` inkludiert sein und zudem Ã¼ber einen eigenen dedizierten Workspace (z.B. `<RepoName>.code-workspace` im zentralen Verzeichnis) verfÃ¼gen.

---

## ðŸ“‚ Repository-Level Split Standard

DU AGIERST AB SOFORT STRENG NACH DEM DEZENTRALEN REPOSITORY-SPLIT-STANDARD UND DER NEUEN ORDNERSTRUKTUR UND NAMENSGEBUNG!

ÃœberprÃ¼fe und beachte fÃ¼r alle Arbeiten an diesem System folgende unumstÃ¶ÃŸliche Kernregeln:

### 1. Repository-Level Split (Sicherheit & Open-Source-Capability)
Kein Code- oder Grundsystem-Repository darf sensible Konfigurationen, IP-Adressen, PasswÃ¶rter oder Hosts-Daten enthalten!
Jede DomÃ¤ne ist in ZWEI bis DREI getrennte Repositories unterteilt:
- **core / infra / ui / app**: Beinhaltet AUSSCHLIESSLICH den Quellcode, Templates, Docker/LXC-Setups und Skripte (VollstÃ¤ndig teilbar/Open-Source).
- **config**: Beinhaltet AUSSCHLIESSLICH die privaten Einstellungen (Unterteilt in `/global` fÃ¼r systemweite Standards und `/hosts` fÃ¼r spezifische Maschinen/IPs).
- **backup**: Beinhaltet AUSSCHLIESSLICH historische Datenbank-Dumps, System-Snapshots und Archive.

### 2. Agenten & Prompts Trennung
Das Repository `agents_and_prompts` beinhaltet AUSSCHLIESSLICH die systemweiten Standards (`SYSTEM_WIDE_STANDARD.md`), AusfÃ¼hrungs-Direktiven (`JULES_EXECUTION_DIRECTIVE.md`), Prompt-Templates und Verhaltensregeln der Agenten. Es enthÃ¤lt KEINE Host- oder Infrastruktur-Configs!

### 3. Repo-Namensschema & DomÃ¤nen
- **LLM Stack**: `llm_stack_core`, `llm_stack_config`, `llm_stack_backup`
- **Home Assistant**: `ha_core`, `ha_config`, `ha_backup_full`, `ha_backup`, `ha_extensions`
- **Infrastructure**: `homelab_infra`, `homelab_config`, `homelab_backup`
- **Agents & Prompts**: `agents_and_prompts`

### 4. Anweisung
FÃ¼hre alle KonfigurationsÃ¤nderungen, Code-Refactorings und Pushes ausschlieÃŸlich unter Einhaltung dieses Schemas durch. Speichere maschinenspezifische Daten NIEMALS im core/infra Repo, sondern immer im jeweiligen config Repo unter `/hosts/<hostname>_config.yaml`!

---

## ðŸ—ï¸ Mandatory File Dependency Map

> Every agent MUST understand and respect these dependencies.
> When modifying any file, ALL dependent files must be updated in the SAME commit.

```
MASTER_INSTRUCTIONS.md
    â””â”€â”€ Depends on / Must stay in sync with:
        â”œâ”€â”€ memory/CONTEXT.md              (current state)
        â”œâ”€â”€ memory/DECISIONS.md            (architecture choices)
        â”œâ”€â”€ locks/.locked                  (lock state)
        â”œâ”€â”€ docs/CHANGELOG.md             (every change logged)
        â”œâ”€â”€ docs/DEPENDENCIES.md          (when deps change)
        â”œâ”€â”€ docs/TESTS.md                 (when tests change)
        â””â”€â”€ docs/SOURCES.md              (when references added)

Source Code Files
    â””â”€â”€ Must trigger updates to:
        â”œâ”€â”€ docs/CHANGELOG.md             (ALWAYS)
        â”œâ”€â”€ docs/DEPENDENCIES.md          (if deps changed)
        â”œâ”€â”€ docs/TESTS.md                 (if tests changed)
        â”œâ”€â”€ File headers/comments         (ALWAYS - keep in sync)
        â””â”€â”€ memory/CONTEXT.md             (ALWAYS)
```

---

## ðŸ”„ Agent Session Protocol

### Step 1 â€” Orientation (ALWAYS FIRST)
```
1. Read Agent.md                          â†’ Identity, rules, code standards
2. Read this file (MASTER_INSTRUCTIONS.md) â†’ Startup protocol & dependencies
3. Read memory/CONTEXT.md                 â†’ Current project state
4. Read locks/.locked                     â†’ Check for active locks
5. Read memory/DECISIONS.md              â†’ Understand past choices
6. Identify your role from roles/roles.md
```

### Step 2 â€” Lock Check
```
IF .locked contains entries:
    IF your target files are listed â†’ STOP, execute HANDOVER protocol
    IF your target files are NOT listed â†’ proceed, register your lock
ELSE:
    Proceed and register your lock before writing
```

> ðŸ“– Full locking rules: [`config/locking.config.md`](config/locking.config.md)
> ðŸ“– Handover protocol: [`locks/HANDOVER.md`](locks/HANDOVER.md)

### Step 3 â€” Work
```
- Work in correct branch (NEVER write directly to `release`)
- Update file headers/comments in every file you touch
- Log decisions in memory/DECISIONS.md
- Keep changes atomic (one logical unit per commit)
```

> ðŸ“– Branch strategy: [`config/branches.config.md`](config/branches.config.md)
> ðŸ“– Code standards: [`Agent.md`](Agent.md) Â§6

### Step 4 â€” Close Session
```
1. Update docs/CHANGELOG.md
2. Update docs/DEPENDENCIES.md (if changed)
3. Update docs/TESTS.md (if changed)
4. Update memory/CONTEXT.md
5. Release your locks in locks/.locked
6. Append to locks/LOCK_REGISTRY.md
7. Commit with semantic message (see config/branches.config.md)
```

---

## ðŸ“ File Header Standard

Every source file MUST contain a header with this information:

```
# FILE: <filename>
# PURPOSE: <one-line description>
# DEPENDS ON: <list of files this depends on>
# DEPENDED ON BY: <list of files that depend on this>
# LAST MODIFIED: <ISO8601 date>
# MODIFIED BY: <agent-id or human>
# CHANGE SUMMARY: <what changed and why>
# BRANCH: <which branch this applies to>
```

For code files, use appropriate comment syntax:
```python
# FILE: module.py | PURPOSE: ... | DEPENDS ON: config.py | ...
```
```javascript
// FILE: service.js | PURPOSE: ... | DEPENDS ON: db.js | ...
```

---

## ðŸ”„ Periodic Optimisation Protocol

Every **5 agent sessions** OR on explicit request, run:
```
1. Review entire project structure for consolidation opportunities
2. Check for duplicate logic, redundant files
3. Audit dependencies (docs/DEPENDENCIES.md)
4. Propose consolidations to human before executing
5. Document changes in docs/CHANGELOG.md
```

---

## âš™ï¸ Environment Data & Secrets Management

- **Centralized Environment Configs (MANDATORY):** Alle umgebungsspezifischen Konfigurationen (wie URLs, Pfade, Hostnamen, Credentials) MÃœSSEN zwingend in einer zentralen Datei gesammelt werden.
- **Unified Naming & Format:** Die Benennung dieser Datei muss Ã¼ber alle Repositories hinweg einheitlich sein. Als Standard wird `environment.json` (mit Pseudo-Kommentaren) oder `environment.yaml` / `.env` festgelegt.
- **Self-Documenting Comments:** In der Konfigurationsdatei (oder einer zugehÃ¶rigen `.example`-Datei) MUSS im Zeilenkommentar immer genug Information stehen, um die Datei direkt ausfÃ¼llen zu kÃ¶nnen. Dies umfasst:
  - Beispielwerte & Defaults
  - Dummy-Daten
  - Klare Anforderungen (z.B. "Das Passwort muss mindestens 8 Zeichen lang sein und Sonderzeichen enthalten")
- **Separation of Code & Config:** Skripte mÃ¼ssen immer so geschrieben werden, dass das eigentliche Skript verÃ¶ffentlicht werden kann ("publishable") und **keine privaten Daten** enthÃ¤lt.
- **Secure Storage (Settings):** Wenn spezifische Einstellungen getroffen werden (Client, Dienstname, Configs), mÃ¼ssen diese sicher, sortiert und getrennt gespeichert werden, sodass Skripte und Einstellungen wiederverwendet werden kÃ¶nnen.
- **Environment Inheritance:** Daten zum Environment mÃ¼ssen immer sicher passend abgespeichert werden und vererben sich automatisch auf die Unterordner.

---

## ðŸ—‘ï¸ Dump- & WIP-Folder und Data Consolidation

- **ðŸ—‘ï¸ Dump-Folder (`dump/`):** Jedes Repository besitzt einen dedizierten Dump-Ordner, in dem Daten temporÃ¤r abgelegt werden kÃ¶nnen.
  - **TÃ¤gliche Kontrolle:** Der Ordner wird 1x am Tag kontrolliert.
  - **Einsortierung:** Daten werden, wenn nÃ¶tig nach RÃ¼ckfrage, passend einsortiert.

- **ðŸš§ WIP-Folder (`WIP/`):** Jedes Repository besitzt immer einen WIP-Ordner (vergleichbar mit einem Playground), um unfertige Sachen schnell zwischenzuspeichern.
  - **Monatliche ÃœberprÃ¼fung:** Dieser Ordner wird 1x im Monat (wie das gesamte Repo) Ã¼berprÃ¼ft und aufgerÃ¤umt/konsolidiert.

- **Konsolidierungs-PrÃ¼fung:** Der Agent prÃ¼ft bei den Bereinigungen, ob explizit eine Konsolidierung sinnvoll ist (z. B. bei verschiedenen Test-Versionen, anderen AnsÃ¤tzen oder Ãœberschneidungen mit Scripts/Configs anderer Projekten).
  - **Historien-Wiederherstellung:** Werden beim AufrÃ¤umen verschiedene Versionen einer Datei gefunden, MUSS der Agent versuchen, den zeitlichen Verlauf bzw. die Historie wiederherzustellen und diese konform und konsistent im Git zu speichern (z. B. durch sequenzielle Commits der Versionen).
- **Scope:** Der Prozess kann fÃ¼r das einzelne Repo oder fÃ¼r alle Repos im Workspace ausgelÃ¶st werden.

---

## ðŸ§ª Automated Testing Standard (High-Fidelity Mock & Integration Testing)

Every repository and component MUST implement a rigorous, automated, non-elevated, and high-fidelity testing process that adheres to the following principles:

### 1. Separate Script-Driven Test Runner
- Create a dedicated test runner script (e.g., `tests/Run-FullTestSuite.ps1` or `tests/test_runner.py`) in the `tests/` directory.
- The test runner must execute fully unattended (non-interactive) without requiring human input or blocking the console.

### 2. High-Fidelity Test Environment Mocking
- **No-Privilege Mode Support:** Provide a clean mock-bypass toggle (e.g., `$global:BypassAdminCheck` or `$env:BYPASS_ADMIN_CHECK`) to safely bypass any required Administrator or system elevation checks.
- **Unattended Console Detection:** Ensure all interactive prompts, confirmation checks (e.g., "J/N" menus), and GUI prompts are bypassed under test/automation mode (e.g., overriding raw interactive console checks).
- **Mocking System/Network Actions:** Instead of failing on remote system calls, Active Directory pings, or SMTP transports, intercept them under test bypass mode to output realistic success logs and simulated return states.

### 3. Step-by-Step Function & Scenario Coverage
- **Step-by-Step Function Testing:** Separately verify each independent module, function, and parameter set of the codebase.
- **Dynamic Log Verification (`GenerateFromLog`):** Test the full roundtrip of state changes by ensuring outputs of a provisioning step are dynamically parsed and fed into downstream query/replay steps (e.g., re-running from logs).
- **Component and Standalone Testing:** Add tests for all supplementary templates, dashboards, and CLI session launchers (both dry-run summaries and connectivity-only modes).

### 4. Dummy/Local Data Requirements
- **Always Online Test Targets:** Use dummy/local test targets (e.g., `127.0.0.1` and `localhost` in `Clients_Test.csv`) for connection validation to ensure they are always online and reachable.
- **Controlled Test Dataset:** Maintain a representative dummy CSV/data set (e.g., `Users_Test_5.csv` representing participants, teachers, and admins) to exercise all branches.

### 5. Strict Error Catching and Validation
- **Exit Code Verification:** Ensure that non-zero exit codes or script exit statuses (`$LASTEXITCODE`) are intercepted inside the test block and thrown as terminating errors so that failures are caught.

---

## ðŸ”– Version Management & Auto-Commit Protocol

### Pflege von `version.json` und `package.json`

Der Agent ist verantwortlich fÃ¼r die AktualitÃ¤t der Versionsdateien in jedem Workspace:

```
- version.json  â†’ enthÃ¤lt { "version": "<semver>", "updated": "<ISO8601>" }
- package.json  â†’ "version"-Feld muss mit version.json Ã¼bereinstimmen
```

Bei jeder inhaltlichen Ã„nderung am Code:
1. Semver erhÃ¶hen (patch / minor / major je nach Ã„nderungstiefe)
2. Beide Dateien atomar aktualisieren
3. `Last Updated`-Felder in Datei-Headern und `MASTER_INSTRUCTIONS.md` Â§ Meta anpassen

### Trigger â€” Wann wird automatisch committed?

Der Agent Ã¼berwacht den aktiven Workspace kontinuierlich. Ein **Auto-Commit** wird ausgelÃ¶st, wenn **eines** der folgenden Ereignisse eintritt:

| Ereignis | Beschreibung |
|---|---|
| **Task erledigt** | Ein Checklist-Item wird in einer `task.md` oder `CONTEXT.md` auf `[x]` gesetzt |
| **version.json geÃ¤ndert** | Der `version`-Wert wurde erhÃ¶ht |
| **package.json geÃ¤ndert** | Das `version`-Feld wurde geÃ¤ndert |
| **Explizite Anforderung** | Nutzer fordert einen Commit an |

### Auto-Commit-Ablauf

```
1. Diff analysieren   â†’ git diff --staged oder alle ungestagten Ã„nderungen prÃ¼fen
2. Commit-Message     â†’ semantic, prÃ¤gnant, auf Englisch:
                        <type>(<scope>): <summary>
                        Beispiele:
                          feat(auth): add JWT refresh token logic
                          fix(ui): correct button alignment on mobile
                          chore(deps): bump version to 1.4.2
3. AusfÃ¼hren:
   git add .
   git commit -m "<generierte Message>"
   git push origin main
4. Meldung in der Inbox:
   âœ… Committed & pushed: "<commit-message>" â†’ main
```

> âš ï¸ **Regel:** Niemals direkt auf `release`-Branch pushen.
> Der Auto-Commit gilt immer fÃ¼r den Branch `main`, sofern kein anderer Branch aktiv ist.

> ðŸ“– Branch-Strategie: [`config/branches.config.md`](config/branches.config.md)

---

## ðŸ“Š Prompt Library Reference

All reusable prompts are catalogued in:
> [`config/prompts.config.md`](config/prompts.config.md)

Categories: Code Review Â· Debugging Â· Refactoring Â· Architecture Â· Testing Â· Performance Â· Tooling & DevOps

---

## ðŸŒ Sources & References

All external references: [`docs/SOURCES.md`](docs/SOURCES.md)

Key references:
- Semantic versioning: `https://semver.org/`
- Conventional commits: `https://www.conventionalcommits.org/`
- EditorConfig: `https://editorconfig.org/`
- Git flow: `https://nvie.com/posts/a-successful-git-branching-model/`

---

## âš¡ Emergency Restart Checklist

If project context is lost, execute in order:

```
â˜ 1. git clone / git pull latest from release branch
â˜ 2. Read Agent.md                          â†’ Identity & rules
â˜ 3. Read this file (MASTER_INSTRUCTIONS.md) â†’ Startup protocol
â˜ 4. Read memory/CONTEXT.md                 â†’ Current state
â˜ 5. Read memory/DECISIONS.md              â†’ Past decisions
â˜ 6. Read docs/CHANGELOG.md (last 10 entries)
â˜ 7. Check locks/.locked for active sessions
â˜ 8. Read locks/LOCK_REGISTRY.md for history
â˜ 9. Proceed with Step 1 of Agent Session Protocol above
```

---

## ðŸ“ Project Growth & Maturity Review Protocol

### 1. Triggers â€” Wann wird ein Growth Review durchgefÃ¼hrt?
Ein Growth Review wird durchgefÃ¼hrt bei:
1. **Jeder 10. Agent-Session** (ergÃ¤nzend zum 5-Session Optimization Protocol)
2. **Expliziter Anforderung** durch den User
3. **Erreichen folgender Schwellwerte** (automatisch im Session Start-Check):

| Metrik | Schwellwert | Empfohlene Aktion |
|---|---|---|
| **Dateien im Repo** | > 20 Dateien (ohne `.agent/`, `.git/`) | Ordnerstruktur prÃ¼fen, `src/` o. Ã„. einfÃ¼hren |
| **LOC einer Datei** | > 500 Zeilen | Aufteilen in Module/Funktionen |
| **LOC gesamt** | > 2.000 Zeilen | Architektur-Review, Package-Struktur prÃ¼fen |
| **Plattformen** | > 1 OS-Ziel (Win + Linux) | Cross-Plattform Abstraktion (Docker, Polyglot) |
| **Sprachen im Repo** | > 2 Sprachen | PrimÃ¤rsprache definieren, Build-System einfÃ¼hren |
| **Externe Deps** | > 5 ohne Deklaration | Package Manager einfÃ¼hren (`requirements.txt`, `package.json`) |
| **Inline-Code** | Shell/PowerShell mit > 20 Zeilen Python/C/SQL | Script extrahieren |
| **Test-Abdeckung** | 0 Tests bei > 500 LOC | Test-Framework einfÃ¼hren (Pester, pytest) |

### 2. Review-Checkliste
Der Agent prÃ¼ft bei jedem Growth Review:
- **Scope**: Ist der Projekt-Scope noch klar definiert oder wÃ¤chst das Tool zu einer All-in-One Suite?
- **Architektur**: Ist die Verzeichnisstruktur fÃ¼r die ProjektgrÃ¶ÃŸe noch angemessen?
- **Sprachen & Plattform**: Ist die gewÃ¤hlte Sprache noch optimal? (z.B. Migration von Bash zu Python bei komplexer JSON/Rest-Logik).
- **Dependencies**: Sind alle externen Pakete deklariert und isoliert (venv, node_modules)?
- **QualitÃ¤t & Tests**: Gibt es einen automatisierten Test-Runner (unattended, non-interactive)?
- **Dokumentation**: Ist die README aktuell? Gibt es ein CHANGELOG bei > 5 Releases?

### 3. Projekt-Reifegrade (Maturity Levels)
- ðŸŸ¢ **L0 (Einzelscript)**: 1 Datei, < 200 LOC. Erfordert: Header-Kommentar + standardisiertes Error Handling.
- ðŸŸ¡ **L1 (Multi-File Tool)**: 2â€“10 Dateien, < 1.000 LOC. Erfordert: `README.md`, `src/` Ordner, `justfile` fÃ¼r grundlegende AblÃ¤ufe.
- ðŸŸ  **L2 (Strukturiertes Projekt)**: 10â€“30 Dateien, < 5.000 LOC, Test-Suite. Erfordert: `.agent/`, `docs/`, `tests/`, `CHANGELOG.md`, Versionierung.
- ðŸ”´ **L3 (Package / Service)**: 30+ Dateien, APIs, Multi-Plattform. Erfordert: Versionierung (`version.json`), Build-System, Docker, CI/CD Pipeline.

---

*This file must be updated whenever the framework changes significantly.*
*All agents are responsible for keeping this file accurate.*


