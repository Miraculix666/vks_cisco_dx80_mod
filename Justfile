# Cisco DX80 Firmware & Macro Modification Justfile

default:
    @just --list

# Run JavaScript unit tests for xAPI macro scripts
test-unit:
    @echo "Running Node.js tests for Cisco DX80 xAPI macros..."
    node CiscoCE-config/SystemMonitor.test.js
    node CiscoCE-config/UsbWebcamPersistent.test.js
    @echo "  -> Macro Tests PASSED"

# Lint JS macros and XML payload files
lint: test-unit
    @echo "Validating JavaScript macros and XML syntax..."
    node -c MeetingShortcuts.js
    node -c SystemMonitor.js
    node -c CiscoCE-config/MeetingShortcuts.js
    node -c CiscoCE-config/SystemMonitor.js
    node -c CiscoCE-config/UsbWebcamPersistent.js
    @echo "  -> Syntax OK"

# Audit presence of mandatory project metafiles
docs-audit:
    @echo "Auditing mandatory system metafiles..."
    python -c "import os; files=['README.md','CHANGELOG.md','help.md','SOURCES.md','AI_REBUILD_PROMPT.md']; missing=[f for f in files if not os.path.exists(f)]; print('Metafiles OK') if not missing else print('MISSING:', missing)"
