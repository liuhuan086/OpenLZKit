# Tencent Cloud Operations Runbook

## 日常操作原则

腾讯云 Landing Zone 运维以组织节点、成员账号、CAM、CCN、CloudAudit/CLS 和管控策略为核心。主账号只用于组织级治理和应急，不做日常资源操作。所有生产变更通过 Terraform PR、plan artifact 和审批进入。

## 新成员账号接入

1. 确认业务 owner、成本中心、环境、节点、地域和网络域。
2. 在 `live/10-org` 或 `account-factory` 添加成员账号。
3. 在 `live/20-identity` 添加 CAM 角色和用户组映射。
4. 在 `live/30-network` / `35-connectivity` 创建 VPC 或接入 CCN。
5. 在 `live/40-security` 继承管控策略。
6. 在 `live/50-logging` 确认 CloudAudit/CLS 投递。

## 权限变更

- 人员权限通过 CAM 组或 SSO 映射，不直接给个人绑定生产管理员。
- 自动化通过 CAM 角色和 STS 临时凭证，不使用长期 SecretKey。
- 跨账号 trust document 必须限定来源 UIN 和条件。

## 网络变更

- 先确认 CIDR 不重叠。
- CCN 挂载必须记录业务 owner 和路由域。
- sandbox 不挂载到 prod hub；如需临时互通，必须有到期时间。

## Drift 处理

```bash
terraform -chdir=multi-cloud/tencentcloud/live/<stack> plan -detailed-exitcode
```

- 手工新增资源：判断是否纳管，必要时 import。
- 手工删除资源：先确认业务影响，再通过 Terraform 恢复或从 state 移除。
- 权限漂移：优先撤销直接绑定，回到组/角色模型。

## 常见故障

| 场景 | 处理 |
|---|---|
| 成员账号无法创建 | 检查实名、计费、组织配额和联系人信息。 |
| AssumeRole 失败 | 检查 trust document、来源 UIN、STS 权限和策略边界。 |
| CCN 不通 | 检查 attachment、route table、安全组、网络 ACL 和跨账号授权。 |
| 管控策略误阻断 | 先从 sandbox 复现，临时移除 attachment 或加条件例外。 |
| CLS 没有日志 | 检查 CloudAudit 跟踪集、CLS topic、投递权限和保留期。 |

## 应急访问

- 主账号和 break-glass CAM 用户必须强 MFA、独立告警、短时使用。
- 应急操作后补 PR、补审计说明和复盘。
- 泄露 SecretKey 时立即禁用、轮换、查 CloudAudit 并追踪影响范围。
