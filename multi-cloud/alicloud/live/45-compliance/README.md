# live/45-compliance (Alibaba Cloud)

Creates Cloud Config aggregate compliance visibility after security and logging
destinations exist.

## What it does

- Enables the Cloud Config recorder.
- Creates a multi-account aggregator.
- Creates aggregate managed rules.
- Groups rules into compliance packs.
- Delivers snapshots and non-compliance notifications to a central destination.

## Static validation

```bash
terraform -chdir=live/45-compliance fmt -check -recursive
terraform -chdir=live/45-compliance init -backend=false
terraform -chdir=live/45-compliance validate
```

`plan`/`apply` require Cloud Config administrative permissions.
