# Module: alicloud/org

Builds the Alibaba Cloud **Resource Directory** folder hierarchy (and, optionally,
member accounts) for the Landing Zone organization layer.

## Responsibilities

- Read the existing Resource Directory and its root folder.
- Create a one- or two-level folder hierarchy with a consistent name prefix.
- Optionally create Resource Directory member accounts placed into folders.

It does **not**:

- Enable the Resource Directory — that is a one-time bootstrap action (`live/00-bootstrap`).
- Manage RAM, network, logging or billing — those belong to their own modules.

## Preconditions

- Resource Directory is already enabled on the management account.
- Caller has `ResourceManager` permissions to create folders/accounts.

## Usage

```hcl
module "org" {
  source = "../../modules/org"

  name_prefix = "lz-"

  folders = {
    security = {
      display_name = "Security"
      children = {
        audit-log      = { display_name = "Audit Log" }
        security-tools = { display_name = "Security Tooling" }
      }
    }
    workloads = {
      display_name = "Workloads"
      children = {
        prod = { display_name = "Prod" }
        dev  = { display_name = "Dev" }
      }
    }
    sandbox = { display_name = "Sandbox" }
  }
}
```

See [examples/basic](../../examples/basic) for a complete, validated example.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `""` | Prefix applied to every folder name (naming convention). |
| `folders` | `map(object)` | — | Folder hierarchy under the RD root. Key is a stable id; `display_name` is the name; `children` is one optional nested level. |
| `accounts` | `map(object)` | `{}` | Member accounts to create. `folder_key` references a `folders` key (`"<parent>/<child>"` for children). Empty by default — creating accounts has **billing impact**. |
| `tags` | `map(string)` | `{}` | Tags merged onto created member accounts. Folders do not support tags. |

## Outputs

| Name | Description |
|---|---|
| `root_folder_id` | Resource Directory root folder id. |
| `folder_ids` | Map of folder key to created folder id. |
| `account_ids` | Map of account key to created member account id. |

## Security notes

- Member-account creation is **off by default**; enable only with billing and approval in place.
- No credentials, account ids or bucket names are hard-coded — supply them via the provider/credential chain and `-backend-config`.
- Folders are global to the Resource Directory; this module is region-independent.

## Testing

Static checks (no cloud account required):

```bash
terraform -chdir=examples/basic fmt -check -recursive
terraform -chdir=examples/basic init -backend=false
terraform -chdir=examples/basic validate
```

`plan`/`apply` require RAM credentials for the management account and are run from
`live/10-org`, gated by PR review and approval. See [../../tests](../../tests).
