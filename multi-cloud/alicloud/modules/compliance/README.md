# Module: alicloud/compliance

Creates Alibaba Cloud Cloud Config runtime compliance controls for a multi-account
Landing Zone.

## Responsibilities

- Enable Cloud Config configuration recorder.
- Create a multi-account aggregator.
- Create aggregate managed rules.
- Group rules into aggregate compliance packs.
- Deliver snapshots, configuration changes and non-compliance events.

It does **not**:

- Replace plan-time Conftest/Rego checks.
- Replace Resource Directory control policies.
- Create the log/SLS/OSS destination used by delivery channels.

## Security notes

- Start with visibility rules for tags, encryption and public exposure before
  enabling remediation.
- Keep aggregator scope explicit: folder-based aggregation is preferred over
  manually maintained account lists.
- Deliver non-compliance events to a central audit destination.

## Testing

```bash
terraform -chdir=examples/compliance fmt -check -recursive
terraform -chdir=examples/compliance init -backend=false
terraform -chdir=examples/compliance validate
```
