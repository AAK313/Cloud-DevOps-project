#!/usr/bin/env bash
set -euo pipefail

: "${IMAGE_NAME:?IMAGE_NAME is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"
: "${IMAGE_URI:?IMAGE_URI is required}"
GIT_BRANCH="${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD)}"

log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*"
}

build_image() {
  log "Building Docker image ${IMAGE_URI}"
  docker build -t "${IMAGE_URI}" .
}

scan_image() {
  if [[ "${TRIVY_ENABLED:-false}" =~ ^(true|1|yes)$ ]]; then
    log "Scanning image ${IMAGE_URI} with Trivy"
    docker pull aquasec/trivy:latest >/dev/null
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --exit-code 1 --severity HIGH,CRITICAL "${IMAGE_URI}"
  else
    log "Trivy scan skipped (TRIVY_ENABLED not true)"
  fi
}

push_image() {
  log "Pushing image ${IMAGE_URI}"
  docker push "${IMAGE_URI}"
}

delete_local_image() {
  log "Deleting local image ${IMAGE_URI}"
  docker rmi -f "${IMAGE_URI}" || log "Image already removed"
}

update_manifests() {
  local manifest="k8s/ivolve/deployment.yaml"
  log "Updating manifest ${manifest} with ${IMAGE_URI}"
  sed -i -E "s|(image:\s*)(.*)|\\1${IMAGE_URI}|" "${manifest}"
}

push_manifests() {
  log "Preparing to push manifest changes"
  git config user.email "github-actions@users.noreply.github.com"
  git config user.name "github-actions"
  if git diff --quiet -- k8s/ivolve/deployment.yaml; then
    log "No manifest changes to commit"
    return
  fi
  git add k8s/ivolve/deployment.yaml
  git commit -m "chore(manifests): update image to ${IMAGE_TAG}" || log "No changes committed"
  git push origin "$GIT_BRANCH"
}
