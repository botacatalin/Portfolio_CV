#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

IMAGE="me:0.0.1"

git pull --ff-only
docker info >/dev/null

# Remove the previous deployment so its container releases port 8006.
if docker image inspect "$IMAGE" >/dev/null 2>&1; then
    containers=$(docker ps -aq --filter "ancestor=$IMAGE")
    while IFS= read -r container; do
        if [[ -n "$container" ]]; then
            docker rm -f "$container"
        fi
    done <<< "$containers"
    docker rmi -f "$IMAGE"
fi

docker build -t "$IMAGE" .
docker run -d -p 8006:8006 "$IMAGE"
