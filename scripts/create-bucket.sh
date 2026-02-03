#!/usr/bin/env bash
set -euo pipefail

# Create a bucket in MinIO using the mc client pod.
# Usage: MINIO_ROOT_USER=... MINIO_ROOT_PASSWORD=... BUCKET=... ./scripts/create-bucket.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set -a
if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi
set +a

MINIO_ROOT_USER="${MINIO_ROOT_USER:-root}"
BUCKET="${BUCKET:-longhorn-backups}"

if [ -z "${MINIO_ROOT_PASSWORD:-}" ]; then
  echo "Error: MINIO_ROOT_PASSWORD not set"
  exit 1
fi

kubectl run minio-mc --rm -i --restart=Never \
  --namespace=minio \
  --image=minio/mc:latest \
  --env="MC_HOST_minio=http://$MINIO_ROOT_USER:$MINIO_ROOT_PASSWORD@minio.minio.svc.cluster.local:9000" \
  -- mb --ignore-existing minio/"$BUCKET"

echo "Bucket '$BUCKET' created"
