# Module: gcp/org

Builds the Google Cloud **folder hierarchy** for the Landing Zone organization
layer.

## Responsibilities

- Create a one- or two-level folder hierarchy under the organization (or a parent folder).
- Expose folder resource names/ids for placing projects and binding IAM/policy.

It does **not**: create projects (see `modules/project-factory`), assign IAM, or
set organization policies (see `modules/org-policies`).

## Usage

```hcl
module "org" {
  source      = "../../modules/org"
  parent      = "organizations/123456789012"
  name_prefix = "lz-"

  folders = {
    common = {
      display_name = "Common"
      children = {
        logging  = { display_name = "Logging" }
        security = { display_name = "Security" }
      }
    }
    sandbox = { display_name = "Sandbox" }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name_prefix` | `string` | `"lz-"` | Prefix on folder display names. |
| `parent` | `string` | — | `organizations/<org_id>` or `folders/<id>`. |
| `folders` | `map(object)` | — | Hierarchy: `display_name` + one optional `children` level. |

## Outputs

| Name | Description |
|---|---|
| `folder_names` | Map of key to resource name (`folders/<number>`). |
| `folder_ids` | Map of key to numeric folder id. |

## Security notes

- Folders are organization-global; caller needs Folder Admin at the parent.
- Use the folder hierarchy to inherit org policy and IAM down to projects.

Validated via [live/10-org](../../live/10-org); see [../../tests](../../tests).
