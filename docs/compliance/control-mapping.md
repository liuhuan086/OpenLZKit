# Control Mapping

OpenLZKit 的策略亮点不只是“有 Terraform module”，而是把企业控制目标映射到各云原生能力、plan-time Rego 检查和可提交证据。本文是跨云控制映射的权威入口；provider-specific 细节仍保留在各云 `docs/`、`policies/` 和 module README 中。

## 控制矩阵

| Control ID | 风险 | AWS 实现 | 阿里云实现 | Azure 实现 | GCP 实现 | 腾讯云实现 | Rego 检查 | 证据 |
|---|---|---|---|---|---|---|---|---|
| SEC-001 | 对象存储公开访问 | S3 Block Public Access、SCP、AWS Config | OSS bucket ACL/policy 基线 | Storage Account public access disabled、Azure Policy | GCS Public Access Prevention | COS ACL/policy 基线 | `s3_state.rego`，后续扩展 storage policy | plan JSON、Config/Policy finding |
| SEC-002 | 审计日志被关闭或删除 | CloudTrail organization trail、S3 Object Lock、SCP deny | ActionTrail、OSS retention | Activity Log、Diagnostic Settings、immutable storage | Cloud Audit Logs、log sink、retention | CloudAudit、CLS/COS retention | `organizations.rego` | CloudTrail/ActionTrail/Activity Log 状态 |
| IAM-001 | wildcard trust 导致跨账号接管 | IAM role trust policy 限定 principal、external id、OIDC condition | RAM role trust 限定 principal | Entra workload federation / role assignment scope | Workload Identity Federation / IAM binding | CAM role trust 限定 principal | `iam_trust.rego` | Conftest output、role trust 摘要 |
| IAM-002 | 过宽权限策略 | IAM policy 最小权限、permission boundary | RAM policy 最小权限 | Azure RBAC scope 与 custom role | IAM role least privilege | CAM policy 最小权限 | `iam_policy.rego` | plan JSON、policy diff |
| FIN-001 | 成本无法归属 | Organizations Tag Policy、Budgets、CUR | Tag Policy、预算、账单明细 | Azure Policy tags、Budget、Cost Export | Labels、Budgets、Billing Export | 分账标签、预算 | `tags.rego` | plan JSON、预算/账单导出摘要 |
| NET-001 | prod 与 sandbox 网络互通 | TGW route table association/propagation 隔离 | CEN/TR route table 隔离 | Hub-Spoke VNet peering/route table | Shared VPC/firewall/routing | CCN/route table 隔离 | 后续扩展 network policy | route table matrix、flow log |
| STATE-001 | Terraform state 泄露或被篡改 | S3 versioning、encryption、DynamoDB lock、public access block | OSS versioning/encryption、lock | Storage Account versioning/encryption、state lock | GCS versioning/encryption | COS versioning/encryption | `s3_state.rego`，后续扩展各云 state policy | backend plan、bucket/storage controls |
| REL-001 | 变更不可回滚 | 独立 live stack/state、plan artifact、approval | 同左，使用阿里云资源目录语义 | 同左，按 subscription/management group | 同左，按 project/folder | 同左，按账号/UIN | CI gate + review checklist | plan artifact、rollback log |

## 使用方式

1. 新增 provider-specific Rego 时，先在本表新增或更新 Control ID。
2. 每条控制必须至少有一个可执行检查或明确的云上验证证据。
3. 如果某朵云没有等价能力，写清楚“无原生等价，使用补偿控制”，不要用通用词掩盖差异。
4. 任何真实证据进入仓库前必须脱敏账号、ARN、tenant、subscription、UIN、bucket 唯一名、邮箱和个人信息。

## 当前优先级

1. AWS：补齐 `SEC-001`、`IAM-001`、`IAM-002`、`FIN-001`、`STATE-001` 的 plan-time evidence。
2. 阿里云：复用控制矩阵，补 OSS/RAM/Tag Policy 对应 Rego。
3. Azure/GCP/腾讯云：先补 static validation，再做 sandbox verified path。
