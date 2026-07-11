#!/usr/bin/env bash

log() {
    local log="$1"
    echo "$(date --utc +%FT%TZ): $log"
}

deploy_website() {
    export BUILD_VERSION=$(git rev-parse HEAD)
    log "Deploying new website version $BUILD_VERSION"

    git pull
    
    log "Running build..."
    docker compose rm -f
    docker compose build

    OLD_FE=$(docker ps -aqf "name=frontend")
    OLD_BE=$(docker ps -aqf "name=backend")
    log "Scaling website up..."
    docker compose up -d --no-deps --scale frontend=2 --no-recreate frontend
    docker compose up -d --no-deps --scale backend=2 --no-recreate backend

    sleep 5

    log "Scaling old server down..."
    docker container rm -f $OLD_FE
    docker container rm -f $OLD_BE
    docker compose up -d --no-deps --scale frontend=1 --no-recreate frontend
    docker compose up -d --no-deps --scale backend=1 --no-recreate backend

    log "Reloading Nginx..."
    NGINX_CONTAINER=$(docker ps -aqf "name=nginx")
    docker exec $NGINX_CONTAINER nginx -s reload
}

log "Fetching remote repo..."
git fetch

UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [ $LOCAL = $REMOTE ]; then
    log "No git changes detected"
elif [ $LOCAL = $BASE ]; then 
    log "Changes detected, running redeploy..."
    deploy_website
elif [ $REMOTE = $BASE ]; then
    log "Local changes detected, stashing changes and running redeploy..."
    git stash
    deploy_website
else
    log "your git HEAD and upstream have diverged!"
fi
