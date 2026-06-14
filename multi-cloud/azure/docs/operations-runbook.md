# Azure Operations Runbook

## 日常操作原则

Azure Landing Zone 运维应以 PR、plan artifact、审批和审计日志为唯一变更入口。Portal 可用于只读排障；生产修复必须回写 Terraform。所有操作先判断 scope：tenant、management group、subscription、resource group 还是 resource，避免在过高层级误改。

## 新订阅接入

1. 确认业务 owner、成本中心、环境、数据分级和网络域。
2. 在 `live/10-org` 或 `live/15-departments` 添加订阅关联和标签。
3. 在 `live/20-identity` 添加最小 RBAC group assignment。
4. 在 `live/30-network` / `35-connectivity` 添加 VNet 或 hub 接入。
5. 在 `live/40-security` 确认策略继承；如需例外，记录 reason 和 expiry。
6. 在 `live/50-logging` 确认 Activity Log 和诊断设置。

## 权限变更

- 人员访问优先改 Entra group 成员关系，不直接给个人授予 RBAC。
- CI/CD 访问通过 federated credential 和 scoped role assignment。
- 生产 Owner 权限只走 break-glass 或 PIM。

## 网络变更

- 先做 CIDR 冲突检查，再建 VNet/peering。
- 变更 UDR/Firewall 前确认回滚路由。
- Private Endpoint 上线必须同步 DNS 验证。

## Drift 处理

```bash
terraform -chdir=multi-cloud/azure/live/<stack> plan -detailed-exitcode
```

- exit code 0：无漂移。
- exit code 2：存在漂移，先判断是否紧急修复或手工变更。
- exit code 1：配置或凭证错误，先修验证环境。

漂移处理顺序：保留证据 -> 判断 owner -> import 或回滚手工变更 -> PR 固化。

## 应急访问

- Break-glass 账号必须强 MFA、独立告警、短时使用。
- 应急操作后 24 小时内补 PR 和事后复盘。
- 不允许把 break-glass 凭证写入 Terraform、CI secret 或文档。

## 常见故障

| 场景 | 处理 |
|---|---|
| 订阅被策略阻断上线 | 查看 Activity Log 和 Policy compliance，确认是策略 bug 还是业务例外。 |
| OIDC plan 失败 | 检查 federated credential subject、分支/environment、RBAC scope。 |
| 资源无法删除 | 检查 resource lock、deny assignment、policy effect 和依赖资源。 |
| 日志没有进入工作区 | 检查 diagnostic setting、category、workspace id 和区域支持。 |
| 成本异常 | 按订阅、资源组、tag 和 meter 逐层定位，必要时临时 budget action。 |

## 变更验收

- `terraform fmt`、`validate`、TFLint、Checkov、Conftest 通过。
- plan artifact 经平台、安全和业务 owner 审核。
- 关键输出（订阅、角色、日志、网络）可通过 Azure CLI/API 查询。
