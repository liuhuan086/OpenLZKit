# Tencent Cloud Identity Model

## 目标

腾讯云身份模型以 CAM 用户组、CAM 角色、策略和 STS 临时凭证为核心。人员访问优先通过 SSO/身份提供商映射到 CAM 用户组或角色；机器访问通过 OIDC/AssumeRole 获取临时密钥；禁止把 SecretId/SecretKey 写入仓库或作为默认自动化方式。

## 云原生服务

- CAM 用户、用户组、策略：人员访问管理。
- CAM 角色：跨账号和服务角色。
- 身份提供商 / SSO：企业身份联合。
- STS AssumeRole：短期凭证。
- 权限边界和标签鉴权：限制最大权限与资源范围。

## 模块边界

- [`modules/identity`](../modules/identity)：CAM 自定义策略、角色和策略绑定。
- [`modules/identity-groups`](../modules/identity-groups)：用户组和组策略分配。
- [`modules/cross-account-access`](../modules/cross-account-access)：跨账号角色信任与资源共享。
- [`modules/delegation`](../modules/delegation)：委派管理和组织共享。

不负责：

- 创建长期访问密钥。
- 企业 IdP 生命周期管理。
- 把个人 CAM 用户直接授予生产管理员权限。

## 推荐角色

| 角色 | 范围 | 用途 |
|---|---|---|
| `platform-admin` | platform/network/logging 成员账号 | 管理平台共享能力。 |
| `security-auditor` | 所有成员账号只读 | 安全审计与合规查看。 |
| `workload-operator` | 业务成员账号 | 业务部署和排障。 |
| `finops-reader` | 计费/标签只读 | 成本归因和预算查看。 |
| `break-glass` | 最小必要账号 | 应急访问，强 MFA、强审计。 |

## 输入、输出与依赖

主要输入：

- `policies`
- `roles`
- `role_policy_attachments`
- `groups`
- `cross_account_roles`
- `trusted_uins`

主要输出：

- `policy_ids`
- `role_ids`
- `group_ids`
- `role_arns`

依赖：

- 主账号或自动化账号具备 CAM 管理权限。
- 跨账号角色 trust document 限定来源 UIN、条件和动作。
- SSO 或 IdP 已完成企业侧配置。

## 测试

```bash
terraform -chdir=multi-cloud/tencentcloud/live/20-identity init -backend=false
terraform -chdir=multi-cloud/tencentcloud/live/20-identity validate
terraform -chdir=multi-cloud/tencentcloud/live/24-cross-account-access init -backend=false
terraform -chdir=multi-cloud/tencentcloud/live/24-cross-account-access validate
terraform -chdir=multi-cloud/tencentcloud/live/25-sso init -backend=false
terraform -chdir=multi-cloud/tencentcloud/live/25-sso validate
```

集成测试：在 sandbox 成员账号创建测试角色，使用 STS assume role 获取临时凭证，确认不能访问未授权账号或资源。

## 回滚

- 先解绑策略和角色信任关系。
- 再删除测试角色、用户组或策略。
- 对生产 SSO 组只移除映射，不删除企业身份源。

## 常见故障

| 现象 | 排查 |
|---|---|
| AssumeRole 失败 | 检查 trust document、来源 UIN、role session name 和 STS 权限。 |
| 权限过大 | 查策略是否存在 `action = "*"` 或 `resource = "*"`，补条件约束。 |
| 用户仍可访问 | 检查用户是否在多个 CAM 组或有直接策略绑定。 |
| SecretKey 泄露 | 立即禁用密钥、轮换、查 CloudAudit，并改用角色临时凭证。 |
