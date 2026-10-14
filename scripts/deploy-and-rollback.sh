
#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE="${1:?Usage: deploy-and-rollback.sh IMAGE NAME PORT CANDIDATE_PORT [simulate]}"
NAME="${2:?Container name required}"
PORT="${3:?Live port required}"
CANDIDATE_PORT="${4:?Candidate port required}"
SIMULATE="${5:-false}"

OLD_IMAGE="$(sudo docker inspect --format='{{.Config.Image}}' "$NAME" 2>/dev/null || true)"

cleanup_candidate() {
  sudo docker rm -f "${NAME}-candidate" >/dev/null 2>&1 || true
}

rollback() {
  echo "Restoring previous image: $OLD_IMAGE"
  sudo docker rm -f "$NAME" >/dev/null 2>&1 || true

  if [ -z "$OLD_IMAGE" ]; then
    echo "CRITICAL: No previous image is available."
    return 1
  fi

  sudo docker run -d --name "$NAME" -p "$PORT:3000" "$OLD_IMAGE"

  for i in $(seq 1 10); do
    if curl --fail "http://localhost:$PORT/health"; then
      echo "Rollback successful: previous image is healthy."
      return 0
    fi
    sleep 2
  done

  echo "CRITICAL: Previous image did not become healthy."
  sudo docker logs "$NAME" || true
  return 1
}

cleanup_candidate
sudo docker build -t "$IMAGE" .
sudo docker run -d --name "${NAME}-candidate" \
  -p "$CANDIDATE_PORT:3000" "$IMAGE"

candidate_healthy=0
for i in $(seq 1 10); do
  if curl --fail "http://localhost:$CANDIDATE_PORT/health"; then
    candidate_healthy=1
    break
  fi
  sleep 2
done

if [ "$candidate_healthy" -ne 1 ]; then
  sudo docker logs "${NAME}-candidate" || true
  cleanup_candidate
  echo "Candidate failed. Existing application remains untouched."
  exit 1
fi

cleanup_candidate
sudo docker rm -f "$NAME"

if [ "$SIMULATE" = "true" ]; then
  sudo docker run -d --name "$NAME" \
    --entrypoint sh -p "$PORT:3000" "$IMAGE" \
    -c 'sleep 300'
else
  sudo docker run -d --name "$NAME" -p "$PORT:3000" "$IMAGE"
fi

deployed_healthy=0
for i in $(seq 1 10); do
  if curl --fail "http://localhost:$PORT/health"; then
    deployed_healthy=1
    break
  fi
  sleep 2
done

if [ "$deployed_healthy" -ne 1 ]; then
  echo "Post-deployment health check failed."
  sudo docker logs "$NAME" || true

  if rollback; then
    exit 1
  else
    exit 2
  fi
fi

echo "Deployment successful: $IMAGE"
