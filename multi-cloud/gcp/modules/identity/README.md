# Module: gcp/identity

Creates least-privilege **custom organization IAM roles** and **IAM member
bindings** at folder/project scope. People reach roles via Cloud Identity groups
(group members preferred over users).

## Responsibilities

- Define custom org roles (least-privilege `permissions`).
- Bind roles to members at folder or project scope.

It does **not**: create Cloud Identity groups (supply group emails) or manage
service accounts (see `modules/cross-account-access`).

## Usage

```hcl
module "identity" {
  source = "../../modules/identity"
  org_id = "123456789012"

  custom_org_roles = {
    lzSecurityAuditor = {
      title       = "LZ Security Auditor"
      permissions = ["resourcemanager.projects.get", "logging.logEntries.list"]
    }
  }

  folder_bindings = {
    auditors = { folder = "folders/111", role = "roles/viewer", member = "group:auditors@example.com" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `org_id` | `string` | `null` | Org id for custom roles. |
| `custom_org_roles` | `map(object)` | `{}` | Custom roles (title, permissions, stage). |
| `folder_bindings` | `map(object)` | `{}` | Folder-scope IAM member bindings. |
| `project_bindings` | `map(object)` | `{}` | Project-scope IAM member bindings. |

## Outputs

| Name | Description |
|---|---|
| `custom_role_ids` | Map of role_id to custom role resource id. |

## Security notes

- Prefer `group:` members; avoid `user:` bindings.
- Keep custom-role `permissions` minimal; never include IAM self-management in operator roles.

Validated via [live/20-identity](../../live/20-identity); see [../../tests](../../tests).
