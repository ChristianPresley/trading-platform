#!/bin/bash
# Checkpoint update helper for zcov coverage tracking
# Usage: ./update.sh <function_name> <status> [coverage_pct]
# Example: ./update.sh "classifyModule" "tested" "85.3"

PROGRESS_FILE="$(dirname "$0")/progress.json"
TIMESTAMP=$(date -Iseconds)

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <function_name> <status> [coverage_pct]"
    exit 1
fi

FUNC="$1"
STATUS="$2"
COV="${3:-}"

# Log checkpoint
echo "[$TIMESTAMP] $FUNC -> $STATUS ${COV:+(coverage: ${COV}%)}" >> "$(dirname "$0")/checkpoint.log"

echo "Checkpoint logged: $FUNC -> $STATUS"
