# AWS Sandbox Apply Report

> 本文是 AWS verified path 的证据报告模板与执行清单。当前仓库不包含任何真实 AWS 账号、组织 ID、CloudTrail 事件或账单数据；实际执行时必须只提交脱敏后的 plan、output、截图摘要和审计证据。

## 目标

把 AWS 从“静态完整的 Landing Zone blueprint”推进到“可验证样板”。报告必须回答：

- 哪个 sandbox Organization / account scope 被使用。
- 哪些 live stack 真实 apply，哪些只做 dry-run。
- 每一步生成或变更了哪些资源。
- apply 前后如何验证安全、日志、合规、成本和 workload handoff。
- 遇到哪些 AWS 权限、配额、服务可用性或 Control Tower/AFT 约束。
- 如何 rollback，如何保存证据，如何确认没有敏感信息进入仓库。

## Sandbox 范围

| 项 | 示例值 | 说明 |
|---|---|---|
| Organization | `o-example` | 只允许提交脱敏标识，不提交真实 org id |
| Management account | `123456789012` | 使用明显假值占位 |
| Region | `us-east-1` | 以实际 sandbox 支持区域为准 |
| Execution identity | `GitHub OIDC -> OpenLZKitSandboxApplyRole` | 禁止长期 access key |
| State backend | `openlzkit-example-tfstate` | 必须启用版本化、加密和 public access block |
| Evidence location | `evidence/aws/YYYY-MM-DD/` | 建议本地或私有工件库保存，仓库只提交脱敏摘要 |

仓库内可提交的证据形态见 [aws-apply-evidence](aws-apply-evidence/README.md) 与 [sanitized-plan-output](sanitized-plan-output/README.md)。rollback 结果单独记录在 [aws-sandbox-rollback-report.md](aws-sandbox-rollback-report.md)。

## Apply 顺序与验证状态

| 顺序 | Stack | 目标 | 当前状态 | 验证证据 |
|---:|---|---|---|---|
| 1 | `multi-cloud/aws/live/00-bootstrap` | S3 state、DynamoDB lock、KMS、CI role | static-ready | `terraform validate`、Checkov、state bucket controls |
| 2 | `multi-cloud/aws/live/10-org` | OU baseline 与 account vending 入口 | static-ready; apply opt-in | Organizations list、OU tree、account create dry-run/approval |
| 3 | `multi-cloud/aws/live/15-departments` | 部门 OU、部门角色、标签基线 | static-ready | OU path、department role trust、tag baseline |
| 4 | `multi-cloud/aws/live/20-identity` | IAM account baseline | static-ready | password policy、permission boundary、account alias |
| 5 | `multi-cloud/aws/live/24-cross-account-access` | STS/OIDC/RAM access path | static-ready | assume-role test、trust policy Conftest |
| 6 | `multi-cloud/aws/live/25-sso` | IAM Identity Center permission sets | static-ready | permission set list、group assignments |
| 7 | `multi-cloud/aws/live/30-network` | VPC/subnet/endpoint/flow logs | static-ready | VPC route tables、flow log destination |
| 8 | `multi-cloud/aws/live/35-connectivity` | Transit Gateway 与 route table 隔离 | static-ready | TGW association/propagation matrix |
| 9 | `multi-cloud/aws/live/40-security` | SCP 与 Tag Policy guardrails | static-ready | Organizations policy attachments、Conftest output |
| 10 | `multi-cloud/aws/live/45-compliance` | AWS Config、Security Hub、GuardDuty | static-ready | Config recorder、Security Hub standards、GuardDuty admin |
| 11 | `multi-cloud/aws/live/50-logging` | CloudTrail、log archive、Object Lock | static-ready | organization trail、S3 retention、KMS key |
| 12 | `multi-cloud/aws/live/55-delegation` | delegated admin 与 RAM sharing | static-ready | delegated service principals、RAM share scope |
| 13 | `multi-cloud/aws/live/60-finops` | budgets、anomaly、CUR、cost category | static-ready | budget list、CUR destination、cost tags |
| 14 | `multi-cloud/aws/live/70-workload-onboarding` | workload access role 与 handoff | static-ready | handoff output、role trust、owner tags |

`static-ready` 表示当前仓库已有 Terraform/OpenTofu HCL、README 和离线验证入口；不等于已经在真实 AWS sandbox apply。完成真实执行后，把状态改为 `sandbox-applied` 或 `dry-run-only`，并在证据列写入脱敏摘要。

## 执行前检查

1. 确认使用短期凭证：AWS IAM Identity Center session 或 OIDC AssumeRole。
2. 确认目标账号不是生产账号，且 Organization/OU 允许测试。
3. 执行 `terraform fmt -check -recursive`、`terraform validate`、TFLint、Checkov、Conftest。
4. 对会创建账号、修改 SCP、打开 delegated admin、启用日志保留的 stack 做人工审批。
5. 确认服务配额：Organizations account creation、CloudTrail、Config、TGW attachment、Security Hub、GuardDuty、CUR。
6. 准备 rollback：每个 stack 都必须有 `terraform destroy` 可行性判断或手工回退步骤。

## Evidence Checklist

| 证据 | 最低要求 | 敏感信息处理 |
|---|---|---|
| Terraform plan JSON | 保存 `terraform show -json` 的脱敏摘要 | 删除 account id、principal arn、bucket 唯一名 |
| Terraform output | 只保留 key 名和资源类型摘要 | 不提交真实 ids、arns、emails |
| Conftest output | 记录 pass/fail 与 policy 名 | 可直接提交，确认输入已脱敏 |
| CloudTrail | 记录事件类型和时间窗口 | 不提交真实 user ARN 或 source IP |
| AWS Config / Security Hub | 记录 enabled standards/rules | 不提交 finding resource id |
| Budgets / CUR | 记录预算维度和 CUR 目的地类型 | 不提交真实金额以外的账单明细 |
| Rollback log | 记录回退命令、结果和剩余资源 | 不提交真实资源 id |

## Evidence File Contract

| 文件 | 何时提交 | 内容 |
|---|---|---|
| `docs/demo/aws-apply-evidence/YYYY-MM-DD/<stack>-summary.md` | 真实 sandbox apply 或 dry-run 后 | stack scope、apply 类型、resource type action counts、policy result、runtime check 摘要 |
| `docs/demo/sanitized-plan-output/YYYY-MM-DD/<stack>-plan-summary.md` | plan 已脱敏且经过人工复核后 | `terraform show -json` 的人工摘要，不含 raw plan/state |
| `docs/demo/aws-sandbox-rollback-report.md` | rollback 演练后更新 | destroy/detach/retain 结果、剩余风险、后续 owner |

`v0.1.0` 只交付 evidence contract，不声称这些文件已有真实 AWS 输出；`v0.2.0` 才应把 applied/dry-run 状态写入每层 stack。

## Rollback Summary

| Stack | 回滚方式 | 注意事项 |
|---|---|---|
| `00-bootstrap` | 通常不自动 destroy；先迁移/备份 state | state bucket 和 lock table 是其他 stack 的依赖 |
| `10-org` | 对测试账号使用关闭/移除流程；OU 可 destroy | AWS account 关闭有冷却期，不要用生产 email |
| `40-security` | 先 detach SCP/Tag Policy，再删除 policy | 不要直接从 root 推广未验证策略 |
| `45-compliance` | 先关闭 delegated admin/aggregator，再删除 recorder | 避免残留组织级服务配置 |
| `50-logging` | 保留审计归档；只回滚测试 trail/stream | Object Lock 可能阻止删除 |
| `60-finops` | 删除测试预算、异常检测、CUR | 确认没有影响生产成本报告 |

## 报告结论模板

```text
Date: 2026-06-15
Scope: AWS sandbox Organization only
Stacks applied: 00-bootstrap, 10-org
Stacks dry-run only: 15-departments..70-workload-onboarding
Validation passed: fmt, validate, checkov, conftest
Known limitations: IAM Identity Center assignment not applied; Security Lake unavailable in selected region
Rollback status: state retained, sandbox OU resources destroyed
Next action: apply 20-identity and 24-cross-account-access after permission review
```
