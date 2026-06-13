# Module: gcp/delegation

**Delegated management** (FP-8): least-privilege folder-level IAM delegation and
Shared VPC subnet-level access. Folder delegations **reject `roles/owner`** via a
precondition.

## Responsibilities

- Delegate management of a folder to a team (`google_folder_iam_member`), never Owner.
- Grant `networkUser` on a specific Shared VPC subnet (`google_compute_subnetwork_iam_member`).

It does **not**: enable the Shared VPC host / attach service projects (see
`modules/connectivity`) or create groups/service accounts.

## Usage

```hcl
module "delegation" {
  source = "../../modules/delegation"

  folder_delegations = {
    network-team = { folder = "folders/222", role = "roles/compute.networkAdmin", member = "group:network@example.com" }
  }
  subnet_delegations = {
    prod = { project = "host", region = "us-central1", subnetwork = "lz-prod-workload", member = "serviceAccount:..." }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `folder_delegations` | `map(object)` | `{}` | Folder IAM (folder, role≠owner, member). |
| `subnet_delegations` | `map(object)` | `{}` | Subnet networkUser grants (project, region, subnetwork, member). |

## Outputs

| Name | Description |
|---|---|
| `folder_delegation_ids` | Map of folder delegation key to id. |
| `subnet_delegation_ids` | Map of subnet delegation key to id. |

## Security notes

- **`roles/owner` is rejected** for folder delegations — delegate specific admin roles only.
- Subnet-level `networkUser` shares a single subnet, not the whole host network — least-privilege Shared VPC.

Validated via [live/55-delegation](../../live/55-delegation); see [../../tests](../../tests).
