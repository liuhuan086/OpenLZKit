# live/15-departments (Alibaba Cloud)

Creates business department boundaries after the core Resource Directory folder
tree exists.

## What it does

- Creates one department folder per entry.
- Creates one department admin RAM role per entry.
- Optionally attaches existing Resource Directory control policies to each
  department folder.
- Creates department tag policies for `owner`, `cost_center`, `env` and
  `data_classification`.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `cn-hangzhou` | Alibaba Cloud provider region. |
| `parent_folder_id` | `string` | — | Existing folder id under which department folders are created. |
| `departments` | `map(object)` | `{}` | Departments to create; empty by default to avoid accidental org changes. |

## Static validation

```bash
terraform -chdir=live/15-departments fmt -check -recursive
terraform -chdir=live/15-departments init -backend=false
terraform -chdir=live/15-departments validate
```

`plan`/`apply` require management-account Resource Directory and RAM permissions.
