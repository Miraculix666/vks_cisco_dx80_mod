# verify-alignment.ps1
# PURPOSE: Verify the correct implementation of the repository split and independent agent configurations
# LAST MODIFIED: 2026-08-12
# MODIFIED BY: Agent

$ErrorActionPreference = "Continue"

Write-Host "=== Starting Repository-Level Split Compliance Audit ===" -ForegroundColor Cyan

# 1. Verify New Folder Structure
Write-Host "`n[1] Checking Directory Names..." -ForegroundColor Yellow
$folders = @("ha config", "ha backup full", "ha_backup", "ha core", "1lm stack core", "11m stack_config", "11m stack_backup", "agents_and_prompts", "homelab infra", "homelab config")
foreach ($f in $folders) {
    $path = "C:\GitHub\$f"
    if (Test-Path $path) {
        Write-Host "  [OK] Folder exists: $f" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Missing folder: $f" -ForegroundColor Red
    }
}

# 2. Verify Deletion of Old Duplicates & Folders
Write-Host "`n[2] Checking Deletion of Old Redundant Folders..." -ForegroundColor Yellow
$oldFolders = @("HomeAssistant-config-", "homelab-full", "HA_backup", "homelab-repo", "LLM_Stack")
foreach ($old in $oldFolders) {
    $path = "C:\GitHub\$old"
    if (-not (Test-Path $path)) {
        Write-Host "  [OK] Old folder removed: $old" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Redundant old folder still exists: $old" -ForegroundColor Red
    }
}

# 3. Verify .agent Junction Status (Should be physical folders, no cross-repo junctions)
Write-Host "`n[3] Auditing .agent Junction Status..." -ForegroundColor Yellow
Get-ChildItem -Path "C:\GitHub" -Directory | ForEach-Object {
    $agentPath = Join-Path $_.FullName ".agent"
    if (Test-Path $agentPath) {
        $item = Get-Item $agentPath -Force
        if ($item.Attributes -match "ReparsePoint") {
            Write-Host "  [FAIL] $($_.Name) has a directory junction: $($item.LinkTarget) (expected physical folder)" -ForegroundColor Red
        } else {
            Write-Host "  [OK] $($_.Name) has a physical independent .agent directory" -ForegroundColor Green
        }
    }
}

# 4. Verify Global .agent Junction
Write-Host "`n[4] Checking Global Root .agent Junction..." -ForegroundColor Yellow
$rootJunction = Get-Item "C:\GitHub\.agent" -ErrorAction SilentlyContinue
if ($rootJunction -and $rootJunction.Attributes -match "ReparsePoint" -and $rootJunction.LinkTarget -like "*agents_and_prompts*") {
    Write-Host "  [OK] Global .agent points to agents_and_prompts/.agent: $($rootJunction.LinkTarget)" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Global .agent junction is invalid or points to wrong target" -ForegroundColor Red
}

# 5. Verify Workspace Configuration JSON
Write-Host "`n[5] Validating all.code-workspace..." -ForegroundColor Yellow
$wsPath = "C:\GitHub\all.code-workspace"
if (Test-Path $wsPath) {
    try {
        $json = Get-Content $wsPath -Raw | ConvertFrom-Json
        $validPaths = $json.folders | Where-Object { 
            $_.path -match "HomeAssistant-config-" -or $_.path -match "homelab-full" -or $_.path -match "HA_backup" -or $_.path -match "LLM_Stack"
        }
        if ($validPaths) {
            Write-Host "  [FAIL] all.code-workspace contains deprecated paths: $($validPaths.path)" -ForegroundColor Red
        } else {
            Write-Host "  [OK] all.code-workspace is clean of deprecated paths" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [FAIL] Failed to parse all.code-workspace JSON: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  [FAIL] all.code-workspace does not exist" -ForegroundColor Red
}

# 6. Verify Git Remotes in Key Repositories
Write-Host "`n[6] Auditing Git Remotes..." -ForegroundColor Yellow
$remotes = @{
    "ha config"          = "ha_config.git"
    "ha backup full"     = "ha_backup_full.git"
    "ha_backup"     = "ha_backup.git"
    "ha core"            = "ha_core.git"
    "1lm stack core"     = "LLM_Stack.git"
    "11m stack_config"   = "11m_stack_config.git"
    "11m stack_backup"   = "11m_stack_backup.git"
    "agents_and_prompts" = "agents_and_prompts.git"
    "homelab infra"      = "homelab_infra.git"
    "homelab config"     = "homelab_config.git"
}
foreach ($repo in $remotes.Keys) {
    $path = "C:\GitHub\$repo"
    if (Test-Path "$path\.git") {
        $url = git -C $path remote get-url origin 2>$null
        $expected = $remotes[$repo]
        if ($url -match $expected) {
            Write-Host "  [OK] $repo remote matches expected: $expected" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $repo remote is '$url' (expected: $expected)" -ForegroundColor Red
        }
    }
}

Write-Host "`n=== Audit Complete ===" -ForegroundColor Cyan


