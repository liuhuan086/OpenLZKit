# live/55-delegation (GCP)

Delegated management (FP-8): least-privilege folder-level IAM delegation (never
`roles/owner`) and subnet-level Shared VPC `networkUser` grants. Both are empty
by default and supplied per environment.

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan -var project_id=<project> \
  -var 'folder_delegations={network={folder="folders/222",role="roles/compute.networkAdmin",member="group:network@example.com"}}'
# apply after PR review + approval
```
