# Module: gcp/cross-account-access

**Cross-project access** (FP-4): service accounts (machine identities) with
Workload Identity Federation impersonation (no keys) and least-privilege
cross-project IAM bindings.

## Responsibilities

- Create service accounts.
- Bind roles to service accounts or explicit members at target projects.
- Grant repo-scoped federated principalSets permission to impersonate the SA (`roles/iam.workloadIdentityUser`).

It does **not**: create the WIF pool (see `00-bootstrap`), create Cloud Identity
groups, or define custom roles (see `modules/identity`).

## Usage

```hcl
module "cross_account" {
  source = "../../modules/cross-account-access"

  service_accounts = {
    cicd-deployer = { account_id = "lz-cicd-deployer", project = var.project_id }
  }
  wif_bindings = {
    github = { service_account_key = "cicd-deployer", member = "principalSet://.../attribute.repository/org/repo" }
  }
  project_bindings = {
    deploy = { project = "workload-prod", role = "roles/editor", service_account_key = "cicd-deployer" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `service_accounts` | `map(object)` | `{}` | Machine identities (account_id, project). |
| `project_bindings` | `map(object)` | `{}` | Target-project IAM (SA via key or explicit member). |
| `wif_bindings` | `map(object)` | `{}` | WIF impersonation (principalSet → SA). |

## Outputs

| Name | Description |
|---|---|
| `service_account_emails` | Map of SA key to email. |
| `project_binding_ids` | Map of binding key to id. |

## Security notes

- No service-account keys — impersonation via Workload Identity Federation only.
- Scope `member` principalSets to the specific repo; keep project roles least-privilege (avoid `roles/owner`).

Validated via [live/24-cross-account-access](../../live/24-cross-account-access); see [../../tests](../../tests).
