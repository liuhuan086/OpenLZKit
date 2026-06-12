# live/35-connectivity (Alibaba Cloud)

Creates CEN / Transit Router hub-spoke connectivity after baseline VPCs exist.

## What it does

- Creates or reuses a CEN instance.
- Creates a Transit Router.
- Creates route tables for shared, prod, non-prod or sandbox segments.
- Attaches VPCs to Transit Router.
- Adds cross-account grants for externally owned VPCs.
- Associates, propagates and explicitly routes attachments.

## Static validation

```bash
terraform -chdir=live/35-connectivity fmt -check -recursive
terraform -chdir=live/35-connectivity init -backend=false
terraform -chdir=live/35-connectivity validate
```

`plan`/`apply` require network-account CEN permissions and permissions on
cross-account grant targets.
