# Alibaba Cloud Operations Runbook

## 日常操作原则

阿里云 Landing Zone 运维围绕 Resource Directory、RAM/CloudSSO、CEN/TR、ActionTrail/SLS、Cloud Config 和标签策略。资源目录管理账号不承载业务资源；生产变更必须通过 Terraform PR、plan artifact 和审批进入。控制台手工操作只用于排障或 break-glass，事后必须回写 IaC。

## 新账号接入

1. 确认 owner、成本中心、环境、Folder、地域、网络域和数据分级。
2. 在 `live/10-org` 或 `account-factory` 添加成员账号。
3. 在 `live/20-identity` / `25-sso` 添加 CloudSSO 或 RAM 角色分配。
4. 在 `live/30-network` / `35-connectivity` 创建 VPC 或接入 CEN/TR。
5. 在 `live/40-security` 继承管控策略和安全偏好。
6. 在 `live/50-logging` 确认 ActionTrail/SLS 投递。
7. 在 `live/60-finops` 确认标签策略和预算/成本归因。

## 权限变更

- 人员访问优先改 CloudSSO group assignment。
- 自动化访问通过 OIDC/STS AssumeRole。
- 禁止在 CI secret 中保存 AccessKey；发现后立即轮换并审计。

## 网络变更

- 先确认 CIDR 不重叠。
- CEN/TR 接入必须记录业务 owner、路由表和传播域。
- sandbox 不接入 prod 路由域；临时互通必须有到期时间。

## Drift 处理

```bash
terraform -chdir=multi-cloud/alicloud/live/<stack> plan -detailed-exitcode
```

- 手工新增资源：判断是否纳管，必要时 import 后补变量。
- 手工删除资源：评估业务影响，再通过 Terraform 恢复或移除 state。
- 权限漂移：撤销个人直接绑定，回到 CloudSSO/RAM role 模型。

## 常见故障

| 场景 | 处理 |
|---|---|
| 成员账号创建失败 | 检查 Resource Directory 状态、实名认证/计费、配额和联系人信息。 |
| CloudSSO 登录失败 | 检查身份源同步、访问配置、账号分配和 MFA 策略。 |
| STS AssumeRole 失败 | 检查 trust policy、principal ARN、外部 id 和 session policy。 |
| CEN/TR 路由不通 | 检查 attachment、路由表关联/传播、安全组和网络 ACL。 |
| ActionTrail 无日志 | 检查跟踪、SLS project/logstore、投递权限和地域。 |
| 标签不合规 | 检查 tag policy attachment scope 和 Terraform module 必填标签。 |

## 应急访问

- Break-glass 账号必须强 MFA、独立告警、短时使用。
- 应急后 24 小时内补 PR、补审计说明和复盘。
- 若 AccessKey 泄露，立即禁用、轮换、查 ActionTrail，并评估影响账号和资源范围。

## 变更验收

- Terraform fmt/validate、TFLint、Checkov、Conftest 通过。
- 关键输出可查询：账号 id、RAM role、CloudSSO assignment、CEN/TR attachment、SLS logstore。
- 日志、策略和成本标签在 sandbox 中验证后再推广。
