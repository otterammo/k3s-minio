#!/usr/bin/env bash
set -euo pipefail

# Create MinIO root credentials secret.
# Usage: MINIO_ROOT_PASSWORD=... ./scripts/create-secret.sh
# If MINIO_ROOT_PASSWORD is empty, a random password is generated.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set -a
if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi
set +a

MINIO_ROOT_USER="root"
MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-}"

if [ -z "$MINIO_ROOT_PASSWORD" ]; then
  set +o pipefail
  MINIO_ROOT_PASSWORD="$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 32)"
  set -o pipefail
  echo "Auto-generated MinIO root password: $MINIO_ROOT_PASSWORD"
fi

kubectl create namespace minio --dry-run=client -o yaml | kubectl apply -f -
kubectl -n minio create secret generic minio-root \
  --from-literal=MINIO_ROOT_USER="$MINIO_ROOT_USER" \
  --from-literal=MINIO_ROOT_PASSWORD="$MINIO_ROOT_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "MinIO root secret applied in namespace minio"
