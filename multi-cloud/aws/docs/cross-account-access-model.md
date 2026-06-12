# AWS Cross-account Access Model

## 目标

企业 Landing Zone 需要让安全、审计、CI/CD、网络和共享服务账号访问其他成员账号，但不能依赖长期 access key 或人工 IAM user。跨账号访问模型把访问路径标准化为 STS AssumeRole、OIDC workload federation 和受控 AWS RAM resource share。

## 云原生服务

- IAM Role + STS AssumeRole：源账号主体临时进入目标账号角色。
- IAM OIDC Provider + AssumeRoleWithWebIdentity：CI/CD 或工作负载通过 OIDC 联邦进入目标角色。
- IAM managed policy / inline policy：给目标角色附加最小权限。
- AWS RAM：共享 Transit Gateway、子网、License、AMI 等支持共享的资源。

## 模块边界

由 [`modules/cross-account-access`](../modules/cross-account-access) 实现：

- **负责**：创建目标账号跨账号 IAM role、OIDC provider、managed/inline policy attachment、AWS RAM resource share、principal association、resource association。
- **不负责**：创建账号、创建共享资源本身、分配 IAM Identity Center 用户/组、部署 workload 应用资源。

## 标准场景

| 场景 | 源账号 | 目标账号 | 权限建议 |
|---|---|---|---|
| 安全审计 | security-tooling | workload accounts | `SecurityAudit` 或只读审计策略 |
| CI/CD 部署 | automation / GitHub Actions / GitLab | workload account | workload-scoped deploy policy + OIDC 条件 |
| 日志归档 | log-archive | workload account | 只允许写入审计目的地或读取必要日志 |
| 网络共享 | network | workload account | AWS RAM + 最小共享权限 |

## Trust Policy 要求

- `trusted_principal_arns` 和 `federated_principal_arns` 必须是精确 ARN，不允许 `*`。
- 第三方或跨组织访问优先设置 `external_id`。
- OIDC role 必须带 `aud`、`sub` 等条件，限制到具体组织、仓库、分支或环境。
- CI/CD 不使用长期 access key；人员访问不通过 IAM user 扩散。

## 输入、输出与依赖

主要输入：

- `access_roles`：跨账号角色定义，包含可信主体、ExternalId、OIDC 条件和权限。
- `oidc_providers`：可选 OIDC provider 定义。
- `resource_shares`：AWS RAM 共享定义。
- `common_tags`：公共标签。

主要输出：

- `role_names`
- `role_arns`
- `oidc_provider_arns`
- `resource_share_arns`

依赖：

- 目标账号已存在。
- 源主体 ARN 已明确。
- 共享资源已存在且支持 AWS RAM。
- 调用身份具备 IAM 和 RAM 权限。

## 测试

静态检查：

```bash
terraform -chdir=multi-cloud/aws/examples/cross-account-access fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/cross-account-access init -backend=false
terraform -chdir=multi-cloud/aws/examples/cross-account-access validate

terraform -chdir=multi-cloud/aws/live/24-cross-account-access fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/24-cross-account-access init -backend=false
terraform -chdir=multi-cloud/aws/live/24-cross-account-access validate

conftest verify --policy multi-cloud/aws/policies
```

集成验证：

- 在 sandbox 目标账号创建一个只读审计角色，用安全账号 root ARN + ExternalId 测试 AssumeRole。
- 在 sandbox OIDC provider 上测试一条 CI/CD workflow，确认非目标仓库或分支无法获取凭证。
- 对 AWS RAM share 先共享到 sandbox account，再推广到业务账号。

## 回滚

- 先下线使用该角色的自动化任务或访问分配。
- 移除 RAM principal/resource association，再删除 resource share。
- 删除 role policy attachment 和 inline policy，再删除 IAM role。
- 最后删除不再使用的 OIDC provider。

## 常见故障

| 现象 | 排查 |
|---|---|
| AssumeRole 被拒绝 | 检查源主体 ARN、ExternalId、session policy 和 SCP 是否匹配。 |
| OIDC 失败 | 检查 provider thumbprint、aud、sub 条件和 token issuer。 |
| 权限不足 | 检查 managed/inline policy 是否覆盖目标 API，优先最小自定义策略。 |
| RAM 共享失败 | 检查资源是否支持 RAM、principal 是否在允许范围内、是否需要启用组织共享。 |
