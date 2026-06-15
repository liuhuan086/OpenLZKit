# Release Plan

OpenLZKit 的 release 不只表示代码打 tag，还表示文档、策略、测试和证据达到一个可复核的成熟度。每个 release 都必须说明：哪些能本地静态验证，哪些需要真实云账号，哪些仍是设计/模板。

## 版本路线

| Version | 名称 | What works | Static-only | Requires real cloud account | Known limitations |
|---|---|---|---|---|---|
| `v0.1.0` | Documentation + Static Validation Release | 五朵云目录、AWS/阿里云较完整策略、Demo Mode、控制映射、runbook | 大多数 Terraform validate、Rego unit tests、文档检查 | 无强制真实 apply | 不声称任何云已完成真实 sandbox verified |
| `v0.2.0` | AWS Verified Sandbox Release | AWS 至少一条从 bootstrap 到 workload handoff 的脱敏证据链 | 其他云保持 static validation | AWS sandbox Organization | 受 Organizations、Identity Center、Security Lake 区域/权限限制 |
| `v0.3.0` | Alibaba Cloud Verified Sandbox Release | 阿里云复用 verified path 方法 | Azure/GCP/腾讯云 static validation | 阿里云资源目录 sandbox | 云上账号和资源目录配额限制 |
| `v0.4.0` | Policy-as-Code Compliance Mapping Release | 跨云控制矩阵与更多 provider-specific Rego | 部分运行时控制仍需手工证据 | 选定云的 plan/integration | 合规映射不是认证结论 |
| `v1.0.0` | Multi-cloud Governance Blueprint Release | 至少两朵云 verified path，五朵云静态治理完整 | 未验证云仍标注 static-only | sandbox accounts/subscriptions/projects | 不替代生产 Control Tower、AFT 或企业审批系统 |

## Release Checklist

- README、docs index、云 README 和测试说明已同步。
- `terraform fmt`、`terraform validate`、TFLint、Checkov、Conftest 的适用范围已说明。
- 所有账号、租户、订阅、UIN、ARN、邮箱和 bucket 唯一名均为明显假值或已脱敏。
- 有 Demo path：业务申请、预期账号/OU/网络/控制、policy evidence。
- 有 rollback/runbook：state、权限、审计、账号售卖失败、OIDC 故障。
- Release notes 明确 `What works`、`Static-only`、`Requires real cloud account`、`Known limitations`。
