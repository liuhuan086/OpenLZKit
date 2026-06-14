# Google Cloud Identity Model

## 目标

GCP 身份模型以 Cloud Identity group、IAM binding、Service Account 和 Workload Identity Federation 为核心。人员访问走 group-to-role binding；机器访问走 WIF + service account impersonation；默认禁止下载 service account key。IAM 绑定必须显式 scope 到 organization、folder 或 project，避免把 `roles/owner` 授到组织层。

## 云原生服务

- Cloud Identity Groups：人员访问分组。
- IAM Custom Roles：最小权限角色。
- IAM Bindings / Members：组织、folder、project scope 的授权。
- Service Account：工作负载和自动化身份。
- Workload Identity Federation：GitHub OIDC 等外部身份换取短期凭证。
- Service Account Impersonation：CI/CD 以短期令牌模拟部署身份。

## 模块边界

- [`modules/identity`](../modules/identity)：自定义角色、IAM binding。
- [`modules/identity-groups`](../modules/identity-groups)：Cloud Identity group 和 group scope 绑定。
- [`modules/cross-account-access`](../modules/cross-account-access)：跨项目 IAM、WIF、service account impersonation。
- [`modules/delegation`](../modules/delegation)：Folder 级委派和 Shared VPC 接入授权。

不负责：

- HR/IdP 到 Cloud Identity 的生命周期同步。
- 创建长期 service account key。
- 在业务 project 内创建任意用户。

## 推荐角色

| 角色 | Scope | 用途 |
|---|---|---|
| `platform-admin` | platform folder | 管理共享网络、日志、自动化 project。 |
| `security-auditor` | organization/folders readonly | 查看 SCC、日志和资产。 |
| `workload-deployer` | workload project | CI/CD 部署业务资源。 |
| `network-admin` | network folder/project | Shared VPC 和子网授权。 |
| `break-glass` | 最小必要 scope | 应急访问，强 MFA、短会话、审计。 |

## 输入、输出与依赖

主要输入：

- `org_id`
- `custom_roles`
- `iam_bindings`
- `groups`
- `service_accounts`
- `workload_identity_pool_name`
- `github_owner` / `github_repo`

主要输出：

- `custom_role_ids`
- `group_ids`
- `service_account_emails`
- `workload_identity_provider_name`

依赖：

- Cloud Identity 域已验证。
- 执行身份具备 Cloud Identity 和 IAM 管理权限。
- GitHub OIDC subject 使用组织级示例或企业仓库，不使用个人仓库。

## 测试

```bash
terraform -chdir=multi-cloud/gcp/live/20-identity init -backend=false
terraform -chdir=multi-cloud/gcp/live/20-identity validate
terraform -chdir=multi-cloud/gcp/live/24-cross-account-access init -backend=false
terraform -chdir=multi-cloud/gcp/live/24-cross-account-access validate
terraform -chdir=multi-cloud/gcp/live/25-sso init -backend=false
terraform -chdir=multi-cloud/gcp/live/25-sso validate
```

集成测试：创建测试 group 并绑定到 sandbox folder；用 GitHub OIDC 获取短期凭证并模拟 CI service account，确认不能访问未授权 project。

## 回滚

- 先移除 IAM binding/member。
- 再删除 WIF provider 或 service account impersonation 权限。
- 最后删除测试 service account 和 group。
- 外部同步的人员 group 不应由 Terraform 删除源对象。

## 常见故障

| 现象 | 排查 |
|---|---|
| WIF 认证失败 | 检查 issuer、attribute mapping、principalSet subject 和 repo。 |
| 权限过大 | 搜索 organization 层 `roles/owner` / `roles/editor`，改为 folder/project scope。 |
| IAM 不生效 | 等待 IAM 传播，并确认绑定在正确 resource。 |
| Service account key 被创建 | 用 Org Policy 禁止 key creation，并扫描 `google_service_account_key`。 |
