# Module: gcp/org-policies

Organization **guardrails as Organization Policy** (the SCP-equivalent for GCP):
boolean and list constraints applied at the organization or a folder.

## Responsibilities

- Apply boolean-constraint policies (e.g. disable service-account key creation, require OS Login).
- Apply list-constraint policies (e.g. allowed resource locations, deny external VM IPs).

It does **not**: create folders/projects or run runtime detection (see
`modules/compliance` / Security Command Center).

## Usage

```hcl
module "org_policies" {
  source = "../../modules/org-policies"
  parent = "organizations/123456789012"

  boolean_policies = {
    disable-sa-key-creation = { constraint = "constraints/iam.disableServiceAccountKeyCreation" }
  }
  list_policies = {
    allowed-locations = { constraint = "constraints/gcp.resourceLocations", allowed_values = ["in:us-locations"] }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `parent` | `string` | — | `organizations/<id>` or `folders/<id>`. |
| `boolean_policies` | `map(object)` | `{}` | Boolean constraints (`constraint`, `enforce`). |
| `list_policies` | `map(object)` | `{}` | List constraints (allowed/denied values, deny_all/allow_all). |

## Outputs

| Name | Description |
|---|---|
| `boolean_policy_ids` | Map of boolean policy key to id. |
| `list_policy_ids` | Map of list policy key to id. |

## Security notes

- Apply at the organization (or highest folder) so child resources inherit; roll out by folder where risky.
- Recommended baseline: disable SA keys, skip default network, require OS Login, restrict locations, deny external VM IPs.

Validated via [live/40-security](../../live/40-security); see [../../tests](../../tests).
