# Module: alicloud/account-factory

Creates Alibaba Cloud Resource Directory member accounts from a standard account
vending contract.

## Responsibilities

- Create member accounts in existing Resource Directory folders.
- Enforce standard naming via `name_prefix`.
- Merge common tags with per-account tags.
- Require the FinOps tag set before account creation.

It does **not**:

- Create folders — use `modules/org` and pass its `folder_ids` output.
- Enable Resource Directory — that is a one-time bootstrap action.
- Configure RAM roles, SSO, network, logging or budgets in the new account.

## Preconditions

- Resource Directory is already enabled on the management account.
- Target folders already exist.
- Caller has ResourceManager permissions to create member accounts.
- Billing and account ownership approvals are complete.

## Usage

```hcl
module "accounts" {
  source = "../../modules/account-factory"

  name_prefix = "lz-"
  folder_ids  = module.org.folder_ids

  accounts = {
    payment_dev = {
      display_name = "Payment Dev"
      folder_key   = "workloads/dev"
      tags = {
        owner               = "payments-platform"
        cost_center         = "cc-1001"
        env                 = "dev"
        project             = "payment"
        data_classification = "internal"
      }
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `""` | Prefix applied to every member account display name. |
| `folder_ids` | `map(string)` | — | Folder key to Resource Directory folder id. |
| `accounts` | `map(object)` | `{}` | Member accounts to create; `folder_key` must exist in `folder_ids`. |
| `common_tags` | `map(string)` | `{ managed_by = "terraform" }` | Tags merged onto every account. |
| `required_tag_keys` | `list(string)` | FinOps keys | Required keys after tag merge. |

## Outputs

| Name | Description |
|---|---|
| `account_ids` | Map of account key to created member account id. |
| `account_display_names` | Map of account key to created member account display name. |

## Security notes

- Account creation is intentionally opt-in. Keep `accounts = {}` until the
  platform team has billing, naming and ownership approval.
- Do not hard-code real account ids or personal data in examples or tests.
- Run `plan` only from a sandbox management account using short-lived STS
  credentials.

## Testing

Static checks (no cloud account required):

```bash
terraform -chdir=examples/account-factory fmt -check -recursive
terraform -chdir=examples/account-factory init -backend=false
terraform -chdir=examples/account-factory validate
```

`plan`/`apply` require management-account Resource Directory permissions.
