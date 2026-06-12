# Module: azure/logging

Stands up the **central Log Analytics workspace** (audit/log sink) and routes
resource logs to it via diagnostic settings.

## Responsibilities

- Create a Log Analytics workspace with retention.
- Attach `azurerm_monitor_diagnostic_setting` to target resources (route logs/metrics to the workspace).

It does **not**: configure Defender for Cloud (see `modules/compliance`), Entra
ID tenant diagnostic settings, or alert rules.

## Usage

```hcl
module "logging" {
  source              = "../../modules/logging"
  resource_group_name = azurerm_resource_group.logging.name
  location            = "eastus"
  workspace_name      = "central-audit"

  diagnostic_settings = {
    keyvault = { target_resource_id = azurerm_key_vault.x.id }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on resource names. |
| `resource_group_name` | `string` | — | Resource group. |
| `location` | `string` | — | Region. |
| `workspace_name` | `string` | — | Workspace name. |
| `sku` | `string` | `PerGB2018` | Workspace SKU. |
| `retention_in_days` | `number` | `365` | Data retention. |
| `diagnostic_settings` | `map(object)` | `{}` | Resource log routing (target + category groups). |
| `tags` | `map(string)` | `{}` | Tags. |

## Outputs

| Name | Description |
|---|---|
| `workspace_id` | Log Analytics workspace id. |
| `workspace_name` | Workspace name. |
| `diagnostic_setting_ids` | Map of setting key to id. |

## Security notes

- Centralize logs in a dedicated logging subscription/workspace, separate from workloads.
- Set retention to the compliance requirement; restrict workspace RBAC to auditors.

Validated via [live/50-logging](../../live/50-logging); see [../../tests](../../tests).
