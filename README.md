# k3s-minio

MinIO S3-compatible object storage for the k3s cluster.

## Deployment

This repo is deployed automatically by ArgoCD from the `k3s-infra` cluster bootstrap. ArgoCD watches the `manifests/` directory on the `main` branch.

### Prerequisites

- `minio-root` secret must exist in the `minio` namespace (created by `k3s-infra`'s `make create-all-secrets`)
- A node labeled `storage=external` with `/mnt/external/minio` available

### Manual deployment (local dev)

```bash
cp .env.example .env
# edit .env
make deploy
```
