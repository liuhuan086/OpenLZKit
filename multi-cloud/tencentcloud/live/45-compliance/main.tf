variable "region" {
  description = "Tencent Cloud region for the provider."
  type        = string
  default     = "ap-guangzhou"
}

provider "tencentcloud" {
  region = var.region
}

# 45-compliance: CSIP (Cloud Security Center) periodic risk scan covering ports,
# weak passwords, PoC vulnerabilities and configuration risk. Runtime compliance
# complementing the plan-time Conftest gate and manage-policy guardrails.
module "compliance" {
  source = "../../modules/compliance"

  scan_tasks = {
    baseline = {
      task_name       = "lz-baseline-scan"
      scan_asset_type = 0
      scan_item       = ["port", "weakpass", "poc", "configrisk"]
      scan_plan_type  = 1
      task_mode       = 0
    }
  }
}

output "scan_task_ids" {
  value = module.compliance.scan_task_ids
}
