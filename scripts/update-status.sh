#!/usr/bin/env bash
set -euo pipefail
REPO="kameki23/mac-openclaw"
OUT="$(cd "$(dirname "$0")/.." && pwd)/status.json"

# Lightweight updater (safe for cron)
telegram="unknown"
doing=0
blocked=0
failed=0

if command -v gh >/dev/null 2>&1; then
  failed="$(gh run list --repo "$REPO" --limit 20 --json conclusion 2>/dev/null | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.filter(x=>x.conclusion==="failure").length)}catch{console.log(0)}})')"
fi

cat > "$OUT" <<JSON
{
  "updatedAt": "$(date +"%Y-%m-%d %H:%M:%S")",
  "telegram": "$telegram",
  "doingTasks": $doing,
  "blockedTasks": $blocked,
  "githubActionsFailed": $failed,
  "dailyCostChecked": false
}
JSON

echo "updated: $OUT"
