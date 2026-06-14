# Alibaba Cloud Identity Model

## 目标

阿里云 Landing Zone 的身份模型分为三层：人员访问走 CloudSSO/RAM 角色分配，机器访问走 OIDC/STS AssumeRole，账号内基线走 RAM 密码策略和安全偏好。默认禁止长期 AccessKey 作为 CI/CD 或人员日常访问方式；跨账号访问必须限定 trusted principal、条件和最小权限。

## 云原生服务

- Resource Directory：多账号组织和成员账号边界。
- RAM Role / Policy：账号内和跨账号权限。
- CloudSSO：企业人员访问和多账号授权。
- STS AssumeRole：短期凭证。
- OIDC Provider：GitHub Actions 等外部身份联合。
- RAM Account Alias / Password Policy / Security Preference：账号基线。

## 模块边界

- [`modules/identity`](../modules/identity)：RAM 账号基线、角色、策略和安全偏好。
- [`modules/sso`](../modules/sso)：CloudSSO 用户/组、访问配置和账号分配。
- [`modules/cross-account-access`](../modules/cross-account-access)：跨账号角色和资源共享。
- [`modules/delegation`](../modules/delegation)：委派服务管理和共享能力。

不负责：

- 企业 IdP/HR 系统人员生命周期。
- 创建长期 AccessKey。
- 把个人 RAM 用户直接授予生产管理员权限。

## 推荐角色

| 角色 | 范围 | 用途 |
|---|---|---|
| `platform-admin` | shared/network/logging 账号 | 平台共享能力管理。 |
| `security-auditor` | 全部账号只读 | 安全审计、配置和日志查看。 |
| `workload-operator` | 业务账号 | 业务部署和排障。 |
| `finops-reader` | 资源目录/费用中心只读 | 成本归因和预算分析。 |
| `break-glass` | 最小必要账号 | 应急访问，强 MFA、短会话、强审计。 |

## 输入、输出与依赖

主要输入：

- `account_alias`
- `password_policy`
- `security_preferences`
- `roles`
- `policies`
- `permission_sets`
- `assignments`
- `trusted_principals`

主要输出：

- `role_names`
- `policy_names`
- `cloud_sso_access_configuration_ids`
- `assignment_ids`

依赖：

- Resource Directory 已启用。
- CloudSSO 目录和身份源已准备。
- CI/CD OIDC provider 已限定企业仓库 subject。

## 测试

```bash
terraform -chdir=multi-cloud/alicloud/live/20-identity init -backend=false
terraform -chdir=multi-cloud/alicloud/live/20-identity validate
terraform -chdir=multi-cloud/alicloud/live/24-cross-account-access init -backend=false
terraform -chdir=multi-cloud/alicloud/live/24-cross-account-access validate
terraform -chdir=multi-cloud/alicloud/live/25-sso init -backend=false
terraform -chdir=multi-cloud/alicloud/live/25-sso validate
```

集成测试：在 sandbox 账号创建测试 RAM role，通过 STS assume role 获取临时凭证，确认 session 权限、有效期和审计记录符合预期。

## 回滚

- 先删除账号分配和角色策略绑定。
- 再删除测试 role/policy/CloudSSO access configuration。
- 外部 IdP 源用户和生产 group 不应由 Terraform 删除。

## 常见故障

| 现象 | 排查 |
|---|---|
| AssumeRole 失败 | 检查 trusted principal、外部 id、条件、角色名和 STS 权限。 |
| CloudSSO 分配不生效 | 检查账号是否在 Resource Directory，用户/组是否同步完成。 |
| AccessKey 仍被创建 | 检查 RAM 安全偏好和 CI secret，改用 OIDC/STS。 |
| 权限过大 | 搜索 `Action = "*"` 或 `Resource = "*"`，补最小权限和条件。 |
