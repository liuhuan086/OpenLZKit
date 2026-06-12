# Module: alicloud/sso

Creates Alibaba Cloud CloudSSO identity and account-access objects.

## Responsibilities

- Create or reuse a CloudSSO directory.
- Create CloudSSO groups and optional local users.
- Attach local users to groups.
- Create access configurations (permission sets) with system or inline policies.
- Assign groups/users/external principal ids to accounts.
- Provision access configurations to target accounts when required.

It does **not**:

- Store or rotate user passwords.
- Replace enterprise IdP/SCIM lifecycle management.
- Create member accounts.
- Create custom RAM policies outside CloudSSO access configurations.

## Preconditions

- CloudSSO is available in the Alibaba Cloud organization.
- Target accounts already exist.
- For production users, prefer SCIM or external IdP over local users.

## Usage

```hcl
module "sso" {
  source = "../../modules/sso"

  directory_name = "lz-sso"

  groups = {
    platform_admins = {
      name        = "platform-admins"
      description = "Landing Zone platform administrators."
    }
  }

  access_configurations = {
    security_audit = {
      name             = "SecurityAudit"
      session_duration = 3600
      permission_policies = [{
        name = "SecurityAudit"
        type = "System"
      }]
    }
  }

  assignments = {
    audit_to_prod = {
      access_configuration_key = "security_audit"
      principal_type           = "Group"
      group_key                = "platform_admins"
      target_id                = "1234567890123456"
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `create_directory` | `bool` | `true` | Create a CloudSSO directory. |
| `directory_id` | `string` | `null` | Existing directory id when not creating one. |
| `groups` | `map(object)` | `{}` | CloudSSO groups. |
| `users` | `map(object)` | `{}` | Optional local CloudSSO users. |
| `group_memberships` | `map(object)` | `{}` | Local user to group memberships. |
| `access_configurations` | `map(object)` | `{}` | CloudSSO permission sets. |
| `assignments` | `map(object)` | `{}` | Account assignments. |
| `provisionings` | `map(object)` | `{}` | Access configuration provisioning targets. |

## Outputs

| Name | Description |
|---|---|
| `directory_id` | CloudSSO directory id. |
| `group_ids` | CloudSSO group ids by key. |
| `user_ids` | CloudSSO user ids by key. |
| `access_configuration_ids` | Access configuration ids by key. |
| `assignment_ids` | Assignment ids by key. |

## Security notes

- Keep `allow_user_to_get_credentials = false` unless temporary credential
  download is explicitly approved.
- Use groups for assignments; avoid assigning individual users to accounts.
- Prefer system/read-only policies first, then add reviewed custom inline
  policies for operational roles.
- Do not put passwords in Terraform variables or examples.

## Testing

Static checks (no cloud account required):

```bash
terraform -chdir=examples/sso fmt -check -recursive
terraform -chdir=examples/sso init -backend=false
terraform -chdir=examples/sso validate
```

`plan`/`apply` require CloudSSO administrative permissions.
