# Google Cloud Security Baseline

## 目标

GCP 安全基线用 Organization Policy 做预防控制，用 Security Command Center、Cloud Asset Inventory 和 Cloud Logging 做运行时发现和审计。组织层默认禁止 service account key、默认网络、公开存储桶和未批准区域；敏感变更必须通过 PR、plan 和审批。

## 云原生服务

- Organization Policy：布尔/列表约束和自定义约束。
- Security Command Center：组织级安全发现和导出。
- Cloud Asset Inventory：资产盘点和变更查询。
- Cloud Logging / Audit Logs：Admin Activity、Data Access 和系统事件。
- KMS / CMEK：关键数据服务加密策略。
- IAM Recommender / Policy Analyzer：权限审查辅助。

## 模块边界

- [`modules/org-policies`](../modules/org-policies)：Org Policy 约束和 folder scope 应用。
- [`modules/compliance`](../modules/compliance)：SCC source、导出和通知。
- [`modules/logging`](../modules/logging)：聚合 log sink、日志桶和 BigQuery 导出。

不负责：

- 全量合规框架控制库。
- 安全团队的 SIEM 规则和工单流程。
- 业务应用内安全配置。

## 推荐基线

| 控制 | 默认 |
|---|---|
| Service account key | 禁止创建和上传，CI/CD 使用 WIF。 |
| Default network | 禁止自动创建 default network。 |
| External IP | 生产默认禁止 VM 外网 IP。 |
| Storage public access | 禁止公开 bucket，启用 uniform bucket-level access。 |
| Location | 只允许批准区域或多区域。 |
| OS Login | 对 Compute Engine 强制 OS Login。 |
| Labels | 强制 `owner`、`cost_center`、`env`、`project`、`data_classification`。 |

## 输入、输出与依赖

主要输入：

- `parent`
- `boolean_policies`
- `list_policies`
- `custom_constraints`
- `scc_exports`
- `notification_configs`

主要输出：

- `boolean_policy_ids`
- `list_policy_ids`
- `scc_export_ids`
- `notification_config_ids`

依赖：

- Organization/Folders 已建立。
- SCC 组织级权限和目标 BigQuery/Pub/Sub 资源已准备。
- 例外流程定义 owner、reason、expiry 和补偿控制。

## 测试

```bash
terraform -chdir=multi-cloud/gcp/live/40-security init -backend=false
terraform -chdir=multi-cloud/gcp/live/40-security validate
terraform -chdir=multi-cloud/gcp/live/45-compliance init -backend=false
terraform -chdir=multi-cloud/gcp/live/45-compliance validate
```

集成测试：在 sandbox folder 附加约束，尝试创建 SA key、外网 IP VM 和公开 bucket，确认被拒绝或生成 finding。

## 回滚

- 误阻断时优先在 folder 层临时 override，不删除组织层策略。
- 修改策略先从 sandbox/nonprod 验证再推广到 prod。
- SCC 导出停止前确认日志和发现有替代路径。

## 常见故障

| 现象 | 排查 |
|---|---|
| Org Policy 不生效 | 检查 parent、inherit_from_parent 和 dry-run/boolean/list 规则。 |
| 创建资源被意外拒绝 | 查看 Policy Troubleshooter 和 audit log，确认具体 constraint。 |
| SCC 没有 finding | 检查 SCC tier、服务启用、导出 filter 和目标权限。 |
| WIF 仍可创建 key | 扫描 Terraform 中 `google_service_account_key` 并启用 key 禁用策略。 |
