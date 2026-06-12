# AWS Security Baseline

## 目标

安全基线把企业护栏前移到 AWS Organizations 层，先阻断高风险动作，再用 AWS Config、Security Hub 和 GuardDuty 做运行时发现。FP-2 聚焦 Organizations SCP 与 Tag Policy；运行时合规服务在后续 FP-7 深化。

## 云原生服务

- AWS Organizations Service Control Policy：组织、OU、账号级别的权限上限。
- AWS Organizations Tag Policy：统一标签键和值集合，服务于成本、资产、数据分级和自动化。
- AWS Control Tower controls：生产环境可与本仓库策略并行，避免重复或冲突。
- Conftest / Rego：在 Terraform plan 阶段阻止明显不安全的策略变更。

## 模块边界

`modules/org-policies` 负责：

- 创建 `SERVICE_CONTROL_POLICY` 和 `TAG_POLICY`。
- 校验策略内容是合法 JSON。
- 把策略附加到 root、OU 或账号。
- 输出 policy id、arn 和 attachment id。

不负责：

- 生成所有企业策略目录。
- 启用 Control Tower。
- 启用 Config、Security Hub、GuardDuty 或日志归档。

## 默认策略

`live/40-security` 提供三类企业基线策略：

| 策略 key | 类型 | 目的 |
|---|---|---|
| `deny_disable_audit` | SCP | 禁止关闭 CloudTrail、Config、GuardDuty、Security Hub 等审计/检测能力。 |
| `deny_unapproved_regions` | SCP | 限制大多数资源型 API 只能在允许 Region 执行。 |
| `required_tags` | Tag Policy | 统一 `owner`、`cost_center`、`env`、`project`、`data_classification` 标签。 |

策略附件默认为空。生产中应通过评审后的 `policy_attachments` 显式传入 root、OU 或 account id，先在 sandbox OU 验证，再推广到生产 OU/root。

## 输入与输出

主要输入：

- `policies`：策略 map，包含 name、description、type、content。
- `attachments`：策略附件 map，包含 `policy_key` 和 `target_id`。
- `allowed_regions`：`live/40-security` 区域限制策略的允许 Region。

主要输出：

- `policy_ids`
- `policy_arns`
- `attachment_ids`

## 测试

静态验证：

```bash
terraform -chdir=multi-cloud/aws/examples/org-policies fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/org-policies init -backend=false
terraform -chdir=multi-cloud/aws/examples/org-policies validate

terraform -chdir=multi-cloud/aws/live/40-security fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/40-security init -backend=false
terraform -chdir=multi-cloud/aws/live/40-security validate

conftest verify --policy multi-cloud/aws/policies
```

集成验证：

- 使用 sandbox management account 或受控委派身份运行 plan。
- 先把 SCP 附加到 sandbox OU，确认不会阻断 break-glass、审计、SSO、CI/CD 必需路径。
- 再逐步推广到 nonprod、prod 和 root。

## 回滚

- 误阻断时，优先移除或修正对应 attachment，而不是删除策略文档。
- 区域限制 SCP 推广前保留 break-glass 流程，并确认全局服务例外列表满足企业实际服务使用。
- Tag Policy 不等同于强制拒绝所有未打标签资源；需要与 SCP、Config、CI policy-as-code 配合。

## 常见故障

| 现象 | 排查 |
|---|---|
| 策略 JSON 无法 validate | 检查 `content` 是否由 `jsonencode` 生成，避免手写 JSON 语法错误。 |
| 附件失败 | 确认 `target_id` 是 root、OU 或 account id，且执行身份具备 Organizations 权限。 |
| 区域限制影响全局服务 | 审查 `NotAction` 例外列表，必要时先在 sandbox OU 验证。 |
| Tag Policy 没有阻止创建资源 | Tag Policy 主要标准化标签；强制拒绝需结合 SCP、Config 或 CI 检查。 |
