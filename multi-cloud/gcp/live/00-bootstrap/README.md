# live/00-bootstrap (GCP)

The one-time foundation every later stack depends on. Runs with **local state**,
then migrates its own state into the GCS bucket it creates.

## What it creates

- **GCS state bucket** — versioned, uniform bucket-level access, public access
  prevention enforced.
- **Workload Identity Federation** — a pool + GitHub OIDC provider restricted to
  this repository, plus a CI service account that the repo's federated identity
  may impersonate (no service-account key is created).

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `project_id` | `string` | — | Seed/platform project. |
| `region` | `string` | `us-central1` | Provider region. |
| `location` | `string` | `US` | State bucket location. |
| `state_bucket_name` | `string` | — | Globally-unique bucket name. |
| `github_owner` / `github_repo` | `string` | — | Repo allowed to impersonate the CI identity. |
| `pool_id` / `provider_id` | `string` | `github-pool` / `github` | WIF pool/provider ids. |
| `labels` | `map(string)` | `{}` | Bucket labels. |

## Run

```bash
terraform init                 # local state
terraform validate             # static, no project
terraform apply \
  -var project_id=my-seed-project \
  -var state_bucket_name=my-lz-tfstate \
  -var github_owner=example-org -var github_repo=openlzkit-example

# then migrate state into the new bucket
terraform init -migrate-state \
  -backend-config="bucket=my-lz-tfstate" \
  -backend-config="prefix=gcp/00-bootstrap"
```

## Security notes

- CI authenticates via Workload Identity Federation — no service-account key is created or stored.
- The OIDC provider is restricted to `<owner>/<repo>`; impersonation is scoped to that repo's principalSet.
- The state bucket enforces public access prevention and uniform bucket-level access.
