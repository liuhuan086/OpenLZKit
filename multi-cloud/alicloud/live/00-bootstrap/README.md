# live/00-bootstrap (Alibaba Cloud)

The one-time foundation that every later stack depends on. Runs with **local
state**, then migrates its own state into the OSS bucket it creates.

## What it creates

- **Resource Directory** — enables the org root used by `10-org` (toggle with `enable_resource_directory`).
- **OSS state bucket** — versioned, AES256-encrypted, private ACL; backend for `10-org` and beyond.
- **GitHub Actions OIDC provider + plan role** (`lz-cicd-plan`) — short-lived CI credentials, no long-lived AccessKey.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `cn-hangzhou` | Region for the state bucket. |
| `state_bucket_name` | `string` | — | Globally-unique OSS bucket name. |
| `enable_resource_directory` | `bool` | `true` | Enable the Resource Directory (account-wide, one-time). |
| `github_owner` / `github_repo` | `string` | — | Repo allowed to assume the CI/CD role via OIDC. |
| `tags` | `map(string)` | `{}` | Tags on taggable resources. |

## Run

```bash
terraform init                       # local state
terraform validate                   # static, no account
terraform apply \
  -var state_bucket_name=my-lz-tfstate \
  -var github_owner=liuhuan086 -var github_repo=OpenLZKit

# then migrate state into the new bucket
terraform init -migrate-state \
  -backend-config="bucket=my-lz-tfstate" -backend-config="region=cn-hangzhou"
```

## Security notes

- CI/CD uses OIDC federation; no AccessKey/Secret is stored.
- The OIDC trust is scoped to `repo:<owner>/<repo>:*` — tighten to `:environment:prod` etc. for apply roles.
- Bucket name and account id are supplied as variables, never hard-coded.
