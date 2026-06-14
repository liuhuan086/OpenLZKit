# Azure Identity Model

## 目标

Azure 身份模型以 Microsoft Entra ID 为中心。人员访问通过 Entra group + Azure RBAC + 条件访问/PIM 控制；自动化通过 Federated Identity Credential 使用 OIDC 换取短期令牌；工作负载优先使用 Managed Identity。默认禁止 client secret、长期证书和共享管理员账号。

## 云原生服务

- Microsoft Entra ID：用户、组、应用注册和服务主体。
- Azure RBAC：管理组、订阅、资源组和资源级授权。
- Managed Identity：Azure 原生工作负载身份。
- Federated Identity Credential：GitHub Actions / CI OIDC 到 Entra 应用或用户分配托管身份。
- PIM / Conditional Access：生产建议启用 JIT、MFA 和强条件访问。

## 模块边界

- [`modules/identity`](../modules/identity)：创建自定义角色、RBAC assignment 和托管身份基础对象。
- [`modules/entra-access`](../modules/entra-access)：人员访问组、应用、服务主体和联合凭据。
- [`modules/cross-account-access`](../modules/cross-account-access)：CI/CD 跨订阅部署身份和 role assignment。
- [`modules/delegation`](../modules/delegation)：Lighthouse 委派和跨租户管理入口。

不负责：

- 企业 IdP、HR 系统或 SCIM 同步。
- PIM 激活审批策略本身。
- 在代码中保存 client secret。

## 推荐角色

| 角色 | 范围 | 用途 |
|---|---|---|
| `platform-admin` | Platform 管理组或平台订阅 | 管理共享网络、日志、身份平台。 |
| `security-reader` | tenant/root 管理组只读 | 跨订阅审计与合规查看。 |
| `workload-contributor` | 应用订阅或资源组 | 业务团队日常部署。 |
| `finops-reader` | 管理组/订阅只读 | 成本与标签治理。 |
| `break-glass` | 最小必要范围 | 应急访问，强 MFA、短时、强审计。 |

## 输入、输出与依赖

主要输入：

- `groups`
- `custom_roles`
- `role_assignments`
- `managed_identities`
- `federated_credentials`
- `github_owner` / `github_repo`

主要输出：

- `group_object_ids`
- `managed_identity_client_ids`
- `role_assignment_ids`
- `federated_credential_ids`

依赖：

- Entra tenant 已建立基础安全策略。
- 目标 scope 已存在。
- GitHub OIDC subject 使用明确 owner/repo/branch/environment，不能写个人真实仓库。

## 测试

```bash
terraform -chdir=multi-cloud/azure/live/20-identity init -backend=false
terraform -chdir=multi-cloud/azure/live/20-identity validate
terraform -chdir=multi-cloud/azure/live/24-cross-account-access init -backend=false
terraform -chdir=multi-cloud/azure/live/24-cross-account-access validate
```

集成测试：用测试 Entra group 绑定到 sandbox 订阅，验证成员加入/移除后的权限变化；用 GitHub OIDC 只获取 plan 级权限，不授予生产 apply 权限。

## 回滚

- 先撤销 role assignment。
- 再删除 federated credential。
- 最后删除托管身份、应用或测试组。
- 生产组和外部 IdP 同步对象不应由 Terraform 随意删除。

## 常见故障

| 现象 | 排查 |
|---|---|
| OIDC 登录失败 | 检查 issuer、subject、audience 和 repo/environment 是否匹配。 |
| RBAC 生效慢 | Azure RBAC 有传播延迟，等待后再验证，避免重复授权。 |
| 用户权限过大 | 检查是否在上层管理组继承了 Owner/Contributor。 |
| 托管身份访问失败 | 检查 identity client id、scope 和目标服务是否支持 Managed Identity。 |
