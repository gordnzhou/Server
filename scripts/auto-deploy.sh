#!/usr/bin/env bash

LOG_PATH="/home/gordon/scripts/auto-deploy.log"
DEPLOY_SCRIPT_PATH="/home/gordon/scripts/deploy-if-changed.sh"
export DOCKER_CONTEXT=gordon

MAX_LINES=10240
if [ -f "$LOG_PATH" ]; then
    tail -n "$MAX_LINES" "$LOG_PATH" > "${LOG_PATH}.tmp" &&
    mv "${LOG_PATH}.tmp" "$LOG_PATH"
fi

LOCK_FILE="$(pwd)/portfolio.lock"
cd /home/gordon/services/mywebsite
flock -n "$LOCK_FILE" "$DEPLOY_SCRIPT_PATH" >> "$LOG_PATH" 2>&1