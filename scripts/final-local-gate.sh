#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
./scripts/validate-static-baseline.sh
python3 scripts/validate-prototype.py
node --check app.js
for gate in scripts/check-ec-cloud-0{6,7,8,9}.mjs scripts/check-ec-cloud-1{0,1,2,3,4}.mjs; do node "$gate"; done
(cd apps/web && node --test tests/**/*.test.mjs)
echo 'FINAL LOCAL GATE: PASS'
