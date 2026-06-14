# Module: tencentcloud/compliance

**Runtime compliance** (FP-7): CSIP (Cloud Security Center) risk-scan tasks
covering ports, weak passwords, PoC vulnerabilities and configuration risk.
Complements the plan-time Conftest gate and the manage-policy guardrails.

## Responsibilities

- Create CSIP periodic risk-scan tasks (`tencentcloud_csip_risk_center`).

It does **not**: create CloudAudit tracks (see `modules/logging`) or define manage
policies (see `modules/control-policies`).

## Usage

```hcl
module "compliance" {
  source = "../../modules/compliance"

  scan_tasks = {
    baseline = {
      task_name       = "lz-baseline-scan"
      scan_asset_type = 0
      scan_item       = ["port", "weakpass", "poc", "configrisk"]
      scan_plan_type  = 1
    }
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `scan_tasks` | `map(object)` | `{}` | CSIP scan tasks (task_name, scan_item, asset/plan/mode fields). |

## Outputs

| Name | Description |
|---|---|
| `scan_task_ids` | Map of scan task key to id. |

## Notes

- CSIP is account/organization-scoped; deploy from the security account.
- Pair with CloudAudit (50-logging) for an audit trail and Conftest for plan-time guardrails.

Validated via [live/45-compliance](../../live/45-compliance); see [../../tests](../../tests).
