# Module: tencentcloud/org

Builds the Tencent Cloud **organization (TCO) node hierarchy** for the Landing
Zone organization layer.

## Responsibilities

- Create a one- or two-level organization node hierarchy under the root node.
- Expose node ids for placing member accounts and attaching manage policies.

It does **not**: create member accounts (see `modules/account-factory`), attach
manage policies (see `modules/control-policies`), or manage CAM.

## Usage

```hcl
module "org" {
  source       = "../../modules/org"
  root_node_id = 2001
  name_prefix  = "lz-"

  nodes = {
    security = {
      name     = "Security"
      children = { audit-log = { name = "Audit Log" } }
    }
    sandbox = { name = "Sandbox" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on node names. |
| `root_node_id` | `number` | — | Organization root node id. |
| `nodes` | `map(object)` | — | Hierarchy: `name` + one optional `children` level. |
| `tags` | `map(string)` | `{}` | Tags on created nodes. |

## Outputs

| Name | Description |
|---|---|
| `node_ids` | Map of node key (top-level and `<parent>/<child>`) to node id. |

## Security notes

- Organization must be enabled on the management account; caller needs org admin.
- Use the node hierarchy to inherit manage policies down to member accounts.

Validated via [live/10-org](../../live/10-org); see [../../tests](../../tests).
