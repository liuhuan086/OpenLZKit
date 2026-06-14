# Azure Security Baseline

## 目标

Azure 安全基线由 Azure Policy 预防控制、Defender for Cloud 运行时检测、集中日志和最小 RBAC 组成。策略应在管理组层前移，生产默认拒绝公网高危暴露、禁止不合规区域、要求加密和标签；例外必须有 owner、reason、expiry date 和补偿控制。

## 云原生服务

- Azure Policy / Initiative：预防和审计 guardrails。
- Policy Assignment / Exemption：按管理组、订阅或资源组生效和管理例外。
- Defender for Cloud：云安全态势、建议和威胁检测。
- Activity Log / Diagnostic Settings：操作审计。
- Microsoft Sentinel / Log Analytics：集中分析和告警。
- Resource Locks：保护关键平台资源，谨慎使用。

## 模块边界

- [`modules/policy-guardrails`](../modules/policy-guardrails)：策略定义、initiative、assignment、exemption。
- [`modules/compliance`](../modules/compliance)：Defender、诊断设置、安全联系人等运行时合规。
- [`modules/logging`](../modules/logging)：Log Analytics、存储归档和日志路由。

不负责：

- SOC 分析规则的完整目录。
- 企业合规框架映射的所有控制项。
- 手工例外审批系统。

## 推荐基线

| 控制 | 默认 |
|---|---|
| 区域限制 | 只允许企业批准区域，global 服务例外单独说明。 |
| 公网入口 | 禁止 0.0.0.0/0 高危端口；生产 PaaS 默认 Private Endpoint。 |
| 加密 | 存储、磁盘、数据库默认启用平台或客户托管密钥。 |
| 日志 | Activity Log 和资源诊断进入集中 Log Analytics / Storage。 |
| 标签 | `owner`、`cost_center`、`env`、`project`、`data_classification`。 |
| 身份 | 禁止长期 secret 作为默认；生产使用 PIM/JIT。 |

## 输入、输出与依赖

主要输入：

- `policy_definitions`
- `policy_assignments`
- `policy_exemptions`
- `allowed_locations`
- `security_contact_email`
- `diagnostic_settings`

主要输出：

- `policy_assignment_ids`
- `policy_exemption_ids`
- `defender_plan_ids`
- `diagnostic_setting_ids`

依赖：

- 管理组层级已建立。
- 日志工作区或归档存储已存在。
- 例外流程已约定审批人与到期清理机制。

## 测试

```bash
terraform -chdir=multi-cloud/azure/live/40-security init -backend=false
terraform -chdir=multi-cloud/azure/live/40-security validate
terraform -chdir=multi-cloud/azure/live/45-compliance init -backend=false
terraform -chdir=multi-cloud/azure/live/45-compliance validate
```

集成测试：在 sandbox 管理组附加策略，尝试创建未打标签资源和高危公网规则，确认被拒绝或产生合规 finding。

## 回滚

- 误阻断时优先临时 exemption，不直接删除策略定义。
- 先从低层 scope 移除 assignment，再调整 initiative。
- Defender 和日志停用前必须确认替代监控路径。

## 常见故障

| 现象 | 排查 |
|---|---|
| 策略没有阻断 | 检查 assignment scope、effect、mode 和资源类型是否匹配。 |
| 合规状态延迟 | Azure Policy 扫描有延迟，可触发重新评估后再判断。 |
| 例外长期存在 | 检查 exemption 是否有到期时间和 owner，纳入定期审查。 |
| 生产 apply 被阻断 | 在 plan 阶段先跑 policy-as-code，必要时走审批例外。 |
